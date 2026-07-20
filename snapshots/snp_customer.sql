{% snapshot snp_customer %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='last_modified_date'
    )
}}

SELECT *
FROM {{ ref('base_customer') }}

{% endsnapshot %}