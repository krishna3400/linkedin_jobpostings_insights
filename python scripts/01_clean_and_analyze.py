"""
LinkedIn Job Postings — Cleaning & Exploratory Data Analysis
Author: (your name)
Source file: linkedin_job_posts_insights.xlsx (31,597 raw scraped rows)

This script:
 1. Cleans a messy, real-world scraped LinkedIn jobs dataset
 2. Engineers useful fields (country, benefits count, data-role flag, month)
 3. Computes the headline insights used across SQL Server / Power BI / Tableau / Excel
 4. Saves a clean CSV (for import into SQL Server / Tableau / Power BI) and PNG charts
"""

import pandas as pd
import numpy as np
import re
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

pd.set_option("display.max_columns", None)

# ---------------------------------------------------------------------------
# 1. LOAD
# ---------------------------------------------------------------------------
RAW_PATH = "extracted/linkedin_job_posts_insights.xlsx"
df = pd.read_excel(RAW_PATH)

print(f"RAW rows: {len(df):,}  cols: {df.shape[1]}")

# ---------------------------------------------------------------------------
# 2. CLEAN
# ---------------------------------------------------------------------------

def clean_str(x):
    """Collapse embedded newlines / repeated whitespace from HTML-scraped text."""
    if pd.isna(x):
        return np.nan
    return re.sub(r"\s+", " ", str(x)).strip()

str_cols = ["job_title", "company_name", "location", "hiring_status",
            "seniority_level", "job_function", "employment_type", "industry"]
for c in str_cols:
    df[c] = df[c].apply(clean_str)

# --- de-duplicate (34% of raw rows were exact duplicates from re-scraping) ---
before = len(df)
df = df.drop_duplicates()
print(f"Removed {before - len(df):,} exact duplicate rows")

# --- hiring_status: strip the "+N benefits" suffix into its own numeric field ---
def split_status(x):
    if pd.isna(x):
        return pd.Series([np.nan, 0])
    m = re.match(r"(.*?)(?:\s*\+(\d+)\D*benefits?)?$", x)
    base = m.group(1).strip() if m else x
    n = int(m.group(2)) if m and m.group(2) else 0
    if base not in ("Actively Hiring", "Be an early applicant"):
        base = "Other/Benefits listed"
    return pd.Series([base, n])

df[["hiring_status_clean", "benefits_count"]] = df["hiring_status"].apply(split_status)

# --- employment_type: strip stray "Employment type " prefix from mis-scraped rows ---
df["employment_type_clean"] = df["employment_type"].str.replace(
    r"^Employment type\s+", "", regex=True)

# --- seniority_level: values like "Full-time"/"Contract" are employment-type
#     leakage (a source-page scraping defect), not real seniority levels -> null them
BAD_SENIORITY = {"Full-time", "Part-time", "Contract", "Internship", "Other", "Volunteer"}
df["seniority_level_clean"] = df["seniority_level"].where(
    ~df["seniority_level"].isin(BAD_SENIORITY))

# --- location -> city / region / country ---
def split_location(loc):
    if pd.isna(loc):
        return pd.Series([np.nan, np.nan, np.nan])
    parts = [p.strip() for p in loc.split(",")]
    if len(parts) == 3:
        return pd.Series(parts)
    if len(parts) == 2:
        return pd.Series([parts[0], np.nan, parts[1]])
    return pd.Series([np.nan, np.nan, parts[0]])

df[["city", "region", "country"]] = df["location"].apply(split_location)
# 2-letter US state codes with no country listed ("Chicago, IL") -> country = United States
US_STATE = re.compile(r"^[A-Z]{2}$")
df.loc[df["country"].apply(lambda x: isinstance(x, str) and bool(US_STATE.match(x))), "country"] = "United States"

# --- date fields ---
df["date"] = pd.to_datetime(df["date"])
df["post_month"] = df["date"].dt.to_period("M").astype(str)
df["post_year"] = df["date"].dt.year

# --- data/tech role flag (useful cut for a data-analytics-flavoured portfolio) ---
DATA_ROLE_RX = re.compile(
    r"data (scientist|analyst|engineer)|machine learning|\bml\b|analytics|business intelligence|\bbi\b",
    re.IGNORECASE)
df["is_data_role"] = df["job_title"].fillna("").str.contains(DATA_ROLE_RX)

# --- drop rows with no usable job_title at all ---
df = df[df["job_title"].notna()].reset_index(drop=True)

