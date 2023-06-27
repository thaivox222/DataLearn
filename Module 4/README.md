### DE-101 Module 4

#### Disclaimer  
В оригинале курса лабораторные работы четвертого модуля выполняются с помощью ETL-инструмента Pentaho DI.
Но из-за того, что данный софт требует большой объем оперативной памяти при использовании, а также достаточно нетривиальную установку, я решил выполнять работы с помощью другого инструмента, схожего по функционалу - KNIME Analytics Platform. Десктопная версия Knime бесплатна при использовании, все операции extraxt-transform-load выполняются в GUI-интерфейсе и требуют минимальные знания sql-кода или можно вообще обойтись без него. Но теорию SQL знать желательно.

#### Практика 4.3
Установка Knime на Windows проходит легко, требуется лишь задать путь, в котором будет располагаться рабочий проект и задать размер оперативной памяти, которая будет выделена для операций работы с данными. При обработке больших данных у Knime подключается дисковый кэш.

Окно загрузки Knime AP  
![lets_pic](/docs/images/Knime_load_screen.jpg)  
  

#### Практика 4.4  
В качестве отправной точки был взят файл superstore_general.csv из архива исходников Павла Новичкова (ссылка есть в описании лабы)  

Worklflow создания таблицы измерений products_dim:  
![lets_pic](/docs/images/products_dim.jpg)  


Worklflow создания таблицы измерений clients_dim:  
![lets_pic](/docs/images/clients_dim.jpg)  


Worklflow создания таблицы измерений shipping_dim:  
![lets_pic](/docs/images/shipping_dim.jpg)  


Worklflow создания таблицы измерений channels_dim:   
![lets_pic](/docs/images/channels_dim.jpg)  

Так выглядит операция создания таблицы фактов в интерфейсе Knime. Вместо inner join sql-statement используем Joiner ноду
в линейном графе:  
![lets_pic](/docs/images/fact_table.jpg) 

А так выглядит общий Worklflow создания таблиц измерений и таблицы фактов:  
![lets_pic](/docs/images/worklflow.jpg) 


#### Практика 4.5  

Строго говоря, Knime AP не является stand-alone приложением для ETL. Это аналитическая платформа, которая позволяет делать любую аналитику без кода, используя только GUI-интерфейс. И Knime способен решать задачи, начиная от экстракции данных из множества источников, до создания моделей машинного обучения. Поэтому, ожидать от Knime поддержки всех 34 подсистем ETL , описаных Р.Кимбалом не приходится. Но все же некоторые из них я сумел найти.

Extract system  
![lets_pic](/docs/images/extract.jpg)  

Data cleansing system  
![lets_pic](/docs/images/cleaning.jpg)  

Error event tracking  
![lets_pic](/docs/images/error_hadle.jpg) 

Deduplication  
![lets_pic](/docs/images/dedup.jpg)  

Surrogate key generator 
![lets_pic](/docs/images/skey.jpg) 

Aggregate builder  
![lets_pic](/docs/images/agg_builder.jpg)  

Workflow monitor    
![lets_pic](/docs/images/monitor.jpg) 


Файл в папке с модулем knime-export.knar - сам итоговый workflow, который можно скачать и импортировать в собственный инстанс Knime.

#### Практика 4.6  

Если описанные в разделе 4.6 такие инструменты как Tableau prep, по сути являются приставкой по обработке данных к мощному средству по визуализации  - Tableau, то в случаем с Knime все наоборот.
Knime AP - это как раз таки мощное средство по обработке данных, но в своем функционале он имеет и встроенные средства по визуализации. Вот примеры простейших чартов, сделанных в Knime:

Bar chart
![lets_pic](/docs/images/barchart.jpg) 

Line chart
![lets_pic](/docs/images/linechart.jpg) 

Scatterplot chart
![lets_pic](/docs/images/scatterplot.jpg) 

Tag cloud chart
![lets_pic](/docs/images/tag_cloud.jpg) 

Ну, а трансформации и различные средства чистки данных  - это то, что у Knime в избытке. Если вам не хватает какого-то встроенного функционала, ищите на портале Knime hub, где community выкладывает свои кастомные ноды для работы с данными.  

#### Практика 4.7  

В качестве практики по этой лабе укажу [ссылку](https://github.com/thaivox222/dbt_long) на свой репо, в котором тестировал подходы инкрементальной загрузки в ClickHouse с помощью dbt.   
Так получилось, что знакомство с dbt у меня состоялось гораздо заранее прохождения 4 модуля DATA LEARN ¯\_(ツ)_/¯


 



















