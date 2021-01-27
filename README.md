## Баг с префиксами баз данных в `ClickHouse`

При обьявлении sql алиаса `FROM log AS l` в JOIN запросе получаем ошибку несоответствия столбцов, например:

```
Code: 47. DB::Exception: 
Received from clickhouse:9000. DB::Exception: 
Missing columns: 'l.docs' 
while processing query: 'SELECT lemma, city, date, packet FROM default.log ARRAY JOIN docs GLOBAL ALL INNER JOIN default.docs_to_packets_week ON doc = l.docs WHERE (toDate(date) > subtractDays(today(), 1)) AND (city != 0)', 
required columns: 'lemma' 'doc' 'date' 'l.docs' 'packet' 'city', 
maybe you meant:  '['lemma']' '['docs']' '['date']' '['docs']' '['city']', 
joined columns: 'doc' 'packet', 
arrayJoin columns: 'docs'
```

А если добавить перед `log` префикс базы данных `default.`, например `FROM default.log AS l` то этот же запрос
сработает.  
И это действительно странно!  
Ведь ошибка говорила совсем не об этом (1) и мы уже находились в default (2).

## Как воспроизвести баг?

1. Запустить сервер `docker-compose up clickhouse`
1. Применить схему `make cleanup-schema init-schema` и убедиться в наличие ошибки.
1. Заменить `log` на `default.log` в последнем запросе в файле `schema.sql` и убедиться что ошибка исчезает при
   добавлении префикса.

При желании, клиента к ClickHouse можно получить командой `docker-compose run client`.
