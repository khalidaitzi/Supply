select
    {{ dbt_utils.generate_surrogate_key([
        'customer_id'
    ]) }} as customer_key,

    customer_id,
    customer_name,
    customer_segment,
    country,
    region,
    created_date,

    loaded_at as source_loaded_at,
    current_timestamp() as dbt_updated_at,
    {{ get_run_id() }} as dbt_run_id

from {{ ref('customers') }}
