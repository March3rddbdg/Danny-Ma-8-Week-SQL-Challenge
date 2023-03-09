/* 

DANNY MA 8 WEEK SQL CHALLENGE - WEEK 7: Balanced Tree Clothing Company

HIGH LEVEL SALES ANALYSIS

*/

-- For each of the questions below, I will provide 2 answers: the first being the over total for all products, the second being the total broken down by product name.

-- 1. What was the total quantity sold for all products?

SELECT 	
	SUM(qty) AS total_sold
FROM sales;

-- 45, 216 total products have been sold.

-- Broken down by products:
	
SELECT 
    product_name,
    SUM(qty) AS total_sold
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1;


-- 2. What is the total generated revenue for all products before discounts?

SELECT 
	SUM(qty * price) AS total_rev
FROM sales;

-- $1,289,453 is the total revenue for all products before any discounts have been applied.alter

-- Broken down by product:

SELECT 
	product_name,
    SUM(qty * sales.price) AS total_rev
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1;

-- 3. What is the total discount amount for all products?

SELECT 
	SUM(discount) AS total_discount
FROM sales;

-- $182,700 is the total discount amount for all products.

-- Broken down by products:

SELECT 
	product_name,
    SUM(discount) AS total_discount
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1;


-- Just for fun: The total revenue after discounts applied?

WITH cte_total AS (
SELECT
	SUM(qty * price) AS total_pre,
    SUM(discount) AS total_discount
FROM sales )

SELECT 
	total_pre - total_discount AS final_rev
FROM cte_total;

-- After discounts applied, the total revenue is $1,106,753.

-- Broken down by products:

SELECT
	product_name,
    SUM(qty * sales.price) - SUM(discount) AS final_rev
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1 ;