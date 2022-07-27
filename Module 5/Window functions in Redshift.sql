select * from public.sales
limit 1

select * from public.event
limit 1

-- вариант с CTE котррый мог быть использован без оконок
with
q1 as(
  select buyerid, sum(qtysold*pricepaid) as sumsold
from public.sales
group by buyerid
)
, q2 as(
  select sum(sumsold) as sumtot
  from q1
)
select *, sumsold/sumtot*100 as prcnt
from q1, q2

-- Шаг 1, вариант с оконкой по сумме тотал
select buyerid, sumsold, sum(sumsold) OVER() as sumtotal, sumsold/sumtotal*100 as prcnt
FROM(
select buyerid, sum(qtysold*pricepaid) as sumsold
from public.sales
group by buyerid)
order by prcnt desc

-- варинат с оконкой по кол-ву
select buyerid, sumsold, count(sumsold) OVER() as sumtotal
FROM(
select buyerid, sum(qtysold*pricepaid) as sumsold
from public.sales
group by buyerid)

-- соотв, можно применять любую агрегатную функцию: мин, макс, каунт, сум, среднюю и т.д.

select buyerid, pricepaid, AVG(pricepaid) OVER() as awg_item
from public.sales

-- Вывод: легко запомнить, что в агрегатыных оконках просто добавляется OVER()

-- Шаг2 , усложним задачу и добавим дополнительный аналитический разрез eventname

select eventname,buyerid, sumsold, sum(sumsold) OVER(PARTITION BY eventname) as tot_event, sum(sumsold) OVER() as sumtotal
from(
select eventname, buyerid, sum(qtysold*pricepaid) as sumsold 
from public.sales t1
left join public.event t2 on t1.eventid=t2.eventid
group by buyerid, eventname
order by eventname)

-- Вывод: при добавлении аналитического разреза внутри OVER() надо прописать требуемую партицию (т.е. разрез)

--Шаг 3, усложним задачу ещё! и посчитаем сумму с накоплением в разрезе
select dtk, eventname, sumsold , sum(sumsold) OVER(PARTITION BY dtk ORDER by eventname ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as tot_event
from(
select DATE(saletime) as dtk, eventname, buyerid, sum(qtysold*pricepaid) as sumsold
from public.sales t1
left join public.event t2 on t1.eventid=t2.eventid
group by dtk, eventname, buyerid)

-- ПОЯСНЕНИЕ К ПРЕДЫДУЩЕМУ СНИППЕТУ: код выводит в последнем столбце сумму с накоплением по дате. Т.е. как только начинается партиция
-- с новой датой, то накопление начинает считаться заново.
-- То, что написано капсом - это т.н. window range. Возможно на других движках он не потребуется, но на редшифте без его указания запрос
-- не будет отрабатывать. По сути мы указыаем там, что надо считать сумму начиная с UNBOUNDED PRECEDING (предыдущая с верхнего краю? до CURRENT ROW(текущей строки)

-- Модификация предыдущег сниппета, с count и субкатегории:
select eventname, dtk , count(cnt_buyer) OVER(PARTITION BY eventname ORDER by dtk ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as tot_event
from(
select  DATE(saletime) as dtk, eventname, listid, count(buyerid) as cnt_buyer
from public.sales t1
left join public.event t2 on t1.eventid=t2.eventid
group by eventname, listid, dtk)
LIMIT 500

======РАНЖИРУЮЩИЕ ОКОНКИ ===============================

select dtk, eventname, cnt,
--ROW_NUMBER() OVER(PARTITION BY dtk ORDER by cnt) as row_number,
-- RANK() OVER(PARTITION BY dtk ORDER by cnt) as rank
-- DENSE_RANK() OVER(PARTITION BY dtk ORDER by cnt) as dense_rank,
NTILE(3) OVER(PARTITION BY dtk ORDER by eventname) as ntile
from(
select DATE(saletime) as dtk, eventname, count(buyerid) as cnt, sum(qtysold*pricepaid) as sumsold
from public.sales t1
left join public.event t2 on t1.eventid=t2.eventid
group by dtk, eventname
LIMIT 12)

--DENSE_RANK на примере (видно как меняется ранг в завис-ти от сортировки и начинается заново при смене партиции:
SELECT
dtk, cnt
, DENSE_RANK() OVER(PARTITION BY dtk ORDER by cnt) as dense_rank
from(
select DATE_PART(month, DATE(saletime)) as dtk,
  -- DATE(saletime) as dtk,
  eventname, count(eventname) as cnt, sum(qtysold*pricepaid) as sumsold
from public.sales t1
left join public.event t2 on t1.eventid=t2.eventid
--WHERE eventname = 'Foo Fighters'
group by dtk, eventname
HAVING cnt > 25)



-- ДЗ - какую оконку использовать, чтобы вывести порядковую нумерацию строк в пределах группы?
-- Я нашёл 2 способа:
select dtk, eventname, cnt,
DENSE_RANK() OVER(PARTITION BY dtk ORDER by eventname) as dense_rank
-- ROW_NUMBER() OVER(PARTITION BY dtk) as row_number
from(
select DATE(saletime) as dtk, eventname, count(buyerid) as cnt, sum(qtysold*pricepaid) as sumsold
from public.sales t1
left join public.event t2 on t1.eventid=t2.eventid
group by dtk, eventname)


-- Оконки со смещением
--предыдущая/последующая строка в окне
select dtk, eventname-- , sumsold
,LAG(eventname,1) OVER(PARTITION BY dtk ORDER BY dtk) AS lag -- в данном примере работает как lead(т.е. выводит послед., а не предыдущ.)
,LEAD(eventname,1) OVER(PARTITION BY dtk ORDER BY dtk) AS lead
from(
select DATE(saletime) as dtk, eventname, count(buyerid) as cnt, sum(qtysold*pricepaid) as sumsold
from public.sales t1
left join public.event t2 on t1.eventid=t2.eventid
group by dtk, eventname)

-- вот правильный пример
select buyerid, saletime, qtysold,
lag(qtysold,1) over (order by buyerid, saletime) as prev_qtysold
from public.sales
where buyerid = 3 order by buyerid, saletime;


-- Первая/последняя строка в окне
select dtk, eventname-- , sumsold
,FIRST_VALUE(eventname) OVER(PARTITION BY dtk ORDER BY dtk rows between unbounded preceding and unbounded following) AS FV-- в данном примере работает как lead(т.е. выводит послед., а не предыдущ.)
,LAST_VALUE(eventname) OVER(PARTITION BY dtk ORDER BY dtk rows between unbounded preceding and unbounded following) AS LV
from(
select DATE(saletime) as dtk, eventname, count(buyerid) as cnt, sum(qtysold*pricepaid) as sumsold
from public.sales t1
left join public.event t2 on t1.eventid=t2.eventid
group by dtk, eventname)

-- Аналитические оконки
select dtk, eventname, sumsold,
-- CUME_DIST() OVER(PARTITION BY dtk ORDER BY dtk, eventname DESC) AS CD,
-- PERCENT_RANK() OVER(PARTITION BY dtk ORDER BY dtk, eventname DESC) AS PR,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sumsold) OVER(PARTITION BY dtk) AS PercC, --0.5 - это пятый перцентиль или медиана (т.е. авыведет половину значений
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY sumsold) OVER(PARTITION BY dtk) AS PercD
from(
select DATE(saletime) as dtk, eventname, count(buyerid) as cnt, sum(qtysold*pricepaid) as sumsold
from public.sales t1
left join public.event t2 on t1.eventid=t2.eventid
group by dtk, eventname)