with source_sessions as (

    select *
    from {{ source('raw', 'sessions') }}

),

deduplicated as (

    select *,
        row_number() over (
            partition by session_id
            order by session_start_timestamp
        ) as row_num
    from source_sessions

),

cleaned as (

    select
        trim(session_id) as session_id,
        nullif(trim(user_id), '') as user_id,

        try_to_timestamp(session_start_timestamp) as session_start_timestamp,
        try_to_timestamp(session_end_timestamp) as raw_session_end_timestamp,

        case
            when platform in ('Web', 'Android', 'iOS')
            then platform
            else null
        end as platform,

        case
            when device_type in ('Desktop', 'Mobile', 'Tablet')
            then device_type
            else null
        end as device_type,

        case
            when session_status in ('Completed', 'Abandoned')
            then session_status
            else null
        end as session_status

    from deduplicated
    where row_num = 1

),

validated as (

    select
        c.session_id,

        case
            when u.user_id is not null
            then c.user_id
            else null
        end as user_id,

        c.session_start_timestamp,

        case
            when c.raw_session_end_timestamp >= c.session_start_timestamp
            then c.raw_session_end_timestamp
            else null
        end as session_end_timestamp,

        c.platform,
        c.device_type,
        c.session_status

    from cleaned c

    left join {{ ref('stg_users') }} u
        on c.user_id = u.user_id

)

select *
from validated