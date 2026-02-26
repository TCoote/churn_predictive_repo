# Churn Prediction dbt Pipeline - Project Summary

## Executive Overview

This project builds a production-ready data pipeline for customer churn prediction using dbt and Databricks. The pipeline transforms raw CRM data into a clean, validated dataset structured for machine learning model training.

**Status:** ✅ Data Preparation Complete | 🔄 Feature Engineering In Progress

---

## What We've Accomplished (Phase 1: Data Preparation)

### ✅ Architecture Built
- **Medallion Architecture** implemented with 3 distinct layers
  - Bronze: Raw CRM data (600 customer records)
  - Silver: Cleaned & standardized data (1 view)
  - Gold: Business-ready star schema (3 tables)

### ✅ 4 Data Models Created
1. **stg_churn** (Silver Layer - VIEW)
   - 600 rows of cleaned customer metrics
   - Handles missing values with try_cast()
   - Standardizes text, dates, and types
   - Ready for dimension & fact table creation

2. **dim_customer** (Gold Layer - TABLE)
   - 227 unique customers with latest attributes
   - One row per customer
   - Uses ROW_NUMBER() for proper deduplication
   - Attributes: name, email, segment, region, tier

3. **dim_date** (Gold Layer - TABLE)
   - 3 date records with temporal breakdowns
   - Columns: year, month_num, month_name, quarter
   - Supports time-based filtering and grouping
   - month_num validated 1-12

4. **fct_customer_month** (Gold Layer - TABLE)
   - 600 metric records (multiple rows per customer)
   - All historical months preserved for trend analysis
   - Combines behavioral, financial, and satisfaction metrics
   - Ready for ML model training

### ✅ 25 Data Quality Tests Implemented

**By Test Type:**
- **NOT NULL (13 tests)** - Critical fields always populated
- **UNIQUE (3 tests)** - No duplicates in dimension keys
- **ACCEPTED VALUES (4 tests)** - Valid value ranges (e.g., month 1-12)
- **RELATIONSHIPS (5 tests)** - Foreign key integrity, no orphans
- **FRESHNESS (1 test)** - Source data < 24h old

**Test Results:** 25/25 PASSED ✅

### ✅ Data Quality Improvements
- try_cast() handles "n/a" and bad values gracefully
- ROW_NUMBER() with PARTITION BY deduplicates properly
- Text normalization (UPPER, TRIM) standardizes formats
- Boolean conversion for consistency
- Date parsing and standardization

### ✅ Documentation Complete
- **docs.md** - Project overview and common queries
- **schema.yml** - Column descriptions, ownership, tests
- **LEARNING_SUMMARY.md** - Comprehensive learning guide (12 sections)
- **Meta fields** - Owner, tier, entity type, sensitivity tracking
- **Interactive docs** - Generated with `dbt docs serve`

### ✅ Code Quality & Version Control
- Python wrapper (dbt_wrapper.py) for CLI access
- Clean dbt_project.yml configuration
- Proper schema management (empty schema string in profiles)
- Git repository initialized and pushed to GitHub
- All 26 files committed with detailed messages

---

## Current State: ML-Ready Data

### What We Have Now
```
Fact Table (fct_customer_month):
├─ 600 rows (customer metrics by month)
├─ All raw features:
│  ├─ Behavioral: num_logins_30d, support_tickets_90d, last_login_days_ago
│  ├─ Financial: tenure_months, monthly_charges, total_charges
│  ├─ Satisfaction: nps_score, csat_score
│  └─ Status: is_active, churn_next_30d (TARGET)
├─ All historical months (Jan-Apr 2024)
├─ Clean data with no nulls in critical fields
├─ Proper data types (INT, DECIMAL, BOOLEAN, DATE)
└─ ✅ Ready for ML training
```

### What ML Model Can Learn
- Customers with low tenure (new) churn more
- Decreasing logins predict churn
- Declining NPS predicts churn
- Support tickets correlate with satisfaction
- High monthly charges alone don't prevent churn

---

