{{
    config(
        materialized='table'
    )
}}

SELECT DISTINCT
    product_id,
    user_id,
    CASE 
        WHEN rating ~ '^[0-9.]+$' THEN CAST(rating AS DECIMAL(2,1))
        ELSE NULL 
    END AS rating,
    CASE 
        WHEN rating_count ~ '^[0-9,]+$' THEN CAST(REPLACE(rating_count, ',', '') AS INTEGER)
        ELSE NULL 
    END AS rating_count
FROM {{ ref('stg_sales') }}
WHERE user_id IS NOT NULL 
  AND rating IS NOT NULL
