with source_organizations as (

    select *
    from {{ source('raw', 'organizations') }}

),

deduplicated as (

    select *,
        row_number() over (
            partition by organization_id
            order by created_timestamp
        ) as row_num
    from source_organizations

),

cleaned as (

    select
        trim(organization_id) as organization_id,
        nullif(trim(organization_name), '') as organization_name,
        nullif(trim(industry), '') as industry,

        case
            when company_size in ('Small', 'Medium', 'Enterprise')
            then company_size
            else null
        end as company_size,

        nullif(trim(country), '') as country,

        try_to_timestamp(created_timestamp) as created_timestamp,

        case
            when organization_status in ('Active', 'Suspended', 'Closed')
            then organization_status
            else null
        end as organization_status

    from deduplicated
    where row_num = 1

)

select *
from cleaned