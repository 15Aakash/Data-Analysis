with source_experiments as (

    select *
    from {{ source('raw', 'experiments') }}

),

deduplicated as (

    select *,
        row_number() over (
            partition by experiment_id
            order by start_date
        ) as row_num
    from source_experiments

),

cleaned as (

    select
        trim(experiment_id) as experiment_id,
        nullif(trim(experiment_name), '') as experiment_name,
        nullif(trim(experiment_description), '') as experiment_description,

        case
            when primary_metric in (
                'Activation Rate',
                'Paid Conversion Rate',
                'Feature Adoption Rate'
            )
            then primary_metric
            else null
        end as primary_metric,

        try_to_date(start_date) as start_date,
        try_to_date(end_date) as raw_end_date,

        case
            when experiment_status in ('Completed', 'Running')
            then experiment_status
            else null
        end as experiment_status

    from deduplicated
    where row_num = 1

),

validated as (

    select
        experiment_id,
        experiment_name,
        experiment_description,
        primary_metric,
        start_date,

        case
            when raw_end_date is null then null
            when raw_end_date >= start_date then raw_end_date
            else null
        end as end_date,

        experiment_status

    from cleaned

)

select *
from validated