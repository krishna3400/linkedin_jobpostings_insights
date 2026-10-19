/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.

SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- Retrieve a list of unique countries postings originate from
SELECT DISTINCT
    country
FROM gold.dim_locations
ORDER BY country;

-- Retrieve a list of unique industries, job functions, and seniority levels
SELECT DISTINCT
    industry,
    job_function,
    seniority_level
FROM gold.fact_postings
ORDER BY industry, job_function, seniority_level;

-- Retrieve a list of unique employment types
SELECT DISTINCT
    employment_type
FROM gold.fact_postings
ORDER BY employment_type;
