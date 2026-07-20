{{ config(
    materialized='view'
) }}

SELECT

    tenure_years,

    COUNT(employee_id) AS employee_count,

    AVG(target_achievement_percentage)
        AS avg_target_achievement_percentage,

    AVG(total_sales_amount)
        AS avg_total_sales_amount,

    AVG(performance_rating)
        AS avg_performance_rating,

    SUM(orders_processed)
        AS total_orders_processed

FROM {{ ref('dim_employee') }}

GROUP BY tenure_years

ORDER BY tenure_years