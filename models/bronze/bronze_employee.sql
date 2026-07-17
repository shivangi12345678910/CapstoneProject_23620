{{
    config(
        materialized='incremental',
        schema='BRONZE'
    )
}}

SELECT
    RAW_VALUES AS JSON_DATA,
    CURRENT_TIMESTAMP() AS _LOADED_AT,
    '{{ invocation_id }}' AS _BATCH_ID
FROM {{ source('raw_data','EX_EMPLOYEE') }}