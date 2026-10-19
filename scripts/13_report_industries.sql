/*
===============================================================================
Industry Report
===============================================================================
Purpose:
    - This report consolidates key industry-level metrics and behaviors.

Highlights:
    1. Gathers essential fields such as industry and posting details.
    2. Segments industries by posting volume to identify High-Demand, Mid-Demand, or Low-Demand.
    3. Aggregates industry-level metrics:
       - total postings
       - total actively-hiring postings
       - total companies (unique)
       - total countries (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last posting)
       - actively-hiring rate
       - average benefits listed
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_industries
-- =============================================================================
IF OBJECT_ID('gold.report_industries', 'V') IS NOT NULL
    DROP VIEW gold.report_industries;
GO

CREATE VIEW gold.report_industries AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_postings and dimensions
---------------------------------------------------------------------------*/
    SELECT
	    f.posting_id,
        f.post_date,
		f.company_key,
        f.hiring_status,
        f.benefits_count,
        l.country,
        f.industry
    FROM gold.fact_postings f
    LEFT JOIN gold.dim_locations l
        ON f.location_key = l.location_key
    WHERE f.post_date IS NOT NULL  -- only consider valid posting dates
),

industry_aggregations AS (
/*---------------------------------------------------------------------------
2) Industry Aggregations: Summarizes key metrics at the industry level
---------------------------------------------------------------------------*/
SELECT
    industry,
    DATEDIFF(MONTH, MIN(post_date), MAX(post_date)) AS lifespan,
    MAX(post_date) AS last_posting_date,
    COUNT(posting_id) AS total_postings,
	COUNT(DISTINCT company_key) AS total_companies,
	COUNT(DISTINCT country) AS total_countries,
    SUM(CASE WHEN hiring_status = 'Actively Hiring' THEN 1 ELSE 0 END) AS actively_hiring_postings,
	AVG(CAST(benefits_count AS FLOAT)) AS avg_benefits_listed
FROM base_query
WHERE industry IS NOT NULL

GROUP BY
    industry
)

/*---------------------------------------------------------------------------
  3) Final Query: Combines all industry results into one output
---------------------------------------------------------------------------*/
SELECT
	industry,
	last_posting_date,
	DATEDIFF(MONTH, last_posting_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_postings > 1000 THEN 'High-Demand'
		WHEN total_postings >= 200 THEN 'Mid-Demand'
		ELSE 'Low-Demand'
	END AS industry_segment,
	lifespan,
	total_postings,
	total_companies,
	total_countries,
	actively_hiring_postings,
	avg_benefits_listed,

	-- Actively-Hiring Rate
	CASE
		WHEN total_postings = 0 THEN 0
		ELSE CAST(actively_hiring_postings AS FLOAT) / total_postings
	END AS actively_hiring_rate

FROM industry_aggregations
