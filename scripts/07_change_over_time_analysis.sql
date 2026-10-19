/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-- Analyse posting activity over time
-- Quick Date Functions
SELECT
    YEAR(post_date) AS post_year,
    MONTH(post_date) AS post_month,
    COUNT(*) AS total_postings,
    COUNT(DISTINCT company_key) AS total_companies,
    SUM(CASE WHEN hiring_status = 'Actively Hiring' THEN 1 ELSE 0 END) AS actively_hiring
FROM gold.fact_postings
WHERE post_date IS NOT NULL
GROUP BY YEAR(post_date), MONTH(post_date)
ORDER BY YEAR(post_date), MONTH(post_date);

-- DATETRUNC()
SELECT
    DATETRUNC(month, post_date) AS post_month,
    COUNT(*) AS total_postings,
    COUNT(DISTINCT company_key) AS total_companies
FROM gold.fact_postings
WHERE post_date IS NOT NULL
GROUP BY DATETRUNC(month, post_date)
ORDER BY DATETRUNC(month, post_date);

-- FORMAT()
SELECT
    FORMAT(post_date, 'yyyy-MMM') AS post_month,
    COUNT(*) AS total_postings,
    COUNT(DISTINCT company_key) AS total_companies
FROM gold.fact_postings
WHERE post_date IS NOT NULL
GROUP BY FORMAT(post_date, 'yyyy-MMM')
ORDER BY FORMAT(post_date, 'yyyy-MMM');
