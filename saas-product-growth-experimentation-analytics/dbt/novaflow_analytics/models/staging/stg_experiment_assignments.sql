with source_assignments as (

    select *
    from {{ source('raw', 'experiment_assignments') }}

),

deduplicated as (

    select *,
        row_number() over (
            partition by assignment_id
            order by assigned_timestamp
        ) as row_num
    from source_assignments

),

cleaned as (

    select
        trim(assignment_id) as assignment_id,
        nullif(trim(experiment_id), '') as experiment_id,
        nullif(trim(user_id), '') as user_id,

        case
            when experiment_group in ('Control', 'Treatment')
            then experiment_group
            else null
        end as experiment_group,

        try_to_timestamp(assigned_timestamp) as assigned_timestamp,
        try_to_timestamp(exposure_timestamp) as raw_exposure_timestamp

    from deduplicated
    where row_num = 1

),

validated as (

    select
        c.assignment_id,

        case
            when e.experiment_id is not null
            then c.experiment_id
            else null
        end as experiment_id,

        case
            when u.user_id is not null
            then c.user_id
            else null
        end as user_id,

        c.experiment_group,
        c.assigned_timestamp,

        case
            when c.raw_exposure_timestamp >= c.assigned_timestamp
            then c.raw_exposure_timestamp
            else null
        end as exposure_timestamp

    from cleaned c

    left join {{ ref('stg_experiments') }} e
        on c.experiment_id = e.experiment_id

    left join {{ ref('stg_users') }} u
        on c.user_id = u.user_id

)

select *
from validated