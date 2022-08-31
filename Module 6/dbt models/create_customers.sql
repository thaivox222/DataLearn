{{ config(
	materialized="table"
	,alias='customers') }}


select
 _AIRBYTE_DATA:ID::integer as id
,_AIRBYTE_DATA:FIRST_NAME::string as first_name
,_AIRBYTE_DATA:LAST_NAME::string as last_name
from {{ source('STAGING','_AIRBYTE_RAW_JAFFLE_SHOP_CUSTOMERS') }}