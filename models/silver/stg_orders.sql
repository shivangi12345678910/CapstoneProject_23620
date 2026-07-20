{{ config(
    materialized='table',
    schema='SILVER'
) }}

WITH order_items_flat AS (

    SELECT

        bo.order_id,

        item.value:product_id::STRING AS product_id,

        item.value:quantity::NUMBER AS quantity,

        item.value:unit_price::NUMBER(18,2) AS unit_price,

        item.value:cost_price::NUMBER(18,2) AS cost_price,

        item.value:discount_amount::NUMBER(18,2) AS item_discount_pct

    FROM {{ ref('base_orders') }} bo,

    LATERAL FLATTEN(
        INPUT => PARSE_JSON(bo.order_items)
    ) item

),

order_item_agg AS (

    SELECT

        order_id,

        COUNT(product_id) AS total_items,

        SUM(quantity) AS total_quantity,

        SUM(
            quantity * unit_price
        ) AS total_item_revenue,

        SUM(
            quantity * cost_price
        ) AS total_item_cost,

        SUM(item_discount_pct) AS total_item_discount,

        SUM(
            quantity
            * unit_price
            * (
                1 - (item_discount_pct / 100)
            )
        ) AS line_revenue,

        SUM(
            quantity * cost_price
        ) AS line_cost

    FROM order_items_flat

    GROUP BY order_id

),

current_orders AS (

    SELECT

        order_id,

        customer_id,

        employee_id,

        store_id,

        campaign_id,

        UPPER(
            TRIM(
                COALESCE(order_status,'UNKNOWN')
            )
        ) AS order_status,

        UPPER(
            TRIM(
                COALESCE(order_source,'UNKNOWN')
            )
        ) AS order_source,

        INITCAP(
            TRIM(
                COALESCE(payment_method,'Unknown')
            )
        ) AS payment_method,

        INITCAP(
            TRIM(
                COALESCE(shipping_method,'Unknown')
            )
        ) AS shipping_method,

        total_amount,

        discount_amount,

        shipping_cost,

        tax_amount,

        order_date,

        shipping_date,

        delivery_date,

        estimated_delivery_date,

        created_at,

        billing_address,

        shipping_address,

        order_items,

        _LOADED_AT,

        _BATCH_ID

    FROM {{ ref('base_orders') }}

)

SELECT

    o.order_id,

    o.customer_id,

    o.employee_id,

    o.store_id,

    o.campaign_id,

    o.order_status,

    o.order_source,

    o.payment_method,

    o.shipping_method,

    o.total_amount,

    o.discount_amount,

    o.shipping_cost,

    o.tax_amount,

    o.order_date,

    o.shipping_date,

    o.delivery_date,

    o.estimated_delivery_date,

    o.created_at,

    oi.total_items,

    oi.total_quantity,

    oi.total_item_revenue,

    oi.total_item_cost,

    oi.total_item_discount,

    o.order_date AS order_date_key,

    WEEK(o.order_date) AS order_week,

    MONTH(o.order_date) AS order_month,

    QUARTER(o.order_date) AS order_quarter,

    YEAR(o.order_date) AS order_year,

    DATE_PART(
        HOUR,
        o.created_at
    ) AS order_hour,

    CASE

        WHEN DATE_PART(HOUR,o.created_at) >= 5
         AND DATE_PART(HOUR,o.created_at) < 12

        THEN 'Morning'

        WHEN DATE_PART(HOUR,o.created_at) >= 12
         AND DATE_PART(HOUR,o.created_at) < 17

        THEN 'Afternoon'

        WHEN DATE_PART(HOUR,o.created_at) >= 17
         AND DATE_PART(HOUR,o.created_at) < 22

        THEN 'Evening'

        ELSE 'Night'

    END AS order_time_of_day,

    DATEDIFF(
        DAY,
        o.order_date,
        o.shipping_date
    ) AS processing_days,

    DATEDIFF(
        DAY,
        o.shipping_date,
        o.delivery_date
    ) AS shipping_days,

    CASE

        WHEN o.delivery_date IS NOT NULL
         AND o.delivery_date <= o.estimated_delivery_date

        THEN 'On Time'

        WHEN o.delivery_date IS NOT NULL
         AND o.delivery_date > o.estimated_delivery_date

        THEN 'Delayed'

        WHEN o.delivery_date IS NULL
         AND CURRENT_DATE() > o.estimated_delivery_date

        THEN 'Potentially Delayed'

        ELSE 'In Transit'

    END AS delivery_status,

    (
        oi.line_revenue
        * (
            1 - (o.discount_amount / 100)
          )
    )
    - oi.line_cost
    - o.shipping_cost
    - o.tax_amount

    AS profit_amount,

    CASE

        WHEN oi.line_revenue > 0

        THEN ROUND(

            (
                (
                    (
                        oi.line_revenue
                        * (
                            1 - (o.discount_amount / 100)
                          )
                    )
                    - oi.line_cost
                    - o.shipping_cost
                    - o.tax_amount
                )
                / oi.line_revenue
            ) * 100,

            2

        )

        ELSE NULL

    END AS profit_margin_percentage,

    _LOADED_AT,

    _BATCH_ID

FROM current_orders o

LEFT JOIN order_item_agg oi
    ON o.order_id = oi.order_id

QUALIFY ROW_NUMBER()
OVER(
    PARTITION BY o.order_id
    ORDER BY o.created_at DESC
)=1