SELECT
    year_month,
    COUNT(*) FILTER (WHERE status = 'active')           AS converted,
    COUNT(*) FILTER (WHERE trial_start_date IS NOT NULL) AS trial_starts,
    ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'active') /
    NULLIF(COUNT(*) FILTER (WHERE trial_start_date IS NOT NULL), 0)
    , 2)                                                AS conversion_rate_pct
FROM facts.fact_subscriptions
GROUP BY year_month
ORDER BY year_month;
