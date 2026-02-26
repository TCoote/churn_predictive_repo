Initial churn prediction dbt pipeline - Production Ready
FEATURES:
- Medallion Architecture: Bronze (raw) -> Silver (clean) -> Gold (analysis)
- 4 Data Models: stg_churn (view), dim_customer, dim_date, fct_customer_month
- 25 Comprehensive Data Quality Tests
- Interactive Documentation with Data Lineage

MODELS:
- Silver Layer: stg_churn (cleaned staging view with try_cast for bad data)
- Gold Layer:
  * dim_customer (227 unique customers, latest attributes)
  * dim_date (date dimension with year/month/quarter)
  * fct_customer_month (600 records with customer metrics)

TESTING:
- NOT NULL constraints on critical fields
- UNIQUE key validation for dimensions
- ACCEPTED VALUES for enum fields
- RELATIONSHIP integrity across star schema
- SOURCE FRESHNESS monitoring (24h/48h thresholds)

DATA QUALITY IMPROVEMENTS:
- try_cast() in silver layer handles 'n/a' values gracefully
- ROW_NUMBER() window function for proper dimension deduplication
- Proper type casting and text normalization
- Boolean conversion for has_autopay field

DOCUMENTATION:
- docs.md: Complete project guide with common queries
- schema.yml: Column-level documentation with ownership
- LEARNING_SUMMARY.md: 12-section guide for dbt mastery
- Meta fields: owner, tier, entity, materialization, sensitivity

DATABRICKS INTEGRATION:
- Catalog: demosuitedev-processed
- Schemas: bronze, silver, gold
- Connected via Databricks HTTP adapter

TOOLS:
- dbt_wrapper.py: Python CLI wrapper (no .exe needed)
- start_dbt.cmd: Quick launch script for development
- profiles.yml: Configured for Databricks connectivity

LEARNING OUTCOMES:
1. Medallion architecture patterns
2. Star schema design
3. Data quality testing strategy
4. Documentation-driven development
5. Window functions vs aggregations
6. Type casting best practices
7. dbt command workflows
8. Interactive documentation generation
