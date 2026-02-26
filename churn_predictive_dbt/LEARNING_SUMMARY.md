# dbt Learning & Implementation Summary

## Overview
This document summarizes the complete dbt data pipeline built for churn prediction, including best practices learned and architectural decisions made.

---

## 1. Architecture: Medallion Pattern

We implemented a 3-layer data architecture:

### Bronze Layer
- **Definition**: Raw data, no transformations
- **Schema**: `bronze`
- **Tables**: `churn_raw` (600 customer records)
- **Key Feature**: Freshness checks (warn after 24h, error after 48h)

### Silver Layer
- **Definition**: Cleaned, standardized data
- **Schema**: `silver`
- **Tables**: `stg_churn` (view)
- **Transformations**:
  - Type casting with `try_cast()` to handle bad data
  - Text normalization (UPPER, TRIM)
  - Boolean conversion
  - Date standardization
- **Key Learning**: Data quality fixes happen HERE, not in gold

### Gold Layer
- **Definition**: Business-ready tables (star schema)
- **Schema**: `gold`
- **Tables**:
  - `dim_customer` - Customer dimension (227 unique customers)
  - `dim_date` - Date dimension (3 dates in demo)
  - `fct_customer_month` - Fact table (600 metrics)

---

## 2. Data Quality & Testing

### Test Types Implemented

| Test Type | Example | Purpose |
|-----------|---------|---------|
| **NOT NULL** | customer_id never null | Ensure completeness |
| **UNIQUE** | customer_id unique in dim | No duplicates in dimensions |
| **ACCEPTED VALUES** | churn ∈ {0,1} | Validate enums |
| **RELATIONSHIPS** | fct.customer_id → dim.customer_id | Referential integrity |
| **FRESHNESS** | source data < 24h old | Data staleness detection |

**Total Tests**: 25 tests across all models

### Key Learning: Where to Fix Data
❌ DON'T: Fix in gold layer with `try_cast()`
✅ DO: Fix in silver layer with proper null handling

---

## 3. Best Practices Applied

### 1. Window Functions Over Aggregations
**Problem**: `MAX(customer_name)` picks alphabetically, not logically
**Solution**: Use `ROW_NUMBER()` with `PARTITION BY` and `ORDER BY`

```sql
row_number() over (partition by customer_id order by as_of_date desc) as recency_rank
```

### 2. Proper Type Casting in Silver
**Problem**: Source data has 'n/a' values for numeric fields
**Solution**: Use `try_cast()` to convert bad values to NULL

```sql
try_cast(tenure_months as int) as tenure_months  -- Returns NULL for 'n/a'
```

### 3. Documentation Driven Development
Created:
- `docs.md` - Project overview and guidance
- `schema.yml` - Column-level documentation
- Meta fields for owner, tier, sensitivity

### 4. Clean Configuration
- Removed unused seed configurations
- Set schema to empty string in profiles
- Proper schema organization (silver vs gold)

---

## 4. dbt Commands & Workflow

### Core Commands
```bash
dbt run        # Build all models
dbt test       # Run all data quality tests
dbt clean      # Remove compiled artifacts
dbt parse      # Validate project structure
dbt docs generate  # Create documentation
dbt docs serve     # View interactive docs at localhost:8000
```

### Execution Flow
```
1. dbt run
   ├─ Read sources
   ├─ Build stg_churn (SILVER)
   ├─ Build dim_customer (GOLD)
   ├─ Build dim_date (GOLD)
   └─ Build fct_customer_month (GOLD)

2. dbt test
   ├─ Test stg_churn (not null, accepted values)
   ├─ Test dim_customer (unique, relationships)
   ├─ Test dim_date (unique, value ranges)
   └─ Test fct_customer_month (relationships, constraints)
```

---

## 5. Product Metrics Built

### Behavioral Metrics
- `num_logins_30d` - Product engagement
- `support_tickets_90d` - Support demand
- `last_login_days_ago` - Recency

### Financial Metrics
- `tenure_months` - Customer lifetime
- `monthly_charges` - Revenue per customer
- `total_charges` - Lifetime value

### Satisfaction Metrics
- `nps_score` - Net Promoter Score
- `csat_score` - Customer satisfaction

### Target Variable
- `churn_next_30d` - Whether customer churned (0/1)

---

## 6. Databricks Integration

### Connection Details
- **Catalog**: `demosuitedev-processed`
- **Schemas**:
  - `bronze` - Raw data
  - `silver` - Cleaned staging
  - `gold` - Business tables
