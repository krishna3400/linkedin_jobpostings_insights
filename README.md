                                       💼 LinkedIn Job Postings Analytics
SQL & Python analysis of 20,500+ real-world job postings across 108 countries
   

📖 Overview
This project analyzes a real-world dataset of 20,519 LinkedIn job postings (cleaned from 31,597 raw scraped rows) spanning 108 countries, 6,656 companies, and 24 months (May 2021 – April 2023). It follows a complete analytics workflow: cleaning messy scraped data in Python, modeling it into a SQL Server star schema, analyzing it through 13 progressive SQL scripts, and consolidating findings into reusable reporting views.

The goal: turn raw, duplicate-heavy job listing data into a clear, queryable picture of where hiring is happening, which industries are driving it, and what the data/analytics job market looks like specifically.

🔄 Pipeline
1️⃣	Raw scraped LinkedIn export — 31,597 rows, 9 columns, 34.9% duplicates
2️⃣	Python (pandas) cleaning — strip whitespace/HTML artifacts, drop exact duplicates, split hiring_status into status + benefits count, null out mis-scraped seniority values, parse location into city/region/country
3️⃣	Gold layer build — generate surrogate keys, split into fact_postings / dim_companies / dim_locations
4️⃣	SQL Server — 20,519 cleaned rows loaded into a star-schema Gold layer
5️⃣	Analysis — 11 exploratory/analytical SQL scripts + 2 reusable reporting views
6️⃣	Power BI dashboard — final visualization layer
🗂️ Data Model
Star-schema design, three Gold-layer tables:

Table	Grain	Key Columns
gold.fact_postings	one row per job posting	posting_id, company_key, location_key, post_date, hiring_status, benefits_count, seniority_level, job_function, employment_type, industry, is_data_role
gold.dim_companies	one row per company	company_key, company_name
gold.dim_locations	one row per city/region/country	location_key, city, region, country
🧠 Analysis Themes
#	Script	What it does
01	database_exploration.sql	Schema/metadata exploration via INFORMATION_SCHEMA
02	dimensions_exploration.sql	Distinct values across each dimension
03	date_range_exploration.sql	Temporal boundaries of the dataset
04	measures_exploration.sql	Headline KPIs — counts, averages
05	magnitude_analysis.sql	Totals grouped by a single dimension
06	ranking_analysis.sql	Top-N companies/industries using window-function ranking
07	change_over_time_analysis.sql	Monthly posting trends
08	cumulative_analysis.sql	Running totals and moving averages
09	performance_analysis.sql	Month-over-month growth via LAG()
10	data_segmentation.sql	CASE-based tiers (benefit tiers, company posting-volume tiers)
11	part_to_whole_analysis.sql	% contribution of each category to the total
12	report_companies.sql	gold.report_companies view — High-Volume Recruiter / Regular Employer / One-Off Poster segments, recency, actively-hiring rate
13	report_industries.sql	gold.report_industries view — High/Mid/Low-Demand industry segments, recency, average benefits listed
📊 Key Findings
🏢	Tech dominates hiring — "Technology, Information and Internet," "IT Services and IT Consulting," and "Staffing and Recruiting" are the top 3 industries, ~31% of all postings combined
🌍	Geographic concentration — India, the US, and the UK account for ~75% of all postings
📈	Seniority skews mid-career — 42.6% Mid-Senior level vs. 29.9% Entry level
📊	Data/ML/Analytics roles = 11.3% of all postings; the US narrowly outpaces India specifically for data roles, even though India leads in overall volume
⏱️	Hiring urgency is mixed — only 42% of postings were flagged "Actively Hiring"; the majority were "Be an early applicant"
📁 Repository Structure
python/01_clean_and_analyze.py	Raw data cleaning pipeline
python/02_build_gold_layer.py	Surrogate keys, star-schema split
datasets/csv-files/	Gold-layer CSVs, ready for BULK INSERT
docs/project_roadmap.md	Pipeline overview & architecture notes
scripts/	13 SQL analysis scripts, run in order
🚀 How to Run
Open SQL Server Management Studio (or Azure Data Studio) connected to a SQL Server 2019+ instance.
Run scripts/00_init_database.sql. This drops and recreates LinkedInJobsAnalytics — update the BULK INSERT ... FROM file paths to point to your local datasets/csv-files/ folder first.
Run scripts 01 → 13 in order — each is independent and safe to re-run, except 00 (destructive) and 12/13 (which drop and recreate their views, also safe to re-run).
Query the two reporting views for a one-stop summary:
SELECT * FROM gold.report_companies ORDER BY total_postings DESC;
SELECT * FROM gold.report_industries ORDER BY total_postings DESC;
🛠️ Tools Used
    

🛡️ License
This project is licensed under the MIT License.
