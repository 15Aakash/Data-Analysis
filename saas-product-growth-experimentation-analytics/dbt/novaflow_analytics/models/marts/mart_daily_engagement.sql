with daily_activity as (

    select
        cast(session_start_timestamp as date) as activity_date,
        user_id

    from {{ ref('stg_sessions') }}

    group by
        cast(session_start_timestamp as date),
        user_id

),

dates as (

    select distinct activity_date
    from daily_activity

),

final as (

    select
        d.activity_date,

        count(distinct case
            when a.activity_date = d.activity_date
            then a.user_id
        end) as dau,

        count(distinct case
            when a.activity_date between dateadd('day', -6, d.activity_date)
                                    and d.activity_date
            then a.user_id
        end) as wau,

        count(distinct case
            when a.activity_date between dateadd('day', -29, d.activity_date)
                                    and d.activity_date
            then a.user_id
        end) as mau

    from dates d

    left join daily_activity a
        on a.activity_date between dateadd('day', -29, d.activity_date)
                              and d.activity_date

    group by d.activity_date

)

select
    activity_date,
    dau,
    wau,
    mau,

    round(
        100.0 * dau / nullif(mau, 0),
        2
    ) as dau_mau_ratio_pct

from final