{% snapshot snp_employee %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='employee_id',
        strategy='timestamp',
        updated_at='last_modified_date'
    )
}}

SELECT *
FROM {{ ref('base_employee') }}

{% endsnapshot %}