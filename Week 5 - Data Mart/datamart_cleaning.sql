USE data_mart;
/*

DANNY MA 8 WEEK SQL CHALLENGE: WEEK 5 - DATA MART

DATA CLEANING QUERIES

*/

-- I will create a temp table with cleaned data, to preserve original data as good practice.
-- First, go through each cleaning step, then I'll compile them into one large query for temp table creation. 

-- 1. Convert week_date column to DATE format.
SELECT
	week_date
FROM weekly_sales;
-- this is out of order. If I use date or dateformat functions, the first number will be year which is incorrect.
-- this is formatted as "DD/M/YY" currently
-- it's also a VARCHAR and not a date

SELECT
	str_to_date(week_date, '%d/%m/%Y') AS week_date_new
FROM weekly_sales;
-- Perfect. This is what I'll use for the week_date column in temp table.


-- 2. Add a week number column as second column for each week date value.
--    For example, any date between 1/1 - 1/7 will be week 1, 1/8-1/14 week 2, etc.
WITH cte_week AS (
SELECT
	week_date,
	str_to_date(week_date, '%d/%m/%Y') AS week_date_new
FROM weekly_sales )

SELECT
	week_date_new,
    WEEK(week_date_new) AS week_number
FROM cte_week ;


-- 3. Add a month number with the calendar month for each week date value as the third column

WITH cte_week AS (
SELECT
	week_date,
	str_to_date(week_date, '%d/%m/%Y') AS week_date_new
FROM weekly_sales )

SELECT
	week_date_new,
    WEEK(week_date_new) AS week_number,
    MONTH(week_date_new) AS month_number
FROM cte_week ;


-- 4. Add a calendar_year column as 4th column containing either 2018, 2019 or 2020 values.

WITH cte_week AS (
SELECT
	week_date,
	str_to_date(week_date, '%d/%m/%Y') AS week_date_new
FROM weekly_sales )

SELECT
	week_date_new,
    WEEK(week_date_new) AS week_number,
    MONTH(week_date_new) AS month_number,
    YEAR(week_date_new) AS calendar_year
FROM cte_week ;


-- 5. Add a new column called age_band after the original segment column uisng the following mapping on the number inside segment
-- Segment 1 = YOung Adult Age Band
-- Segment 2 = Middle Aged
-- Segment 3 or 4 = Retirees

SELECT 
	segment,
    CASE
		WHEN RIGHT(segment, 1) = 1 THEN 'Young Adults'
        WHEN RIGHT(segment,1) = 2 THEN 'Middle Aged'
        WHEN RIGHT(segment,1) = 3 OR RIGHT(segment,1) = 4 THEN 'Retirees'
        ELSE NULL END AS age_band
FROM weekly_sales;


-- 6. Add a new demographic column using the first letter in the segment values.
-- C = Couples demographic
-- F = Families

SELECT 
	segment,
    CASE
		WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
        WHEN LEFT(segment, 1) = 'F' THEN 'Families'
        ELSE NULL END AS demographic
FROM weekly_sales;


-- 7. Ensure all segment 'null' or unknow values are null
UPDATE weekly_sales
SET segment = NULL WHERE segment = 'null';

-- 8. Generate new avg_transaction column as sales value divided by the transactions rounded to 2 decimal places
-- Because sales and transactions are integers, I'll need to cast them as decimals for this computation to ensure I get decimals to round

SELECT
	ROUND(CAST(sales AS DECIMAL)/CAST(transactions AS DECIMAL), 2) AS avg_transaction
FROM weekly_sales;


-- 9. Now it's time to assemble this table!
DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TABLE clean_weekly_sales  (
week_date DATE NULL,
week_number INT NULL,
month_number INT NULL,
calendar_year YEAR NULL,
region VARCHAR(13) NULL,
platform VARCHAR(7) NULL,
segment VARCHAR(4) NULL,
age_band VARCHAR(25) NULL,
demographic VARCHAR(20) NULL,
customer_type VARCHAR(8) NULL,
transactions INT NULL,
sales INT NULL,
avg_transactions FLOAT NULL);

INSERT INTO clean_weekly_sales (
SELECT 
	str_to_date(week_date, '%d/%m/%Y'),
    WEEK(week_date),
    MONTH(DATE(week_date)),
    YEAR(str_to_date(week_date, '%d/%m/%Y')),
    region,
    platform,
    segment,
    CASE 
		WHEN RIGHT(segment, 1) = 1 THEN 'Young Adults'
        WHEN RIGHT(segment,1) = 2 THEN 'Middle Aged'
        WHEN RIGHT(segment,1) = 3 OR RIGHT(segment,1) = 4 THEN 'Retirees'
        ELSE NULL END,
	CASE
		WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
        WHEN LEFT(segment, 1) = 'F' THEN 'Families'
        ELSE NULL END,
	customer_type,
    transactions,
    sales,
    ROUND(CAST(sales AS DECIMAL)/CAST(transactions AS DECIMAL), 2)
FROM weekly_sales );

-- Have to update the week_number column to ensure the week number is correct by pulling the date value from week_date and then pulling week from that.
UPDATE clean_weekly_sales
SET week_number = WEEK(DATE(week_date));

UPDATE clean_weekly_sales
SET age_band = 'Unknown' WHERE age_band IS NULL;
UPDATE clean_weekly_sales
SET demographic = 'Unknown' WHERE demographic IS NULL;

SELECT *
FROM clean_weekly_sales;


    




