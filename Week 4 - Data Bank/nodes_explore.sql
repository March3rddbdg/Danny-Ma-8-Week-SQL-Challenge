/* 

DANNY MA 8 WEEK SQL CHALLENGE: WEEK 4 - DATA BANK

CUSTOMER NODES EXPLORATION

*/


-- 1. How many unique nodes are there on the Data Bank system?

-- Nodes are like digital bank branches, and are within the region.
-- Count distinct node_ids in customer_nodes table
SELECT
	COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;

-- There are 5 nodes.


-- 2. What is the number of nodes per region?

-- Total number of nodes per region
SELECT
	region_id,
	COUNT(node_id) AS total_nodes
FROM customer_nodes
GROUP BY 1
ORDER BY 1;

-- Region 1: 770 total nodes
-- Region 2: 735 total nodes
-- Region 3: 714 total nodes
-- Region 4: 665 total nodes
-- Region 5: 616 total nodes 


-- 3. How many customers are allocated to each region?

-- Looking for a count of unique customer ids grouped by region id.

SELECT
	region_id,
	COUNT(DISTINCT customer_id) AS unique_customer
FROM customer_nodes
GROUP BY 1;

-- Region 1: 110 customers
-- Region 2: 105 customers
-- Region 3: 102 customers
-- Region 4: 95 customers
-- Region 5: 88 customers

-- I'm going to take it a step further and add in the region name to give this data some context
SELECT
	customer_nodes.region_id,
    region_name,
	COUNT(DISTINCT customer_id) AS unique_customer
FROM customer_nodes
	INNER JOIN regions
		ON customer_nodes.region_id = regions.region_id
GROUP BY 1,2;

-- Australia: 110 customers; Australia is the largest region in terms of customer base. Very interesting - Data Bank is popular in Australia!
-- America: 105 customers
-- Africa: 102 customers
-- Asia: 95 customers
-- Europe: 88 customers; Europe is the smallest region in terms of customer base.


-- 4. How many days, on average, are customers reallocated to a different node?

-- Customers are moved to other nodes for security purposes.
-- I need to look at how customer ids change node_ids and the dates involved

-- Looking at one random customer_id to get a feel for data points involved.
SELECT
	customer_id,
    node_id,
    start_date,
    end_date
FROM customer_nodes
WHERE customer_id = 102;
    
-- I need to find the different in dates from end date to start date  
-- I also need to filter out the date '9999-12-31' as that's included in dataset as expiration date of sorts  

SELECT
	datediff(end_date, start_date) AS days_to_reallocate
FROM customer_nodes
WHERE end_date <> '9999-12-31';

-- Now take the average of this
SELECT
	AVG(datediff(end_date, start_date)) AS avg_reallocate_days
FROM customer_nodes
WHERE end_date <> '9999-12-31';

-- Round to 1 decimal place to make it look nicer
SELECT
	ROUND(AVG(datediff(end_date, start_date)), 1) AS avg_reallocate_days
FROM customer_nodes
WHERE end_date <> '9999-12-31';

-- On average, Data Bank reallocates customers to different nodes every 14.6 days.


