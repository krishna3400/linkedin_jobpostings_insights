/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'LinkedInJobsAnalytics' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
    and the three gold-layer tables used by every script in this project.

WARNING:
    Running this script will drop the entire 'LinkedInJobsAnalytics' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'LinkedInJobsAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'LinkedInJobsAnalytics')
BEGIN
    ALTER DATABASE LinkedInJobsAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LinkedInJobsAnalytics;
END;
GO

-- Create the 'LinkedInJobsAnalytics' database
CREATE DATABASE LinkedInJobsAnalytics;
GO

USE LinkedInJobsAnalytics;
GO

-- Create Schemas
CREATE SCHEMA gold;
GO

CREATE TABLE gold.dim_companies(
	company_key int,
	company_name nvarchar(300)
);
GO

CREATE TABLE gold.dim_locations(
	location_key int,
	city nvarchar(150),
	region nvarchar(150),
	country nvarchar(150)
);
GO

CREATE TABLE gold.fact_postings(
	posting_id int,
	job_title nvarchar(300),
	company_key int,
	location_key int,
	post_date date,
	hiring_status nvarchar(50),
	benefits_count tinyint,
	seniority_level nvarchar(50),
	job_function nvarchar(200),
	employment_type nvarchar(50),
	industry nvarchar(300),
	is_data_role bit
);
GO

TRUNCATE TABLE gold.dim_companies;
GO

BULK INSERT gold.dim_companies
FROM 'C:\sql\linkedin-sql-analytics-project\datasets\csv-files\gold.dim_companies.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	CODEPAGE = '65001',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_locations;
GO

BULK INSERT gold.dim_locations
FROM 'C:\sql\linkedin-sql-analytics-project\datasets\csv-files\gold.dim_locations.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	CODEPAGE = '65001',
	TABLOCK
);
GO

TRUNCATE TABLE gold.fact_postings;
GO

BULK INSERT gold.fact_postings
FROM 'C:\sql\linkedin-sql-analytics-project\datasets\csv-files\gold.fact_postings.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	CODEPAGE = '65001',
	TABLOCK
);
GO
