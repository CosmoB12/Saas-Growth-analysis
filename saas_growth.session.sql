CREATE TABLE events_raw(
    distinct_id VARCHAR(38),
    event_type VARCHAR(15),
    time TIMESTAMP,
    mp_country_code VARCHAR(3),
    platform VARCHAR(15),
    feature_name VARCHAR(16),
    session_id VARCHAR(10),
    insert_id VARCHAR(38)
)