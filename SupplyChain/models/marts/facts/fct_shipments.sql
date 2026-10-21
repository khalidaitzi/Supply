{{
    config(
        materialized='incremental',
        unique_key='shipment_id',
        incremental_strategy='merge',
        on_schema_change='sync_all_columns',
        cluster_by=['ship_date']
    )
}}

with source_data as (

    select *
    from {{ ref('int_logistics__shipment_performance') }}

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
        shipment_id,
        order_id,

        {{ dbt_utils.generate_surrogate_key([
            'carrier_id'
        ]) }} as carrier_key,

        {{ dbt_utils.generate_surrogate_key([
            'customer_id'
        ]) }} as customer_key,

        {{ dbt_utils.generate_surrogate_key([
            'warehouse_id'
        ]) }} as warehouse_key,

        carrier_id,
        customer_id,
        warehouse_id,

        order_date,
        promised_date,
        ship_date,
        delivery_date,

        shipment_status,
        tracking_number,
        freight_cost,

        order_to_ship_days,
        transit_days,
        is_on_time_delivery,
        delivery_delay_days,

        record_loaded_at as source_loaded_at,
        current_timestamp() as dbt_updated_at,
        {{ get_run_id() }} as dbt_run_id

    from source_data

)

select *
from final
