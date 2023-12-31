-- Create Databse
Create database  If Not Exists walmartSales;

-- Create table
USE walmartSales;
CREATE TABLE IF NOT EXISTS sales(
		invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
		branch VARCHAR(5) NOT NULL,
		city VARCHAR(30) NOT NULL,
		customer_type VARCHAR(30) NOT NULL,
		gender VARCHAR(30) NOT NULL,
		product_line VARCHAR(100) NOT NULL,
		unit_price DECIMAL(10,2) NOT NULL,
		quantity INT NOT NULL,
		tax_pct FLOAT(6,4) NOT NULL,
		total DECIMAL(12, 4) NOT NULL,
		date DATETIME NOT NULL,
		time TIME NOT NULL,
		payment VARCHAR(15) NOT NULL,
		cogs DECIMAL(10,2) NOT NULL,
		gross_margin_pct FLOAT(11,9),
		gross_income DECIMAL(12, 4),
		rating FLOAT(2, 1)
);


select * from walmartSales.sales;

-- -----------------------------------------------------------------------------------------------------
-- ------------------------------------- Feature engineering --------------------------------------------
-- time_of_day
select 
	time,
    (case
		when `time` between "00:00:00" And "12:00:00" then "Morning" 
		when `time` between "12:01:00" And "16:00:00" then "Afternoon"
        else "Evening"
    end) as time_of_date
from sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

update sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

-- day_name

select 
	date,
    dayname(date)
from sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

update sales
SET day_name = substring(dayname(date) , 1,3);

-- month_name

select 
	date,
    monthname(date)
from sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

update sales
SET month_name = substring(monthname(date) , 1,3);

-- -------------------------------------------------------------------------------------------------------
-- --------------------------------- Generic -------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------

-- How many uniques cities does the data have
select  
	distinct city 
from sales;

-- Count of distinct cities

select  
	count(distinct city )
from sales;

-- In which cityis each branch

select  
	distinct city , branch
from sales;

-- -------------------------------------------------------------------------------------------------------
-- --------------------------------- Product -------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------

-- How many unique product lines does the data have?
select  
	distinct product_line
from sales;

select  
	count(distinct product_line)
from sales;

-- What is the most common payment method?

select
	payment, count( payment) as payment_count
from sales
group by payment
order by payment_count desc;  -- Ans -> Most common method is cash

-- What is the most selling product line?

select  
	product_line , count( product_line) as product_count
from sales
group by product_line
order by product_count desc; -- Ans -> most selling product line is 'Fashion accessories', '178'

-- What is the total revenue by month?

select 
	month_name ,sum(total) as total_revenue 
from sales
group by month_name
order by total_revenue DESC; -- Ans -> Highest revenue is in 'Jan', '116291.8680'


-- What month had the largest COGS?

select 
	month_name ,SUM(cogs) as largest_cogs 
from sales
group by month_name
order by largest_cogs DESC; -- Ans -> Largest cogs is in 'Jan', '110754.16'


-- What product line had the largest revenue?

select 
	product_line ,SUM(total) as largest_Product_revenue
from sales
group by product_line
order by largest_Product_revenue DESC; -- Ans -> Largest product line revenue is 'Food and beverages', '56144.8440'

-- What is the city with the largest revenue?

select 
	city ,SUM(total) as largest_city_revenue 
from sales
group by city
order by largest_city_revenue DESC; -- Ans -> Largest city revenue is 'Naypyitaw', '110490.7755'


-- What product line had the largest VAT?

select 
	product_line ,AVG(tax_pct) as largest_productline_tax
from sales
group by product_line
order by largest_productline_tax DESC; -- Ans -> Largest tax on product line  is 'Home and lifestyle', '16.03033124'

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(total) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(total) > 322 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?

select 
	branch , sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select Avg(quantity) from sales)
order by qty desc; -- Ans -> Branch A sold more products

-- What is the most common product line by gender?

select 
	product_line,gender,count(gender) as total_cnt
from sales
group by gender, product_line
order by total_cnt desc; -- Ans -> For female it's 'Fashion accessories', 'Female', '96'

-- What is the average rating of each product line?

select 
	product_line, round(Avg(rating) , 2) as avg_rat
from sales
group by product_line
order by avg_rat desc; -- Ans -> Highest rating is for 'Food and beverages', '7.11'

 
-- -------------------------------------------------------------------------------------------------------
-- --------------------------------- Sales ----------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday

select
	 day_name, time_of_day , count(*) as total_sales
from sales
where day_name != "Sat" And day_name != "Sun"
group by  day_name , time_of_day
order by total_sales desc;

-- Which of the customer types brings the most revenue?

select 
	customer_type , Sum(total) as total_revenue
from sales
group by customer_type
order by total_revenue desc; -- Ans-> 'Member', '163625.1015'

-- Which city has the largest tax percent/ VAT (Value Added Tax)?

select 
	city , sum(tax_pct) as highest_tax
from sales
group by city
order by highest_tax desc; -- Ans -> 'Naypyitaw', '5261.4655'

-- Which customer type pays the most in VAT?

select 
	customer_type , Sum(tax_pct) as cust_tax
from sales
group by customer_type
order by cust_tax desc; -- Ans-> 'Member', '7791.6715'

-- -------------------------------------------------------------------------------------------------------
-- --------------------------------- Customer ----------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------

-- How many unique customer types does the data have?

select
	distinct customer_type
from sales; -- Ans -> 2

-- How many unique payment methods does the data have?

select
	distinct payment
from sales; -- Ans -> 3

-- What is the most common customer type?

SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC; -- Ans -> 'Member', '499'

-- Which customer type buys the most?

select
	customer_type, count(*) as high_qty
from sales
group by customer_type
order by high_qty desc; -- Ans -> 'Member', '499'

-- What is the gender of most of the customers?
select
	gender, count(*) as gen_count
from sales
group by gender
order by gen_count desc; -- Ans -> 'Male', '498'

-- What is the gender distribution per branch?

SELECT
    branch,
    gender,
    COUNT(*) AS gender_count
FROM
    sales
GROUP BY
    branch , gender;


