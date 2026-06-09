CREATE SCHEMA IF NOT EXISTS dimensions;

CREATE TABLE dimensions.date AS
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT          AS date_key,
    d                                     AS full_date,
    EXTRACT(YEAR FROM d)::INT             AS year,
    EXTRACT(QUARTER FROM d)::INT          AS quarter,
    'Q' || EXTRACT(QUARTER FROM d)::INT   AS quarter_label,    -- 'Q1', 'Q2' etc
    EXTRACT(MONTH FROM d)::INT            AS month,
    TO_CHAR(d, 'Mon')                     AS month_short,      -- 'Jan', 'Feb'
    TO_CHAR(d, 'Month')                   AS month_name,       -- 'January'
    TO_CHAR(d, 'YYYY-MM')                 AS year_month,       -- '2024-01' joins to Mixpanel
    EXTRACT(DAY FROM d)::INT              AS day,
    TO_CHAR(d, 'Day')                     AS day_name,
    EXTRACT(DOW FROM d)::INT              AS day_of_week,      -- 0=Sunday
    EXTRACT(WEEK FROM d)::INT             AS week_number,
    CASE WHEN EXTRACT(MONTH FROM d) <= 6
         THEN 'H1' ELSE 'H2' END          AS fiscal_half,
    CASE WHEN EXTRACT(DOW FROM d) IN (0,6)
         THEN false ELSE true END         AS is_weekday

FROM generate_series(
    '2024-01-01'::DATE,
    '2025-07-01'::DATE,
    '1 day'
) AS d;

ALTER TABLE dimensions.date
ADD CONSTRAINT dim_date_pk PRIMARY KEY (date_key);

----------------------------------------------------------------------------------------------------


CREATE TABLE dimensions.dim_plans AS
SELECT
    pr.product_id                               AS plan_id,
    pr.name                                     AS plan_name,
    pr.tier                                     AS plan_tier,          -- starter | pro | business
    pr.description                              AS plan_description,
    p.price_id,
    p.billing_interval,                                                -- month | year
    p.unit_amount                               AS price_cents,
    p.unit_amount / 100.0                       AS price_usd,          -- convert from cents
    CASE p.billing_interval
        WHEN 'month' THEN p.unit_amount / 100.0
        WHEN 'year'  THEN (p.unit_amount / 100.0) / 12
    END                                         AS monthly_equivalent_usd,
    pr.active                                   AS is_active,
    CASE pr.tier
        WHEN 'starter'  THEN 1
        WHEN 'pro'      THEN 2
        WHEN 'business' THEN 3
    END                                         AS tier_rank           -- for sorting in dashboard

FROM raw.products pr
LEFT JOIN raw.prices p
    ON p.product_id = pr.product_id;

ALTER TABLE dimensions.dim_plans
ADD CONSTRAINT dim_plans_pk PRIMARY KEY (price_id);

----------------------------------------------------------------------------------------------------


CREATE TABLE dimensions.dim_channels AS

-- Google Ads channels
SELECT
    'google_ads'                            AS channel_id,
    'Google Ads'                            AS channel_name,
    'Paid'                                  AS channel_type,
    'Search & Display'                      AS channel_category,
    TRUE                                    AS is_paid,
    'google_ads_campaigns'                  AS source_table

UNION ALL

-- LinkedIn Ads
SELECT
    'linkedin_ads'                          AS channel_id,
    'LinkedIn Ads'                          AS channel_name,
    'Paid'                                  AS channel_type,
    'Social'                                AS channel_category,
    TRUE                                    AS is_paid,
    'linkedin_ads_campaigns'                AS source_table

UNION ALL

-- Organic channels from HubSpot source field
SELECT DISTINCT
    LOWER(REPLACE(hs.acquisition_source, ' ', '_'))  AS channel_id,
    hs.acquisition_source                            AS channel_name,
    'Organic'                                        AS channel_type,
    CASE hs.acquisition_source
        WHEN 'Organic Search'   THEN 'SEO'
        WHEN 'Referral'         THEN 'Referral'
        WHEN 'Product Hunt'     THEN 'Community'
        ELSE 'Other'
    END                                              AS channel_category,
    FALSE                                            AS is_paid,
    'hubspot_contacts'                               AS source_table

FROM raw.hubspot_contacts hs
WHERE hs.acquisition_source NOT ILIKE '%google%'
  AND hs.acquisition_source NOT ILIKE '%linkedin%'
  AND hs.acquisition_source IS NOT NULL;

ALTER TABLE dimensions.dim_channels
ADD CONSTRAINT dim_channels_pk PRIMARY KEY (channel_id);

----------------------------------------------------------------------------------------------------

CREATE TABLE dimensions.dim_customers AS
SELECT
    -- identity keys
    a.user_id                                   AS customer_id,        -- auth UUID, primary key
    a.stripe_customer_id                        AS stripe_customer_id, -- joins to raw.invoices
    h.vid                                       AS hubspot_vid,        -- joins to raw.hubspot_contacts

    -- contact info
    a.email,
    h.firstname,
    h.lastname,
    h.company,
    h.job_title,

    -- acquisition
    s.acquisition_channel                       AS acquisition_channel,
    dc.channel_name                             AS acquisition_channel_name,
    dc.channel_type                             AS acquisition_channel_type,
    dc.is_paid                                  AS is_paid_acquisition,

    -- customer profile
    h.country,
    a.timezone,
    a.auth_provider,                                                    -- email | google | github
    h.lifecycle_stage,

    -- subscription info at signup
    s.plan_id                                   AS initial_plan_id,
    sc.plan_tier                                AS initial_plan_tier,
    s.trial_start                               AS trial_start_date,
    s.trial_end                                 AS trial_end_date,

    -- dates
    a.date_created                              AS signup_date,
    a.last_sign_in_at                           AS last_active_date,

    -- status
    CASE
        WHEN s.status = 'active'   THEN TRUE
        ELSE FALSE
    END                                         AS is_active,
    CASE
        WHEN s.canceled_at IS NOT NULL THEN TRUE
        ELSE FALSE
    END                                         AS has_churned,
    s.canceled_at                               AS churn_date,

    -- metadata
    a.locale,
    h.num_associated_deals,
    a.date_created                              AS record_created_at

FROM raw.auth_users a

-- HubSpot: get CRM attributes
LEFT JOIN raw.hubspot_contacts h
    ON h.auth_user_id = a.user_id

-- Stripe subscriptions: get plan and status
LEFT JOIN raw.subscriptions s
    ON s.customer_id = a.stripe_customer_id

-- dim_plans: get plan tier label
LEFT JOIN dimensions.dim_plans sc
    ON sc.price_id = s.plan_id

-- dim_channels: get clean channel attributes
LEFT JOIN dimensions.dim_channels dc
    ON dc.channel_id = LOWER(REPLACE(s.acquisition_channel, ' ', '_'));

ALTER TABLE dimensions.dim_customers
ADD CONSTRAINT dim_customers_pk PRIMARY KEY (customer_id);



