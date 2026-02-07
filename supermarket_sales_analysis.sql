create database supermarket_sales;

use supermarket_sales;

CREATE TABLE raw_supermarket_sales (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(255),
    segment VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_name VARCHAR(255),
    sales DECIMAL(10, 4),
    quantity INT,
    discount DECIMAL(5, 2),
    profit DECIMAL(10, 4)
);


load data infile "C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/supermarket_sales_converted.csv"
into table raw_supermarket_sales 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

create table sales
(row_id INT PRIMARY KEY,
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    city VARCHAR(50),
    product_id VARCHAR(50),
    sales DECIMAL(10, 4),
    quantity INT,
    discount DECIMAL(5, 2),
    profit DECIMAL(10, 4)
)
select row_id, order_id, customer_id, city, product_id,
sales, quantity, discount, profit from raw_supermarket_sales;

select * from sales limit 50;

create table customer
(customer_id VARCHAR(50),
customer_name VARCHAR(100),
segment VARCHAR(50))
select customer_id, customer_name, segment
from raw_supermarket_sales;



create table orders
(order_id VARCHAR(50),
product_id VARCHAR(50),
order_date DATE,
ship_date DATE,
ship_mode VARCHAR(50),
country VARCHAR(100),
city VARCHAR(100),
state VARCHAR(100),
postal_code VARCHAR(20),
region VARCHAR(50)
)
select order_id, product_id, order_date, ship_date,
		ship_mode, country, city, state, postal_code, region
		from raw_supermarket_sales;

select * from orders limit 50;

create table products 
(product_id varchar(50),
product_name varchar(200),
category varchar(100),
sub_category varchar(50)
)
select product_id, product_name,
category, sub_category from raw_supermarket_sales;

/* Sales and profit by city */
/*1. Sales */

select city 'City', sum(sales) 'Total Sales ($)'
from sales
group by 1 order by 2
limit 30;



/*2. Profit */
select city 'City', sum(profit) 'Total Profit ($)' 
from sales 
group by 1 order by 2 desc limit 30;


/* Sales and Profit by State */

/* Sales by state */

select o.state 'State', sum(s.sales) 'Total Sales ($)'
from sales s 
inner join orders o on o.city = s.city
group by 1 order by 2 limit 30;


/* Profit by State */
select o.state 'State', sum(s.profit) 'Total Profit ($)'
from sales s 
inner join orders o on o.city = s.city
group by 1 order by 2 limit 30;


/* Profit ratio (Sum(profit)/sum(sales)) by State */
select o.state 'State', round(sum(s.profit)/sum(s.sales),2)*100 'Profit Ratio (Profit/Sales) %'
from sales s 
inner join orders o on o.city = s.city
group by 1 order by 2 limit 30;

SELECT product_id, COUNT(*) 
FROM products 
GROUP BY product_id 
HAVING COUNT(*) > 1;



/* Total Profit by Sub-Category */
SELECT p.sub_category 'Sub-Category', SUM(s.profit) 'Total Profit ($)'
FROM sales s
INNER JOIN (
    SELECT DISTINCT product_id, sub_category 
    FROM products
) p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC;

/* Profit Ratio by Sub-Category */
SELECT p.sub_category 'Sub-Category', round(SUM(s.profit)/SUM(s.sales)*100,2) 'Profit Ratio'
FROM sales s
INNER JOIN (
    SELECT DISTINCT product_id, sub_category 
    FROM products
) p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 desc;

/* Basket Analysis by sub-category*/
SELECT p.sub_category 'Sub-Category', SUM(s.quantity) 'Total Quantity', round(sum(s.profit),0) 'Profit ($)'
FROM sales s
INNER JOIN (
    SELECT DISTINCT product_id, sub_category 
    FROM products
) p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC;

/* Basket Analysis by sub-category and by segments */
SELECT c.segment, p.sub_category 'Sub-Category', SUM(s.quantity) 'Total Quantity', round(sum(s.profit),0) 'Profit ($)'
FROM sales s
INNER JOIN (
    SELECT DISTINCT product_id, sub_category 
    FROM products
) p ON s.product_id = p.product_id
inner join customer c on c.customer_id = s.customer_id
GROUP BY 1,2
ORDER BY 1,3 DESC;


