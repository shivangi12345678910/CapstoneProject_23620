{{ config(
    materialized='view'
) }}

SELECT

    c.customer_segment,

    COUNT(DISTINCT f.order_id) AS total_orders,

    COUNT(DISTINCT c.customer_id) AS total_customers,

    SUM(f.total_sales_amount) AS total_sales_amount,

    AVG(f.total_sales_amount) AS avg_order_value,

    SUM(f.quantity_sold) AS total_quantity_sold

FROM {{ ref('fact_sales') }} f

INNER JOIN {{ ref('dim_customer') }} c
    ON f.customer_key = c.customer_key

GROUP BY c.customer_segment