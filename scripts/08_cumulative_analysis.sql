/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track posting activity over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total postings per month
-- and the running total of postings over time
SELECT
	post_month,
	total_postings,
	SUM(total_postings) OVER (ORDER BY post_month) AS running_total_postings,
	AVG(avg_benefits) OVER (ORDER BY post_month) AS moving_avg_benefits
FROM
(
    SELECT
        DATETRUNC(month, post_date) AS post_month,
        COUNT(*) AS total_postings,
        AVG(CAST(benefits_count AS FLOAT)) AS avg_benefits
    FROM gold.fact_postings
    WHERE post_date IS NOT NULL
    GROUP BY DATETRUNC(month, post_date)
) t
ORDER BY post_month;
