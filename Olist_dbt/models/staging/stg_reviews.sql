-- models/staging/stg_reviews.sql

SELECT
    review_id,
    order_id,
    SAFE_CAST(review_score AS INT64) AS review_score,

    CASE
        WHEN TRIM(review_creation_date) = '' THEN NULL
        ELSE SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', REPLACE(review_creation_date, ' UTC', ''))
    END AS review_creation_date,

    CAST(NULL AS TIMESTAMP) AS review_answer_timestamp,
    --NULL AS review_answer_timestamp,  -- or clean this too if you ever re-enable

    NULLIF(TRIM(review_comment_title), '') AS review_comment_title,
    NULLIF(TRIM(review_comment_message), '') AS review_comment_message
FROM {{ source('raw', 'olist_order_reviews_dataset') }}