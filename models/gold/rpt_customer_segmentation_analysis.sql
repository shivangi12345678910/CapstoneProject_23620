{{ config(
    materialized='view'
) }}

SELECT

    c.customer_segment,

    COUNT(DISTINCT c.customer_id) AS customer_count,

    COUNT(DISTINCT f.order_id) AS total_orders,

    SUM(f.total_sales_amount) AS total_sales_amount,

    SUM(f.profit_amount) AS total_profit_amount,

    AVG(f.total_sales_amount) AS average_order_value

FROM {{ ref('fact_sales') }} f

INNER JOIN {{ ref('dim_customer') }} c
    ON f.customer_key = c.customer_key

GROUP BY c.customer_segment

ORDER BY total_sales_amount DESC