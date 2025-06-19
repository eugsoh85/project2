WITH deduplicated AS (
    SELECT * EXCEPT(row_number)
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY review_id
                   ORDER BY review_creation_date DESC
               ) AS row_number
        FROM {{ ref('stg_reviews') }}
    )
    WHERE row_number = 1
)

SELECT
    review_id,
    order_id,
    SAFE_CAST(review_score AS INT64) AS review_score,
    SAFE_CAST(review_creation_date AS DATE) AS review_creation_date,
    SAFE_CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp
FROM deduplicated