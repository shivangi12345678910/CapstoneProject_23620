{{ config(
    materialized='table',
    schema='SILVER'
) }}

SELECT

    f.value:store_id::STRING AS store_id,
    f.value:store_name::STRING AS store_name,
    f.value:store_type::STRING AS store_type,
    f.value:region::STRING AS region,
    f.value:manager_id::STRING AS manager_id,
    f.value:email::STRING AS email,
    f.value:phone_number::STRING AS phone_number,
    f.value:operating_hours::STRING AS operating_hours,
    f.value:services::STRING AS services,
    f.value:is_active::BOOLEAN AS is_active,
    f.value:employee_count::STRING AS employee_count,
    f.value:size_sq_ft::STRING AS size_sq_ft,
    f.value:monthly_rent::STRING AS monthly_rent,
    f.value:current_sales::STRING AS current_sales,
    f.value:sales_target::STRING AS sales_target,
    f.value:opening_date::DATE AS opening_date,
    f.value:last_modified_date::DATE AS last_modified_date,
    f.value:address.street::STRING AS street,
    f.value:address.city::STRING AS city,
    f.value:address.state::STRING AS state,
    f.value:address.country::STRING AS country,
    f.value:address.zip_code::STRING AS zip_code,
    _LOADED_AT,
    _BATCH_ID

FROM {{ ref('bronze_store') }},
LATERAL FLATTEN(
    INPUT => JSON_DATA:stores_data
) f