{{
    config(
        materialized='incremental',
        unique_key='order_line_id',
        incremental_strategy='merge',
        on_schema_change='sync_all_columns',
        cluster_by=['order_date']
    )
}}

with source_data as (

    select *
    from {{ ref('int_sales__order_lines_enriched') }}

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
        order_line_id,
        order_id,

        {{ dbt_utils.generate_surrogate_key([
            'customer_id'
        ]) }} as customer_key,

        {{ dbt_utils.generate_surrogate_key([
            'product_id'
        ]) }} as product_key,

        {{ dbt_utils.generate_surrogate_key([
            'warehouse_id'
        ]) }} as warehouse_key,

        order_date,
        promised_date,

        customer_id,
        product_id,
        warehouse_id,

        order_status,
        sales_channel,
        currency_code,

        quantity,
        unit_price,
        discount_pct,

        gross_sales_amount,
        discount_amount,
        net_sales_amount,
        total_standard_cost,
        gross_margin_amount,
        gross_margin_rate,

        record_loaded_at as source_loaded_at,
        current_timestamp() as dbt_updated_at,
        {{ get_run_id() }} as dbt_run_id

    from source_data

)

select *
from final
