-- models/staging/stg_payments.sql

SELECT
    order_id,
    payment_sequential,
    LOWER(CASE
        WHEN payment_type IN ('credit_card', 'boleto', 'voucher', 'debit_card', 'not_defined') THEN payment_type
        ELSE 'other'
    END) AS payment_type,
    IFNULL(CAST(payment_installments AS INT64), 0) AS payment_installments,
    IFNULL(CAST(payment_value AS FLOAT64), 0.0) AS payment_value
FROM {{ source('raw', 'olist_order_payments_dataset') }}
WHERE order_id IS NOT NULL
  AND payment_sequential IS NOT NULL