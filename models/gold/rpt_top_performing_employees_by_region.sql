{{ config(
    materialized='view'
) }}

SELECT

    s.region,

    e.employee_id,

    e.full_name,

    e.standardized_role,

    COUNT(DISTINCT f.order_id) AS total_orders,

    SUM(f.total_sales_amount) AS total_sales_amount,

    SUM(f.profit_amount) AS total_profit_amount,

    SUM(f.quantity_sold) AS total_quantity_sold

FROM {{ ref('fact_sales') }} f

INNER JOIN {{ ref('dim_employee') }} e
    ON f.employee_key = e.employee_key

INNER JOIN {{ ref('dim_store') }} s
    ON f.store_key = s.store_key

GROUP BY

    s.region,
    e.employee_id,
    e.full_name,
    e.standardized_role

ORDER BY
    total_sales_amount DESC