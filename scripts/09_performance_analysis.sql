/*
===============================================================================
Performance Analysis (Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of industries or countries over time.
    - For benchmarking and identifying high-performing entities.
    - To track monthly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the monthly performance of industries by comparing their posting volume
to both the average volume for that industry and the previous month's volume */
WITH monthly_industry_postings AS (
    SELECT
        DATETRUNC(month, f.post_date) AS post_month,
        f.industry,
        COUNT(*) AS current_postings
    FROM gold.fact_postings f
    WHERE f.post_date IS NOT NULL
      AND f.industry IS NOT NULL
    GROUP BY
        DATETRUNC(month, f.post_date),
        f.industry
)
SELECT
    post_month,
    industry,
    current_postings,
    AVG(current_postings) OVER (PARTITION BY industry) AS avg_postings,
    current_postings - AVG(current_postings) OVER (PARTITION BY industry) AS diff_avg,
    CASE
        WHEN current_postings - AVG(current_postings) OVER (PARTITION BY industry) > 0 THEN 'Above Avg'
        WHEN current_postings - AVG(current_postings) OVER (PARTITION BY industry) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Month-over-Month Analysis
    LAG(current_postings) OVER (PARTITION BY industry ORDER BY post_month) AS prev_month_postings,
    current_postings - LAG(current_postings) OVER (PARTITION BY industry ORDER BY post_month) AS diff_mom,
    CASE
        WHEN current_postings - LAG(current_postings) OVER (PARTITION BY industry ORDER BY post_month) > 0 THEN 'Increase'
        WHEN current_postings - LAG(current_postings) OVER (PARTITION BY industry ORDER BY post_month) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS mom_change
FROM monthly_industry_postings
ORDER BY industry, post_month;
