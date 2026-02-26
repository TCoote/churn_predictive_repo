{{ config(materialized='table') }}

with ranked_customers as (
    select
        customer_id,
        customer_name,
        email,
        segment,
        region,
        product_tier,
        row_number() over (partition by customer_id order by as_of_date desc) as recency_rank
    from {{ ref('stg_churn') }}
)

select
    customer_id,
    customer_name,
    email,
    segment,
    region,
    product_tier
from ranked_customers
where recency_rank = 1
