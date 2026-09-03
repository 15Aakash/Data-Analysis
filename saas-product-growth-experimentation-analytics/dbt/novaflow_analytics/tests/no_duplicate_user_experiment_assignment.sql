select
    experiment_id,
    user_id,
    count(*) as assignment_count

from {{ ref('stg_experiment_assignments') }}

group by
    experiment_id,
    user_id

having count(*) > 1