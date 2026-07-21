{{ config(
    materialized='table',
    schema='SILVER'
) }}

SELECT

    f.value:supplier_id::STRING AS supplier_id,
    f.value:supplier_name::STRING AS supplier_name,
    f.value:supplier_type::STRING AS supplier_type,
    f.value:tax_id::STRING AS tax_id,
    f.value:website::STRING AS website,
    f.value:credit_rating::STRING AS credit_rating,
    f.value:payment_terms::STRING AS payment_terms,
    f.value:preferred_carrier::STRING AS preferred_carrier,
    f.value:categories_supplied::STRING AS categories_supplied,
    f.value:minimum_order_quantity::STRING AS minimum_order_quantity,
    f.value:lead_time_days::STRING AS lead_time_days,
    f.value:year_established::STRING AS year_established,
    f.value:is_active::BOOLEAN AS is_active,
    f.value:last_order_date::DATE AS last_order_date,
    f.value:last_modified_date::DATE AS last_modified_date,
    f.value:contact_information.email::STRING AS contact_email,
    f.value:contact_information.phone::STRING AS contact_phone,
    f.value:contact_information.contact_person::STRING AS contact_person,
    f.value:contract_details::STRING AS contract_details,
    f.value:performance_metrics::STRING AS performance_metrics,
    _LOADED_AT,
    _BATCH_ID

FROM {{ ref('bronze_supplier') }},
LATERAL FLATTEN(
    INPUT => JSON_DATA:suppliers_data
) f