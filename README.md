# Customer Journey Analysis using DBT and RudderStack

This repository contains a sample DBT project for RudderStack. It can be applied on the RudderStack data residing in Google BigQuery. 

## Overview

This DBT project builds on top of the source table `tracks` which is created by default in all the RudderStack warehouse destinations. 

The data from the `tracks` table is used to first create a session abstraction and then prepare the sequence of 5 events triggered by the customer during the course of a session. This sequence represents the customer's journey. You can add more number of events in the journey by adding the necessary code to `dbt_tracks_flow.sql`.

## How to Use This Repository

This project was created on the [**DBT Cloud**](https://cloud.getdbt.com). Hence there is no `profiles.yml` file with the connection information.

Developers who want to execute the models on the Command Line Interface (CLI) mode will need to create additional configuration files by 
following the directions provided [here](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/).

**Note**: While this code has been tested for Google BigQuery, it should also be usable for other RudderStack-supported data warehouses like Amazon Redshift and Snowflake. The only differences that might arise are with regards to the functions related to timestamp handling and analytics. Even then, we believe the code should be usable by replacing the BigQuery functions with their counterparts from Redshift or Snowflake, as required.

### Sequence of Commands

The sequence in which the DBT models should be executed for a fresh run is as follows:
- `dbt_aliases_mapping`

This model/table has two attributes/columns - `alias` and `dbt_visitor_id`. This table captures the linkages between one or more `anonymous_id` values (`alias`) and a `user_id` (`dbt_visitor_id`).

- `dbt_mapped_tracks`

This table has the columns `event_id`, `anonymous_id`, `dbt_visitor_id`, `timestamp`, `event`, and `idle_time_minutes`.

`event` represents the actual event name. `timestamp` corresponds to the instant when the event was actually generated.
`idle_time_minutes` captures the time gap between the current event and the immediately preceding one.

- `dbt_session_tracks`

This table contains the columns `session_id`, `dbt_visitor_id`, `session_start_at`, `session_sequence_number`, and `next_session_start_at`. 

The data in the `dbt_mapped_tracks` table is partitioned first by `dbt_visitor_id`. It is then partitioned further into 
groups of events where the time gap within one group i.e. `idle_time_minutes` is not more than 30 minutes. In other words - if `idle_time_minutes`for an event is more than 30, a new group is created. 

Some important points to note:

  1. These groups of sequential events are essentially the sessions.The value of `idle_time_minutes` can be modified in the model definition. 
  2. The `session_sequence_number` represents the order of the session for a particular user.
  3. The `session_id` is of the form `session_sequence_number - dbt_visitor_id`.

- `dbt_track_facts`

This table has the columns `anonymous_id`, `timestamp`, `event_id`, `event`, `session_id`, `dbt_visitor_id`, and 
`track_sequence_number`. 

In this table, the information from `dbt_session_tracks` is tied back to the records in the `dbt_mapped_tracks` table.
Each event is now tied to a `session_id` and within the session, the event is assigned a `track_sequence_number`.

- `dbt_tracks_flow`

The columns in this table are `event_id`, `session_id`, `track_sequence_number`, `event`, `dbt_visitor_id`, `timestamp`,
`event_2`, `event_3`, `event_4`, and `event_5`. This is essentially a table where each event and 4 subsequent events are 
represented in each record. 

**Note**: Please remember to change `schema` in `tracks.yml` and `dbt_aliases_mapping.sql` to your database schema.

# What is RudderStack?

[RudderStack](https://rudderstack.com/) is a **customer data pipeline** tool for collecting, routing and processing data from your websites, apps, cloud tools, and data warehouse.

More information on RudderStack can be found [here](https://github.com/rudderlabs/rudder-server).

## Contact us

If you come across any issues while configuring or using this project, please feel free to start a conversation on our [Slack](https://resources.rudderstack.com/join-rudderstack-slack) channel. We will be happy to help you.
