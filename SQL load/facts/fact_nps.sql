CREATE SCHEMA IF NOT EXISTS facts;

CREATE TABLE facts.fact_nps AS
SELECT
    -- keys
    n.response_id,
    c.customer_id,
    TO_CHAR(n.submitted_at, 'YYYYMMDD')::INT            AS date_key,
    TO_CHAR(n.submitted_at, 'YYYY-MM')                  AS year_month,

    -- scores
    n.nps_score,
    CASE
        WHEN n.nps_score >= 9 THEN 'Promoter'
        WHEN n.nps_score >= 7 THEN 'Passive'
        ELSE 'Detractor'
    END                                                 AS nps_category,
    CASE
        WHEN n.nps_score >= 9 THEN  1
        WHEN n.nps_score >= 7 THEN  0
        ELSE                        -1
    END                                                 AS nps_value,

    -- open text
    n.reason,
    n.feature_request,

    -- customer attributes for slicing
    c.initial_plan_tier                                 AS plan_tier,
    c.country,
    c.acquisition_channel,
    n.submitted_at

FROM raw.nps_responses n
LEFT JOIN dimensions.dim_customers c
    ON c.customer_id = n.user_id;

ALTER TABLE facts.fact_nps
ADD CONSTRAINT fact_nps_pk PRIMARY KEY (response_id);