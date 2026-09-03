with source_features as (

    select *
    from {{ source('raw', 'features') }}

),

deduplicated as (

    select *,
        row_number() over (
            partition by feature_id
            order by launch_date
        ) as row_num
    from source_features

),

cleaned as (

    select
        trim(feature_id) as feature_id,
        nullif(trim(feature_name), '') as feature_name,

        case
            when feature_category in (
                'Core',
                'Collaboration',
                'Integration',
                'Automation',
                'Reporting',
                'Security',
                'AI'
            )
            then feature_category
            else null
        end as feature_category,

        case
            when minimum_plan in ('Free', 'Pro', 'Business')
            then minimum_plan
            else null
        end as minimum_plan,

        case
            when feature_status in ('Active', 'Beta')
            then feature_status
            else null
        end as feature_status,

        try_to_date(launch_date) as launch_date

    from deduplicated
    where row_num = 1

)

select *
from cleaned