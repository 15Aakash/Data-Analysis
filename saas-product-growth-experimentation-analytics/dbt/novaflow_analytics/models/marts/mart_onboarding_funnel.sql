with completed_steps as (

    select
        onboarding_step,
        step_order,
        count(distinct user_id) as users_completed

    from {{ ref('stg_onboarding_events') }}

    where completion_status = 'Completed'

    group by
        onboarding_step,
        step_order

),

with_previous as (

    select
        onboarding_step,
        step_order,
        users_completed,

        lag(users_completed) over (
            order by step_order
        ) as previous_step_users

    from completed_steps

),

final as (

    select
        onboarding_step,
        step_order,
        users_completed,

        round(
            100.0 * users_completed
            / max(users_completed) over (),
            2
        ) as conversion_from_start_pct,

        case
            when previous_step_users is null then 100.00
            else round(
                100.0 * users_completed / previous_step_users,
                2
            )
        end as step_conversion_pct,

        case
            when previous_step_users is null then 0.00
            else round(
                100.0 * (previous_step_users - users_completed)
                / previous_step_users,
                2
            )
        end as step_dropoff_pct

    from with_previous

)

select *
from final
order by step_order