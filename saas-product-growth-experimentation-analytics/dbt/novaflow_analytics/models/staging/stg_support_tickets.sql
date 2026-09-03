with source_tickets as (

    select *
    from {{ source('raw', 'support_tickets') }}

),

deduplicated as (

    select *,
        row_number() over (
            partition by ticket_id
            order by created_timestamp
        ) as row_num
    from source_tickets

),

cleaned as (

    select
        trim(ticket_id) as ticket_id,
        nullif(trim(user_id), '') as user_id,

        case
            when ticket_category in (
                'Product Issue',
                'Billing',
                'Feature Request',
                'Account',
                'Integration',
                'Performance',
                'Security'
            )
            then ticket_category
            else null
        end as ticket_category,

        case
            when priority in ('Low', 'Medium', 'High', 'Critical')
            then priority
            else null
        end as priority,

        try_to_timestamp(created_timestamp) as created_timestamp,
        try_to_timestamp(resolved_timestamp) as raw_resolved_timestamp,

        case
            when ticket_status in (
                'Open',
                'In Progress',
                'Resolved',
                'Closed'
            )
            then ticket_status
            else null
        end as ticket_status,

        case
            when try_to_number(satisfaction_score) between 1 and 5
            then try_to_number(satisfaction_score)
            else null
        end as satisfaction_score,

        case
            when try_to_decimal(resolution_time_hours, 12, 2) >= 0
            then try_to_decimal(resolution_time_hours, 12, 2)
            else null
        end as resolution_time_hours

    from deduplicated
    where row_num = 1

),

validated as (

    select
        c.ticket_id,

        case
            when u.user_id is not null
            then c.user_id
            else null
        end as user_id,

        c.ticket_category,
        c.priority,
        c.created_timestamp,

        case
            when c.raw_resolved_timestamp >= c.created_timestamp
            then c.raw_resolved_timestamp
            else null
        end as resolved_timestamp,

        c.ticket_status,
        c.satisfaction_score,
        c.resolution_time_hours

    from cleaned c

    left join {{ ref('stg_users') }} u
        on c.user_id = u.user_id

)

select *
from validated