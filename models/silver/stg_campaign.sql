{{ config(
    materialized='table',
    schema='SILVER'
) }}

WITH transformed AS (

    SELECT

        campaign_id,

        INITCAP(
            TRIM(
                COALESCE(campaign_name,'Unknown')
            )
        ) AS campaign_name,

        INITCAP(
            TRIM(
                COALESCE(campaign_type,'Unknown')
            )
        ) AS campaign_type,

        INITCAP(
            TRIM(
                COALESCE(channel,'Unknown')
            )
        ) AS channel,

        TRIM(description) AS description,

        TRIM(target_audience) AS target_audience,

        TRY_TO_NUMBER(
            REPLACE(
                REPLACE(
                    TRIM(budget),
                    '$',
                    ''
                ),
                ',',
                ''
            )
        ) AS budget,

        TRY_TO_NUMBER(
            REPLACE(
                REPLACE(
                    TRIM(total_cost),
                    '$',
                    ''
                ),
                ',',
                ''
            )
        ) AS total_cost,

        TRY_TO_NUMBER(
            REPLACE(
                REPLACE(
                    TRIM(total_revenue),
                    '$',
                    ''
                ),
                ',',
                ''
            )
        ) AS total_revenue,

        TRY_TO_NUMBER(
            roi_calculation
        ) AS roi_calculation,

        TO_DATE(start_date) AS start_date,

        TO_DATE(end_date) AS end_date,

        TO_DATE(last_modified_date) AS last_modified_date,

        DATEDIFF(
            DAY,
            TO_DATE(start_date),
            TO_DATE(end_date)
        ) AS campaign_duration_days,

        _LOADED_AT,

        _BATCH_ID

    FROM {{ ref('base_campaign') }}

)

SELECT *
FROM transformed

QUALIFY ROW_NUMBER()
OVER(
    PARTITION BY campaign_id
    ORDER BY last_modified_date DESC
) = 1