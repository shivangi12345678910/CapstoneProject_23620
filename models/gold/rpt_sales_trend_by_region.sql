{{ config(
    materialized='view'
) }}

SELECT

    d.year,

    d.month,

    s.region,

    SUM(f.total_sales_amount) AS total_sales_amount,

    SUM(f.profit_amount) AS total_profit_amount,

    SUM(f.quantity_sold) AS total_quantity_sold

FROM {{ ref('fact_sales') }} f

INNER JOIN {{ ref('dim_store') }} s
    ON f.store_key = s.store_key

INNER JOIN {{ ref('dim_date') }} d
    ON f.date_key = d.date_key

GROUP BY

    d.year,

    d.month,

    s.region