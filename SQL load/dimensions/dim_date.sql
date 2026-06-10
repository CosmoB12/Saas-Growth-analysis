CREATE SCHEMA IF NOT EXISTS dimensions;

CREATE TABLE dimensions.date AS
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT          AS date_key,
    d                                     AS full_date,
    EXTRACT(YEAR FROM d)::INT             AS year,
    EXTRACT(QUARTER FROM d)::INT          AS quarter,
    'Q' || EXTRACT(QUARTER FROM d)::INT   AS quarter_label,    -- 'Q1', 'Q2' etc
    EXTRACT(MONTH FROM d)::INT            AS month,
    TO_CHAR(d, 'Mon')                     AS month_short,      -- 'Jan', 'Feb'
    TO_CHAR(d, 'Month')                   AS month_name,       -- 'January'
    TO_CHAR(d, 'YYYY-MM')                 AS year_month,       -- '2024-01' joins to Mixpanel
    EXTRACT(DAY FROM d)::INT              AS day,
    TO_CHAR(d, 'Day')                     AS day_name,
    EXTRACT(DOW FROM d)::INT              AS day_of_week,      -- 0=Sunday
    EXTRACT(WEEK FROM d)::INT             AS week_number,
    CASE WHEN EXTRACT(MONTH FROM d) <= 6
         THEN 'H1' ELSE 'H2' END          AS fiscal_half,
    CASE WHEN EXTRACT(DOW FROM d) IN (0,6)
         THEN false ELSE true END         AS is_weekday

FROM generate_series(
    '2024-01-01'::DATE,
    '2025-07-01'::DATE,
    '1 day'
) AS d;

ALTER TABLE dimensions.date
ADD CONSTRAINT dim_date_pk PRIMARY KEY (date_key);
