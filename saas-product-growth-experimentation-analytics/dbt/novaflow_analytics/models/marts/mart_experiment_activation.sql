with assignments as (

    select
        assignment_id,
        experiment_id,
        user_id,
        experiment_group,
        assigned_timestamp,
        exposure_timestamp

    from {{ ref('stg_experiment_assignments') }}

    where experiment_id = 'EXP001'

),

activation as (

    select
        user_id,
        activated_7d_flag
    from {{ ref('mart_user_activation') }}

),

joined as (

    select
        a.assignment_id,
        a.experiment_id,
        a.user_id,
        a.experiment_group,
        a.assigned_timestamp,
        a.exposure_timestamp,

        coalesce(u.activated_7d_flag, 0) as activated_7d_flag

    from assignments a

    left join activation u
        on a.user_id = u.user_id

),

group_results as (

    select
        experiment_id,
        experiment_group,

        count(*) as assigned_users,

        sum(activated_7d_flag) as activated_users,

        round(
            100.0 * sum(activated_7d_flag)
            / nullif(count(*), 0),
            2
        ) as activation_rate_pct

    from joined

    group by
        experiment_id,
        experiment_group

)

select *
from group_results