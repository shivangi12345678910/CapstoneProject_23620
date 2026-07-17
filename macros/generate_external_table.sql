
{% macro generate_external_table() %}

{% set folders = [
    'customer_data',
    'product_data',
    'supplier_data',
    'employee_data',
    'orders_data',
    'campaign_data',
    'store_data'
] %}
{% for folder in folders %}
    {% set table_name = 'EX_' ~ folder.replace('_data', '') | upper %}
    {% set sql %}
    CREATE OR REPLACE EXTERNAL TABLE
    {{target.database }}.{{ target.schema }}.{{ table_name }}
    (
        RAW_VALUES VARIANT AS ($1)
    )
    LOCATION=@CT_SHIVANGI_TEKRIWAL_DB.DBT_STEKRIWAL.RAW/Capstone_Project_Data/{{ folder }}
    FILE_FORMAT=(
        TYPE=JSON
        STRIP_OUTER_ARRAY=TRUE
    )
    AUTO_REFRESH=FALSE;
    {% endset %}
    {{ log('Creating ' ~ table_name, info=True) }}
    {% do run_query(sql) %}
{% endfor %}
{% endmacro %}



