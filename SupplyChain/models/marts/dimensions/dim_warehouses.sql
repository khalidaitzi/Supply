select
    {{ dbt_utils.generate_surrogate_key([
        'warehouse_id'
    ]) }} as warehouse_key,

    warehouse_id,
    warehouse_name,
    country,
    region,
    capacity_units,

    loaded_at as source_loaded_at,
    current_timestamp() as dbt_updated_at,
    {{ get_run_id() }} as dbt_run_id

from {{ ref('warehouses') }}
