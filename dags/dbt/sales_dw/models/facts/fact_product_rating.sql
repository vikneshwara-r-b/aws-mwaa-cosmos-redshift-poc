{{
    config(
        materialized='table'
    )
}}

SELECT
    p.product_id,
    p.product_name,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM
    {{ ref('dim_product') }} p
    JOIN {{ ref('dim_rating') }} r ON r.product_id = p.product_id
WHERE r.rating IS NOT NULL
GROUP BY
    p.product_id,
    p.product_name
