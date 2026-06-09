WITH avg_months_tier AS(

SELECT
    plan_tier,
    ROUND(AVG(mrr_contribution),2) AS arpu,
    ROUND(
            COUNT(*) FILTER (WHERE is_churned = TRUE)::NUMERIC
            / NULLIF(COUNT(*), 0)
        , 4)   AS churn_rate
FROM facts.fact_subscriptions
GROUP BY plan_tier

)

SELECT
    plan_tier,
    arpu,
    churn_rate,
    ROUND(1.0 / NULLIF(churn_rate,0),2) AS lifetime_months,
    ROUND(arpu *(1.0 / NULLIF(churn_rate,0)) * 0.75 ,2)AS ltv
FROM avg_months_tier
ORDER BY ltv DESC

