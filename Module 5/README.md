### DE-101 Module 5

#### Disclaimer
К моменту старта этого модуля я уже имел небольшой опыт работы с Yandex Cloud и VK Cloud. Последнее время активно использовал последний для изучения различных DE-tools. Поэтому в рамках 5-го модуля я решил сконцентрироваться больше на AWS CLoud, а Azure пока пропустить, т.к. нагрузка изучать плотно два облака требовала бОльших временных ресурсов. Поэтому часть практических работ я выполнял в уже знакомом мне VK Cloud.

Артефакты к пятому модулю DE-101:

[VK Cloud CI-CD.pdf](/docs/VK-Cloud-CI-CD.pdf) - пример реализации пайплайна с доставкой кода в облако VK. Требовалось установить Apache Airflow
на облачный инстанс. Рабочая база на ClickHouse крутится на отдельной машинке. Проблема заключалось в том, как писать код для дагов Airflow на моем домашнем лэптопе и при этом сразу тестировать его и исправлять ошибки. Т.к. сам Airflow был развернут в облаке, то я имел прямой доступ к папке dags только по SSH. Но такой способ не позволял мне сохранять файлы сразу из Jupyter Notebook.
В итоге было найдено такое решение: в бакете S3 были созданы рабочие папки для хранения .py-скриптов. Этот бакет монтировался в виде папки на инстансе с Airflow и в его конфиге для папки dags был прописан путь к монтируемой папке.
На лэптоп я установил программу Disk-O, которая позволяет подключать S3-бакеты как обычный сетевой диск. Т.о. я мог сохранять мои скрипты прямо в S3-бакет, как если бы они лежали на моем локальном диске. После сохранения скрипта Aiflow сразу видел скрипт дага в папке и я мог его оперативно протестировать и исправить тут же ошибки.
Для пользователей VK Cloud программа Disk-O бесплатна, т.о. я не понес никаких дополнительных затрат на реализацию этого пайплайна.


[AWS VPC infrastructure.pdf](/docs/AWS-VPC-infrastructure.pdf)  - пример архитектурного решения в AWS CLoud.
Было создан VPC с двумя Availability Zones (AZ). В каждой AZ были созданы Private и Public сабнеты. Internet Gateway позволяет делать коннект к инстансам из паблик сабнетов. NAT позволяет инстансам из приватных сабнетов выходить в интернет, но подключится к ним напрямую извне нельзя, т.к. они изолированы сабнетом. Можно зайти сначала на инстанс из паблик сабнета , а из него уже на  инсанс из приват сабнета. Вся логика входа/выхода в интернет из VPC прописана в раут-таблицах. 

[Ссылка](https://longmeister_7612.hb.bizmrg.com/upload/datetime.html) на страничку из моего блога (обычная static web-page), которая лежит в публичном S3-бакете и доступна из браузера. Имхо, в VK в части шеринга объектов из S3 все реализовано намного проще, чем в AWS. Не надо настраивать Static web Hosting и заморачиваться с policy. Просто делаешь файл публично доступным и получаешь сразу ссылку.
![lets_pic](/docs/images/vk-sharing-object.jpg)

Deploy a DWH.sql - код к лабе из Модуль 5.8  Я выбрал проект [Deploy a Data Warehouse](https://aws.amazon.com/getting-started/hands-on/deploy-data-warehouse/) ОЧЕНЬ громкое название проекта, но на самом деле даются самые азы SQL: как на Redshift создать юзера, схему, базу данных, дать гранты, инсертить данные (не из внешнего файла, а из самого запроса), сделать селект. Подводный камень этого проекта - при создании самого кластера для тренировок есть возможность выбрать кластер dc2.large с Free Trial. И сначала я именно его и выбрал. Но как оказалось, к нему невоможно подключиться с помощью дибивера. Как только я не танцевал с правилами Security Groups - не дает установить соединение и всё. Да, можно было писать код в красивом query-editor-2, но мы ведь тренируем рабочий навык, а на работе вы вряд ли будете использовать web-редактор.
Поэтому я снёс бесплатный кластер, и поставил такой же, но с платным тарифом. Применил те же самые настройки безопасности и вуаля! -  дибивер сразу же подключился.
Зато прокачался в кастомной настройке  параметров кластера, т.к. бесплатный ставится по дефолтным, которые нельзя поменять. Это вобщем и оказалось самым ценным в этом проекте.
Сам проект состоит из 8 тасков, которые проходятся в пределах часа, после чего ваш кластер можно тушить. И в итоге вам в биллинг прилетит стомость только 1 часа.

Window functions in Redshift.sql - мой практикум по оконкам, который я проходил за пределами курса DE-101, на том самом кластере, который создавал выше. Можно использовать как справочник с готовыми сниппетами по оконкам. И да, это Redshift compatible!