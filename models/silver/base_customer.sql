{{ config(
    materialized='view',
    schema='SILVER'
) }}

SELECT

    f.value:customer_id::STRING AS customer_id,
    f.value:first_name::STRING AS first_name,
    f.value:last_name::STRING AS last_name,
    COALESCE(
    TRY_TO_DATE(f.value:birth_date::STRING,'YYYY-MM-DD'),
    TRY_TO_DATE(f.value:birth_date::STRING,'MM/DD/YYYY'),
    TRY_TO_DATE(f.value:birth_date::STRING,'DD-MM-YYYY')
    ) AS birth_date,
    f.value:email::STRING AS email,
    f.value:phone::STRING AS phone,
    f.value:income_bracket::STRING AS income_bracket,
    f.value:occupation::STRING AS occupation,
    f.value:loyalty_tier::STRING AS loyalty_tier,
    f.value:preferred_communication::STRING AS preferred_communication,
    f.value:preferred_payment_method::STRING AS preferred_payment_method,
    f.value:marketing_opt_in::BOOLEAN AS marketing_opt_in,
    COALESCE(
    TRY_TO_DATE(f.value:registration_date::STRING,'YYYY-MM-DD'),
    TRY_TO_DATE(f.value:registration_date::STRING,'MM/DD/YYYY'),
    TRY_TO_DATE(f.value:registration_date::STRING,'DD-MM-YYYY')
    ) AS registration_date,
    COALESCE(
    TRY_TO_DATE(f.value:last_purchase_date::STRING,'YYYY-MM-DD'),
    TRY_TO_DATE(f.value:last_purchase_date::STRING,'MM/DD/YYYY'),
    TRY_TO_DATE(f.value:last_purchase_date::STRING,'DD-MM-YYYY')
    ) AS last_purchase_date,
    f.value:total_purchases::NUMBER AS total_purchases,
    f.value:total_spend::NUMBER(18,2) AS total_spend,
    TRY_TO_TIMESTAMP(f.value:last_modified_date::STRING)
    AS last_modified_date,
    f.value:address.street::STRING AS street,
    f.value:address.city::STRING AS city,
    f.value:address.state::STRING AS state,
    f.value:address.country::STRING AS country,
    f.value:address.zip_code::STRING AS zip_code,
    _LOADED_AT,
    _BATCH_ID

FROM {{ ref('bronze_customer') }},
LATERAL FLATTEN(
    INPUT => JSON_DATA:customers_data
) f