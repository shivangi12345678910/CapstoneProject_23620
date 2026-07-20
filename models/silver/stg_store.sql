{{ config(
    materialized='table',
    schema='SILVER'
) }}

WITH current_store AS (

    SELECT *
    FROM {{ ref('snp_store') }}
    WHERE dbt_valid_to IS NULL

),

transformed AS (

    SELECT

        store_id,

        INITCAP(
            TRIM(
                COALESCE(store_name,'Unknown')
            )
        ) AS store_name,

        INITCAP(
            TRIM(
                COALESCE(store_type,'Unknown')
            )
        ) AS store_type,

        INITCAP(
            TRIM(
                COALESCE(region,'Unknown')
            )
        ) AS region,

        manager_id,

        CASE
            WHEN REGEXP_LIKE(
                LOWER(TRIM(email)),
                '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
            )
            THEN LOWER(TRIM(email))
            ELSE NULL
        END AS email,

        REGEXP_REPLACE(
            COALESCE(phone_number,''),
            '[^0-9]',
            ''
        ) AS phone_number,

        operating_hours,

        services,

        is_active,

        employee_count,

        size_sq_ft,

        monthly_rent,

        current_sales,

        sales_target,

        opening_date,

        last_modified_date,

        INITCAP(TRIM(street)) AS street,

        INITCAP(TRIM(city)) AS city,

        UPPER(TRIM(state)) AS state,

        UPPER(TRIM(country)) AS country,

        zip_code,

        CASE

            WHEN size_sq_ft < 5000
            THEN 'Small'

            WHEN size_sq_ft BETWEEN 5000 AND 10000
            THEN 'Medium'

            ELSE 'Large'

        END AS store_size_category,

        DATEDIFF(
            YEAR,
            opening_date,
            CURRENT_DATE()
        ) AS store_age_years,

        CASE

            WHEN sales_target > 0

            THEN ROUND(
                (current_sales / sales_target) * 100,
                2
            )

            ELSE NULL

        END AS sales_target_achievement_percentage,

        CASE

            WHEN size_sq_ft > 0

            THEN ROUND(
                current_sales / size_sq_ft,
                2
            )

            ELSE NULL

        END AS revenue_per_sq_ft,

        CASE

            WHEN employee_count > 0

            THEN ROUND(
                current_sales / employee_count,
                2
            )

            ELSE NULL

        END AS employee_efficiency,

        CASE

            WHEN sales_target > 0
             AND (current_sales / sales_target) * 100 < 90

            THEN 'Y'

            ELSE 'N'

        END AS performance_issue_flag,

        _LOADED_AT,

        _BATCH_ID,

        dbt_valid_from,

        dbt_valid_to

    FROM current_store

)

SELECT *
FROM transformed

QUALIFY ROW_NUMBER()
OVER(
    PARTITION BY store_id
    ORDER BY dbt_valid_from DESC
)=1