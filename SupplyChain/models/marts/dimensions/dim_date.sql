with date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="to_date('2023-01-01')",
        end_date="to_date('2031-01-01')"
    ) }}

),

final as (

    select
        date_day::date as date_key,

        year(date_day) as year_number,
        quarter(date_day) as quarter_number,
        month(date_day) as month_number,
        monthname(date_day) as month_name,

        year(date_day)
            || '-Q'
            || quarter(date_day) as year_quarter,

        to_char(date_day, 'YYYY-MM')
            as year_month,

        weekofyear(date_day) as week_number,
        dayofmonth(date_day) as day_of_month,
        dayofweekiso(date_day) as day_of_week_number,
        dayname(date_day) as day_of_week_name,

        date_trunc(
            'month',
            date_day
        )::date as month_start_date,

        last_day(
            date_day,
            'month'
        )::date as month_end_date,

        date_trunc(
            'quarter',
            date_day
        )::date as quarter_start_date,

        dayofweekiso(date_day) in (6, 7)
            as is_weekend

    from date_spine

)

select *
from final
