/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For company segmentation, posting-volume categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/* Segment postings by how many benefits are listed, and
count how many postings fall into each segment */
WITH benefit_segments AS (
    SELECT
        posting_id,
        benefits_count,
        CASE
            WHEN benefits_count = 0 THEN 'No benefits listed'
            WHEN benefits_count BETWEEN 1 AND 3 THEN '1-3 benefits'
            WHEN benefits_count BETWEEN 4 AND 6 THEN '4-6 benefits'
            ELSE '7+ benefits'
        END AS benefits_range
    FROM gold.fact_postings
)
SELECT
    benefits_range,
    COUNT(posting_id) AS total_postings
FROM benefit_segments
GROUP BY benefits_range
ORDER BY total_postings DESC;

/* Group companies into three segments based on posting behavior:
	- High-Volume Recruiter: 20+ postings (likely a staffing/recruiting agency)
	- Regular Employer: 3-19 postings
	- One-Off Poster: 1-2 postings
And find the total number of companies by each group
*/
WITH company_postings AS (
    SELECT
        c.company_key,
        COUNT(*) AS total_postings
    FROM gold.fact_postings f
    LEFT JOIN gold.dim_companies c
        ON f.company_key = c.company_key
    GROUP BY c.company_key
)
SELECT
    company_segment,
    COUNT(company_key) AS total_companies
FROM (
    SELECT
        company_key,
        CASE
            WHEN total_postings >= 20 THEN 'High-Volume Recruiter'
            WHEN total_postings BETWEEN 3 AND 19 THEN 'Regular Employer'
            ELSE 'One-Off Poster'
        END AS company_segment
    FROM company_postings
) AS segmented_companies
GROUP BY company_segment
ORDER BY total_companies DESC;
