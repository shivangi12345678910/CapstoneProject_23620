{{ config(
    materialized='view'
) }}

SELECT

    p.product_name,

    p.category,

    SUM(f.quantity_sold) AS total_quantity_sold,

    SUM(f.total_sales_amount) AS total_sales_amount,

    SUM(f.profit_amount) AS total_profit_amount

FROM {{ ref('fact_sales') }} f

INNER JOIN {{ ref('dim_product') }} p
    ON f.product_key = p.product_key

GROUP BY

    p.product_name,

    p.category

ORDER BY total_sales_amount DESC