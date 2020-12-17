CREATE TABLE metrics (
    dateTime DateTime,
    userId UInt32,
    ring Nullable(FixedString(32)),
    name LowCardinality(String),
    value Float32,
    attributes Array(Tuple(LowCardinality(String), String))
)
ENGINE=MergeTree
ORDER BY (dateTime, name, userId)
PARTITION BY toYYYYMMDD(dateTime)