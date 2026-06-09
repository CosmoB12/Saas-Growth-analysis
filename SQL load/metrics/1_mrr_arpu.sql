SELECT
     ROUND(SUM(mrr_contribution),2) AS mrr,
     COUNT(*) AS  active_subscriptions,
     ROUND(AVG(mrr_contribution),2) AS arpu

FROM facts.fact_subscriptions

WHERE is_active = TRUE

--active subscriptions by plan tier

SELECT
    plan_tier,
    COUNT(*),
     SUM(mrr_contribution) AS mrr,
     AVG(mrr_contribution) AS arpu

FROM facts.fact_subscriptions

WHERE is_active = TRUE

GROUP BY plan_tier

SELECT * FROM  facts.fact_subscriptions

-- churn count
SELECT
    is_churned,
    COUNT(*) AS customers

FROM  facts.fact_subscriptions
GROUP BY 1