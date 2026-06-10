WITH mrr_cogs AS (
    SELECT
        d.year_month,
        SUM(p.monthly_equivalent_usd)           AS mrr,
        SUM(p.monthly_equivalent_usd) * 0.25    AS cogs
    FROM facts.fact_subscriptions s
    JOIN dimensions.date d
        ON d.year_month >= TO_CHAR(s.current_period_start, 'YYYY-MM')
        AND d.year_month <= TO_CHAR(
            COALESCE(s.churn_date, '2025-06-30'::DATE), 'YYYY-MM')
    JOIN dimensions.dim_plans p
        ON p.price_id = s.plan_price_id
    GROUP BY d.year_month
)
SELECT
    year_month,
    ROUND(mrr, 2)                               AS mrr,
    ROUND(cogs, 2)                              AS cogs,
    ROUND(mrr - cogs, 2)                        AS gross_profit,
    ROUND(((mrr - cogs) / mrr) * 100, 2)        AS gross_margin_pct
FROM mrr_cogs
ORDER BY year_month;