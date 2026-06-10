CREATE SCHEMA IF NOT EXISTS dimensions;
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