/* Basket analysis for shared sub-categories in the same orders */
select s1.sub_category `Product (a)`, s2.sub_category `Product (b)`,
		count(distinct s1.order_id) `Times bought together` 
		from (select  
			s.order_id, p.sub_category 
			from sales s 
			join products p
			on p.product_id = s.product_id) s1
			join (select  
			s.order_id, p.sub_category 
			from sales s  
			join products p 
			on p.product_id = s.product_id) s2 
			on s1.order_id = s2.order_id  
			and s1.sub_category < s2.sub_category 
	group by 1,2 
	order by 3 desc ;
			
		
/* Shipping performance: computation of the average shipping time for each city
 * From the worst to the best performance */
select s.city City, avg(datediff(o.ship_date, o.order_date)) `Average shipping days`
		from sales s 
		join orders o on s.order_id = o.order_id
		group by City
		order by 2 desc;

/* Customer Retention analysis */
WITH FirstOrders AS (
    SELECT 
        s.customer_id, 
        MIN(o.order_date) AS first_purchase_date,
        YEAR(MIN(o.order_date)) AS cohort_year
    FROM sales s 
    join orders o on o.order_id = s.order_id 
    GROUP BY s.customer_id
),
SecondOrders AS (
    SELECT 
        s.customer_id, 
        MIN(o.order_date) AS second_purchase_date
    FROM sales s
    join orders o on o.order_id = s.order_id
    JOIN FirstOrders f ON s.customer_id = f.customer_id
    WHERE o.order_date > f.first_purchase_date
    GROUP BY s.customer_id
)
SELECT 
    f.cohort_year AS `Acquition year (Cohort)`,
    COUNT(f.customer_id) AS `Total aquired customers`,
    ROUND(AVG(DATEDIFF(s.second_purchase_date, f.first_purchase_date)), 0) AS `Average days to second order`,
    ROUND((COUNT(s.second_purchase_date) / COUNT(f.customer_id)) * 100, 2) AS `Retention Rate (%)`,
	(LAG(ROUND(AVG(DATEDIFF(s.second_purchase_date, f.first_purchase_date)), 0),1) over (order by f.cohort_year) -
	ROUND(AVG(DATEDIFF(s.second_purchase_date, f.first_purchase_date)), 0))/
	LAG(ROUND(AVG(DATEDIFF(s.second_purchase_date, f.first_purchase_date)), 0),1) over (order by f.cohort_year)*100
	'Annual improvement in first/second order timespan (%)'
	FROM FirstOrders f
LEFT JOIN SecondOrders s ON f.customer_id = s.customer_id
GROUP BY 1
order by 1;



with first_orders as 
	(select s.customer_id,
	min(o.order_date) first_orders_date,
	year(min(o.order_date)) cohort_year
	from sales s 
	join orders o on o.order_id = s.order_id
	group by 1),
	second_orders as 
	(select s.customer_id,
	min(o.order_date) second_orders_date
	from sales s
	join orders o on o.order_id = s.order_id
	join first_orders f on f.customer_id = s.customer_id
	where o.order_date > f.first_orders_date
	group by 1)
select f.cohort_year, 
	count(*) 'Number of aquired customers',
	avg(datediff(s.second_orders_date - f.first_orders_date)) 'Average days to 2nd order'
	from first_orders f 
	join second_orders s on s.customer_id = f.customer_id
	group by 1;
	
	

with first_orders as 
	(select s.order_id,
	min(o.order_date) first_order_date,
	year(min(o.order_date)) cohort_year 
	from sales s
	join orders o on o.order_id = s.order_id
	group by 1),
	second_orders as 
	(select s.order_id,
	min(o.order_date) second_order_date
	from sales s 
	join orders o on o.order_id = s.order_id 
	join first_orders f on f.customer_id = s.customer_id
	where o.order_date > f.first_order_date 
	group by 1) 
	select f.cohort_year, 
			count(f.customer_id) 'Total acquired customers',
			datediff(s.second_order_date, f.first_year_date)
			from first_orders f 
			join second_orders s on f.order_id = s.order_id
			group by 1;


