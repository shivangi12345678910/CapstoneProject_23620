{{ config(
    materialized='table'
) }}

SELECT

    {{ dbt_utils.generate_surrogate_key(
        ['store_id']
    ) }} AS store_key,

    store_id,

    store_name,

    store_type,

    region,

    manager_id,

    email,

    phone_number,

    street,
    city,
    state,
    country,
    zip_code,

    employee_count,

    size_sq_ft,

    store_size_category,

    store_age_years,

    revenue_per_sq_ft,

    employee_efficiency,

    performance_issue_flag,

    opening_date

FROM {{ ref('stg_store') }}