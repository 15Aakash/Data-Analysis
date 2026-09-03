with users as (

    select
        user_id,
        cast(registration_timestamp as date) as registration_date,
        signup_platform,
        acquisition_channel
    from {{ ref('stg_users') }}
    where registration_timestamp is not null

),

activity as (

    select distinct
        user_id,
        cast(session_start_timestamp as date) as activity_date
    from {{ ref('stg_sessions') }}

),

observation_period as (

    select
        max(activity_date) as max_activity_date
    from activity

),

retention_flags as (

    select
        u.user_id,
        u.registration_date,
        u.signup_platform,
        u.acquisition_channel,

        case
            when dateadd('day', 1, u.registration_date) <= o.max_activity_date
            then 1 else 0
        end as eligible_d1_flag,

        case
            when dateadd('day', 7, u.registration_date) <= o.max_activity_date
            then 1 else 0
        end as eligible_d7_flag,

        case
            when dateadd('day', 30, u.registration_date) <= o.max_activity_date
            then 1 else 0
        end as eligible_d30_flag,

        max(
            case
                when a.activity_date = dateadd('day', 1, u.registration_date)
                then 1 else 0
            end
        ) as retained_d1_flag,

        max(
            case
                when a.activity_date = dateadd('day', 7, u.registration_date)
                then 1 else 0
            end
        ) as retained_d7_flag,

        max(
            case
                when a.activity_date = dateadd('day', 30, u.registration_date)
                then 1 else 0
            end
        ) as retained_d30_flag

    from users u

    cross join observation_period o

    left join activity a
        on u.user_id = a.user_id
       and a.activity_date between
           dateadd('day', 1, u.registration_date)
           and dateadd('day', 30, u.registration_date)

    group by
        u.user_id,
        u.registration_date,
        u.signup_platform,
        u.acquisition_channel,
        o.max_activity_date

)

select *
from retention_flags