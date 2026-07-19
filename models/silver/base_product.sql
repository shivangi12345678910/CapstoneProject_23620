{{ config(
    materialized='view',
    schema='SILVER'
) }}

SELECT

    f.value:product_id::STRING AS product_id,
    f.value:name::STRING AS product_name,
    f.value:brand::STRING AS brand,
    f.value:category::STRING AS category,
    f.value:subcategory::STRING AS subcategory,
    f.value:product_line::STRING AS product_line,
    f.value:color::STRING AS color,
    f.value:size::STRING AS size,
    f.value:weight::STRING AS weight,
    f.value:dimensions::STRING AS dimensions,
    f.value:short_description::STRING AS short_description,
    f.value:technical_specs::STRING AS technical_specs,
    f.value:unit_price::NUMBER(18,2) AS unit_price,
    f.value:cost_price::NUMBER(18,2) AS cost_price,
    f.value:stock_quantity::NUMBER AS stock_quantity,
    f.value:reorder_level::NUMBER AS reorder_level,
    f.value:supplier_id::STRING AS supplier_id,
    f.value:warranty_period::STRING AS warranty_period,
    f.value:is_featured::BOOLEAN AS is_featured,
    f.value:launch_date::DATE AS launch_date,
    f.value:last_modified_date::DATE AS last_modified_date,
    _LOADED_AT,
    _BATCH_ID

FROM {{ ref('bronze_product') }},
LATERAL FLATTEN(
    INPUT => JSON_DATA:products_data
) f