/*
===============================================================================
Date Range Exploration
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Determine the first and last posting date and the total duration in months
SELECT
    MIN(post_date) AS first_posting_date,
    MAX(post_date) AS last_posting_date,
    DATEDIFF(MONTH, MIN(post_date), MAX(post_date)) AS posting_range_months
FROM gold.fact_postings;

-- How many distinct months of posting activity are actually covered?
SELECT
    COUNT(DISTINCT DATETRUNC(month, post_date)) AS months_with_data
FROM gold.fact_postings;