## What We're Doing Next (Phase 2: Feature Engineering)

### 🔄 Feature Engineering (In Progress)

Feature engineering = Creating derived features by combining raw data with business logic

#### **Tier 1: Simple Derived Features** (Next)
```sql
-- Engagement Features
login_frequency = num_logins_30d / 30  -- Daily logins
days_since_login_ratio = last_login_days_ago / tenure_months  -- Recency ratio
support_intensity = support_tickets_90d / 3  -- Tickets per month

-- Financial Features
monthly_to_total_ratio = monthly_charges / total_charges  -- Avg monthly spend
tenure_months_binned = CASE 
  WHEN tenure_months < 3 THEN 'new'
  WHEN tenure_months < 12 THEN 'active'
  ELSE 'loyal' END

-- Satisfaction Features
satisfaction_gap = nps_score - csat_score  -- NPS vs CSAT mismatch
satisfaction_tier = CASE
  WHEN nps_score >= 9 THEN 'promoter'
  WHEN nps_score >= 7 THEN 'passive'
  ELSE 'detractor' END
```

**Why these?**
- Ratios scale values (login frequency normalized by days)
- Binning creates categorical features (new vs loyal)
- Domain logic applies business knowledge (NPS < 7 = at risk)

#### **Tier 2: Interaction Features** (Following)
```sql
-- How do features interact?
tenure_x_engagement = tenure_months * login_frequency
  -- Loyal customers who stop engaging = churn risk

price_sensitivity = monthly_charges * (nps_score < 7)
  -- Expensive customers with low NPS = high risk

engagement_satisfaction = login_frequency * nps_score
  -- Low engagement + low satisfaction = definite churn
```

#### **Tier 3: Lag Features** (Advanced)
```sql
-- Previous month comparisons
login_change_mom = num_logins_30d - LAG(num_logins_30d, 1) OVER (PARTITION BY customer_id ORDER BY as_of_date)
  -- Is engagement going UP or DOWN?

nps_change_mom = nps_score - LAG(nps_score, 1) OVER (PARTITION BY customer_id ORDER BY as_of_date)
  -- Is satisfaction improving or declining?

churn_momentum = SUM(churn_next_30d) OVER (PARTITION BY customer_id ORDER BY as_of_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
  -- How many months in a row showing churn signal?
```

**Why lag features?**
- Trends matter more than snapshots
- "Logins dropped from 14→8→3" is stronger signal than "3 logins now"
- ML learns velocity, not just position

---

## Implementation Roadmap

### Phase 1: ✅ COMPLETE
- [x] Data pipeline architecture
- [x] Model creation (4 models)
- [x] Data quality tests (25 tests)
- [x] Documentation
- [x] GitHub repository setup

### Phase 2: 🔄 IN PROGRESS (Feature Engineering)
- [ ] Create intermediate model `int_customer_churn_features.sql`
- [ ] Implement Tier 1 derived features
- [ ] Add tests for new features
- [ ] Document feature definitions
- [ ] Validate feature distributions

### Phase 3: 📋 PLANNED (ML Model)
- [ ] Data scientist exploratory analysis
- [ ] Feature selection & importance ranking
- [ ] Model training (Logistic Regression, Random Forest, XGBoost)
- [ ] Model evaluation (accuracy, recall, F1 score)
- [ ] Model deployment
- [ ] Prediction pipeline setup

### Phase 4: 📋 PLANNED (Actions & Monitoring)
- [ ] Create intervention logic ("If risk > 80%, prioritize for retention")
- [ ] Set up prediction refreshes (daily/weekly)
- [ ] Dashboard for churn risk scores
- [ ] Monitor model performance over time
- [ ] Retrain model quarterly with new data

---

## Technical Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Data Warehouse** | Databricks | Cloud-based SQL analytics |
| **Data Orchestration** | dbt 1.11.6 | Data transformation & testing |
| **Language** | SQL | Data queries & transformations |
| **Python** | 3.13.12 | Wrapper & environment |
| **Version Control** | Git/GitHub | Code management |
| **Adapter** | dbt-databricks 1.11.5 | Databricks connectivity |

