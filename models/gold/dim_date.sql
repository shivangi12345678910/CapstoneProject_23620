{{ config(
    materialized='table'
) }}


WITH date_spine AS (

    {{
        dbt_utils.date_spine(
            datepart="day",
            start_date="cast('2020-01-01' as date)",
            end_date="cast('2030-12-31' as date)"
        )
    }}

)


SELECT

    {{ dbt_utils.generate_surrogate_key(
        ['date_day']
    ) }} AS date_key,

    date_day AS full_date,

    YEAR(date_day) AS year,

    QUARTER(date_day) AS quarter,

    MONTH(date_day) AS month,

    MONTHNAME(date_day) AS month_name,

    WEEK(date_day) AS week,

    DAYOFWEEK(date_day) AS day_of_week,

    DAYNAME(date_day) AS day_name,

    CASE

        WHEN MONTH(date_day) IN (12,1,2)
        THEN 'Winter'

        WHEN MONTH(date_day) IN (3,4,5)
        THEN 'Spring'

        WHEN MONTH(date_day) IN (6,7,8)
        THEN 'Summer'

        ELSE 'Fall'

    END AS season,

    CASE
        WHEN
            TO_CHAR(date_day,'MM-DD') IN
            (
                '01-01', -- New Year
                '07-04', -- Independence Day
                '12-25'  -- Christmas
            )
        THEN TRUE
        ELSE FALSE
    END AS holiday_flag

FROM date_spine