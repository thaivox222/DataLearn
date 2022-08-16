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
SNOWFLAKE 101 (вводные уроки по основам Снежинки)  
![lets_pic](/docs/images/snowflake_cloud_academy-1.jpg)  
ANALYSIS AND VISUALIZATION BEST PRACTICES  
![lets_pic](/docs/images/snowflake_cloud_academy-2.jpg)  
DATA MANAGEMENT FOR ANALYSTS  
![lets_pic](/docs/images/snowflake_cloud_academy-3.jpg)  
ADVANCED ANALYTICS AND EMERGING TRENDS  
![lets_pic](/docs/images/snowflake_cloud_academy-4.jpg)  

По факту в этих видео есть парочка воркшопов, а остальные - много  болтавни с примерами юзкейсов. Практических знаний ноль, зато прокачаешься в том как и с чем эту Снежинку готовят.
