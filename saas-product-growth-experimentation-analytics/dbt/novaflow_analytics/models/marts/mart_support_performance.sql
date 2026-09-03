with tickets as (

    select
        ticket_id,
        user_id,
        ticket_category,
        priority,
        created_timestamp,
        resolved_timestamp,
        ticket_status,
        satisfaction_score,
        resolution_time_hours
    from {{ ref('stg_support_tickets') }}

),

final as (

    select
        ticket_category,
        priority,

        count(*) as total_tickets,

        count_if(
            ticket_status in ('Resolved', 'Closed')
        ) as resolved_tickets,

        count_if(
            ticket_status in ('Open', 'In Progress')
        ) as unresolved_tickets,

        round(
            avg(resolution_time_hours),
            2
        ) as avg_resolution_time_hours,

        round(
            avg(satisfaction_score),
            2
        ) as avg_satisfaction_score,

        round(
            100.0 *
            count_if(ticket_status in ('Resolved', 'Closed'))
            / nullif(count(*), 0),
            2
        ) as resolution_rate_pct

    from tickets

    group by
        ticket_category,
        priority

)

select *
from final