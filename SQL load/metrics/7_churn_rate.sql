-- blended churn 
SELECT
    ROUND(COUNT(*) FILTER (WHERE is_churned = TRUE)::NUMERIC /
    NULLIF(COUNT(*), 0), 4) AS churn_rate
FROM facts.fact_subscriptions;

-- churn by month 
SELECT
    year_month,
    COUNT(*)                                                    AS total_customers,
    COUNT(*) FILTER (WHERE is_churned = TRUE)                   AS churned,
    ROUND(COUNT(*) FILTER (WHERE is_churned = TRUE)::NUMERIC /
    NULLIF(COUNT(*), 0), 4)                                     AS churn_rate
FROM facts.fact_subscriptions
GROUP BY year_month
ORDER BY year_month;

-- churn by plan tier 
SELECT
    plan_tier,
    COUNT(*)                                                    AS total_customers,
    COUNT(*) FILTER (WHERE is_churned = TRUE)                   AS churned,
    ROUND(COUNT(*) FILTER (WHERE is_churned = TRUE)::NUMERIC /
    NULLIF(COUNT(*), 0), 4)                                     AS churn_rate
FROM facts.fact_subscriptions
GROUP BY plan_tier
ORDER BY churn_rate DESC;