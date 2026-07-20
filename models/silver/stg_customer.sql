{{ config(
    materialized='table',
    schema='SILVER'
) }}

WITH current_customers AS (

    SELECT *
    FROM {{ ref('snp_customer') }}
    WHERE dbt_valid_to IS NULL

),

cleaned_customer AS (

    SELECT

        customer_id,

        COALESCE(
            INITCAP(TRIM(first_name)),
            'Unknown'
        ) AS first_name,

        COALESCE(
            INITCAP(TRIM(last_name)),
            'Unknown'
        ) AS last_name,

        CONCAT(
            COALESCE(INITCAP(TRIM(first_name)), 'Unknown'),
            ' ',
            COALESCE(INITCAP(TRIM(last_name)), 'Unknown')
        ) AS full_name,

        birth_date,

        CASE
            WHEN birth_date IS NOT NULL
            THEN DATEDIFF(
                    YEAR,
                    birth_date,
                    CURRENT_DATE()
                 )
            ELSE NULL
        END AS age,

        CASE

            WHEN birth_date IS NULL
            THEN 'Unknown'

            WHEN DATEDIFF(
                    YEAR,
                    birth_date,
                    CURRENT_DATE()
                 ) BETWEEN 18 AND 35
            THEN 'Young'

            WHEN DATEDIFF(
                    YEAR,
                    birth_date,
                    CURRENT_DATE()
                 ) BETWEEN 36 AND 55
            THEN 'Middle-Aged'

            WHEN DATEDIFF(
                    YEAR,
                    birth_date,
                    CURRENT_DATE()
                 ) >= 56
            THEN 'Senior'

            ELSE 'Unknown'

        END AS customer_segment,

        CASE

            WHEN REGEXP_LIKE(
                LOWER(TRIM(email)),
                '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
            )

            THEN LOWER(TRIM(email))

            ELSE NULL

        END AS email,

        REGEXP_REPLACE(
            COALESCE(phone,''),
            '[^0-9]',
            ''
        ) AS phone,

        UPPER(
            TRIM(
                COALESCE(income_bracket,'UNKNOWN')
            )
        ) AS income_bracket,

        UPPER(
            TRIM(
                COALESCE(loyalty_tier,'UNKNOWN')
            )
        ) AS loyalty_tier,

        INITCAP(
            TRIM(
                COALESCE(occupation,'Unknown')
            )
        ) AS occupation,

        UPPER(
            TRIM(
                COALESCE(preferred_communication,'UNKNOWN')
            )
        ) AS preferred_communication,

        INITCAP(
            TRIM(
                COALESCE(preferred_payment_method,'Unknown')
            )
        ) AS preferred_payment_method,

        marketing_opt_in,

        registration_date,

        last_purchase_date,

        total_purchases,

        total_spend,

        INITCAP(
            TRIM(
                COALESCE(street,'Unknown')
            )
        ) AS street,

        INITCAP(
            TRIM(
                COALESCE(city,'Unknown')
            )
        ) AS city,

        UPPER(
            TRIM(
                COALESCE(state,'UNKNOWN')
            )
        ) AS state,

        UPPER(
            TRIM(
                COALESCE(country,'UNKNOWN')
            )
        ) AS country,

        zip_code,

        last_modified_date,

        _LOADED_AT,

        _BATCH_ID,

        dbt_valid_from,

        dbt_valid_to

    FROM current_customers

)

SELECT *
FROM cleaned_customer

QUALIFY ROW_NUMBER()
OVER(
    PARTITION BY customer_id
    ORDER BY dbt_valid_from DESC
) = 1