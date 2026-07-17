
{{ config(
    materialized='table',
    schema='BRONZE'
) }}

SELECT
    RAW_VALUES AS JSON_DATA,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP
FROM {{ source('raw_data','EX_STORE') }}
