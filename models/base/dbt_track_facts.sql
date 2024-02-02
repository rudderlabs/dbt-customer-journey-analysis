/*

below code creates a table to link the track events to the session they belong to. the session association is established via the user identifier linkage and the user session start timestamp.

so if a user u1 has session s1 with start time as t1 and session s2 with start time as t2 - then event e for user u1 would belong to session s1 if its timestamp falls between t1 and t2 or if t2 is null. the second case occurs for the last recorded session for that user.

*/


{{ config(materialized='table') }}

select
    t.anonymous_id,
    t.timestamp,
    t.event_id,
    t.event as event,
    s.session_id,
    t.dbt_visitor_id,
    row_number() over (partition by s.session_id order by t.timestamp) as track_sequence_number
from {{ ref('dbt_mapped_tracks') }} as t
inner join {{ ref('dbt_session_tracks') }} as s
    on
        t.dbt_visitor_id = s.dbt_visitor_id
        and t.timestamp >= s.session_start_at
        and (t.timestamp < s.next_session_start_at or s.next_session_start_at is null)
