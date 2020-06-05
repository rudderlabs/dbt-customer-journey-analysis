# Customer Journey Analysis using DBT and RudderStack

This repository contains a sample DBT project for Rudder stack. It can be applied on Rudder data residing in BigQuery. 

This DBT project builds on top of the source table "tracks" which is created by default in all Rudder warehouse destinations. 

Data from the "tracks" table is used to first create a session abstraction and then prepare the sequence of 5 events triggered by the 
customer in course of a session. This sequence represents the customer's journey. Developers can add more number of events in the journey
by adding relevant code to `dbt_tracks_flow.sql`

This project was created on [**DBT Cloud**](https://cloud.getdbt.com). Hence there is no profiles.yml file with connection information. 
Developers who want to execute the models in Command Line Interface (CLI) mode will need to create additional configuration files 
following the directions provided [**here**](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/)

While this code has been tested for BigQuery, it should also be usable for other Rudder-supported data warehouses like Redshift and Snowflake. 
The only differences might arise with regards to functions related to timestamp handling and analytics. 
Even then, we believe the code should be usable by just replacing the BigQuery functions with their counterparts from Redshift or Snowflake as required.

The sequence in which the DBT models should be executed for a fresh run is as follows:
* dbt_aliases_mapping

This model/table has two attributes/columns - `alias` and `dbt_visitor_id`. This table captures the linkages between one or more `anonymous_id` values (`alias`) and a `user_id` (`dbt_visitor_id`).

* dbt_mapped_tracks

This table has columns - `event_id`, `anonymous_id`, `dbt_visitor_id`, `timestamp`, `event`, `idle_time_minutes`.
`event` represents the actual event name. `timestamp` corresponds to the instant when the event was actually generated.
`idle_time_minutes` captures the time gap between the event and the immediate preceeding one.

* dbt_session_tracks

This table contains columns - `session_id`, `dbt_visitor_id`, `session_start_at`, `session_sequence_number`, `next_session_start_at`. 

Data in the `dbt_mapped_tracks` table is partitioned first by `dbt_visitor_id`. It is then partitioned farther into 
groups of events where within one group the time-gap i.e. `idle_time_minutes` is not more than 30. In other words - if `idle_time_minutes`for an event is more than 30, a new group is created. 

These groups of sequential events are essentially the sessions.The value of 30 can be modified in the model definition. 
The `session_sequence_number` represent the order of the session for a particular user.
The `session_id` is of the form `session_sequence_number - dbt_visitor_id`.

* dbt_track_facts

This table has columns - `anonymous_id`, `timestamp`, `event_id`, `event`, `session_id`, `dbt_visitor_id`, 
`track_sequence_number`. 

In this table, the information from `dbt_session_tracks` is tied back to the records in the `dbt_mapped_tracks` table.
Each event is now tied to a `session_id` and within the session also, the event is assigned a `track_sequence_number`.

* dbt_tracks_flow

Columns in this table are - `event_id`, `session_id`, `track_sequence_number`, `event`, `dbt_visitor_id`, `timestamp`,
`event_2`, `event_3`, `event_4`, `event_5`. This is essentially a table where each event and 4 subsequent events are 
represented in each record. 

**Please remember to change `schema` in `tracks.yml` and `dbt_aliases_mapping.sql` to your database schema**
