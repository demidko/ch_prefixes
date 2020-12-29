.PHONY: init-schema cleanup-schema import eval

PYTHON:=python3

init-schema: schema.sql
	docker-compose run client --multiquery < $<

cleanup-schema: cleanup.sql
	docker-compose run client --multiquery < $<

clean:
	docker-compose run client --multiquery -q "TRUNCATE TABLE metrics; TRUNCATE TABLE sessions;"

import: import.csv.gz
	zcat $< | docker-compose run client -q "INSERT INTO metrics FORMAT CSV"

import.csv.gz: access.log.xz
	pv $< | xz -cd | $(PYTHON) convert.py | gzip - > $@

eval:
	docker-compose run client -q \
		"select arrayFirst(i -> i.1 == 'partsPos', attributes).2 pos, avg(value) from metrics where name = 'viewdir_feed_stat' group by pos"