select
    {{ dbt_utils.generate_surrogate_key([
        'carrier_id'
    ]) }} as carrier_key,

    carrier_id,
    carrier_name,
    service_level,

    loaded_at as source_loaded_at,
    current_timestamp() as dbt_updated_at,
    {{ get_run_id() }} as dbt_run_id

from {{ ref('carriers') }}
