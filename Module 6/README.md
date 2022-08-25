### DE-101 Module 6

## Лабораторная работа по Redshift

Если вы застряли на этапе генерации данных в лабораторной работе по Redshift, то [здесь](Generating_Datasets.md)
обновленный мануал по выполнению задания

Вот такой объём данных в итоге  был загружен в s3  
![lets_pic](/docs/images/S3-gen-data.jpg)

После загрузки сгенерированных данных в мой Redshidt dc2.large 2GB RAM/100GB SSD скорость выполнения запросов следующая:

Таблицы без сжатия, стиля распределения или ключа сортировки: 34,46 сек.  
Таблицы со сжатием, без стиля распределения или ключей сортировки: 27,78 сек.  
Таблицы со сжатием, стилем распределения и ключами сортировки: 19,42 сек.

## Лабораторная работа по Azure

Пришлось пропустить т.к. не могу подтвердить облачный аккаунт (не принимает карты РФ)

## Лабораторная работа по Snowflake

Со времени написания мануала интерфес Снежинки немного изменился. Поэтому указать, например, параметры для file format через модальное окно, как показано на скрине, не получится. Теперь интерфейс предлагает прописать все параметры через конфиг файл.
Вот готовый пример, как прописать в конфиге, чтобы начать загрузку:  

```sql
create file format CSV
    type = CSV
    FIELD_DELIMITER = ','
    ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    -- comment = '<comment>'
```  
У меня же и после прописывания этих параметров продолжили выскакивать эксепшены. Чтобы убрать их я прописал уже в самой команде COPY параметр 'ON_ERROR=CONTINUE'   

```sql
copy into trips from @citibike_trips
ON_ERROR=CONTINUE
file_format=CSV;
```  
Результаты загрузки тестовых данных на Warehouse size = Small

Скриншот 1  
![lets_pic](/docs/images/snw_small_load1.jpg)  
Скриншот 2  
![lets_pic](/docs/images/snw_small_load2.jpg)  
Скриншот 3  
![lets_pic](/docs/images/snw_small_load3.jpg)   

А так отработала загрузка тестовых данных после перехода на  Warehouse size = Large  
Скриншот 4  
![lets_pic](/docs/images/snw_large_load1.jpg)  
Скриншот 5  
![lets_pic](/docs/images/snw_large_load2.jpg) 

А это результат отработки одного и того же селекта до и после кэширования  
![lets_pic](/docs/images/snw_cashing_speed.jpg) 

Если в этом запросе выдает ошибку, попробуйте увеличить параметр result_limit c 5 до 15-20  
```sql
set query_id =
(
    select 
        query_id 
    from table(information_schema.query_history_by_session (result_limit=>5))
    where query_text like 'update%' 
    order by start_time 
    limit 1
);
```  
Я записался на этот [курс](https://www.snowflake.com/data-cloud-academy-data-analysts/) от Snowflake Data Academy.  

Курс состоит из серии видео уроков по темам:  

##### SNOWFLAKE 101 (вводные уроки по основам Снежинки)  

![lets_pic](/docs/images/snowflake_cloud_academy-1.jpg)  

##### ANALYSIS AND VISUALIZATION BEST PRACTICES  

![lets_pic](/docs/images/snowflake_cloud_academy-2.jpg)  

##### DATA MANAGEMENT FOR ANALYSTS  

![lets_pic](/docs/images/snowflake_cloud_academy-3.jpg)  

##### ADVANCED ANALYTICS AND EMERGING TRENDS  

![lets_pic](/docs/images/snowflake_cloud_academy-4.jpg)  


По факту в этих видео есть парочка воркшопов, а остальные - много  болтавни с примерами юзкейсов. Практических знаний ноль, зато прокачаешься в том как и с чем эту Снежинку готовят.  


## Решение кейса [Zero to Snowflake](https://github.com/DecisiveData/ZeroToSnowflake)  

В оригинальном кейсе пайплайн выглядел так: 
```python
Salesforce data -> Fivetran replication -> Snowflake warehouse -> Tableau dashboards  
```
Табло я поменял на опенсорсное решение Apache Superset. Во-первых, Табло я практиковался года 2 назад и уже не так интересно, да и как таковой практики по части BI в кейсе нет. Просто скачиваешь готовый .twbx файл и открывешь его в Tableau Desktop.  
А Суперсет я начал изучать недавно и как раз появилась хорошая возможность попрактиковаться в дашбординге на данных из кейса.  

Salesforce - регистрируем аккаунт девелопера и получаем доступ к free account, no credit card needed  
После регистрации наполняем нашу CRM фейковой датой, которую потом и будем гнать по пайплайну  
[https://appexchange.salesforce.com/listingDetail?listingId=a0N3A00000EO5smUAD](https://appexchange.salesforce.com/listingDetail?listingId=a0N3A00000EO5smUAD)  

Fivetran поключаем как партнерский коннектор из Снежинки. Он будет на триальном доступе 14 дней.  

Снежинка у меня была с неиспользованными триальными кредитами с прошлого воркшопа.  

Apache Superset у меня был развернут в облаке VK Cloud.  

Выполнение первых трех шагов пайплайна не вызывает сложностей, делаем все как прописано в кейсе.
А вот подключение Суперсета к Снежинке пошло не так гладко. Предлагаю ссылку на мой блог [Lets Analyse it!](https://lets-analyse-it.blogspot.com/2022/08/apache-superset-snowflake.html), где я набросал подробный гайд, который позволит вам сэкономить пару вечеров за этим делом.  

В итоге получился вот такой дашбордик на основе данных из Salesforce:  

![lets_pic](/docs/images/sales_dashboard_superset.jpg)   

В результате кейса прокачал сразу несколько навыков:  

- пощупал Salesforce в первом приближении  
- используйпотестил Fivetran и попробовал настроить синхронизацию с Snowflake  
- подключил к Snowflake Apache Superset, попрактиковался в создании чартов и сделал демо-дашборд  








