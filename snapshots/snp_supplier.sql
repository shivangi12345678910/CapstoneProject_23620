{% snapshot snp_supplier %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='supplier_id',
        strategy='timestamp',
        updated_at='last_modified_date'
    )
}}

SELECT *
FROM {{ ref('base_supplier') }}

{% endsnapshot %}