# Sandbox для экспериментов с ClickHouse

## Запуск сервера

```
docker-compose up clickhouse
```

## Импорт схемы

```
make cleanup-schema init-schema
```

## Запуск клиента

Клиента к clickhouse можно получить командой `docker-compose run client`.