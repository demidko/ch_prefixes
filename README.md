# Sandbox для экспериментов со схемой хранения продуктовых метрик

## Запуск сервера

```
docker-compose up clickhouse
```

## Импорт схемы

```
make cleanup-schema init-schema
```

## Импорт данных

Расположить данные в файле `data.csv` (формат смотреть в `data-example.csv`) и выполнить

```
make import
```