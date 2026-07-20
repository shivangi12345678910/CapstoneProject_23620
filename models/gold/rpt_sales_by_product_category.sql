{{ config(
    materialized='view'
) }}

SELECT

    p.category,
    p.subcategory,

    SUM(f.total_sales_amount) AS total_sales_amount,

    SUM(f.cost_amount) AS total_cost_amount,

    SUM(f.profit_amount) AS total_profit_amount,

    SUM(f.quantity_sold) AS total_quantity_sold

FROM {{ ref('fact_sales') }} f

INNER JOIN {{ ref('dim_product') }} p
    ON f.product_key = p.product_key

GROUP BY p.category, p.subcategory