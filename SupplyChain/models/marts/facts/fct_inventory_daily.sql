{{
    config(
        materialized='incremental',
        unique_key='inventory_snapshot_key',
        incremental_strategy='merge',
        on_schema_change='sync_all_columns',
        cluster_by=['snapshot_date']
    )
}}

with source_data as (

    select *
    from {{ ref('int_inventory__daily_status') }}

    {% if is_incremental() %}

        where record_loaded_at >= (

            select dateadd(
                day,
                -{{ var('incremental_lookback_days', 3) }},
                coalesce(
                    max(source_loaded_at),
                    '1900-01-01'::timestamp_ntz
                )
            )
            from {{ this }}

        )

    {% endif %}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key([
            'snapshot_date',
            'warehouse_id',
            'product_id'
        ]) }} as inventory_snapshot_key,

        snapshot_date,

        {{ dbt_utils.generate_surrogate_key([
            'warehouse_id'
        ]) }} as warehouse_key,

        {{ dbt_utils.generate_surrogate_key([
            'product_id'
        ]) }} as product_key,

        warehouse_id,
        product_id,

        on_hand_qty,
        allocated_qty,
        available_qty,
        reorder_point,

        inventory_status,
        is_stockout,
        is_below_reorder_point,
        stock_coverage_index,

        record_loaded_at as source_loaded_at,
        current_timestamp() as dbt_updated_at,
        {{ get_run_id() }} as dbt_run_id

    from source_data

)

select *
from final
