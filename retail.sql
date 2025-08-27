--Creating table 
CREATE TABLE transactions (
    transactions_id   INT PRIMARY KEY,
    sale_date         DATE,
    sale_time         TIME,
    customer_id       BIGINT,
    gender            VARCHAR(15),
    age               INT,
    category          VARCHAR(15),
    quantity          INT,
    price_per_unit    NUMERIC(10,2),
    cogs              NUMERIC(12,2),
    total_sale        NUMERIC(12,2)
);

SELECT * FROM transactions;

--Checking Null Records
SELECT * 
FROM transactions
WHERE 
	transactions_id IS NULL OR
	sale_date IS NULL OR
	sale_time IS NULL OR
	customer_id IS NULL OR
	gender IS NULL OR
	category IS NULL OR
	quantity IS NULL OR
	price_per_unit IS NULL OR
	cogs IS NULL OR
	total_sale IS NULL;

--Deleting Null Records
DELETE 
FROM transactions
WHERE 
	transactions_id IS NULL OR
	sale_date IS NULL OR
	sale_time IS NULL OR
	customer_id IS NULL OR
	gender IS NULL OR
	category IS NULL OR
	quantity IS NULL OR
	price_per_unit IS NULL OR
	cogs IS NULL OR
	total_sale IS NULL;

--Total Number of Sales	
SELECT COUNT(*) 
FROM transactions;

--Total Unique Customers
SELECT COUNT(DISTINCT customer_id) 
FROM transactions;

--Categories
SELECT DISTINCT(category)
FROM transactions;

--Business Key Problems and Answers:

-- 1. Data for the sales made on 2022-11-05 
SELECT *
FROM transactions 
WHERE sale_date = '2022-11-05';

-- 2. All transactions for 'Clothing' category and quantity sold is more than 3 in the month of Nov-2022.
SELECT *  
FROM transactions
WHERE category ='Clothing'
	  AND TO_CHAR(sale_date,'YYYY-MM') = '2022-11'
	  AND quantity >=3;

-- 3. Total Sales for each Category
SELECT category,SUM(total_sale) AS net_sales
FROM transactions
GROUP BY category;

-- 4. Average age of customers who purchased the items from 'Beauty' Category
SELECT ROUND(AVG(age)) AS avg_age
FROM transactions
WHERE category ='Beauty';

-- 5. All Transactions where total sales is greater than 1000
SELECT total_sale
FROM transactions 
WHERE total_sale > 1000;

-- 6. Profit and Margin by Category
SELECT category,
       SUM(total_sale - cogs) AS total_profit,
       ROUND(AVG((total_sale - cogs)/total_sale*100),2) AS avg_margin_pct
FROM transactions
GROUP BY category
ORDER BY total_profit DESC;

-- 7. Total Unique Customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM transactions;

-- 8. Top 5 Customers by Lifetime Spend
SELECT customer_id,
       SUM(total_sale) AS total_spent
FROM transactions
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 5;

-- 9. Repeat Customers 
SELECT customer_id,
       COUNT(*) AS purchase_count,
       SUM(total_sale) AS total_spent
FROM transactions
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY purchase_count DESC;

-- 10. Sales by Gender and Category
SELECT gender, category,
       SUM(total_sale) AS total_sales,
       COUNT(*) AS num_transactions
FROM transactions
GROUP BY gender, category
ORDER BY category, total_sales DESC;

-- 11. Monthly Revenue Trend + Best Month per Year
SELECT * 
FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year_s,
        EXTRACT(MONTH FROM sale_date) AS month_s,
        SUM(total_sale) AS total_revenue,
        RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date)
                     ORDER BY SUM(total_sale) DESC) AS rank_s
    FROM transactions
    GROUP BY year_s, month_s
) t
WHERE rank_s = 1;

-- 12. Day of Week Analysis (Which days are busiest?)
SELECT TO_CHAR(sale_date, 'Day') AS day_of_week,
       COUNT(*) AS total_orders,
       SUM(total_sale) AS total_revenue
FROM transactions
GROUP BY day_of_week
ORDER BY total_orders DESC;

-- 13. Average Order Value (AOV) by Category
SELECT category,
       ROUND(AVG(total_sale),2) AS avg_order_value
FROM transactions
GROUP BY category
ORDER BY avg_order_value DESC;

-- 14. Orders by Shift (Morning <12, Afternoon 12–16, Evening >16)
WITH hourly_sales AS (
    SELECT transactions_id, sale_time,
        CASE 
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 16 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shifts
    FROM transactions
)
SELECT shift, COUNT(*) AS total_orders, SUM(total_sale) AS shift_revenue
FROM hourly_sales h
JOIN transactions t ON h.transactions_id = t.transactions_id
GROUP BY shift
ORDER BY shift;