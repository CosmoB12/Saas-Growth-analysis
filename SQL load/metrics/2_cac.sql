SELECT
    channel_name,
    SUM(spend_usd)                                              AS total_spend_usd,
    COALESCE(SUM(conversions), 0) + COALESCE(SUM(leads), 0)    AS total_acquisitions,
    ROUND(
        SUM(spend_usd) / NULLIF(
            COALESCE(SUM(conversions), 0) + COALESCE(SUM(leads), 0)
        , 0)
    , 2)                                                        AS cac

FROM facts.fact_marketing_spend
GROUP BY channel_name
ORDER BY cac;


