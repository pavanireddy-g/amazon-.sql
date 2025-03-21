####### Amazon Sales Data Analysis ######
-- Overview of Dataset --
-- The data consists of sales record of three cities/branch in Myanmar 
-- which are Naypyitaw, Yangon, Mandalay which took place in first quarter of year 2019 --
-- the data consists of 1000 rows and 17 columns --


-- Objective of Project --
-- The major aim of this project is to gain insight into the sales data of Amazon --
-- and to understand the different factors that affect sales of the different branches --
#-------------------------------------------------------------------------------------------------------#

## Data Wrangling 
 
---- Creating Database -----

CREATE DATABASE amazon;

USE amazon;

---- Creating Table ----

CREATE TABLE IF NOT EXISTS sales (
      invoice_id VARCHAR(30) NOT NULL,
	  branch VARCHAR(5) NOT NULL,
	  city VARCHAR(30) NOT NULL,
	  customer_type VARCHAR(30) NOT NULL,
	  gender VARCHAR(10) NOT NULL,
	  product_line VARCHAR(100) NOT NULL,
	  unit_price DECIMAL(10,2) NOT NULL,
	  quantity INT NOT NULL,
	  VAT FLOAT NOT NULL,
	  total DECIMAL(10,2) NOT NULL,
	  date DATE NOT NULL,
	  time TIME NOT NULL,
	  payment_method VARCHAR(30) NOT NULL,
	  cogs DECIMAL(10,2) NOT NULL,
	  gross_margin_percentage FLOAT NOT NULL,
	  gross_income DECIMAL(10,2) NOT NULL,
	  rating FLOAT NOT NULL
	  );
       
SELECT * FROM sales;

## ANALYSIS LIST
                                                                
---- Product Analysis ----
# Food and Beverages is generating highest revenue. 
# Electronics accessories has recorded highest sales.
# Health and beauty is generating lowest revenue and sales.

---- Sales Analysis ----
# January has generated highest revenue of around 116292.
# Branch A exceeded the average sales.
# Naypyitaw has generated highest revenue.

---- Customer Analysis ----
# Member customer type has contributed in terms of revenue.
# Female have contributed more to the revenue.

-----    FEATURE ENGINEERING   -----

## Adding a new column named time_of_day 

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE sales 
ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = CASE
    WHEN HOUR(time) >= 0 AND HOUR(time) < 12 THEN 'Morning'
    WHEN HOUR(time) >= 12 AND HOUR(time) < 18 THEN 'Afternoon'
    ELSE 'Evening'
END;

## Add a new column day_name

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE sales 
ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DATE_FORMAT(date,  '%a');

## Add a new column month_name

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE sales 
ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = DATE_FORMAT(date,  '%b');

------  BUSINESS QUESTION TO ANSWER ------
								
# 1. What is the count of distinct cities in the dataset?

         SELECT COUNT(DISTINCT(city)) AS count_distinct_city
         FROM sales;
         
# 2. For each branch, what is the corresponding city?

         SELECT distinct branch, city
         FROM sales;
         
# 3. What is the count of distinct product lines in the dataset?

         SELECT COUNT(DISTINCT(product_line)) AS count_distinct_product_line
         FROM sales;
         
# 4. Which payment method occurs most frequently?
        
         SELECT payment_method, COUNT(*) AS count_payment_method
         FROM sales
         GROUP BY payment_method
         ORDER BY count_payment_method DESC
         LIMIT 1;
         
# 5. Which product line has the highest sales?

select product_line, sum(quantity) as total_sales from sales 
group by product_line 
order by total_sales desc
limit 1;

# 6. How much revenue is generated each month?
     
         SELECT month_name, SUM(total) AS total_revenue
         FROM sales
         GROUP BY month_name;
         
# 7. In which month did the cost of goods sold reach its peak?
         
         SELECT month_name
         FROM sales
         WHERE cogs = (SELECT MAX(cogs) FROM sales);

# 8. Which product line generated the highest revenue?
 
         SELECT product_line, SUM(total) AS total_revenue
         FROM sales
         GROUP BY product_line
         ORDER BY total_revenue DESC
         LIMIT 1;
         
# 9. In which city was the highest revenue recorded?

         SELECT city, SUM(total) AS total_revenue
         FROM sales
         GROUP BY city
         ORDER BY total_revenue DESC
         LIMIT 1;
         
# 10. Which product line incurred the highest Value Added Tax?

