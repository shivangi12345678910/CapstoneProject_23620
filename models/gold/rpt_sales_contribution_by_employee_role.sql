{{ config(
    materialized='view'
) }}

SELECT

    e.standardized_role,

    COUNT(DISTINCT f.order_id) AS total_orders,

    SUM(f.quantity_sold) AS total_quantity_sold,

    SUM(f.total_sales_amount) AS total_sales_amount,

    SUM(f.profit_amount) AS total_profit_amount

FROM {{ ref('fact_sales') }} f

INNER JOIN {{ ref('dim_employee') }} e
    ON f.employee_key = e.employee_key

GROUP BY e.standardized_role

ORDER BY total_sales_amount DESC