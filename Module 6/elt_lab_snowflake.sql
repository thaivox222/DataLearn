
-- define tables schemas for airbyte sources

 -- jaffle_shop_stripe_payments 
{"ID":"number","ORDERID":"number","PAYMENTMETHOD":"string","STATUS":"string","AMOUNT":"number","CREATED":"string"}

-- jaffle_shop_customers.csv
{"ID":"number","FIRST_NAME":"string","LAST_NAME":"string"}

-- jaffle_shop_orders.csv
{"ID":"number","USER_ID":"number","ORDER_DATE":"string","STATUS":"string"}


-- Selection from table with json-field
select
 _AIRBYTE_DATA:ID as id
,_AIRBYTE_DATA:FIRST_NAME as first_name
,_AIRBYTE_DATA:LAST_NAME as last_name
from _AIRBYTE_RAW_JAFFLE_SHOP_CUSTOMERS


select
 _AIRBYTE_DATA:ID as id
,_AIRBYTE_DATA:USER_ID as user_id
,_AIRBYTE_DATA:ORDER_DATE as order_date
,_AIRBYTE_DATA:STATUS as status
from _AIRBYTE_RAW_JAFFLE_SHOP_ORDERS

select
 _AIRBYTE_DATA:ID as id
,_AIRBYTE_DATA:ORDERID as order_id
,_AIRBYTE_DATA:PAYMENTMETHOD as paymethod
,_AIRBYTE_DATA:STATUS as status
,_AIRBYTE_DATA:AMOUNT as amount
,_AIRBYTE_DATA:CREATED as created
from _AIRBYTE_RAW_JAFFLE_SHOP_STRIPE_PAYMENTS


-- Версии запросов с реплейсом кавычек
select
 _AIRBYTE_DATA:ID as id
,replace(_AIRBYTE_DATA:FIRST_NAME,'""', '') as first_name
,replace(_AIRBYTE_DATA:LAST_NAME,'""', '') as last_name
from _AIRBYTE_RAW_JAFFLE_SHOP_CUSTOMERS

select
 _AIRBYTE_DATA:ID as id
,_AIRBYTE_DATA:USER_ID as user_id
,replace(_AIRBYTE_DATA:ORDER_DATE,'""', '') as order_date
,replace(_AIRBYTE_DATA:STATUS,'""', '') as status
from _AIRBYTE_RAW_JAFFLE_SHOP_ORDERS

select
 _AIRBYTE_DATA:ID as id
,_AIRBYTE_DATA:ORDERID as order_id
,replace(_AIRBYTE_DATA:PAYMENTMETHOD,'""', '') as paymethod
,replace(_AIRBYTE_DATA:STATUS,'""', '') as status
,_AIRBYTE_DATA:AMOUNT as amount
,replace(_AIRBYTE_DATA:CREATED,'""', '') as created
from _AIRBYTE_RAW_JAFFLE_SHOP_STRIPE_PAYMENTS



--На самомм деле, можно кастовать филды прямо в селекте и тогда реплейсмент не нужен!
select
 _AIRBYTE_DATA:ID::integer as id
,_AIRBYTE_DATA:FIRST_NAME::string as first_name
,_AIRBYTE_DATA:LAST_NAME::string as last_name
from _AIRBYTE_RAW_JAFFLE_SHOP_CUSTOMERS


select
 _AIRBYTE_DATA:ID::integer as id
,_AIRBYTE_DATA:USER_ID::integer as user_id
,_AIRBYTE_DATA:ORDER_DATE::date as order_date
,_AIRBYTE_DATA:STATUS::string as status
from _AIRBYTE_RAW_JAFFLE_SHOP_ORDERS

select
 _AIRBYTE_DATA:ID::integer as id
,_AIRBYTE_DATA:ORDERID::integer as order_id
,_AIRBYTE_DATA:PAYMENTMETHOD::string as paymethod
,_AIRBYTE_DATA:STATUS::string as status
,_AIRBYTE_DATA:AMOUNT::float as amount
,_AIRBYTE_DATA:CREATED::date as created
from _AIRBYTE_RAW_JAFFLE_SHOP_STRIPE_PAYMENTS



-- сборка витрины
WITH q_payments AS(
select
 _AIRBYTE_DATA:ID::integer as id
,_AIRBYTE_DATA:ORDERID::integer as order_id
,_AIRBYTE_DATA:PAYMENTMETHOD::string as paymethod
,_AIRBYTE_DATA:STATUS::string as status
,_AIRBYTE_DATA:AMOUNT::float as amount
,_AIRBYTE_DATA:CREATED::date as created
from _AIRBYTE_RAW_JAFFLE_SHOP_STRIPE_PAYMENTS
)
,q_orders AS(
select
 _AIRBYTE_DATA:ID::integer as id
,_AIRBYTE_DATA:USER_ID::integer as user_id
,_AIRBYTE_DATA:ORDER_DATE::date as order_date
,_AIRBYTE_DATA:STATUS::string as status
from _AIRBYTE_RAW_JAFFLE_SHOP_ORDERS
)
,q_customers AS(
select
 _AIRBYTE_DATA:ID::integer as id
,_AIRBYTE_DATA:FIRST_NAME::string as first_name
,_AIRBYTE_DATA:LAST_NAME::string as last_name
from _AIRBYTE_RAW_JAFFLE_SHOP_CUSTOMERS
)
SELECT q_payments.id as payment_id,q_payments.paymethod,q_payments.status as paymennt_status, q_payments.amount, q_payments.created
,q_payments.order_id, q_orders.order_date, q_orders.status as order_status
,q_orders.user_id, q_customers.first_name,q_customers.last_name
FROM q_payments LEFT JOIN q_orders ON q_payments.order_id = q_orders.id
LEFT JOIN q_customers ON q_orders.user_id = q_customers.id

