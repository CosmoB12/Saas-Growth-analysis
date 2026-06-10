WITH promoter_detractor AS(
SELECT 
   ROUND(100.0 * SUM(CASE WHEN nps_category = 'Promoter' THEN 1 ELSE 0 END)/
   COUNT(*),2) AS promoter_percentage,
   ROUND(100.0 * SUM(CASE WHEN nps_category = 'Passive' THEN 1 ELSE 0 END)/
   COUNT(*),2) AS passive_percentage,
   ROUND(100.0 * SUM(CASE WHEN nps_category = 'Detractor' THEN 1 ELSE 0 END)/
   COUNT(*),2) AS Detractor_percentage,
   COUNT(*)  AS total_responses


FROM facts.fact_nps
)

SELECT
    total_responses,
    promoter_percentage,
    passive_percentage,
    detractor_percentage,
    promoter_percentage - detractor_percentage AS nps_score
FROM promoter_detractor


