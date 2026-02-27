{{ config(materialized='table') }}

select
    customer_id,
    as_of_date,

    -- Usage behaviour
    num_logins_30d,
    support_tickets_90d,
    last_login_days_ago,

    -- Financial behaviour
    cast(tenure_months as int) as tenure_months,
    cast(monthly_charges as double) as monthly_charges,
    cast(total_charges as double) as total_charges,

    -- Satisfaction metrics
    nps_score,
    cast(csat_score as int) as csat_score,

    -- ENGINEERED FEATURES (from intermediate model)
    login_frequency,
    tenure_bucket,
    satisfaction_tier,

    -- Active flag
    is_active,

    -- Target variable
    churn_next_30d

from {{ ref('int_customer_churn_features') }}
