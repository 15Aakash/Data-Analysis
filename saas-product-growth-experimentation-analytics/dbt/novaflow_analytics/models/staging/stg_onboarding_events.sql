with source_onboarding as (

    select *
    from {{ source('raw', 'onboarding_events') }}

),

deduplicated as (

    select *,
        row_number() over (
            partition by onboarding_event_id
            order by event_timestamp
        ) as row_num
    from source_onboarding

),

cleaned as (

    select
        trim(onboarding_event_id) as onboarding_event_id,
        nullif(trim(user_id), '') as user_id,

        case
            when onboarding_step in (
                'Account Created',
                'Email Verified',
                'Profile Completed',
                'Workspace Preferences',
                'Tutorial Completed',
                'First Project Created'
            )
            then onboarding_step
            else null
        end as onboarding_step,

        case
            when try_to_number(step_order) between 1 and 6
            then try_to_number(step_order)
            else null
        end as step_order,

        try_to_timestamp(event_timestamp) as event_timestamp,

        case
            when completion_status in ('Completed', 'Abandoned')
            then completion_status
            else null
        end as completion_status,

        case
            when try_to_number(time_spent_seconds) >= 0
            then try_to_number(time_spent_seconds)
            else null
        end as time_spent_seconds

    from deduplicated
    where row_num = 1

),

validated as (

    select
        c.onboarding_event_id,

        case
            when u.user_id is not null
            then c.user_id
            else null
        end as user_id,

        c.onboarding_step,
        c.step_order,
        c.event_timestamp,
        c.completion_status,
        c.time_spent_seconds

    from cleaned c

    left join {{ ref('stg_users') }} u
        on c.user_id = u.user_id

)

select *
from validated