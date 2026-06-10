CREATE SCHEMA IF NOT EXISTS facts;

CREATE TABLE facts.fact_marketing_spend AS

-- Google Ads
SELECT
    TO_CHAR(g.date, 'YYYYMMDD')::INT                    AS date_key,
    TO_CHAR(g.date, 'YYYY-MM')                          AS year_month,
    'google_ads'                                        AS channel_id,
    dc.channel_name,
    dc.channel_type,
    g.campaign_name,
    g.impressions,
    g.clicks,
    g.cost_usd                                          AS spend_usd,
    g.conversions,
    g.ctr                                               AS ctr_pct,
    g.avg_cpc_usd,
    g.conversion_rate                                   AS conversion_rate_pct,
    g.cost_per_conversion                               AS cost_per_conversion_usd,
    NULL::INTEGER                                       AS leads  -- not tracked in Google export

FROM raw.google_ads g
LEFT JOIN dimensions.dim_channels dc
    ON dc.channel_id = 'google_ads'

UNION ALL

-- LinkedIn Ads
SELECT
    TO_CHAR(l.start_date, 'YYYYMMDD')::INT              AS date_key,
    TO_CHAR(l.start_date, 'YYYY-MM')                    AS year_month,
    'linkedin_ads'                                      AS channel_id,
    dc.channel_name,
    dc.channel_type,
    l.campaign_name,
    l.impressions,
    l.clicks,
    l.spend_usd,
    NULL::INTEGER                                       AS conversions, -- not tracked in LinkedIn export
    NULL::NUMERIC                                       AS ctr_pct,
    l.avg_cpc_usd,
    NULL::NUMERIC                                       AS conversion_rate_pct,
    l.cost_per_lead_usd                                 AS cost_per_conversion_usd,
    l.leads

FROM raw.linkedin_ads l
LEFT JOIN dimensions.dim_channels dc
    ON dc.channel_id = 'linkedin_ads';

SELECT * FROM facts.fact_marketing_spend