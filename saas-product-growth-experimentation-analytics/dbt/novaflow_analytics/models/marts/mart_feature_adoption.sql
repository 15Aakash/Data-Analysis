with feature_usage as (

    select
        pe.feature_id,
        f.feature_name,
        f.feature_category,
        f.minimum_plan,

        count(*) as total_events,
        count(distinct pe.user_id) as unique_users,
        count(distinct pe.session_id) as unique_sessions

    from {{ ref('stg_product_events') }} pe

    inner join {{ ref('stg_features') }} f
        on pe.feature_id = f.feature_id

    where pe.feature_id is not null

    group by
        pe.feature_id,
        f.feature_name,
        f.feature_category,
        f.minimum_plan

),

total_active_users as (

    select
        count(distinct user_id) as active_users
    from {{ ref('stg_product_events') }}

)

select
    f.feature_id,
    f.feature_name,
    f.feature_category,
    f.minimum_plan,
    f.total_events,
    f.unique_users,
    f.unique_sessions,

    round(
        100.0 * f.unique_users
        / nullif(t.active_users, 0),
        2
    ) as feature_adoption_pct

from feature_usage f

cross join total_active_users t