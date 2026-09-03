with source_subscriptions as (

    select *
    from {{ source('raw', 'subscriptions') }}

),

deduplicated as (

    select *,
        row_number() over (
            partition by subscription_id
            order by subscription_start_date
        ) as row_num
    from source_subscriptions

),

cleaned as (

    select
        trim(subscription_id) as subscription_id,
        nullif(trim(user_id), '') as user_id,
        nullif(trim(organization_id), '') as organization_id,
        nullif(trim(plan_id), '') as plan_id,

        try_to_date(subscription_start_date) as subscription_start_date,
        try_to_date(subscription_end_date) as raw_subscription_end_date,

        case
            when billing_cycle in ('Monthly', 'Annual')
            then billing_cycle
            else null
        end as billing_cycle,

        case
            when subscription_status in (
                'Active',
                'Cancelled',
                'Expired',
                'Trial'
            )
            then subscription_status
            else null
        end as subscription_status,

        try_to_boolean(auto_renew_flag) as auto_renew_flag,

        nullif(trim(cancellation_reason), '') as cancellation_reason

    from deduplicated
    where row_num = 1

),

validated as (

    select
        c.subscription_id,

        case
            when c.user_id is not null
                 and c.organization_id is null
                 and u.user_id is not null
            then c.user_id
            else null
        end as user_id,

        case
            when c.organization_id is not null
                 and c.user_id is null
                 and o.organization_id is not null
            then c.organization_id
            else null
        end as organization_id,

        case
            when p.plan_id is not null
            then c.plan_id
            else null
        end as plan_id,

        c.subscription_start_date,

        case
            when c.raw_subscription_end_date >= c.subscription_start_date
            then c.raw_subscription_end_date
            else null
        end as subscription_end_date,

        c.billing_cycle,
        c.subscription_status,
        c.auto_renew_flag,
        c.cancellation_reason

    from cleaned c

    left join {{ ref('stg_users') }} u
        on c.user_id = u.user_id

    left join {{ ref('stg_organizations') }} o
        on c.organization_id = o.organization_id

    left join {{ ref('stg_plans') }} p
        on c.plan_id = p.plan_id

)

select *
from validated