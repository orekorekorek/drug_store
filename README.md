# Описание предметной области. 
База данных (БД) создаётся для информационного обслуживания посетителей аптеки. 
В аптеку города поступает ассортимент лекарств со склада каждые семь дней. Аптека предлагает услуги по продаже
лекарств и их бронированию. Срок бронирования лекарств - три дня. В справочной аптеки можно получить
информацию о лекарствах, находящихся в аптеке: название, форма выпуска, срок годности, аннотация, цена, изготовитель.

## Готовые запросы:
 - Выдавать данные о лекарствах.
 - Предоставлять покупателям возможность бронирования лекарств, сроком на три дня.
 - Выдавать информацию о поступлении лекарства в данную аптеку, исходя из ассортимента на складе.
 - Выдавать информацию о продажах за неделю (месяц, год) данного лекарства.
 - Выполнять поиск лекарства по названию, форме выпуска, изготовителю.
 - Выдавать список лекарств, применяемых для выбранной болезни (легких недугах).

# Запуск

```bash
psql -U your_postgres_user -d postgres -f drug_store.sql
```