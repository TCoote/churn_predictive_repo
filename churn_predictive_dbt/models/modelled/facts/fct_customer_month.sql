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

    -- Active flag
    is_active,

    -- Target variable
    churn_next_30d

from {{ ref('stg_churn') }}
