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
* dbt_mapped_tracks
* dbt_session_tracks
* dbt_track_facts
* dbt_tracks_flow

**Please remember to change `schema` in `tracks.yml` and `dbt_aliases_mapping.sql` to your database schema**
