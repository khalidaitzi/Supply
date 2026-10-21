{% snapshot snap_products %}

{{
    config(
        target_schema='snapshots',
        unique_key='product_id',
        strategy='check',
        check_cols=[
            'product_name',
            'product_category',
            'product_subcategory',
            'standard_cost',
            'list_price',
            'weight_kg',
            'is_active'
        ],
        invalidate_hard_deletes=true
    )
}}

select
    product_id,
    product_name,
    product_category,
    product_subcategory,
    standard_cost,
    list_price,
    weight_kg,
    is_active,

    loaded_at as source_loaded_at,
    source_file_name,
    source_file_checksum,
    airflow_run_id

from {{ ref('products') }}

{% endsnapshot %}
