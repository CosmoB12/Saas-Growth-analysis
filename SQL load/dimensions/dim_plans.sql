CREATE SCHEMA IF NOT EXISTS dimensions;

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

--