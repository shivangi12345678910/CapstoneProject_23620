{{ config(
    materialized='view',
    schema='SILVER'
) }}

SELECT

    f.value:order_id::STRING AS order_id,
    f.value:customer_id::STRING AS customer_id,
    f.value:employee_id::STRING AS employee_id,
    f.value:store_id::STRING AS store_id,
    f.value:campaign_id::STRING AS campaign_id,
    f.value:order_status::STRING AS order_status,
    f.value:order_source::STRING AS order_source,
    f.value:payment_method::STRING AS payment_method,
    f.value:shipping_method::STRING AS shipping_method,
    f.value:total_amount::STRING AS total_amount,
    f.value:discount_amount::STRING AS discount_amount,
    f.value:shipping_cost::STRING AS shipping_cost,
    f.value:tax_amount::STRING AS tax_amount,
    f.value:order_date::DATE AS order_date,
    f.value:shipping_date::DATE AS shipping_date,
    f.value:delivery_date::DATE AS delivery_date,
    f.value:estimated_delivery_date::DATE AS estimated_delivery_date,
    f.value:created_at::TIMESTAMP AS created_at,
    f.value:billing_address::STRING AS billing_address,
    f.value:shipping_address::STRING AS shipping_address,
    f.value:order_items::STRING AS order_items,
    _LOADED_AT,
    _BATCH_ID

FROM {{ ref('bronze_orders') }},
LATERAL FLATTEN(
    INPUT => JSON_DATA:orders_data
) f