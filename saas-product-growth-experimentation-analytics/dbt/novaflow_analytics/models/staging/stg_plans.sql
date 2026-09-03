with source_plans as (

    select *
    from {{ source('raw', 'plans') }}

),

cleaned as (

    select
        trim(plan_id) as plan_id,
        nullif(trim(plan_name), '') as plan_name,

        try_to_decimal(monthly_price, 10, 2) as monthly_price,
        try_to_decimal(annual_price, 10, 2) as annual_price,

        try_to_number(max_users) as max_users,
        try_to_number(storage_limit_gb) as storage_limit_gb,

        case
            when plan_status = 'Active'
            then plan_status
            else null
        end as plan_status

    from source_plans

)

select *
from cleaned