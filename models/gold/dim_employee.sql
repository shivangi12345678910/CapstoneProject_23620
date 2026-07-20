{{ config(
    materialized='table'
) }}

SELECT

    {{ dbt_utils.generate_surrogate_key(
        ['employee_id']
    ) }} AS employee_key,

    employee_id,

    full_name,

    department,

    standardized_role,

    employment_status,

    education,

    work_location,

    email,

    phone,

    employee_age,

    tenure_years,

    performance_rating,

    target_achievement_percentage,

    orders_processed,

    total_sales_amount,

    manager_id,

    country,
    state,
    city

FROM {{ ref('stg_employee') }}