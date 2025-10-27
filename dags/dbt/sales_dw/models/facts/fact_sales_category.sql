{{
    config(
        materialized='table'
    )
}}

WITH deduplicated_sales AS (
    SELECT 
        s.*,
        ROW_NUMBER() OVER (PARTITION BY s.product_id ORDER BY s.user_id) AS row_num
    FROM {{ ref('stg_sales') }} s
),

-- Generate numbers for category splitting (similar to our user splitting logic)
numbers AS (
    SELECT ROW_NUMBER() OVER ()::INTEGER AS n
    FROM {{ ref('stg_sales') }}
    LIMIT 10  -- Max expected category levels
),

-- Split pipe-separated categories into individual rows
category_split AS (
    SELECT 
        ds.*,
        p.product_id,
        TRIM(SPLIT_PART(p.category, '|', numbers.n::INTEGER)) AS category_level,
        numbers.n AS level_number
    FROM deduplicated_sales ds
    JOIN {{ ref('dim_product') }} p ON ds.product_id = p.product_id
    CROSS JOIN numbers
    WHERE ds.row_num = 1  -- Keep existing deduplication logic
      AND numbers.n <= (LENGTH(p.category) - LENGTH(REPLACE(p.category, '|', '')) + 1)
      AND TRIM(SPLIT_PART(p.category, '|', numbers.n::INTEGER)) != ''
)
,actual_sales_by_category AS (
SELECT
    u.user_id,
    cs.category_level AS category,
    SUM(
        CASE 
            WHEN cs.discounted_price ~ '^₹[0-9,]+$' THEN 
                CAST(REPLACE(REPLACE(cs.discounted_price, '₹', ''), ',', '') AS DECIMAL(10, 2))
            ELSE 0
        END
    ) AS sales_amount
FROM
    category_split cs
    JOIN {{ ref('dim_user') }} u ON cs.user_id = u.user_id
GROUP BY
    u.user_id,
    cs.category_level
)

SELECT * FROM actual_sales_by_category
WHERE sales_amount > 0