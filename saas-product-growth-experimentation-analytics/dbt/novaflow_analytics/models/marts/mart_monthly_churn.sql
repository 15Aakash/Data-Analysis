with subscriptions as (

    select
        subscription_id,
        plan_name,
        paid_plan_flag,
        subscription_start_date,
        subscription_end_date,
        subscription_status

    from {{ ref('mart_subscription_revenue') }}

    where paid_plan_flag = 1
      and subscription_start_date is not null

),

months as (

    select distinct
        date_trunc('month', subscription_start_date) as month_start
    from subscriptions

    union

    select distinct
        date_trunc('month', subscription_end_date) as month_start
    from subscriptions
    where subscription_end_date is not null

),

monthly_metrics as (

    select
        m.month_start,

        count_if(
            s.subscription_start_date < m.month_start
            and (
                s.subscription_end_date is null
                or s.subscription_end_date >= m.month_start
            )
        ) as paid_subscriptions_at_start,

        count_if(
            s.subscription_status = 'Cancelled'
            and s.subscription_end_date >= m.month_start
            and s.subscription_end_date < dateadd('month', 1, m.month_start)
        ) as churned_paid_subscriptions

    from months m

    cross join subscriptions s

    group by m.month_start

)

select
    month_start,
    paid_subscriptions_at_start,
    churned_paid_subscriptions,

    round(
        100.0 * churned_paid_subscriptions
        / nullif(paid_subscriptions_at_start, 0),
        2
    ) as monthly_churn_rate_pct

from monthly_metrics

where paid_subscriptions_at_start > 0
order by month_start