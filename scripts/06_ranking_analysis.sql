/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., companies, industries) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 industries post the most jobs?
-- Simple Ranking
SELECT TOP 5
    industry,
    COUNT(*) AS total_postings
FROM gold.fact_postings
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY total_postings DESC;

-- Complex but Flexibly Ranking Using Window Functions
SELECT *
FROM (
    SELECT
        industry,
        COUNT(*) AS total_postings,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_industries
    FROM gold.fact_postings
    WHERE industry IS NOT NULL
    GROUP BY industry
) AS ranked_industries
WHERE rank_industries <= 5;

-- What are the 5 lowest-volume industries (still with meaningful sample size)?
SELECT TOP 5
    industry,
    COUNT(*) AS total_postings
FROM gold.fact_postings
WHERE industry IS NOT NULL
GROUP BY industry
HAVING COUNT(*) >= 20
ORDER BY total_postings;

-- Find the top 10 companies posting the most jobs
SELECT TOP 10
    c.company_key,
    c.company_name,
    COUNT(*) AS total_postings
FROM gold.fact_postings f
LEFT JOIN gold.dim_companies c
    ON c.company_key = f.company_key
GROUP BY
    c.company_key,
    c.company_name
ORDER BY total_postings DESC;

-- Rank companies within each country by posting volume (top 5 per country)
SELECT *
FROM (
    SELECT
        l.country,
        c.company_name,
        COUNT(*) AS total_postings,
        RANK() OVER (PARTITION BY l.country ORDER BY COUNT(*) DESC) AS rank_in_country
    FROM gold.fact_postings f
    LEFT JOIN gold.dim_companies c ON c.company_key = f.company_key
    LEFT JOIN gold.dim_locations l ON l.location_key = f.location_key
    WHERE l.country IN ('India', 'United States', 'United Kingdom', 'Australia')
    GROUP BY l.country, c.company_name
) ranked
WHERE rank_in_country <= 5
ORDER BY country, rank_in_country;
