CREATE SCHEMA IF NOT EXISTS dimensions;
CREATE TABLE dimensions.dim_channels AS

-- Google Ads channels
SELECT
    'google_ads'                            AS channel_id,
    'Google Ads'                            AS channel_name,
    'Paid'                                  AS channel_type,
    'Search & Display'                      AS channel_category,
    TRUE                                    AS is_paid,
    'google_ads_campaigns'                  AS source_table

UNION ALL

-- LinkedIn Ads
SELECT
    'linkedin_ads'                          AS channel_id,
    'LinkedIn Ads'                          AS channel_name,
    'Paid'                                  AS channel_type,
    'Social'                                AS channel_category,
    TRUE                                    AS is_paid,
    'linkedin_ads_campaigns'                AS source_table

UNION ALL

-- Organic channels from HubSpot source field
SELECT DISTINCT
    LOWER(REPLACE(hs.acquisition_source, ' ', '_'))  AS channel_id,
    hs.acquisition_source                            AS channel_name,
    'Organic'                                        AS channel_type,
    CASE hs.acquisition_source
        WHEN 'Organic Search'   THEN 'SEO'
        WHEN 'Referral'         THEN 'Referral'
        WHEN 'Product Hunt'     THEN 'Community'
        ELSE 'Other'
    END                                              AS channel_category,
    FALSE                                            AS is_paid,
    'hubspot_contacts'                               AS source_table

FROM raw.hubspot_contacts hs
WHERE hs.acquisition_source NOT ILIKE '%google%'
  AND hs.acquisition_source NOT ILIKE '%linkedin%'
  AND hs.acquisition_source IS NOT NULL;

ALTER TABLE dimensions.dim_channels
ADD CONSTRAINT dim_channels_pk PRIMARY KEY (channel_id);
