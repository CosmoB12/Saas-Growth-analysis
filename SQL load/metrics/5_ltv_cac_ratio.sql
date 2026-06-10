WITH ltv AS(

SELECT
    plan_tier,
    ROUND(AVG(mrr_contribution),2) AS arpu,
    ROUND(
            COUNT(*) FILTER (WHERE is_churned = TRUE)::NUMERIC
            / NULLIF(COUNT(*), 0)
        , 4)   AS churn_rate
FROM facts.fact_subscriptions
GROUP BY plan_tier

),

cac AS( 
SELECT
 SUM(spend_usd)                                              AS total_spend_usd,
    COALESCE(SUM(conversions), 0) + COALESCE(SUM(leads), 0)    AS total_acquisitions,
    ROUND(
        SUM(spend_usd) / NULLIF(
            COALESCE(SUM(conversions), 0) + COALESCE(SUM(leads), 0)
        , 0)
    , 2)      AS blended_cac    
FROM facts.fact_marketing_spend
)

SELECT
    l.plan_tier,
    l.arpu,
    l.churn_rate,
    ROUND(1.0 / NULLIF(l.churn_rate,0),2) AS lifetime_months,
    ROUND(l.arpu *(1.0 / NULLIF(l.churn_rate,0)) * 0.75 ,2)AS ltv,
    ROUND((l.arpu *(1.0 / NULLIF(l.churn_rate,0)) * 0.75 )/c.blended_cac,2) AS ltv_to_cac_ratio
FROM ltv AS l

CROSS JOIN cac  AS c

ORDER BY ltv DESC


/*
Business: 9.83x — exceptional. For every $1 spent acquiring a Business customer you get $9.83 back. These customers churn least and pay most.
Pro: 3.48x — healthy. Right at the industry benchmark of 3x. Sustainable growth.
Starter: 0.87x — losing money. You're spending $32.61 to acquire a customer who only generates $28.38 in lifetime value. Every Starter customer acquired through paid ads is a net loss.
*/


--solution
-- Push more ad spend toward converting Starter users to Pro/Business — upsell is more efficient than acquisition
-- Reduce Starter churn (22.8%) — even dropping it to 15% would push LTV above CAC
-- Consider whether paid ads should target Starter at all — organic/referral might be a better fit for that tier