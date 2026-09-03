with source_marketing as (

    select *
    from {{ source('raw', 'marketing_attribution') }}

),

deduplicated as (

    select *,
        row_number() over (
            partition by attribution_id
            order by attributed_timestamp
        ) as row_num
    from source_marketing

),

cleaned as (

    select
        trim(attribution_id) as attribution_id,
        nullif(trim(user_id), '') as user_id,

        case
            when acquisition_channel in (
                'Organic Search',
                'Paid Search',
                'Social',
                'Direct',
                'Referral',
                'Partner',
                'Email'
            )
            then acquisition_channel
            else null
        end as acquisition_channel,

        nullif(trim(source), '') as source,

        case
            when medium in (
                'organic',
                'cpc',
                'social',
                'direct',
                'referral',
                'partner',
                'email'
            )
            then medium
            else null
        end as medium,

        nullif(trim(campaign_name), '') as campaign_name,
        nullif(trim(campaign_id), '') as campaign_id,

        try_to_timestamp(attributed_timestamp) as attributed_timestamp,

        nullif(trim(landing_page), '') as landing_page

    from deduplicated
    where row_num = 1

),

validated as (

    select
        c.attribution_id,

        case
            when u.user_id is not null
            then c.user_id
            else null
        end as user_id,

        c.acquisition_channel,
        c.source,
        c.medium,
        c.campaign_name,
        c.campaign_id,
        c.attributed_timestamp,
        c.landing_page

    from cleaned c

    left join {{ ref('stg_users') }} u
        on c.user_id = u.user_id

)

select *
from validated