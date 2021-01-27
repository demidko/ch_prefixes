.PHONY: init-schema cleanup-schema

init-schema: schema.sql
	docker-compose run client --multiquery < $<

cleanup-schema: cleanup.sql
	docker-compose run client --multiquery < $<

clean:
	docker-compose run client --multiquery -q "TRUNCATE TABLE metrics; TRUNCATE TABLE sessions;"