{{ config(
    materialized='view'
) }}

WITH customer_orders AS (

    SELECT

        c.customer_id,

        COUNT(DISTINCT f.order_id) AS order_count

    FROM {{ ref('fact_sales') }} f

    INNER JOIN {{ ref('dim_customer') }} c
        ON f.customer_key = c.customer_key

    GROUP BY c.customer_id

)

SELECT

    ROUND(
        (
            COUNT_IF(order_count > 1) * 100.0
        ) / COUNT(*),
        2
    ) AS repeat_purchase_rate

FROM customer_orders