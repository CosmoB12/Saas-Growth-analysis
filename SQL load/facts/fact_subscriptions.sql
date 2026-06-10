Create SCHEMA IF NOT EXISTS facts

CREATE TABLE facts.fact_subscriptions AS
SELECT
    -- keys
    s.subscription_id,
    c.customer_id,
    c.stripe_customer_id,
    p.price_id                                          AS plan_price_id,
    p.plan_tier,
    TO_CHAR(s.current_period_start, 'YYYYMMDD')::INT    AS date_key,
    TO_CHAR(s.current_period_start, 'YYYY-MM')          AS year_month,

    -- plan details
    p.plan_name,
    p.billing_interval,
    p.price_usd,
    p.monthly_equivalent_usd                            AS mrr_contribution,  -- key MRR field

    -- subscription lifecycle
    s.status,
    s.trial_start                                       AS trial_start_date,
    s.trial_end                                         AS trial_end_date,
    s.current_period_start,
    s.current_period_end,
    s.canceled_at                                       AS churn_date,

    -- calculated flags
    CASE
        WHEN s.status = 'active' THEN TRUE
        ELSE FALSE
    END                                                 AS is_active,
    CASE
        WHEN s.canceled_at IS NOT NULL THEN TRUE
        ELSE FALSE
    END                                                 AS is_churned,
    CASE
        WHEN s.trial_end > NOW() THEN TRUE
        ELSE FALSE
    END                                                 AS is_in_trial,
    CASE
        WHEN s.canceled_at IS NOT NULL
        THEN EXTRACT(DAY FROM s.canceled_at - s.current_period_start)::INT
        ELSE EXTRACT(DAY FROM NOW() - s.current_period_start)::INT
    END                                                 AS days_as_customer,

    -- customer attributes for slicing
    c.acquisition_channel,
    c.acquisition_channel_type,
    c.is_paid_acquisition,
    c.country,
    c.initial_plan_tier                                 AS signup_plan_tier

FROM raw.subscriptions s

-- get clean customer attributes
LEFT JOIN dimensions.dim_customers c
    ON c.stripe_customer_id = s.customer_id

-- get plan details
LEFT JOIN dimensions.dim_plans p
    ON p.price_id = s.plan_id;

ALTER TABLE facts.fact_subscriptions
ADD CONSTRAINT fact_subscriptions_pk PRIMARY KEY (subscription_id);

