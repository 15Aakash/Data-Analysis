with source_users as (

    select *
    from {{ source('raw', 'users') }}

),

deduplicated as (

    select *,
        row_number() over (
            partition by user_id
            order by registration_timestamp
        ) as row_num
    from source_users

),

cleaned as (

    select
        trim(user_id) as user_id,

        case
            when organization_id = 'ORG99999' then null
            else trim(organization_id)
        end as organization_id,

        trim(first_name) as first_name,
        trim(last_name) as last_name,

        case
            when regexp_like(
                trim(email),
                '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$'
            )
            then lower(trim(email))
            else null
        end as email,

        nullif(trim(country), '') as country,

        case
            when try_to_timestamp(registration_timestamp) <= current_timestamp()
            then try_to_timestamp(registration_timestamp)
            else null
        end as registration_timestamp,

        case
            when signup_platform in ('Web', 'Android', 'iOS')
            then signup_platform
            else null
        end as signup_platform,

        case
            when account_status in ('Active', 'Suspended', 'Deleted')
            then account_status
            else null
        end as account_status,

        nullif(trim(acquisition_channel), '') as acquisition_channel

    from deduplicated
    where row_num = 1

)

select *
from cleaned