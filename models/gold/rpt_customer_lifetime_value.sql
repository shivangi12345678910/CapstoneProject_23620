{{ config(
    materialized='view'
) }}

SELECT

    c.customer_id,

    c.full_name,

    c.customer_segment,

    COUNT(DISTINCT f.order_id) AS total_orders,

    SUM(f.total_sales_amount) AS customer_lifetime_value,

    SUM(f.profit_amount) AS lifetime_profit

FROM {{ ref('fact_sales') }} f

INNER JOIN {{ ref('dim_customer') }} c
    ON f.customer_key = c.customer_key

GROUP BY

    c.customer_id,
    c.full_name,
    c.customer_segment