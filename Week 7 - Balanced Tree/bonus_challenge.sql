/* 

DANNY MA 8 WEEK SQL CHALLENGE - WEEK 7: Balanced Tree Clothing Company

BONUS CHALLENGE

*/

-- Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.

SELECT
	product_id,
    price,
    product_prices.id -- style_id in final 
FROM product_prices;

-- Going to use product_hierarchy table and split it into 3 tables for category, segment and style, each building on the previous
-- The style table will have all information from previous 2 plus its own 
-- Will join the new style table with the prices table to deliver the final output

-- cat table:
DROP TABLE IF EXISTS product_categories;
CREATE TABLE product_categories (
id INT,
category_name VARCHAR(10) );

INSERT INTO product_categories
SELECT
	id, 
    level_text
FROM product_hierarchy
WHERE id < 3;

-- segment table
DROP TABLE IF EXISTS product_segments;
CREATE TABLE product_segments (
id INT,
category_id INT,
segment_name VARCHAR(15) );

INSERT INTO product_segments 
SELECT
	id,
    parent_id,
    level_text
FROM product_hierarchy
WHERE id > 2
AND id < 7;

-- add cat info to segments:
ALTER TABLE product_segments
ADD COLUMN category_name VARCHAR(10) AFTER category_id;

UPDATE product_segments 
INNER JOIN (
SELECT
	id,
    category_name
FROM product_categories ) AS a
ON product_segments.category_id = a.id
SET product_segments.category_name = a.category_name;

-- style table
CREATE TABLE product_styles (
id INT,
parent_id INT,
style_name VARCHAR(100) );

INSERT INTO product_styles
SELECT 
	id,
    parent_id,
    level_text
FROM product_hierarchy
WHERE id > 6;

ALTER TABLE product_styles
RENAME COLUMN parent_id TO segment_id;

ALTER TABLE product_styles
ADD COLUMN segment_name VARCHAR(15) AFTER segment_id;

-- add segment info to styles
UPDATE product_styles
INNER JOIN (
SELECT
	id,
	segment_name
FROM product_segments ) AS a
ON product_styles.segment_id = a.id
SET product_styles.segment_name = a.segment_name;

ALTER TABLE product_styles
RENAME COLUMN id TO style_id;

ALTER TABLE product_segments
RENAME COLUMN id TO segment_id;

ALTER TABLE product_categories
RENAME COLUMN id TO category_id;

ALTER TABLE product_styles
ADD COLUMN category_id INT;

ALTER TABLE product_styles
ADD COLUMN category_name VARCHAR(10);

-- add cat info to styles
SELECT 
	segment_id,
    category_id,
    category_name
FROM product_segments;

UPDATE product_styles
INNER JOIN (
SELECT
	segment_id,
    category_id,
    category_name
FROM product_segments) AS a
ON product_styles.segment_id = a.segment_id
SET product_styles.category_id = a.category_id;	

UPDATE product_styles
INNER JOIN (
SELECT
	segment_id,
    category_id,
    category_name
FROM product_segments) AS a
ON product_styles.segment_id = a.segment_id
SET product_styles.category_name = a.category_name;	

-- find product name:
SELECT
	CONCAT(style_name,' ',segment_name,' ', '-',' ',category_name)
FROM product_styles;

-- add product name
ALTER TABLE product_styles 
ADD COLUMN product_name VARCHAR(200);

UPDATE product_styles
SET product_name = CONCAT(style_name,' ',segment_name,' ', '-',' ',category_name);

-- now for final output:
-- product id from prices, price from prices,
-- product name, cat id, seg id, style id cat name, seg name, style name from styles
-- join 2 on styles.style id = prices.id

SELECT
	product_id,
    price,
    product_name,
    category_id,
    segment_id,
    style_id,
    category_name,
    segment_name,
    style_name
FROM product_prices
	INNER JOIN product_styles
		ON product_prices.id = product_styles.style_id;
        
-- It wasn't in a single query, I built tables off of one another to make final output
