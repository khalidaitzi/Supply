select
    {{ dbt_utils.generate_surrogate_key([
        'supplier_id'
    ]) }} as supplier_key,

    supplier_id,
    supplier_name,
    country,
    risk_tier,
    default_lead_time_days,

    loaded_at as source_loaded_at,
    current_timestamp() as dbt_updated_at,
    {{ get_run_id() }} as dbt_run_id

from {{ ref('suppliers') }}
