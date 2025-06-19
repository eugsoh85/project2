-- models/staging/stg_geolocation.sql

WITH deduped AS (
    SELECT DISTINCT
        CAST(geolocation_zip_code_prefix AS STRING) AS zip_code_prefix,
        geolocation_lat AS latitude,
        geolocation_lng AS longitude,
        geolocation_city AS city,
        geolocation_state AS state
    FROM {{ source('raw', 'olist_geolocation_dataset') }}
    WHERE geolocation_lat IS NOT NULL AND geolocation_lng IS NOT NULL
)

SELECT * FROM deduped