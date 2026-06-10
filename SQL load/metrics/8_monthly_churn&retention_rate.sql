
WITH monthly_customers AS (
    SELECT
        d.year_month,
        COUNT(DISTINCT s.subscription_id) FILTER (
            WHERE TO_CHAR(s.current_period_start, 'YYYY-MM') <= d.year_month
            AND (s.churn_date IS NULL OR TO_CHAR(s.churn_date, 'YYYY-MM') > d.year_month)
        )                                               AS active_start,
        COUNT(DISTINCT s.subscription_id) FILTER (
            WHERE s.churn_date IS NOT NULL
            AND TO_CHAR(s.churn_date, 'YYYY-MM') = d.year_month
        )                                               AS churned_this_month
    FROM dimensions.date d
    CROSS JOIN facts.fact_subscriptions s
    WHERE d.year_month BETWEEN '2024-01' AND '2025-06'
    GROUP BY d.year_month
)
SELECT
    year_month,
    active_start,
    churned_this_month,
    active_start - churned_this_month                           AS retained_this_month,
    ROUND(
        churned_this_month::NUMERIC / NULLIF(active_start, 0) * 100
    , 2)                                                        AS monthly_churn_rate_pct,
    ROUND(
        (1 - churned_this_month::NUMERIC / NULLIF(active_start, 0)) * 100
    , 2)                                                        AS monthly_retention_rate_pct
FROM monthly_customers
ORDER BY year_month;