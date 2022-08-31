{{ config(
	materialized="table"
	,alias='payments') }}


select
 _AIRBYTE_DATA:ID::integer as id
,_AIRBYTE_DATA:ORDERID::integer as order_id
,_AIRBYTE_DATA:PAYMENTMETHOD::string as paymethod
,_AIRBYTE_DATA:STATUS::string as status
,_AIRBYTE_DATA:AMOUNT::float as amount
,_AIRBYTE_DATA:CREATED::date as created
from {{ source('STAGING','_AIRBYTE_RAW_JAFFLE_SHOP_STRIPE_PAYMENTS') }}