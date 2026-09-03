with source_events as (

    select *
    from {{ source('raw', 'product_events') }}

),

deduplicated as (

    select *,
        row_number() over (
            partition by event_id
            order by event_timestamp
        ) as row_num
    from source_events

),

cleaned as (

    select
        trim(event_id) as event_id,
        nullif(trim(user_id), '') as user_id,
        nullif(trim(session_id), '') as session_id,
        nullif(trim(feature_id), '') as feature_id,

        nullif(trim(event_name), '') as event_name,

        try_to_timestamp(event_timestamp) as event_timestamp,

        case
            when platform in ('Web', 'Android', 'iOS')
            then platform
            else null
        end as platform,

        nullif(trim(event_value), '') as event_value

    from deduplicated
    where row_num = 1

),

validated as (

    select
        c.event_id,

        case
            when u.user_id is not null
            then c.user_id
            else null
        end as user_id,

        case
            when s.session_id is not null
            then c.session_id
            else null
        end as session_id,

        case
            when f.feature_id is not null
            then c.feature_id
            else null
        end as feature_id,

        c.event_name,
        c.event_timestamp,
        c.platform,
        c.event_value

    from cleaned c

    left join {{ ref('stg_users') }} u
        on c.user_id = u.user_id

    left join {{ ref('stg_sessions') }} s
        on c.session_id = s.session_id

    left join {{ ref('stg_features') }} f
        on c.feature_id = f.feature_id

)

select *
from validated