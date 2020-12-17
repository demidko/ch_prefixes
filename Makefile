.PHONY: init-schema cleanup-schema

init-schema: schema.sql
	docker-compose run client < $<

cleanup-schema: cleanup.sql
	docker-compose run client < $<

## eg. make import INPUT=data.csv
import: data.csv
	cat $< | docker-compose run client -q "INSERT INTO metrics FORMAT CSV"