# final tidy frame for downstream tools
clean = df[[
    "job_title", "company_name", "city", "region", "country", "location",
    "date", "post_month", "post_year", "hiring_status_clean", "benefits_count",
    "seniority_level_clean", "job_function", "employment_type_clean", "industry",
    "is_data_role"
]].rename(columns={
    "hiring_status_clean": "hiring_status",
    "seniority_level_clean": "seniority_level",
    "employment_type_clean": "employment_type",
})

clean.to_csv("outputs/linkedin_jobs_clean.csv", index=False)
print(f"CLEAN rows: {len(clean):,}")
print(clean.isnull().mean().round(3).sort_values(ascending=False))

# ---------------------------------------------------------------------------
# 3. INSIGHTS
# ---------------------------------------------------------------------------
insights = {}

insights["date_range"] = (clean["date"].min().date(), clean["date"].max().date())
insights["total_postings"] = len(clean)
insights["unique_companies"] = clean["company_name"].nunique()
insights["unique_countries"] = clean["country"].nunique()

top_industries = clean["industry"].value_counts().head(10)
top_companies = clean["company_name"].value_counts().head(10)
top_titles = clean["job_title"].value_counts().head(10)
top_countries = clean["country"].value_counts().head(10)
seniority_mix = clean["seniority_level"].value_counts(normalize=True).round(3)
employment_mix = clean["employment_type"].value_counts(normalize=True).round(3)
hiring_status_mix = clean["hiring_status"].value_counts(normalize=True).round(3)
monthly_trend = clean.groupby("post_month").size()
data_role_share = clean["is_data_role"].mean().round(3)
data_role_seniority = clean[clean.is_data_role]["seniority_level"].value_counts(normalize=True).round(3)
avg_benefits_by_status = clean.groupby("hiring_status")["benefits_count"].mean().round(2)

print("\n=== TOP 10 INDUSTRIES ===\n", top_industries)
print("\n=== TOP 10 HIRING COMPANIES ===\n", top_companies)
print("\n=== TOP 10 JOB TITLES ===\n", top_titles)
print("\n=== TOP 10 COUNTRIES ===\n", top_countries)
print("\n=== SENIORITY MIX ===\n", seniority_mix)
print("\n=== EMPLOYMENT TYPE MIX ===\n", employment_mix)
print("\n=== HIRING STATUS MIX ===\n", hiring_status_mix)
print("\n=== MONTHLY POSTING TREND ===\n", monthly_trend)
print("\nShare of postings that are Data/ML/Analytics roles:", data_role_share)
print("\nSeniority mix WITHIN data roles:\n", data_role_seniority)
print("\nAvg benefits listed by hiring status:\n", avg_benefits_by_status)

# ---------------------------------------------------------------------------
# 4. CHARTS (for Excel/Python portfolio use + quick visual sanity check)
# ---------------------------------------------------------------------------
plt.style.use("seaborn-v0_8-whitegrid")

fig, ax = plt.subplots(figsize=(9, 5))
top_industries.sort_values().plot(kind="barh", ax=ax, color="#0A66C2")
ax.set_title("Top 10 Industries by Job Postings")
ax.set_xlabel("Postings")
plt.tight_layout()
plt.savefig("charts/top_industries.png", dpi=150)
plt.close()

fig, ax = plt.subplots(figsize=(10, 5))
monthly_trend.plot(kind="line", marker="o", ax=ax, color="#0A66C2")
ax.set_title("Job Postings by Month")
ax.set_ylabel("Postings")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig("charts/monthly_trend.png", dpi=150)
plt.close()

fig, ax = plt.subplots(figsize=(7, 7))
seniority_mix.plot(kind="pie", ax=ax, autopct="%1.0f%%", startangle=90)
ax.set_ylabel("")
ax.set_title("Seniority Level Mix")
plt.tight_layout()
plt.savefig("charts/seniority_mix.png", dpi=150)
plt.close()

fig, ax = plt.subplots(figsize=(9, 5))
top_countries.sort_values().plot(kind="barh", ax=ax, color="#057642")
ax.set_title("Top 10 Countries by Job Postings")
plt.tight_layout()
plt.savefig("charts/top_countries.png", dpi=150)
plt.close()

print("\nSaved cleaned CSV -> outputs/linkedin_jobs_clean.csv")
print("Saved 4 charts -> charts/")
