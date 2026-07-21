{{ config(
    materialized='table',
    schema='SILVER'
) }}

SELECT

    f.value:employee_id::STRING AS employee_id,
    f.value:first_name::STRING AS first_name,
    f.value:last_name::STRING AS last_name,
    f.value:email::STRING AS email,
    f.value:phone::STRING AS phone,
    f.value:department::STRING AS department,
    f.value:role::STRING AS role,
    f.value:employment_status::STRING AS employment_status,
    f.value:education::STRING AS education,
    f.value:manager_id::STRING AS manager_id,
    f.value:work_location::STRING AS work_location,
    f.value:certifications::STRING AS certifications,
    f.value:performance_rating::STRING AS performance_rating,
    f.value:salary::STRING AS salary,
    f.value:current_sales::STRING AS current_sales,
    f.value:sales_target::STRING AS sales_target,
    f.value:date_of_birth::DATE AS date_of_birth,
    f.value:hire_date::DATE AS hire_date,
    f.value:last_modified_date::DATE AS last_modified_date,
    f.value:address.street::STRING AS street,
    f.value:address.city::STRING AS city,
    f.value:address.state::STRING AS state,
    f.value:address.country::STRING AS country,
    f.value:address.zip_code::STRING AS zip_code,
    _LOADED_AT,
    _BATCH_ID

FROM {{ ref('bronze_employee') }},
LATERAL FLATTEN(
    INPUT => JSON_DATA:employees_data
) f