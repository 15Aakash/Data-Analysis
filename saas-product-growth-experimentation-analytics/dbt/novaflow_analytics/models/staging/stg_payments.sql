with source_payments as (

    select *
    from {{ source('raw', 'payments') }}

),

deduplicated as (

    select *,
        row_number() over (
            partition by payment_id
            order by payment_timestamp
        ) as row_num
    from source_payments

),

cleaned as (

    select
        trim(payment_id) as payment_id,
        nullif(trim(subscription_id), '') as subscription_id,

        try_to_timestamp(payment_timestamp) as payment_timestamp,

        case
            when try_to_decimal(amount, 12, 2) >= 0
            then try_to_decimal(amount, 12, 2)
            else null
        end as amount,

        case
            when currency = 'USD'
            then currency
            else null
        end as currency,

        case
            when payment_status in ('Successful', 'Failed', 'Refunded')
            then payment_status
            else null
        end as payment_status,

        case
            when payment_method_type in ('Card', 'PayPal', 'Bank Transfer')
            then payment_method_type
            else null
        end as payment_method_type,

        nullif(trim(invoice_id), '') as invoice_id

    from deduplicated
    where row_num = 1

),

validated as (

    select
        c.payment_id,

        case
            when s.subscription_id is not null
            then c.subscription_id
            else null
        end as subscription_id,

        c.payment_timestamp,
        c.amount,
        c.currency,
        c.payment_status,
        c.payment_method_type,
        c.invoice_id

    from cleaned c

    left join {{ ref('stg_subscriptions') }} s
        on c.subscription_id = s.subscription_id

)

select *
from validated