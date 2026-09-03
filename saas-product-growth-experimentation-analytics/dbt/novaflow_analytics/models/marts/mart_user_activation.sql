with users as (

    select
        user_id,
        registration_timestamp,
        signup_platform,
        country,
        acquisition_channel
    from {{ ref('stg_users') }}

),

first_project as (

    select
        user_id,
        min(event_timestamp) as first_project_created_timestamp
    from {{ ref('stg_onboarding_events') }}
    where onboarding_step = 'First Project Created'
      and completion_status = 'Completed'
    group by user_id

),

final as (

    select
        u.user_id,
        u.registration_timestamp,
        u.signup_platform,
        u.country,
        u.acquisition_channel,

        fp.first_project_created_timestamp,

        datediff(
            'day',
            u.registration_timestamp,
            fp.first_project_created_timestamp
        ) as days_to_activation,

        case
            when fp.first_project_created_timestamp >= u.registration_timestamp
             and fp.first_project_created_timestamp
                    <= dateadd('day', 7, u.registration_timestamp)
            then 1
            else 0
        end as activated_7d_flag

    from users u

    left join first_project fp
        on u.user_id = fp.user_id

)

select *
from final