{{ config(
	materialized="view"
	,alias='global_mart') }}


WITH q_payments AS(
select *
from {{ref('create_payments')}}
)
,q_orders AS(
select *
from {{ref('create_orders')}}
)
,q_customers AS(
select * 
from {{ref('create_customers')}}
)
SELECT q_payments.id as payment_id,q_payments.paymethod,q_payments.status as payment_status, q_payments.amount, q_payments.created
,q_payments.order_id, q_orders.order_date, q_orders.status as order_status
,q_orders.user_id, q_customers.first_name,q_customers.last_name
FROM q_payments LEFT JOIN q_orders ON q_payments.order_id = q_orders.id
LEFT JOIN q_customers ON q_orders.user_id = q_customers.id