select product_line, max(vat) highest_vat  from sales
group by product_line
order by highest_vat desc
limit 1;
        
# 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

	select product_line, sum(total) as revenue, 
case 
	when sum(total) > (select sum(total)/count(distinct(product_line)) from sales) then 'Good'
    else 'Bad'
end performance
from sales
group by product_line;

# 12. Identify the branch that exceeded the average number of products sold.
select branch, sum(quantity) as product_sold from sales
group by branch
having product_sold > (select sum(quantity)/count(distinct branch) as avg_quantity from sales);

        
# 13. Which product line is most frequently associated with each gender?
with new as 
(select gender, product_line, count(*) as count from sales
group by gender, product_line),

max_count as 
(select max(count) from new group by gender)

select * from new 
where count in (select * from max_count) limit 2;

        
# 14. Calculate the average rating for each product line.

		SELECT product_line, AVG(rating) AS avg_rating
        FROM sales
        GROUP BY product_line;


# 15. Count the sales occurrences for each time of day on every weekday.

        SELECT day_name, time_of_day, COUNT(*) AS sales_count
        FROM sales
        WHERE day_name IN ('Mon', 'Tue', 'Wed', 'Thu', 'Fri')
        GROUP BY day_name, time_of_day;
        
# 16. Identify the customer type contributing the highest revenue.

       SELECT customer_type, SUM(total) AS total_revenue
       FROM sales
       GROUP BY customer_type
       ORDER BY total_revenue DESC
       LIMIT 1;

# 17. Determine the city with the highest VAT percentage.

	   SELECT city, SUM(VAT) / SUM(total) * 100 AS VAT_percentage
       FROM sales
       GROUP BY city
       ORDER BY VAT_percentage DESC
       LIMIT 1;

# 18. Identify the customer type with the highest VAT payments.

      SELECT customer_type, SUM(VAT) AS VAT_Payments
      FROM SALES
      GROUP BY customer_type
      ORDER BY VAT_Payments DESC
      LIMIT 1;

# 19. What is the count of distinct customer types in the dataset?

       SELECT COUNT(DISTINCT(customer_type)) AS count_distinct_customer_type
       FROM sales;
       
# 20. What is the count of distinct payment methods in the dataset?

       SELECT COUNT(DISTINCT(payment_method)) AS count_distinct_payment_method
       FROM sales;
       
# 21. Which customer type occurs most frequently?

       SELECT customer_type, COUNT(*) AS frequency
       FROM sales
       GROUP BY customer_type
       ORDER BY frequency DESC
       LIMIT 1;

      
# 22. Identify the customer type with the highest purchase frequency.

      SELECT customer_type, COUNT(*) AS purchase_frequency
	  FROM sales
	  GROUP BY customer_type
	  ORDER BY purchase_frequency DESC
	  LIMIT 1;

# 23. Determine the predominant gender among customers.

      SELECT gender, COUNT(*) AS gender_count
      FROM sales
	  GROUP BY gender
      ORDER BY gender_count DESC
      LIMIT 1;

# 24. Examine the distribution of genders within each branch.

      SELECT branch,gender, COUNT(*) AS gender_count
      FROM sales
	  GROUP BY branch,gender
      ORDER BY branch,gender_count DESC;

# 25. Identify the time of day when customers provide the most ratings.

      SELECT day_name, EXTRACT(HOUR FROM time) AS hour_of_day, COUNT(*) AS rating_count
      FROM sales
      GROUP BY day_name, EXTRACT(HOUR FROM time)
      ORDER BY rating_count DESC;

# 26. Determine the time of day with the highest customer ratings for each branch.

	  SELECT branch, EXTRACT(HOUR FROM time) AS hour_of_day, COUNT(*) AS rating_count
      FROM sales
      GROUP BY branch, EXTRACT(HOUR FROM time)
      ORDER BY branch, rating_count DESC;
      
# 27. Identify the day of the week with the highest average ratings.

      SELECT day_name, AVG(rating) AS avg_rating
      FROM sales
      GROUP BY day_name
      ORDER BY avg_rating DESC
      LIMIT 1;
      
# 28. Determine the day of the week with the highest average ratings for each branch.

      SELECT branch,day_name, AVG(rating) AS avg_rating
      FROM sales
      GROUP BY branch,day_name
      ORDER BY branch,avg_rating DESC
      LIMIT 1;
     
### Thank You ###