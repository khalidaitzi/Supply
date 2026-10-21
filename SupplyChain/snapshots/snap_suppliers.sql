{% snapshot snap_suppliers %}

{{
    config(
        target_schema='snapshots',
        unique_key='supplier_id',
        strategy='check',
        check_cols=[
            'supplier_name',
            'country',
            'risk_tier',
            'default_lead_time_days'
        ],
        invalidate_hard_deletes=true
    )
}}

select
    supplier_id,
    supplier_name,
    country,
    risk_tier,
    default_lead_time_days,

    loaded_at as source_loaded_at,
    source_file_name,
    source_file_checksum,
    airflow_run_id

from {{ ref('suppliers') }}

{% endsnapshot %}