---

## Data Lineage

```
Bronze Layer (Raw)
    churn_raw (600 rows)
         ↓
Silver Layer (Cleaned)
    stg_churn (600 rows, 1 view)
         ↓
Gold Layer (Analysis Ready)
    ├─ dim_customer (227 rows)
    ├─ dim_date (3 rows)
    └─ fct_customer_month (600 rows)
         ↓
    [ML MODEL TRAINING]
         ↓
    [CHURN PREDICTIONS]
         ↓
    [BUSINESS ACTIONS]
```

---

## Key Metrics

| Metric | Value |
|--------|-------|
| Total Models | 4 (1 view, 3 tables) |
| Data Quality Tests | 25 (100% passing) |
| Raw Records | 600 customers |
| Unique Customers | 227 |
| Historical Months | 4 (Jan-Apr 2024) |
| Fact Table Rows | 600 (metrics by month) |
| Test Pass Rate | 100% |
| Documentation Coverage | 100% (all columns) |

---

## How to Use

### Run Full Pipeline
```bash
cd c:\dev\churn_predictive_repo\churn_predictive_dbt

# Build all models
python dbt_wrapper.py run

# Run all tests
python dbt_wrapper.py test

# Generate interactive documentation
python dbt_wrapper.py docs generate
python dbt_wrapper.py docs serve
```

### View Specific Model
```bash
# Test a specific model
python dbt_wrapper.py test --select dim_customer

# Run a specific model
python dbt_wrapper.py run --select stg_churn
```

### Quick Launch
```bash
# From any directory
c:\dev\churn_predictive_repo\start_dbt.cmd
```

---

## Next Steps for Data Scientists

### 1. Explore the Data
```sql
-- Sample customer journey
SELECT 
  customer_id,
  as_of_date,
  tenure_months,
  num_logins_30d,
  nps_score,
  churn_next_30d
FROM demosuitedev-processed.gold.fct_customer_month
WHERE customer_id IN (555, 556, 557)
ORDER BY customer_id, as_of_date;
```

### 2. Identify Patterns
- Which metrics correlate strongest with churn?
- What's the churn rate by segment/region?
- How do logins vs NPS relate to churn?

### 3. Feature Engineering
- Transform raw features into business logic features
- Create lag features to capture trends
- Interaction features for non-linear relationships

### 4. Model Development
- Train baseline model on raw features
- Iterate with engineered features
- Evaluate multiple algorithms
- Select best performer

---

## Knowledge Transfer

This project demonstrates:
- ✅ Medallion architecture patterns
- ✅ Star schema database design
- ✅ Data quality testing best practices
- ✅ dbt best practices (models, tests, documentation)
- ✅ Databricks data warehouse integration
- ✅ Git version control workflows
- ✅ Production-ready data pipeline practices

---

## Contact & Ownership

- **Owner**: Analytics Team
- **Data Preparation**: Complete ✅
- **Feature Engineering**: In Progress 🔄
- **ML Modeling**: Planned 📋
- **Last Updated**: 2026-02-26

---

## References

- [dbt Documentation](https://docs.getdbt.com)
- [Databricks SQL Reference](https://docs.databricks.com/sql)
- [LEARNING_SUMMARY.md](./churn_predictive_dbt/LEARNING_SUMMARY.md) - Complete learning guide
- [Project Documentation](./churn_predictive_dbt/models/docs.md) - Data & queries guide
- [GitHub Repository](https://github.com/TCoote/churn_predictive_repo)

---

## Success Criteria

| Criterion | Status |
|-----------|--------|
| Data pipeline built | ✅ Complete |
| Models created (4) | ✅ Complete |
| Tests implemented (25) | ✅ Complete |
| 100% test pass rate | ✅ Achieved |
| Documentation complete | ✅ Complete |
| Git repository setup | ✅ Complete |
| Ready for ML training | ✅ Ready |
| Feature engineering | 🔄 In Progress |
| ML model training | 📋 Next Phase |
