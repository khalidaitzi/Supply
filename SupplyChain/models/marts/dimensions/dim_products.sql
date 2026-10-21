select
    {{ dbt_utils.generate_surrogate_key([
        'product_id'
    ]) }} as product_key,

    product_id,
    product_name,
    product_category,
    product_subcategory,
    standard_cost,
    list_price,
    weight_kg,
    is_active,

    loaded_at as source_loaded_at,
    current_timestamp() as dbt_updated_at,
    {{ get_run_id() }} as dbt_run_id

from {{ ref('products') }}
