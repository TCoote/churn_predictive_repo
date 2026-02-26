{{ config(materialized='table') }}

select DISTINCT 
    as_of_date,

    year(as_of_date) as year,
    month(as_of_date) as month_num,
    date_format(as_of_date, 'MMMM') as month_name,
    quarter(as_of_date) as quarter,

    date_trunc('month', as_of_date) as month_start,
    last_day(as_of_date) as month_end

from {{ ref('stg_churn') }}