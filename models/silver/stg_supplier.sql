{{ config(
    materialized='table',
    schema='SILVER'
) }}

WITH current_supplier AS (

    SELECT *
    FROM {{ ref('snp_supplier') }}
    WHERE dbt_valid_to IS NULL

),

transformed AS (

    SELECT

        supplier_id,

        INITCAP(
            TRIM(
                COALESCE(supplier_name,'Unknown')
            )
        ) AS supplier_name,

        INITCAP(
            TRIM(
                COALESCE(supplier_type,'Unknown')
            )
        ) AS supplier_type,

        UPPER(
            TRIM(
                COALESCE(credit_rating,'UNKNOWN')
            )
        ) AS credit_rating,

        lead_time_days,

        minimum_order_quantity,

        INITCAP(
            TRIM(
                COALESCE(payment_terms,'Unknown')
            )
        ) AS payment_terms,

        CASE
            WHEN website ILIKE 'http%'
            THEN LOWER(TRIM(website))
            ELSE CONCAT(
                'https://',
                LOWER(TRIM(website))
            )
        END AS website,

        year_established,

        is_active,

        last_order_date,

        last_modified_date,

        contact_email,

        REGEXP_REPLACE(
            COALESCE(contact_phone,''),
            '[^0-9]',
            ''
        ) AS contact_phone,

        INITCAP(
            TRIM(
                COALESCE(contact_person,'Unknown')
            )
        ) AS contact_person,

        categories_supplied,

        preferred_carrier,

        contract_details,

        performance_metrics,

        tax_id,

        _LOADED_AT,

        _BATCH_ID,

        dbt_valid_from,

        dbt_valid_to

    FROM current_supplier

)

SELECT *
FROM transformed

QUALIFY ROW_NUMBER()
OVER(
    PARTITION BY supplier_id
    ORDER BY dbt_valid_from DESC
) = 1