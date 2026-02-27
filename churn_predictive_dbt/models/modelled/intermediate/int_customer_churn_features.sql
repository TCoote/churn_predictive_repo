{{
  config(
    materialized='view',
    tags=['intermediate']
  )
}}

{#
  Intermediate Model: Customer Churn Features
  
  Purpose: Engineer derived features for churn prediction
  Tier 1 features: Simple transformations and aggregations
  
  Sits between: silver.stg_churn → gold.fct_customer_month
  
  Features created:
  - login_frequency: Logins per day (num_logins_30d / 30)
  - tenure_bucket: Customer tenure grouped into lifecycle stages
  - satisfaction_tier: CSAT score bucketed into tiers
#}

with customer_features as (
  select
    customer_id,
    as_of_date,
    
    -- FEATURE 1: Login Frequency (logins per day)
    round(num_logins_30d / 30.0, 2) as login_frequency,
    
    -- FEATURE 2: Tenure Bucket (customer lifecycle stage)
    case
      when tenure_months < 6 then 'new'
      when tenure_months >= 6 and tenure_months < 12 then 'growing'
      when tenure_months >= 12 and tenure_months < 24 then 'established'
      else 'loyal'
    end as tenure_bucket,
    
    -- FEATURE 3: Satisfaction Tier (customer satisfaction level)
    case
      when csat_score >= 8 then 'high'
      when csat_score >= 6 and csat_score < 8 then 'medium'
      when csat_score is not null then 'low'
      else 'unknown'
    end as satisfaction_tier,
    
    -- Pass through all raw metrics for downstream use
    num_logins_30d,
    support_tickets_90d,
    last_login_days_ago,
    tenure_months,
    monthly_charges,
    total_charges,
    nps_score,
    csat_score,
    is_active,
    churn_next_30d
    
  from {{ ref('stg_churn') }}
)

select * from customer_features
