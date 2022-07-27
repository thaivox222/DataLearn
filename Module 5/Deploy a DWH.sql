select count(*) from sales

CREATE DATABASE SALESDB;

CREATE USER alex PASSWORD '5555555'

CREATE SCHEMA stg AUTHORIZATION alex

select * from pg_namespace;

-- грант на все селекты внутри stg
GRANT SELECT ON ALL TABLES IN SCHEMA stg TO alex

--грант на все внутри stg
GRANT ALL ON SCHEMA stg TO alex


CREATE TABLE stg.demotable (
  PersonID int,
  City varchar (255)
);

INSERT INTO stg.demotable VALUES (781, 'San Jose'), (990, 'Palo Alto');

select * from stg.demotable d 

-- найти все пиды запущенных запросов
SELECT pid, user_name, starttime, query, status
FROM stv_recents
-- WHERE status='Running';

-- скоращенная версия
SELECT pid, trim(user_name), starttime, substring(query,1,20) 
FROM stv_recents
-- WHERE status='Running';

--убить запрос по пиду
CANCEL 610;


--убить запрос через параллельный воркфлоу (если текущий мы не можем начать пока зависший запрос не завершится)
SET query_group TO 'superuser';
CANCEL 610;
RESET query_group;