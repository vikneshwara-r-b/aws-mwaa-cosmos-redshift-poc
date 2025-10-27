{{
    config(
        materialized='view'
    )
}}

WITH numbers AS (
    SELECT ROW_NUMBER() OVER ()::INTEGER AS n
    FROM {{ ref('sales') }}
    LIMIT 20  -- Max expected users per product
),

user_split AS (
    SELECT 
        s.product_id,
        s.product_name,
        s.category,
        s.discounted_price,
        s.actual_price,
        s.discount_percentage,
        s.rating,
        s.rating_count,
        s.about_product,
        s.img_link,
        s.product_link,
        TRIM(SPLIT_PART(s.user_id, ',', numbers.n::INTEGER)) AS user_id,
        TRIM(SPLIT_PART(s.user_name, ',', numbers.n::INTEGER)) AS user_name,
        -- Only include review data for the first user (n=1) to avoid duplication
        CASE WHEN numbers.n = 1 THEN s.review_id END AS review_id,
        CASE WHEN numbers.n = 1 THEN s.review_title END AS review_title,
        CASE WHEN numbers.n = 1 THEN s.review_content END AS review_content,
        numbers.n AS user_seq
    FROM {{ ref('sales') }} s
    CROSS JOIN numbers
    WHERE numbers.n <= (LENGTH(s.user_id) - LENGTH(REPLACE(s.user_id, ',', '')) + 1)
      AND TRIM(SPLIT_PART(s.user_id, ',', numbers.n::INTEGER)) != ''
)

, deduped AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY product_id, user_id ORDER BY user_seq) AS row_num
    FROM user_split
    WHERE user_id IS NOT NULL AND user_id != ''
)

SELECT 
    product_id,
    product_name,
    category,
    discounted_price,
    actual_price,
    discount_percentage,
    rating,
    rating_count,
    about_product,
    user_id,
    user_name,
    review_id,
    review_title,
    review_content,
    img_link,
    product_link
FROM deduped
WHERE row_num = 1
ORDER BY product_id, user_id
