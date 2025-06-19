SELECT
    payment_type,
    ROUND(AVG(payment_value), 2) AS avg_payment_value,
    ROUND(AVG(payment_installments), 2) AS avg_installments
FROM {{ ref('stg_payments') }}
GROUP BY payment_type