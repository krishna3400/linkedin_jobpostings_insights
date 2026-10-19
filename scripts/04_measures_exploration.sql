/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Find the total number of job postings
SELECT COUNT(*) AS total_postings FROM gold.fact_postings;

-- Find how many postings are currently "Actively Hiring"
SELECT COUNT(*) AS actively_hiring
FROM gold.fact_postings
WHERE hiring_status = 'Actively Hiring';

-- Find the average number of benefits listed per posting
SELECT AVG(CAST(benefits_count AS FLOAT)) AS avg_benefits_listed FROM gold.fact_postings;

-- Find the total number of distinct companies hiring
SELECT COUNT(DISTINCT company_key) AS total_companies FROM gold.fact_postings;

-- Find the total number of distinct countries with postings
SELECT COUNT(DISTINCT location_key) AS total_locations FROM gold.fact_postings;
SELECT COUNT(DISTINCT country) AS total_countries FROM gold.dim_locations;

-- Find the total number of data/ML/analytics role postings
SELECT COUNT(*) AS total_data_roles
FROM gold.fact_postings
WHERE is_data_role = 1;

-- Generate a report that shows all key metrics of the job market
SELECT 'Total Postings' AS measure_name, COUNT(*) AS measure_value FROM gold.fact_postings
UNION ALL
SELECT 'Actively Hiring', COUNT(*) FROM gold.fact_postings WHERE hiring_status = 'Actively Hiring'
UNION ALL
SELECT 'Total Companies', COUNT(DISTINCT company_key) FROM gold.fact_postings
UNION ALL
SELECT 'Total Countries', COUNT(DISTINCT country) FROM gold.dim_locations
UNION ALL
SELECT 'Total Data/ML Roles', COUNT(*) FROM gold.fact_postings WHERE is_data_role = 1
UNION ALL
SELECT 'Avg Benefits Listed', AVG(CAST(benefits_count AS FLOAT)) FROM gold.fact_postings;
