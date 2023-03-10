/* 

DANNY MA 8 WEEK SQL CHALLENGE - WEEK 7: Balanced Tree Clothing Company

PRODUCT ANALYSIS

*/

-- 1. What are the top 3 products by total revenue before discounts?

-- JOIN product details table to sales table
-- SUM(qty*price for revneue and group by product name, order by revenue descending

SELECT 
	product_name,
    SUM(sales.price * qty) AS revenue
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1
ORDER BY 2 DESC;

-- The top 3 products by total revenue before discounts applied are:
-- 1. Blue Polo Shirt Mens - $217,683
-- 2. Grey Fashion Jakcet Womens - $209,304
-- 3. White Tee Shirt Mens - $152,000

-- Interesting, 2 of the top 3 revenue generating items are Mens - this brand is popular with men!


-- 2. What is the total quantity, revenue and discount for each segment?

-- join sales and product_details tables on product_id
-- pull sum of quantity ,revenue (sum of sales * qty ), and sum of discount grouped by segment name

SELECT 
	segment_name,
    SUM(qty) AS total_qty,
    SUM(qty * sales.price) AS total_rev,
    SUM(discount) AS total_discount
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1;

-- Jeans segment: 11,349 units, $208,350 in revenue, $45,740 in discounts
-- Shirt segment: 11,265 units, $406,143 in revenue, $46,043 in discounts
-- Socks segment: 11,217 units, $307,977 in revenue, $45,465 in discounts
-- Jacket segment: 11,385 units, $366,983 in revenue, $45, 452 in discounts


-- 3. What is the top selling product for each segment?

-- I assume this question is asking the top product in terms of quantity.
-- Again, join the sales and product details tables on product_id.

SELECT 
	segment_name,
    product_name,
    SUM(qty) AS total_units
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1,2
ORDER BY 3 DESC;

-- Now, add another clause to select statement with RANK() and partition by segment name, order by sum(qty) to get qty rankings within each segment

SELECT 
	segment_name,
    product_name,
    SUM(qty) AS total_units,
    RANK() OVER (PARTITION BY segment_name ORDER BY SUM(qty) DESC) AS seg_rank
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1,2;

-- Now, add filter in where clause where seg_rank = 1 to get top selling product of each segment
WITH cte_rank AS (
SELECT 
	segment_name,
    product_name,
    SUM(qty) AS total_units,
    RANK() OVER (PARTITION BY segment_name ORDER BY SUM(qty) DESC) AS seg_rank
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1,2 )

SELECT *
FROM cte_rank
WHERE seg_rank = 1;

-- Jacket segment: Grey Fashion Jacket - Womens with 3,876 units
-- Jeans segment: Navy Oversized Jeans - Womens with 3,856 units
-- Shirt segment: Blue Polo Shirt - Mens with 3,819 units
-- Socks segment: Navy Solid Socks - Mens with 3,792 units


-- 4. What is the total quantity, revenue and discount for each category?

-- join sales and product_details tables on product_id
-- pull sum of quantity ,revenue (sum of sales * qty ), and sum of discount grouped by category name

SELECT
	category_name,
    SUM(qty) AS total_qty,
    SUM(qty * sales.price) AS total_rev,
    SUM(discount) AS total_discount
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1;

-- Womens: 22,734 units, $575,333 in revenue, $91,192 in discounts
-- Mens: 22,482 units, $714,120 in revenue, $91,508 in discounts
-- Mens products were lower in units but higher revenue, suggesting the products in mens category are more expensive than those in womens.


-- 5. What is the top selling product for each category?

-- Join sales and product details table on product id
-- cateogry name, product name, sum of quantity, grouping on first 2
-- again pull a rank column partitioning by category name and order by sum of quantity desc
-- then make cte and query off of that to find where rank = 1

WITH cte_rank AS (
SELECT 
	category_name,
    product_name,
    SUM(qty) AS total_units,
    RANK() OVER (PARTITION BY category_name ORDER BY SUM(qty) DESC) as cat_rank
FROM sales
	INNER JOIN product_details 
		ON sales.prod_id = product_details.product_id
GROUP BY 1,2 )

SELECT *
FROM cte_rank
WHERE cat_rank = 1;

-- Mens: Blue Polo Shirt Mens with 3,819 units
-- Womens: Grey Fashion Jacket Womens with 3,876 units


-- 6. What is the percentage split of revenue by product for each segment?

-- First, write querey to pull revenue by segment

SELECT
	segment_name,
    product_name,
    SUM(qty * sales.price) AS seg_rev
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1,2;

-- Now add column dividing rev by subquery with total revenue

SELECT
	segment_name,
    product_name,
    SUM(qty * sales.price) AS seg_rev,
    ROUND(((SUM(qty * sales.price)) / (SELECT SUM(qty*price) FROM sales))*100.0,2) AS pct_rev
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1,2 
ORDER BY 1,2;


-- 7. What is the percentage split of revenue by segment for each category?

SELECT
	category_name,
    segment_name,
    SUM(qty * sales.price) AS rev,
    ROUND((SUM(qty * sales.price) / (SELECT SUM(qty * price) FROM sales)) * 100.0,2) AS pct_seg
FROM sales
	INNER JOIN product_details 
		ON sales.prod_id = product_details.product_id
GROUP BY 1,2;

-- Interesting note: the only 2 segments in Womens category are Jackets and Jeans; Mens are Socks are Shirts.
-- Womens Jeans: 16.16% of revenue
-- Womens Jackets: 28.46% of revenue, second highest segment in terms of revenue
-- Mens Shirt: 31.50% of revenue, highest
-- Mens Socks: 23.88% of revenue


-- 8. What is the percentage split of total revenue by category?

SELECT
	category_name,
    SUM(qty * sales.price) AS cat_rev,
    ROUND(((SUM(qty * sales.price)) / (SELECT SUM(qty*price) FROM sales)) *100.0, 2) AS cat_pct
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1;

-- Womens makes up 44.62% of total revenue
-- Mens makes up 55.38% of total revenue


-- 9. What is the total transaction “penetration” for each product?

-- (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)


SELECT 
	DISTINCT prod_id,
    COUNT(DISTINCT txn_id) AS trans
FROM sales
GROUP BY 1;


-- This query gives the number of transactions where each product_id was included
-- Now to find penetration per product

SELECT 
	DISTINCT prod_id,
    ROUND((COUNT(DISTINCT txn_id) / (SELECT COUNT(DISTINCT txn_id) FROM sales)) * 100.0, 2) AS penetration
FROM sales
GROUP BY 1;	

-- Join this with product details for product_name

SELECT 
	DISTINCT prod_id,
    product_name,
    ROUND((COUNT(DISTINCT txn_id) / (SELECT COUNT(DISTINCT txn_id) FROM sales)) * 100.0, 2) AS penetration
FROM sales
	INNER JOIN product_details
		ON sales.prod_id = product_details.product_id
GROUP BY 1,2;	


-- 10. What is the most common combination of at least 1 quantity of any 3 products in a single transaction?

-- Going to do self joins eventually

SELECT
	prod_id,
    COUNT(DISTINCT txn_id) AS count
FROM sales
GROUP BY 1
ORDER BY 2 DESC;
-- This gives how frequently each product is in single transaction
-- Now, join sales on itself and add a clause in select for another product id
-- Self join on txn id = txn id AND product id < product id (to prevent repeats)

SELECT
	a.prod_id AS product_1,
    b.prod_id AS product_2,
    COUNT(DISTINCT a.txn_id) AS count
FROM sales a
	INNER JOIN sales b
		ON a.txn_id = b.txn_id AND a.prod_id < b.prod_id
GROUP BY 1,2
ORDER BY 3 DESC;

-- That's the frequency of each 2 product combinations
-- Now, 3 products, will do another self join with c.sales

SELECT
	a.prod_id AS product_1,
    b.prod_id AS product_2,
    c.prod_id AS product_3,
    COUNT(DISTINCT a.txn_id) AS count
FROM sales a
	INNER JOIN sales b
		ON a.txn_id = b.txn_id AND a.prod_id < b.prod_id
	INNER JOIN sales c
		ON b.txn_id = c.txn_id AND b.prod_id < c.prod_id
GROUP BY 1,2,3
ORDER BY 4 DESC;

SELECT product_name
FROM product_details
WHERE product_id = '9ec847';

SELECT product_name
FROM product_details
WHERE product_id = '5d267b';

SELECT product_name
FROM product_details
WHERE product_id = 'c8d436';

-- Most common combos:
-- White Tee Shirt Mens, Grey Fashion Jacket Womens, Teal Button Up Shirt Mens


