{{ config(
    materialized='table'
) }}

SELECT

    {{ dbt_utils.generate_surrogate_key(
        ['p.product_id']
    ) }} AS product_key,

    p.product_id,

    p.product_name,

    p.brand,

    p.category,

    p.subcategory,

    p.product_line,

    p.product_hierarchy,

    p.color,

    p.size,

    p.weight_kg,

    p.unit_price,

    p.cost_price,

    p.profit_margin_percent,

    p.low_stock_flag,

    s.supplier_id,

    s.supplier_name,

    s.supplier_type,

    s.credit_rating,

    s.payment_terms,

    s.website,

    s.is_active AS supplier_active

FROM {{ ref('stg_product') }} p

LEFT JOIN {{ ref('stg_supplier') }} s
    ON p.supplier_id = s.supplier_id