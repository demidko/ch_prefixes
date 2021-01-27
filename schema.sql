CREATE TABLE log
(
    `date` DateTime,
    `city` UInt32,
    `dir` UInt16,
    `ring` FixedString(32),
    `docs` Array(UInt64),
    `page` UInt8 DEFAULT 0,
    `body` String,
    `engine` String,
    `model` String,
    `generation` UInt8,
    `query` String,
    `lemma` String DEFAULT '',
    `day` UInt8 DEFAULT toDayOfMonth(date),
    `clicks` Array(UInt64) DEFAULT CAST([], 'Array(UInt64)'),
    `ext_docs` Array(UInt64),
    `exact_feed_count` UInt32,
    `client_date` DateTime,
    `lts_address` Int64,
    `document_offset` UInt32 DEFAULT CAST(0, 'UInt32'),
    `tire_height` Float32,
    `tire_width` Float32,
    `flat_type` Array(String),
    `wheel_diameter` Array(Float32),
    `in_set_quantity` Array(UInt8),
    `wheel_season` Array(String),
    `wheel_spike` Array(UInt8),
    `wall_material` Array(String),
    `district` Array(String),
    `floor_range` Array(UInt8),
    `area_total_range` Array(UInt32),
    `construction_status` Array(String),
    `realty_repair` String,
    `price_range` Array(UInt32),
    `agent_type` Array(String),
    `type` String,
    `good_present_state` String,
    `run_flat` UInt8,
    `year_range` Array(UInt16),
    `predestination` Array(String),
    `condition` Array(String),
    `has_images` UInt8,
    `protected_deals` UInt8,
    `section_width` UInt16,
    `section_height` UInt16,
    `wheel_car_model` String,
    `wheel_car_year` UInt16,
    `wheel_car_variation` String,
    `delivery_local` UInt8
)
ENGINE = MergeTree()
PARTITION BY toYYYYMMDD(date)
ORDER BY (date, city, dir, sipHash64(ring))
SAMPLE BY sipHash64(ring)
TTL date + toIntervalMonth(6)
SETTINGS index_granularity = 8192, old_parts_lifetime = 480;

CREATE TABLE attributes
(
    `id` UInt64,
    `version` UInt64,
    `city` UInt32,
    `type` String,
    `images` UInt8,
    `present_state` String,
    `condition` String,
    `price` UInt32,
    `ownerId` UInt32,
    `packetId` UInt32,
    `delivery` UInt8,
    `delivery_local` UInt8 COMMENT 'добавлена 2020-04-23',
    `delivery_local_price` UInt32,
    `updated` Date,
    `dir_id` Int32 DEFAULT -1,
    `is_marked` UInt8 DEFAULT 0,
    `is_deleted` UInt8 DEFAULT 0
)
ENGINE = ReplacingMergeTree(version)
ORDER BY id
TTL updated + toIntervalMonth(6)
SETTINGS index_granularity = 8192, old_parts_lifetime = 480;

CREATE VIEW docs_to_packets_week
(
    `doc` UInt64,
    `packet` UInt32
)
AS SELECT
    any(id) AS doc,
    any(packetId) AS packet
FROM default.attributes
WHERE id GLOBAL IN
(
    SELECT DISTINCT docs
    FROM default.log
    ARRAY JOIN docs
    WHERE ((docs % 100) = 6) AND (toDate(date) > subtractDays(today(), 7)) AND (city != 0)
)
GROUP BY id;

CREATE MATERIALIZED VIEW competitors_one_day_test
(
             `lemma` String,
             `city` UInt32,
             `date` DateTime,
             `packets` Array(UInt32)
)
ENGINE = MergeTree()
ORDER BY (date, city)
POPULATE
AS SELECT
    any(lemma),
    city,
    date,
    arrayReduce('groupUniqArray', groupArray(packet))
FROM
    (SELECT lemma, city, date, packet

         /*
         Несмотря на то что мы уже находимся в default, этот запрос не сработает, выдав ошибку несоответствия столбцов:

         Code: 47. DB::Exception:
         Received from clickhouse:9000.
         DB::Exception:
         Missing columns: 'l.docs'
         while processing query: 'SELECT lemma, city, date, packet FROM default.log ARRAY JOIN docs GLOBAL ALL INNER JOIN default.docs_to_packets_week ON doc = l.docs WHERE (toDate(date) > subtractDays(today(), 1)) AND (city != 0)',
         required columns: 'lemma' 'doc' 'date' 'l.docs' 'packet' 'city',
         maybe you meant:  '['lemma']' '['docs']' '['date']' '['docs']' '['city']',
         joined columns: 'doc' 'packet',
         arrayJoin columns: 'docs'
         */

     FROM log AS l

         /*
         А если добавить перед 'log' префикс базы данных 'default.' то сработает.
         И это действительно странно!
         Ведь ошибка говорила совсем не об этом (1),
         мы уже находились в default (2),
         и даже если бы CH неким образом задействовал local.log, вспомним что у них с default.log одинаковые столбцы (3).
         */

     ARRAY JOIN docs
     GLOBAL INNER JOIN docs_to_packets_week ON doc = l.docs
     WHERE (toDate(date) > subtractDays(today(), 1)) AND (city != 0))
GROUP BY
    cityHash64(lemma),
    city,
    date;
