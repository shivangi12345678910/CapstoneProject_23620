{{ config(
    materialized='table',
    schema='SILVER'
) }}

WITH current_products AS (

    SELECT *
    FROM {{ ref('snp_product') }}
    WHERE dbt_valid_to IS NULL

),

cleaned_products AS (

    SELECT

        product_id,

        INITCAP(TRIM(product_name)) AS product_name,

        INITCAP(TRIM(brand)) AS brand,

        INITCAP(TRIM(category)) AS category,

        INITCAP(TRIM(subcategory)) AS subcategory,

        INITCAP(TRIM(product_line)) AS product_line,

        INITCAP(TRIM(color)) AS color,

        size,

        dimensions,

        short_description,

        technical_specs,

        unit_price,

        cost_price,

        stock_quantity,

        reorder_level,

        supplier_id,

        warranty_period,

        is_featured,

        launch_date,

        last_modified_date,

        TRY_TO_NUMBER(
            REGEXP_REPLACE(
                weight,
                '[^0-9.]',
                ''
            )
        ) AS weight_kg,

        CONCAT(
            INITCAP(TRIM(product_name)),
            ' | ',
            COALESCE(short_description,''),
            ' | ',
            COALESCE(technical_specs,'')
        ) AS product_full_description,

        CONCAT(
            INITCAP(TRIM(category)),
            ' > ',
            INITCAP(TRIM(subcategory)),
            ' > ',
            INITCAP(TRIM(product_line))
        ) AS product_hierarchy,

        CASE
            WHEN unit_price > 0
            THEN ROUND(
                ((unit_price - cost_price)
                 / unit_price) * 100,
                 2
            )
            ELSE NULL
        END AS profit_margin_percent,

        CASE
            WHEN stock_quantity < reorder_level
            THEN 'Y'
            ELSE 'N'
        END AS low_stock_flag,

        _LOADED_AT,
        _BATCH_ID,

        dbt_valid_from,
        dbt_valid_to

    FROM current_products

)

SELECT *
FROM cleaned_products

QUALIFY ROW_NUMBER()
OVER(
    PARTITION BY product_id
    ORDER BY dbt_valid_from DESC
)=1