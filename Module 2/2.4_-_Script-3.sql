
CREATE TABLE "channels_dim"
(
 "channel_id" int NOT NULL,
 "channel"    varchar(30) NOT NULL,
 CONSTRAINT "PK_channels_dim" PRIMARY KEY ( "channel_id" )
);

drop table clients_dim cascade;

CREATE TABLE "clients_dim"
(
 "customer_id"   int NOT NULL,
 "customer_name" varchar(100) NOT NULL,
 "segment"       varchar(30) NOT NULL,
 "country"       varchar(50) NOT NULL,
 "city"          varchar(30) NOT NULL,
 "state"         varchar(30) NOT NULL,
 "postal_code"   int,
 "region"        varchar(30) NOT NULL,
 CONSTRAINT "PK_clients_dim" PRIMARY KEY ( "customer_id" )
);

drop table products_dim cascade;

CREATE TABLE "products_dim"
(
 "product_id"   int NOT NULL,
 "category"     varchar(50) NOT NULL,
 "sub_cutegory" varchar(50) NOT NULL,
 "product_name" varchar(150) NOT NULL,
 CONSTRAINT "PK_products_dim" PRIMARY KEY ( "product_id" )
);

CREATE TABLE "shipping_dim"
(
 "ship_mode_id" int NOT NULL,
 "ship_mode"    varchar(30) NOT NULL,
 CONSTRAINT "PK_shipping_dim" PRIMARY KEY ( "ship_mode_id" )
);


CREATE TABLE "sales_fact"
(
 "row_id"       int NOT NULL,
 "order_id"     int NOT NULL,
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
 CONSTRAINT "PK_sales_fact" PRIMARY KEY ( "row_id" ),
 CONSTRAINT "FK_67" FOREIGN KEY ( "ship_mode_id" ) REFERENCES "shipping_dim" ( "ship_mode_id" ),
 CONSTRAINT "FK_70" FOREIGN KEY ( "product_id" ) REFERENCES "products_dim" ( "product_id" ),
 CONSTRAINT "FK_73" FOREIGN KEY ( "customer_id" ) REFERENCES "clients_dim" ( "customer_id" ),
 CONSTRAINT "FK_76" FOREIGN KEY ( "channel_id" ) REFERENCES "channels_dim" ( "channel_id" )
);

CREATE INDEX "fkIdx_67" ON "sales_fact"
(
 "ship_mode_id"
);

CREATE INDEX "fkIdx_70" ON "sales_fact"
(
 "product_id"
);

CREATE INDEX "fkIdx_73" ON "sales_fact"
(
 "customer_id"
);

CREATE INDEX "fkIdx_76" ON "sales_fact"
(
 "channel_id"
);


insert into shipping_dim 
select 300+row_number () over(), ship_mode from (select distinct ship_mode from orders) a;

select * from shipping_dim

select * from orders

insert into products_dim
select 100+row_number () over(), category, subcategory, product_name from
(select distinct category, subcategory, product_name from orders)a;

select * from products_dim

truncate table clients_dim cascade;
insert into clients_dim
select 200+row_number () over(), customer_name , segment , country, city, state, postal_code, region from
(select distinct customer_name , segment , country, city, state, postal_code, region from orders)a;

select * from clients_dim

insert into channels_dim (channel_id, channel) values ('401','Website');
insert into channels_dim (channel_id, channel) values ('402','Phone');
insert into channels_dim (channel_id, channel) values ('403','Office');

select * from channels_dim

select * from orders limit 15
UPDATE orders SET channel = 'Website'

--updating orders with null data on postal code
update orders
set postal_code = '05401'
where city = 'Burlington'  and postal_code is null;



truncate table sales_fact cascade ;
insert into sales_fact


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
from orders o
inner join shipping_dim s on o.ship_mode = s.ship_mode
inner join clients_dim g on o.customer_name = g.customer_name and o.segment = g.segment and g.country=o.country and g.city = o.city and o.state = g.state and o.postal_code = g.postal_code and o.region = g.region  
inner join products_dim p on o.product_name = p.product_name and o.subcategory=p.sub_cutegory and o.category=p.category
inner join channels_dim cd on cd.channel=o.channel

select * from orders limit 10

select * from sales_fact limit 10

select count(*) from sales_fact
