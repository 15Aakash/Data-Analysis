with activation as (

    select
        count(*) as total_users,
        sum(activated_7d_flag) as activated_users,
        round(
            100.0 * sum(activated_7d_flag) / nullif(count(*), 0),
            2
        ) as activation_rate_pct
    from {{ ref('mart_user_activation') }}

),

engagement as (

    select
        activity_date,
        dau,
        wau,
        mau,
        dau_mau_ratio_pct
    from {{ ref('mart_daily_engagement') }}
    qualify row_number() over (
        order by activity_date desc
    ) = 1

),

revenue as (

    select
        round(sum(current_mrr), 2) as mrr,
        round(sum(current_arr), 2) as arr,

        count_if(
            active_subscription_flag = 1
            and paid_plan_flag = 1
        ) as active_paid_subscriptions,

        round(
            100.0 *
            count_if(
                active_subscription_flag = 1
                and paid_plan_flag = 1
            )
            /
            nullif(
                count_if(active_subscription_flag = 1),
                0
            ),
            2
        ) as active_paid_share_pct

    from {{ ref('mart_subscription_revenue') }}

),

churn as (

    select
        month_start,
        monthly_churn_rate_pct
    from {{ ref('mart_monthly_churn') }}
    where month_start < date_trunc('month', current_date)
    qualify row_number() over (
        order by month_start desc
    ) = 1

)

select
    a.total_users,
    a.activated_users,
    a.activation_rate_pct,

    e.activity_date as engagement_as_of_date,
    e.dau,
    e.wau,
    e.mau,
    e.dau_mau_ratio_pct,

    r.mrr,
    r.arr,
    r.active_paid_subscriptions,
    r.active_paid_share_pct,

    c.month_start as churn_month,
    c.monthly_churn_rate_pct

from activation a
cross join engagement e
cross join revenue r
cross join churn c