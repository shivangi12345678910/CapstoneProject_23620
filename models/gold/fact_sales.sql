{{ config(
    materialized='table'
) }}

WITH order_lines AS (

    SELECT

        o.order_id,
        
        ROW_NUMBER() OVER (
            PARTITION BY o.order_id
            ORDER BY item.index
        ) AS line_number,

        o.customer_id,
        o.store_id,
        o.employee_id,
        o.order_date,

        o.order_source,

        o.shipping_cost,

        item.value:product_id::STRING AS product_id,

        item.value:quantity::NUMBER AS quantity_sold,

        item.value:unit_price::NUMBER(18,2) AS unit_price,

        item.value:cost_price::NUMBER(18,2) AS cost_price,

        item.value:discount_amount::NUMBER(18,2)
            AS discount_amount

    FROM {{ ref('base_orders') }} o,

    LATERAL FLATTEN(
        INPUT => PARSE_JSON(o.order_items)
    ) item

),

enriched AS (

    SELECT

        ol.*,

        dc.customer_key,

        dp.product_key,

        ds.store_key,

        de.employee_key,

        dd.date_key,

        ds.region,

        dc.customer_segment

    FROM order_lines ol

    LEFT JOIN {{ ref('dim_customer') }} dc
        ON ol.customer_id = dc.customer_id

    LEFT JOIN {{ ref('dim_product') }} dp
        ON ol.product_id = dp.product_id

    LEFT JOIN {{ ref('dim_store') }} ds
        ON ol.store_id = ds.store_id

    LEFT JOIN {{ ref('dim_employee') }} de
        ON ol.employee_id = de.employee_id

    LEFT JOIN {{ ref('dim_date') }} dd
        ON ol.order_date = dd.full_date

)

SELECT

    {{ dbt_utils.generate_surrogate_key([
        'order_id',
        'line_number'
    ]) }} AS sales_key,

    order_id,

    customer_key,

    product_key,

    store_key,

    date_key,

    employee_key,

    quantity_sold,

    unit_price,

    quantity_sold * unit_price
        AS total_sales_amount,

    quantity_sold * cost_price
        AS cost_amount,

    discount_amount,

    shipping_cost,

    (
        (quantity_sold * unit_price)
        -
        (quantity_sold * cost_price)
        -
        discount_amount
        -
        shipping_cost
    ) AS profit_amount,

    region,

    order_source AS sales_channel,

    customer_segment
        AS customer_segment_impact

FROM enriched