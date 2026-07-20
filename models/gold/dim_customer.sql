{{ config(
    materialized='table'
) }}

SELECT

    {{ dbt_utils.generate_surrogate_key(
        ['customer_id']
    ) }} AS customer_key,

    customer_id,

    full_name,

    email,

    phone,

    street,
    city,
    state,
    country,
    zip_code,

    age,

    income_bracket,

    occupation,

    loyalty_tier,

    customer_segment,

    registration_date

FROM {{ ref('stg_customer') }}