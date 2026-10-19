import pandas as pd
import numpy as np

df = pd.read_csv("outputs/linkedin_jobs_clean.csv")
df = df[df["job_title"].notna()].reset_index(drop=True)

# ---------------------------------------------------------------------------
# dim_companies
# ---------------------------------------------------------------------------
companies = (
    df["company_name"].fillna("Unknown")
    .drop_duplicates()
    .sort_values()
    .reset_index(drop=True)
)
dim_companies = pd.DataFrame({
    "company_key": range(1, len(companies) + 1),
    "company_name": companies
})
company_map = dict(zip(dim_companies["company_name"], dim_companies["company_key"]))

# ---------------------------------------------------------------------------
# dim_locations
# ---------------------------------------------------------------------------
loc_cols = df[["city", "region", "country"]].fillna("Unknown")
locations = loc_cols.drop_duplicates().reset_index(drop=True)
locations.insert(0, "location_key", range(1, len(locations) + 1))
dim_locations = locations.rename(columns={"city": "city", "region": "region", "country": "country"})

loc_key_map = {
    (r.city, r.region, r.country): r.location_key
    for r in dim_locations.itertuples(index=False)
}

# ---------------------------------------------------------------------------
# fact_postings
# ---------------------------------------------------------------------------
fact = pd.DataFrame()
fact["posting_id"] = range(1, len(df) + 1)
fact["job_title"] = df["job_title"]
fact["company_key"] = df["company_name"].fillna("Unknown").map(company_map)
fact["location_key"] = list(
    df[["city", "region", "country"]].fillna("Unknown")
      .apply(lambda r: loc_key_map[(r.city, r.region, r.country)], axis=1)
)
fact["post_date"] = df["date"]
fact["hiring_status"] = df["hiring_status"]
fact["benefits_count"] = df["benefits_count"].fillna(0).astype(int)
fact["seniority_level"] = df["seniority_level"]
fact["job_function"] = df["job_function"]
fact["employment_type"] = df["employment_type"]
fact["industry"] = df["industry"]
fact["is_data_role"] = df["is_data_role"].astype(bool)

out = "linkedin-sql-analytics-project/datasets/csv-files"
dim_companies.to_csv(f"{out}/gold.dim_companies.csv", index=False)
dim_locations.to_csv(f"{out}/gold.dim_locations.csv", index=False)
fact.to_csv(f"{out}/gold.fact_postings.csv", index=False)

print("dim_companies:", dim_companies.shape)
print("dim_locations:", dim_locations.shape)
print("fact_postings:", fact.shape)
print(fact.head(3).to_string())
