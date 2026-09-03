with subscriptions as (

    select
        subscription_id,
        user_id,
        organization_id,
        plan_id,
        subscription_start_date,
        subscription_end_date,
        billing_cycle,
        subscription_status,
        auto_renew_flag
    from {{ ref('stg_subscriptions') }}

),

plans as (

    select
        plan_id,
        plan_name,
        monthly_price,
        annual_price
    from {{ ref('stg_plans') }}

),

joined as (

    select
        s.subscription_id,
        s.user_id,
        s.organization_id,

        case
            when s.user_id is not null then 'User'
            when s.organization_id is not null then 'Organization'
            else 'Unknown'
        end as customer_type,

        coalesce(s.user_id, s.organization_id) as customer_id,

        s.plan_id,
        p.plan_name,
        p.monthly_price,
        p.annual_price,

        s.billing_cycle,
        s.subscription_status,
        s.subscription_start_date,
        s.subscription_end_date,
        s.auto_renew_flag,

        case
            when p.monthly_price > 0 then 1
            else 0
        end as paid_plan_flag,

        case
            when s.subscription_status = 'Active' then 1
            else 0
        end as active_subscription_flag,

        case
            when s.plan_id is not null
             and s.billing_cycle in ('Monthly', 'Annual')
             and s.subscription_status = 'Active'
            then 1
            else 0
        end as revenue_eligible_flag

    from subscriptions s

    left join plans p
        on s.plan_id = p.plan_id

),

revenue as (

    select
        *,

        case
            when revenue_eligible_flag = 1
             and billing_cycle = 'Monthly'
            then monthly_price

            when revenue_eligible_flag = 1
             and billing_cycle = 'Annual'
            then annual_price / 12.0

            else 0
        end as current_mrr

    from joined

)

select
    *,
    current_mrr * 12 as current_arr
from revenue