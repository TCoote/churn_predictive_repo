# Churn Prediction dbt Documentation

## Project Overview

This dbt project transforms raw customer churn data into clean, analyzed datasets for predictive modeling and business intelligence. It follows the **Medallion Architecture** with three layers:

- **Bronze**: Raw data from source systems
- **Silver**: Cleaned and standardized data
- **Gold**: Business-ready fact and dimension tables

## Data Layers Explained

### Bronze Layer
Raw data imported directly from the source system with minimal transformation. No data quality checks or type casting.

**Contains:**
- `churn_raw` - 600 customer records with churn labels

### Silver Layer
Cleaned, standardized data with proper types, null handling, and validation. This is where data quality gates are enforced.

**Contains:**
- `stg_churn` - Cleaned staging table (VIEW)

**Transformations Applied:**
- Type casting with `try_cast()` for missing values
- Text normalization (UPPER, TRIM)
- Boolean conversion (has_autopay)
- Date standardization

### Gold Layer
Business-ready tables optimized for analysis and reporting. Uses star schema design.

**Contains:**
- `dim_customer` - Customer dimension (latest attributes)
- `dim_date` - Date dimension (for time analysis)
- `fct_customer_month` - Fact table (customer metrics)

## Data Quality Strategy

All models use dbt tests to validate:

1. **NOT NULL** - Critical fields are never empty
2. **UNIQUE** - Primary keys have no duplicates
3. **ACCEPTED VALUES** - Enums match expected values
4. **RELATIONSHIPS** - Foreign keys reference valid records
5. **FRESHNESS** - Source data within expected age

## How to Use

### Run the full pipeline:
```bash
dbt run      # Build all models
dbt test     # Run all tests
dbt docs generate  # Create documentation
dbt docs serve     # View interactive docs
```

### Run specific model:
```bash
dbt run --select stg_churn
dbt test --select dim_customer
```

## Column Descriptions

### Customer Metrics

**tenure_months** - How long customer has been with the company (months)
**monthly_charges** - Monthly subscription cost ($)
**total_charges** - Lifetime subscription value ($)

### Behavioral Metrics

**num_logins_30d** - Number of product logins in last 30 days
**support_tickets_90d** - Number of support tickets filed in last 90 days
**last_login_days_ago** - Days since last login (how active is customer)

### Satisfaction Metrics

**nps_score** - Net Promoter Score (-100 to 100)
**csat_score** - Customer Satisfaction Score (0-5)

### Target Variable

**churn_next_30d** - Did customer churn in next 30 days? (0=No, 1=Yes)

## Common Queries

### Customer Metrics by Region:
```sql
SELECT 
  region,
  COUNT(DISTINCT customer_id) as num_customers,
  AVG(tenure_months) as avg_tenure,
  SUM(CASE WHEN churn_next_30d = 1 THEN 1 ELSE 0 END) / COUNT(*) as churn_rate
FROM demosuitedev-processed.gold.fct_customer_month
GROUP BY region
```

### Churn Risk by Segment:
```sql
SELECT 
  dc.segment,
  COUNT(DISTINCT fc.customer_id) as customers,
  SUM(CASE WHEN fc.churn_next_30d = 1 THEN 1 ELSE 0 END) as churned,
  ROUND(100 * SUM(CASE WHEN fc.churn_next_30d = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) as churn_pct
FROM demosuitedev-processed.gold.fct_customer_month fc
JOIN demosuitedev-processed.gold.dim_customer dc ON fc.customer_id = dc.customer_id
GROUP BY dc.segment
ORDER BY churn_pct DESC
```

## Lineage & Dependencies

The dbt DAG (Directed Acyclic Graph) ensures models build in the correct order:

```
bronze.churn_raw (SOURCE)
     ↓
stg_churn (STAGING - Silver)
     ↓
  ├─→ dim_customer (Dimension - Gold)
  ├─→ dim_date (Dimension - Gold)
  └─→ fct_customer_month (Fact - Gold)
        ↓
   [BI Tools / Analytics]
```

## Contact & Ownership

- **Analytics Team**: Owns gold layer models
- **Data Engineering**: Owns bronze layer ingestion
- For questions: analytics_team@company.com
