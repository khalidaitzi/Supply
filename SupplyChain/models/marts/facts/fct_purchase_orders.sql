{{
    config(
        materialized='incremental',
        unique_key='po_line_id',
        incremental_strategy='merge',
        on_schema_change='sync_all_columns',
        cluster_by=['order_date']
    )
}}

with source_data as (

    select *
    from {{
        ref(
            'int_procurement__purchase_order_lines_enriched'
        )
    }}

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
        po_line_id,
        purchase_order_id,

        {{ dbt_utils.generate_surrogate_key([
            'supplier_id'
        ]) }} as supplier_key,

        {{ dbt_utils.generate_surrogate_key([
            'product_id'
        ]) }} as product_key,

        {{ dbt_utils.generate_surrogate_key([
            'warehouse_id'
        ]) }} as warehouse_key,

        supplier_id,
        product_id,
        warehouse_id,

        order_date,
        expected_date,
        received_date,

        purchase_order_status,

        ordered_qty,
        received_qty,
        missing_qty,
        unit_cost,

        ordered_amount,
        received_amount,
        fill_rate,

        actual_lead_time_days,
        is_supplier_on_time,
        supplier_delay_days,

        record_loaded_at as source_loaded_at,
        current_timestamp() as dbt_updated_at,
        {{ get_run_id() }} as dbt_run_id

    from source_data

)

select *
from final
