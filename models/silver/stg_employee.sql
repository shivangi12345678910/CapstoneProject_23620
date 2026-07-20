{{ config(
    materialized='table',
    schema='SILVER'
) }}

WITH employee_order_metrics AS (

    SELECT

        employee_id,

        COUNT(order_id) AS orders_processed,

        SUM(total_amount) AS total_sales_amount

    FROM {{ ref('stg_orders') }}

    GROUP BY employee_id

),

current_employees AS (

    SELECT *
    FROM {{ ref('snp_employee') }}
    WHERE dbt_valid_to IS NULL

),

cleaned_employee AS (

    SELECT

        e.employee_id,

        INITCAP(TRIM(e.first_name)) AS first_name,

        INITCAP(TRIM(e.last_name)) AS last_name,

        CONCAT(
            INITCAP(TRIM(e.first_name)),
            ' ',
            INITCAP(TRIM(e.last_name))
        ) AS full_name,

        CASE
            WHEN REGEXP_LIKE(
                LOWER(TRIM(e.email)),
                '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
            )
            THEN LOWER(TRIM(e.email))
            ELSE NULL
        END AS email,

        REGEXP_REPLACE(
            COALESCE(e.phone,''),
            '[^0-9]',
            ''
        ) AS phone,

        INITCAP(TRIM(e.department)) AS department,

        CASE

            WHEN LOWER(TRIM(e.role)) = 'sales associate'
            THEN 'Associate'

            WHEN LOWER(TRIM(e.role)) = 'store manager'
            THEN 'Manager'

            WHEN LOWER(TRIM(e.role)) = 'senior manager'
            THEN 'Senior Manager'

            ELSE INITCAP(TRIM(e.role))

        END AS standardized_role,

        UPPER(TRIM(e.employment_status)) AS employment_status,

        INITCAP(TRIM(e.education)) AS education,

        e.manager_id,

        e.work_location,

        e.certifications,

        e.performance_rating,

        e.salary,

        e.current_sales,

        e.sales_target,

        e.date_of_birth,

        e.hire_date,

        e.last_modified_date,

        INITCAP(
            TRIM(
                COALESCE(e.street,'Unknown')
            )
        ) AS street,

        INITCAP(
            TRIM(
                COALESCE(e.city,'Unknown')
            )
        ) AS city,

        UPPER(
            TRIM(
                COALESCE(e.state,'UNKNOWN')
            )
        ) AS state,

        COALESCE(
            UPPER(TRIM(e.country)),
            scm.country,
            'UNKNOWN'
        ) AS country,

        e.zip_code,

        DATEDIFF(
            YEAR,
            e.date_of_birth,
            CURRENT_DATE()
        ) AS employee_age,

        DATEDIFF(
            YEAR,
            e.hire_date,
            CURRENT_DATE()
        ) AS tenure_years,

        CASE

            WHEN e.sales_target > 0

            THEN ROUND(
                (e.current_sales / e.sales_target) * 100,
                2
            )

            ELSE NULL

        END AS target_achievement_percentage,

        COALESCE(
            eom.orders_processed,
            0
        ) AS orders_processed,

        COALESCE(
            eom.total_sales_amount,
            0
        ) AS total_sales_amount,

        _LOADED_AT,

        _BATCH_ID,

        dbt_valid_from,

        dbt_valid_to

    FROM current_employees e

    LEFT JOIN {{ ref('state_country_mapping') }} scm
        ON UPPER(TRIM(e.state)) = scm.state

    LEFT JOIN employee_order_metrics eom
        ON e.employee_id = eom.employee_id

)

SELECT *
FROM cleaned_employee

QUALIFY ROW_NUMBER()
OVER(
    PARTITION BY employee_id
    ORDER BY dbt_valid_from DESC
) = 1