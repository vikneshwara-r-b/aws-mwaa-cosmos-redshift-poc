-- Raw table creation script for Amazon Sales data
CREATE TABLE IF NOT EXISTS sales_dw.public.sales
(
	product_id VARCHAR(256)   ENCODE lzo
	,product_name VARCHAR(10000)   ENCODE lzo
	,category VARCHAR(256)   ENCODE lzo
	,discounted_price VARCHAR(256)   ENCODE lzo
	,actual_price VARCHAR(256)   ENCODE lzo
	,discount_percentage VARCHAR(256)   ENCODE lzo
	,rating VARCHAR(256)   ENCODE lzo
	,rating_count VARCHAR(256)   ENCODE lzo
	,about_product VARCHAR(10000)   ENCODE lzo
	,user_id VARCHAR(256)   ENCODE lzo
	,user_name VARCHAR(256)   ENCODE lzo
	,review_id VARCHAR(256)   ENCODE lzo
	,review_title VARCHAR(10000)   ENCODE lzo
	,review_content VARCHAR(65000)   ENCODE lzo
	,img_link VARCHAR(256)   ENCODE lzo
	,product_link VARCHAR(256)   ENCODE lzo
);

-- Sample query to verify table creation
SELECT * FROM sales_dw.public.sales LIMIT 10;

-- Sample query to count records in the sales table
SELECT count(*) FROM sales_dw.public.sales

