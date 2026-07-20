{% snapshot snp_store %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='store_id',
        strategy='timestamp',
        updated_at='last_modified_date'
    )
}}

SELECT *
FROM {{ ref('base_store') }}

{% endsnapshot %}