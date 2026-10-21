{% snapshot snap_customers %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='check',
        check_cols=[
            'customer_name',
            'customer_segment',
            'country',
            'region',
            'created_date'
        ],
        invalidate_hard_deletes=true
    )
}}

select
    customer_id,
    customer_name,
    customer_segment,
    country,
    region,
    created_date,

    loaded_at as source_loaded_at,
    source_file_name,
    source_file_checksum,
    airflow_run_id

from {{ ref('customers') }}

{% endsnapshot %}
