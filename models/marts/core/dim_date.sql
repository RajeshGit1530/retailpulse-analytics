with date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2024-01-01' as date)",
        end_date="dateadd(year, 2, current_date())"
    ) }}

),

final as (

    select
        -- primary key
        cast(date_day as date)                  as date_key,

        -- date attributes
        date_day                                as full_date,
        year(date_day)                          as year,
        quarter(date_day)                       as quarter,
        month(date_day)                         as month_number,
        monthname(date_day)                     as month_name,
        weekofyear(date_day)                    as week_of_year,
        dayofweek(date_day)                     as day_of_week,
        dayname(date_day)                       as day_name,
        day(date_day)                           as day_of_month,

        -- flags
        case
            when dayofweek(date_day) in (1, 7)
            then true else false
        end                                     as is_weekend,

        case
            when dayofweek(date_day) in (1, 7)
            then false else true
        end                                     as is_weekday,

        -- fiscal (assuming Apr-Mar fiscal year)
        case
            when month(date_day) >= 4
            then year(date_day)
            else year(date_day) - 1
        end                                     as fiscal_year,

        case
            when month(date_day) in (4,5,6)   then 1
            when month(date_day) in (7,8,9)   then 2
            when month(date_day) in (10,11,12) then 3
            else 4
        end                                     as fiscal_quarter

    from date_spine

)

select * from final