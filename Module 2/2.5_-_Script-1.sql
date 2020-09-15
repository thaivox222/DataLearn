select count(*) from stg.orders

create schema dw;

--PRODUCTS TABLE
drop table if exists dw.products_dim

CREATE TABLE dw.products_dim
(
 "product_id"   serial NOT NULL,
 "category"     varchar(50) NOT NULL,
 "sub_cutegory" varchar(50) NOT NULL,
 "product_name" varchar(150) NOT NULL,
 CONSTRAINT "PK_products_dim" PRIMARY KEY (product_id)
);

--deleting rows
truncate table dw.products_dim ;
--inserting data
insert into dw.products_dim
select 100+row_number () over(), category, subcategory, product_name from
(select distinct category, subcategory, product_name from stg.orders)a;
--checking
select * from dw.products_dim cd;

--CLEANING SOURCE TABLE
--Checking null rows
select * from stg.orders
where city = 'Burlington' and postal_code is null;

--also update source file
update stg.orders
set postal_code = '05401'
where city = 'Burlington'  and postal_code is null;

--add new columm with channels and updating it
alter table stg.orders add column channel VARCHAR(15)
UPDATE stg.orders SET channel = 'Website'


--CLIENTS TABLE
drop table if exists dw.clients_dim ;

CREATE TABLE dw.clients_dim
(
 "customer_id"   int NOT NULL,
 "customer_name" varchar(100) NOT NULL,
 "segment"       varchar(30) NOT NULL,
 "country"       varchar(50) NOT NULL,
 "city"          varchar(30) NOT NULL,
 "state"         varchar(30) NOT NULL,
 "postal_code"   varchar(20) NOT null,
 "region"        varchar(30) NOT NULL,
 CONSTRAINT "PK_clients_dim" PRIMARY KEY (customer_id)
);

--updating dw.clients
insert into dw.clients_dim
select 200+row_number () over(), customer_name , segment , country, city, state, postal_code, region from
(select distinct customer_name , segment , country, city, state, postal_code, region from stg.orders)a;

--data quality check. must be 0 rows
select distinct country, city, state, postal_code from dw.clients_dim
where country is null or city is null or postal_code is null;

--SHIPPING TABLE
drop table if exists dw.shipping_dim ;
CREATE TABLE dw.shipping_dim
(
 "ship_mode_id" int NOT NULL,
 "ship_mode"    varchar(30) NOT NULL,
 CONSTRAINT "PK_shipping_dim" PRIMARY KEY (ship_mode_id)
);

--updating dw.shipping_dim
insert into dw.shipping_dim 
select 300+row_number () over(), ship_mode from (select distinct ship_mode from stg.orders) a;

select * from dw.shipping_dim

--CHANNELS TABLE
drop table if exists dw.channels_dim;
CREATE TABLE dw.channels_dim
(
 "channel_id" int NOT NULL,
 "channel"    varchar(30) NOT NULL,
 CONSTRAINT "PK_channels_dim" PRIMARY KEY ( "channel_id" )
);

--updating channels
insert into dw.channels_dim (channel_id, channel) values ('401','Website');
insert into dw.channels_dim (channel_id, channel) values ('402','Phone');
insert into dw.channels_dim (channel_id, channel) values ('403','Office');

select * from dw.channels_dim

--CREATING FACT TABLE
drop table if exists dw.sales_fact ;
CREATE TABLE dw.sales_fact
(
 "row_id"       int NOT NULL,
 "order_id"     varchar(50)NOT NULL,
 "sales"        decimal(15,2) NOT NULL,
 "quantity"     int NOT NULL,
 "discount"     decimal(5,2) NOT NULL,
 "profit"       decimal(15,2) NOT NULL,
 "order_date"   date NOT NULL,
 "ship_date"    date NOT NULL,
 "ship_mode_id" int NOT NULL,
 "product_id"   int NOT NULL,
 "customer_id"  int NOT NULL,
 "channel_id"   int NOT NULL,
 CONSTRAINT PK_sales_fact PRIMARY KEY (row_id),
 CONSTRAINT FK_67 FOREIGN KEY (ship_mode_id) REFERENCES dw.shipping_dim (ship_mode_id),
 CONSTRAINT FK_70 FOREIGN KEY (product_id) REFERENCES dw.products_dim (product_id),
 CONSTRAINT FK_73 FOREIGN KEY (customer_id) REFERENCES dw.clients_dim (customer_id),
 CONSTRAINT FK_76 FOREIGN KEY (channel_id) REFERENCES dw.channels_dim (channel_id)
);

--UPDATING FACT TABLE
insert into dw.sales_fact
select
100+row_number() over() as row_id,
order_id,
sales,
quantity,
discount,
profit,
order_date,
ship_date,
s.ship_mode_id,
p.product_id,
g.customer_id,
cd.channel_id
from stg.orders o
inner join dw.shipping_dim s on o.ship_mode = s.ship_mode
inner join dw.clients_dim g on o.customer_name = g.customer_name and o.segment = g.segment and g.country=o.country and g.city = o.city and o.state = g.state and o.postal_code = g.postal_code and o.region = g.region  
inner join dw.products_dim p on o.product_name = p.product_name and o.subcategory=p.sub_cutegory and o.category=p.category
inner join dw.channels_dim cd on cd.channel=o.channel

--Checking count rows
select count(*) from dw.sales_fact