- **Adapter**: Databricks with HTTP connectivity

### Data Validation SQL
```sql
-- Check row counts
SELECT 'stg_churn' as model, COUNT(*) as row_count FROM dbt.silver.stg_churn
UNION ALL
SELECT 'dim_customer' as model, COUNT(*) as row_count FROM dbt.gold.dim_customer
UNION ALL
SELECT 'fct_customer_month' as model, COUNT(*) as row_count FROM dbt.gold.fct_customer_month;
```

---

## 7. Lessons Learned

### ✅ What Worked Well
1. Medallion architecture provides clear separation of concerns
2. Try_cast in silver layer catches data issues early
3. Window functions more reliable than aggregations for dimensions
4. Test coverage prevents bad data in gold layer
5. Documentation essential for team understanding

### ⚠️ Challenges Overcome
1. **Schema Prefix Issue**: Fixed by setting schema to empty string in profiles.yml
2. **Type Casting Errors**: Solved with try_cast() in silver layer
3. **Dimension Aggregation**: Improved with ROW_NUMBER()
4. **Python 3.13 Compatibility**: Fixed with setuptools package

---

## 8. Next Steps for Advanced Learning

### Level 2: Intermediate Models
- Create `int_*` models between silver and gold
- Example: `int_customer_churn_features`

### Level 3: Macros & Jinja
- Write reusable SQL code
- Dynamic model generation
- Custom validation macros

### Level 4: Advanced Testing
- dbt_expectations package
- Custom SQL tests
- Row count assertions

### Level 5: Performance
- Incremental models
- Conditional transformations
- Benchmark analysis

### Level 6: CI/CD & dbt Cloud
- Automated testing on PR
- Scheduled production runs
- Slack notifications

---

## 9. File Structure

```
churn_predictive_repo/
├── churn_predictive_dbt/
│   ├── dbt_project.yml          # Main project config
│   ├── dbt_wrapper.py           # Python wrapper for dbt CLI
│   ├── start_dbt.cmd            # Quick launch script
│   │
│   ├── models/
│   │   ├── docs.md              # Project documentation
│   │   ├── schema.yml           # Model definitions & tests
│   │   ├── sources.yml          # Source definitions
│   │   │
│   │   ├── processed/
│   │   │   └── staging/
│   │   │       └── stg_churn.sql (SILVER - Cleaned data)
│   │   │
│   │   └── modelled/
│   │       ├── dim_customer.sql (GOLD - Dimension)
│   │       ├── dim_date.sql     (GOLD - Dimension)
│   │       └── fct_customer_month.sql (GOLD - Fact)
│   │
│   ├── tests/                   # Custom tests
│   ├── macros/                  # Reusable SQL code
│   ├── target/                  # Compiled artifacts
│   └── .venv/                   # Python virtual environment
│
└── start_dbt.cmd                # Global launch script
```

---

## 10. Key Metrics & Results

| Metric | Value |
|--------|-------|
| Total Models | 4 (1 view + 3 tables) |
| Total Tests | 25 data quality tests |
| Source Records | 600 customers |
| Unique Customers | 227 (deduplicated in dim) |
| Date Records | 3 (demo data) |
| Fact Table Records | 600 (metrics by customer-month) |
| Test Pass Rate | 100% |
| Documentation Coverage | 100% (all columns documented) |

---

## 11. Running the Pipeline

### For Development:
```cmd
cd c:\dev\churn_predictive_repo\churn_predictive_dbt

# Build models
python dbt_wrapper.py run

# Test data quality
python dbt_wrapper.py test

# View interactive documentation
python dbt_wrapper.py docs generate
python dbt_wrapper.py docs serve
```

### For Production (Future):
```bash
# Would use dbt Cloud with:
# - Scheduled runs every night
# - Slack alerts on test failures
# - Version control integration
# - dbt artifact storage
```

---

## 12. Success Criteria Met

✅ Properly structured medallion architecture
✅ All source data cleaned in silver layer
✅ Comprehensive test coverage (25 tests)
✅ Documented models and columns
✅ Freshness monitoring on sources
✅ Python wrapper for .exe-less access
✅ Databricks integration working
✅ Interactive documentation generated
✅ Git ready to share with team

---

## Contact & Questions

For questions on this implementation:
- Review the interactive docs: `python dbt_wrapper.py docs serve`
- Check `docs.md` for project overview
- Review individual model SQL files for logic
- Run `dbt test --select <model_name>` for debugging

**Owner**: Analytics Team
**Last Updated**: 2026-02-26
