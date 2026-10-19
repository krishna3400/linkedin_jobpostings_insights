/*
===============================================================================
Company Report
===============================================================================
Purpose:
    - This report consolidates key hiring-company metrics and behaviors

Highlights:
    1. Gathers essential fields such as company name and posting details.
	2. Segments companies into categories (High-Volume Recruiter, Regular Employer, One-Off Poster).
    3. Aggregates company-level metrics:
	   - total postings
	   - total actively-hiring postings
	   - distinct industries posted into
	   - distinct countries posted into
	   - posting lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last posting)
		- actively-hiring rate
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_companies
-- =============================================================================
IF OBJECT_ID('gold.report_companies', 'V') IS NOT NULL
    DROP VIEW gold.report_companies;
GO

CREATE VIEW gold.report_companies AS

WITH base_query AS(
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
SELECT
f.posting_id,
f.post_date,
f.hiring_status,
f.industry,
l.country,
c.company_key,
c.company_name
FROM gold.fact_postings f
LEFT JOIN gold.dim_companies c
    ON c.company_key = f.company_key
LEFT JOIN gold.dim_locations l
    ON l.location_key = f.location_key
WHERE f.post_date IS NOT NULL)

, company_aggregation AS (
/*---------------------------------------------------------------------------
2) Company Aggregations: Summarizes key metrics at the company level
---------------------------------------------------------------------------*/
SELECT
	company_key,
	company_name,
	COUNT(posting_id) AS total_postings,
	SUM(CASE WHEN hiring_status = 'Actively Hiring' THEN 1 ELSE 0 END) AS actively_hiring_postings,
	COUNT(DISTINCT industry) AS distinct_industries,
	COUNT(DISTINCT country) AS distinct_countries,
	MAX(post_date) AS last_posting_date,
	DATEDIFF(month, MIN(post_date), MAX(post_date)) AS lifespan
FROM base_query
GROUP BY
	company_key,
	company_name
)
SELECT
company_key,
company_name,
CASE
	 WHEN total_postings >= 20 THEN 'High-Volume Recruiter'
	 WHEN total_postings BETWEEN 3 AND 19 THEN 'Regular Employer'
	 ELSE 'One-Off Poster'
END AS company_segment,
last_posting_date,
DATEDIFF(month, last_posting_date, GETDATE()) AS recency,
total_postings,
actively_hiring_postings,
distinct_industries,
distinct_countries,
lifespan,
-- Compute actively-hiring rate
CASE WHEN total_postings = 0 THEN 0
	 ELSE CAST(actively_hiring_postings AS FLOAT) / total_postings
END AS actively_hiring_rate
FROM company_aggregation
