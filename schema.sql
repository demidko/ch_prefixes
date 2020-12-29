CREATE TABLE metrics (
    dateTime DateTime,
    userId UInt32,
    ring Nullable(FixedString(32)),
    name LowCardinality(String),
    value Float32,
    attrNames Array(LowCardinality(String)),
    attrValues Array(String)
)
ENGINE=MergeTree
ORDER BY (name, userId)
PARTITION BY toYYYYMMDD(dateTime);

CREATE MATERIALIZED VIEW sessions
ENGINE = MergeTree
ORDER BY (userId)
PARTITION BY toYYYYMMDD(startDate)
AS
SELECT userId, ring, min(dateTime) startDate, max(dateTime) endDate, count(*) as count
FROM metrics
GROUP BY userId, ring;