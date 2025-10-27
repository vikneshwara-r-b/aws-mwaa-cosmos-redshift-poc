-- View the list of products from the dim_product table
SELECT * FROM sales_dw.public.dim_product LIMIT 10;

-- View the list of users from the dim_user table
SELECT * FROM sales_dw.public.dim_user LIMIT 10;    

-- View certain records from the fact_sales_category table
SELECT * FROM sales_dw.public.fact_sales_category LIMIT 10; 

-- Total maximum sales under a particular category
SELECT category,SUM(sales_amount) as total_sales
FROM sales_dw.public.fact_sales_category
GROUP BY category
QUALIFY DENSE_RANK() OVER(ORDER BY total_sales desc) <= 5;

-- Top 3 highest spending users in Electronics category
SELECT category,u.user_name,SUM(sales_amount) as total_sales
FROM sales_dw.public.fact_sales_category sc
LEFT JOIN sales_dw.public.dim_user u 
ON sc.user_id = u.user_id 
WHERE category like '%Electronics%'
GROUP BY u.user_name, category
QUALIFY DENSE_RANK() OVER(PARTITION BY category ORDER BY total_sales desc) <= 3
ORDER BY category; 


-- Clean up: Drop the created tables and views (uncomment if needed)
-- DROP TABLE IF EXISTS sales_dw.public.dim_product;
-- DROP TABLE IF EXISTS sales_dw.public.dim_rating;
-- DROP TABLE IF EXISTS sales_dw.public.dim_user;
-- DROP TABLE IF EXISTS sales_dw.public.fact_product_rating;
-- DROP TABLE IF EXISTS sales_dw.public.fact_sales_category;
-- DROP VIEW IF EXISTS sales_dw.public.stg_sales;
-- DROP TABLE IF EXISTS sales_dw.public.sales;