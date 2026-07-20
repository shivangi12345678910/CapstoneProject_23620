{% snapshot snp_product %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='product_id',
        strategy='timestamp',
        updated_at='last_modified_date'
    )
}}

SELECT *
FROM {{ ref('base_product') }}

{% endsnapshot %}