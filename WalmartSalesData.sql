CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
	VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
 );
 
 
 
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- ----------------------------------------------------------------------- Feature Engineering -------------------------------------------------------------------------------------------

-- time_of_day

SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;


ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
); 

-- day_name
SELECT
	date,
    DAYNAME(date) AS day_name 
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10); 

UPDATE sales
SET day_name = DAYNAME(date);

-- month_name

SELECT
	date,
    MONTHNAME(date)
FROM sales;


ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name =  MONTHNAME(date);
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- --------------------------------------------------------------------------------Generic-----------------------------------------------------------------------------------------------

-- How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM sales; 

-- In which city is each branch? 
SELECT 
	DISTINCT branch
FROM sales; 

SELECT 
	DISTINCT city, 
    branch
FROM sales;
 
 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------Product-----------------------------------------------------------------------------------------
 
 -- How many unique product lines does the data have?
SELECT
	COUNT(DISTINCT product_line)
FROM sales;

-- How many total transactions have been completed for each payment category? 
SELECT 
	payment_method,
	COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- What is the highest selling product line?
SELECT
	product_line,
    COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

 -- What is the total revenue by month?
SELECT 
	month_name AS month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;
 
 -- Which month had the largest COGS?
 SELECT
	month_name AS month,
    SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;


-- Which product line had the largest revenue? 
SELECT 
	product_line,
    SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

 -- What is the city with the largest revenue? 
SELECT 
	branch,
    city,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- What product line had the largest VAT? 
SELECT 
	product_line,
	AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Fetch each product line and add a column per product line showing "good" or "bad." If a product line has sold higher than average, "good" will appear. Anything else will be "bad."
SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold? 
SELECT 
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);


-- What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line? 
SELECT
ROUND (AVG(rating), 2) AS avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------Sales------------------------------------------------------------------------------------------


-- Number of sales made in each time of the day per weekday
SELECT 
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name= "Monday"
GROUP BY time_of_day
ORDER BY total_sales DESC; 

-- Which type of customer brings the most revenue? 
SELECT 
	customer_type,
    SUM(total) AS total_rev
FROM sales
GROUP BY customer_type
ORDER BY total_rev DESC;


-- Which city has the largest tax percent / VAT (Value Added Tax)?
SELECT
	city,
    AVG(VAT) AS VAT 
FROM sales
GROUP BY city
ORDER BY VAT;

-- Which customer type pays the most in VAT? 
SELECT
	customer_type,
	AVG(VAT) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- ----------------------------------------------------------------------- Customers------------------------------------------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment_method
FROM sales;

-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;


-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "A"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think it has an effect of the sales per branch and other factors.


-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings; branch B is behind both.


-- Which day of the week has the best ratings typically?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings


-- Which day of the week has the best average sales per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;