/* RFM analysis (Recency, Frequency, Monetary)
*
* Recency value = last order within the dataset - last order of the customer
* Frequency value = total sum of unique orders by customer
* Monetary value = Total sum of sales amount by customer */
WITH RFM_Base AS (
    SELECT 
        s.customer_id,
        MAX(o.order_date) AS last_order_date,
        SUM(s.sales) AS monetary_value,
        COUNT(DISTINCT s.order_id) AS frequency_value
    FROM sales s
    JOIN orders o ON s.order_id = o.order_id AND s.product_id = o.product_id
    GROUP BY s.customer_id
)
SELECT 
    customer_id,
    DATEDIFF((SELECT MAX(order_date) FROM orders), last_order_date) AS 'Recency value',
    frequency_value 'Frequency value',
    ROUND(monetary_value, 2) AS 'Monetary value'
FROM RFM_Base
ORDER BY 4 DESC;

/* Assigning a score to each raw RFM value 
 * Each score represents a quintile */
WITH RFM_Calculated AS (
    SELECT 
        s.customer_id,
        DATEDIFF((SELECT MAX(order_date) FROM orders), MAX(o.order_date)) AS recency,
        COUNT(DISTINCT s.order_id) AS frequency,
        SUM(s.sales) AS monetary
    FROM sales s
    JOIN orders o ON s.order_id = o.order_id AND s.product_id = o.product_id
    GROUP BY s.customer_id
),
RFM_Scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM RFM_Calculated
)
SELECT 
    customer_id,
    recency 'Recency value', frequency 'Frequency value', monetary 'Monetary value',
    r_score 'Recency score', f_score 'Frequency score', m_score 'Monetary score',
    (r_score + f_score + m_score) AS 'RFM total score'
FROM RFM_Scores;



/* Discount vs Profit analysis */

/* Average profit by discount percentage */
SELECT 
    discount AS 'Discount (%)',
    COUNT(*) AS 'Number of sales',
    ROUND(AVG(sales), 2) AS 'Average sale amount ($)',
    ROUND(AVG(profit), 2) AS 'Average profit ($)',
    ROUND(SUM(profit), 2) AS 'Total profit ($)',
    -- Calcoliamo il margine percentuale medio
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS 'Margin (%)'
FROM sales
GROUP BY discount
ORDER BY discount ASC;


/* Discount and profit by category */
SELECT 
    p.category AS 'Category',
    s.discount AS 'Discount',
    ROUND(AVG(s.profit), 2) AS 'Average profit',
    CASE 
        WHEN AVG(s.profit) > 0 THEN 'Positive'
        ELSE 'Negative'
    END AS 'Profitability status'
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY 1,2
order by 3 desc;

/* Discount and profit by sub-category */
SELECT 
    p.sub_category AS 'Category',
    s.discount AS 'Discount',
    ROUND(AVG(s.profit), 2) AS 'Average profit',
    CASE 
        WHEN AVG(s.profit) > 0 THEN 'Positive'
        ELSE 'Negative'
    END AS 'Profitability status'
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY 1,2
ORDER BY 3 desc;




/* Pareto Analysis */
WITH Customer_Profit AS (
    SELECT 
        customer_id,
        SUM(profit) AS total_customer_profit
    FROM sales
    GROUP BY customer_id
),
Cumulative_Analysis AS (
    SELECT 
        customer_id,
        total_customer_profit,
        SUM(total_customer_profit) OVER (ORDER BY total_customer_profit DESC) AS cumulative_profit,
        SUM(total_customer_profit) OVER () AS global_total_profit,
        ROW_NUMBER() OVER (ORDER BY total_customer_profit DESC) AS customer_rank,
        COUNT(*) OVER () AS total_customer_count
    FROM Customer_Profit
)
SELECT 
    customer_id,
    ROUND(total_customer_profit, 2) AS profit,
    ROUND((cumulative_profit / global_total_profit) * 100, 2) AS cumulative_percentage,
    ROUND((customer_rank / total_customer_count) * 100, 2) AS customer_percentage
FROM Cumulative_Analysis
ORDER BY total_customer_profit DESC;






























































