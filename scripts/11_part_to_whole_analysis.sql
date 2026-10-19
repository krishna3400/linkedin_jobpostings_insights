/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for regional comparisons or market-share style breakdowns.

SQL Functions Used:
    - SUM(), COUNT(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

-- Which industries contribute the most to overall postings?
WITH industry_postings AS (
    SELECT
        industry,
        COUNT(*) AS total_postings
    FROM gold.fact_postings
    WHERE industry IS NOT NULL
    GROUP BY industry
)
SELECT
    industry,
    total_postings,
    SUM(total_postings) OVER () AS overall_postings,
    ROUND((CAST(total_postings AS FLOAT) / SUM(total_postings) OVER ()) * 100, 2) AS percentage_of_total
FROM industry_postings
ORDER BY total_postings DESC;

-- Which countries contribute the most to overall postings?
WITH country_postings AS (
    SELECT
        l.country,
        COUNT(*) AS total_postings
    FROM gold.fact_postings f
    LEFT JOIN gold.dim_locations l
        ON l.location_key = f.location_key
    WHERE l.country IS NOT NULL
    GROUP BY l.country
)
SELECT
    country,
    total_postings,
    SUM(total_postings) OVER () AS overall_postings,
    ROUND((CAST(total_postings AS FLOAT) / SUM(total_postings) OVER ()) * 100, 2) AS percentage_of_total
FROM country_postings
ORDER BY total_postings DESC;
