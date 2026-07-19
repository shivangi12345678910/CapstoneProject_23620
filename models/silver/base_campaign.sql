{{ config(
    materialized='view',
    schema='SILVER'
) }}

SELECT

    f.value:campaign_id::STRING AS campaign_id,
    f.value:campaign_name::STRING AS campaign_name,
    f.value:campaign_type::STRING AS campaign_type,
    f.value:channel::STRING AS channel,
    f.value:description::STRING AS description,
    f.value:target_audience::STRING AS target_audience,
    f.value:budget::STRING AS budget,
    f.value:total_cost::STRING AS total_cost,
    f.value:total_revenue::STRING AS total_revenue,
    f.value:roi_calculation::STRING AS roi_calculation,
    f.value:start_date::DATE AS start_date,
    f.value:end_date::DATE AS end_date,
    f.value:last_modified_date::DATE AS last_modified_date,
    _LOADED_AT,
    _BATCH_ID

FROM {{ ref('bronze_campaign') }},
LATERAL FLATTEN(
    INPUT => JSON_DATA:campaign_data
) f

