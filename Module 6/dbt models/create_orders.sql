{{ config(
	materialized="table"
	,alias='orders') }}


select
 _AIRBYTE_DATA:ID::integer as id
,_AIRBYTE_DATA:USER_ID::integer as user_id
,_AIRBYTE_DATA:ORDER_DATE::date as order_date
,_AIRBYTE_DATA:STATUS::string as status
from {{ source('STAGING','_AIRBYTE_RAW_JAFFLE_SHOP_ORDERS') }}