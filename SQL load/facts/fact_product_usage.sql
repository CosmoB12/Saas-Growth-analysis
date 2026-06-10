Create SCHEMA IF NOT EXISTS facts

CREATE TABLE facts.fact_product_usage AS
SELECT
    -- keys
    e.distinct_id                                       AS user_id,
    c.customer_id,
    TO_CHAR(DATE_TRUNC('month', e.time), 'YYYYMMDD')::INT AS date_key,
    TO_CHAR(e.time, 'YYYY-MM')                          AS year_month,

    -- usage metrics aggregated by user per month
    COUNT(*)                                            AS total_events,
    COUNT(*) FILTER (WHERE e.event_type = 'login')      AS logins,
    COUNT(*) FILTER (WHERE e.event_type = 'project_created') AS projects_created,
    COUNT(*) FILTER (WHERE e.event_type = 'task_created')    AS tasks_created,
    COUNT(*) FILTER (WHERE e.event_type = 'feature_used')    AS feature_interactions,
    COUNT(*) FILTER (WHERE e.event_type = 'invite_sent')     AS invites_sent,
    COUNT(*) FILTER (WHERE e.event_type = 'report_viewed')   AS reports_viewed,

    -- engagement score (weighted)
    ROUND(
        (COUNT(*) FILTER (WHERE e.event_type = 'login')           * 1.0 +
         COUNT(*) FILTER (WHERE e.event_type = 'feature_used')    * 2.0 +
         COUNT(*) FILTER (WHERE e.event_type = 'project_created') * 3.0 +
         COUNT(*) FILTER (WHERE e.event_type = 'task_created')    * 1.5 +
         COUNT(*) FILTER (WHERE e.event_type = 'invite_sent')     * 4.0
        ) / NULLIF(COUNT(*), 0)
    , 2)                                                AS engagement_score,

    -- platform breakdown
    COUNT(*) FILTER (WHERE e.platform = 'web')          AS web_events,
    COUNT(*) FILTER (WHERE e.platform = 'mobile_ios')   AS ios_events,
    COUNT(*) FILTER (WHERE e.platform = 'mobile_android') AS android_events,

    -- customer attributes for slicing
    c.initial_plan_tier                                 AS plan_tier,
    c.country,
    c.acquisition_channel

FROM raw.events e

LEFT JOIN dimensions.dim_customers c
    ON c.customer_id = e.distinct_id

GROUP BY
    e.distinct_id,
    c.customer_id,
    DATE_TRUNC('month', e.time),
    TO_CHAR(e.time, 'YYYY-MM'),
    c.initial_plan_tier,
    c.country,
    c.acquisition_channel;

ALTER TABLE facts.fact_product_usage
ADD CONSTRAINT fact_product_usage_pk PRIMARY KEY (user_id, year_month);
