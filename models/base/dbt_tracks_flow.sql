/*

we leverage analytic functions like first_value and nth_value to create 5-event sequences that capture the flow of events during a session. 5 can be increased or decreased as per requirements.

*/

{{ config(materialized='table') }}

with derived_table as (
    select
        event_id,
        session_id,
        track_sequence_number,
        first_value(event ignore nulls) over (partition by session_id order by track_sequence_number asc) as event,
        dbt_visitor_id,
        timestamp,
        nth_value(event, 2) ignore nulls over (partition by session_id order by track_sequence_number asc) as second_event,
        nth_value(event, 3) ignore nulls over (partition by session_id order by track_sequence_number asc) as third_event,
        nth_value(event, 4) ignore nulls over (partition by session_id order by track_sequence_number asc) as fourth_event,
        nth_value(event, 5) ignore nulls over (partition by session_id order by track_sequence_number asc) as fifth_event
    from {{ ref('dbt_track_facts') }}
)
select
    event_id,
    session_id,
    track_sequence_number,
    event,
    dbt_visitor_id,
    cast(timestamp as timestamp) as timestamp,
    second_event as event_2,
    third_event as event_3,
    fourth_event as event_4,
    fifth_event as event_5
from derived_table a
