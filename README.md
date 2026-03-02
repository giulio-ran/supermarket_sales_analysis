# # Supermarket Sales Analysis SQL Project

## Project Overview

**Level**: Intermediate-Advanced
**Dataset**: Supermarket_sales

This project aims to analyze a dataset of retail sales, with the usage of a series of intermediate-to-advanced SQL queries. The endpoint results aim to determine factors such as the relationship between discount and profit, which are the areas more prifitable in terms of categories, geographical regions, andh others (Pareto analysis) and which customers bring the highest profit in different modalities (RFM analysis)

## Objectives
1. **Data exploration and cleaning**: loading the raw data into a landing table, conduct a visual inspection and delete null and duplicated rows, performing an exploratory data analysis
2. **Setting up a supermarket_sales database**: building a database following a Star Schema, which is part of the superfamily of OLTP (Online Transactional Processing) database settings.
3. **Business Analysis**: conducting an in-depth business analysis using intermediate-to-advanced techniques, such as profit ratio analysis, basket analysis, shipping perfomance, customer retention analysis, RFM, and others

## Project structure

### 1. Database setup 
- **Database Creation**: The project starts by creating a database named 'supermarket_sales'.
- **Landing table creation**: A table named `raw_supermarket_sales` is created to store the sales data.

```sql

-- Database and landing table creation 
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

-- Data cleaning from null values
SELECT * FROM raw_supermarket_sales
WHERE 
    row_id IS NULL 
    OR order_id IS null
    or order_date is null 
    OR ship_date IS null
    or ship_mode is null
    OR customer_id IS null
    or customer_name is null
    or segment is null 
    or country is null  
    or city is null 
    or state is null 
    or postal_code is null  
    or region is null  
    or product_id is null 
    OR category IS null
    OR sub_category IS null
    or product_name is null 
    or sales is null  
    or quantity is null 
    or discount is null 
    or profit is null;

-- Data cleaning from duplicate values
SELECT 
    row_id, 
    COUNT(row_id) AS numero_ripetizioni
FROM 
    raw_supermarket_sales
GROUP BY 
    row_id
HAVING 
    COUNT(row_id) > 1;

```

In this case, both null values and duplicate values were absent in the raw data. For this reason, I didn't write any DELETE query.

- **Star Schema setup**: different tables have been created, each one describinig a different dimension of the data; each of these 'descriptive' table can be linked to the principal 'fact' table through a single join.

```sql
-- Star Schema setup
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

create table products 
(product_id varchar(50),
product_name varchar(200),
category varchar(100),
sub_category varchar(50)
)
select product_id, product_name,
category, sub_category from raw_supermarket_sales;
```

### 2. Basic-level business analysis
I proceeded to carry out the first introductory analysis, using simple SQL queries to analyze:
- **Sales and profit by city**: some cities could demostrate a peak in sales, indicating that an investment in those cities may result in a further increase in sales
- **Sales and profit by State**: same reasoning for the previous analysis, but it completes the city analysis with more macroscopic data about the sales on a State level 
- **Profit ratio by State and by sub-category**: the Profit Ratio formula is given by $$\text{Profit Ratio} = \frac{\text{Total Profit}}{\text{Total Sales}} \times 100$$ and it helps to understand how much profit the current sales are generating.
- **Total profit by sub-category**

```sql
-- Sales and profit by city
-- 1. Sales

select city 'City', sum(sales) 'Total Sales ($)'
from sales
group by 1 order by 2
limit 30;



-- 2. Profit
select city 'City', sum(profit) 'Total Profit ($)' 
from sales 
group by 1 order by 2 desc;


-- Sales and Profit by State

-- Sales by state

select o.state 'State', sum(s.sales) 'Total Sales ($)'
from sales s 
inner join orders o on o.city = s.city
group by 1 order by 2;

-- Profit by State
select o.state 'State', sum(s.profit) 'Total Profit ($)'
from sales s 
inner join orders o on o.city = s.city
group by 1 order by 2;

-- Profit ratio (Sum(profit)/sum(sales)) by State
select o.state 'State', round(sum(s.profit)/sum(s.sales),2)*100 'Profit Ratio (Profit/Sales) %'
from sales s 
inner join orders o on o.city = s.city
group by 1 order by 2;

SELECT product_id, COUNT(*) 
FROM products 
GROUP BY product_id 
HAVING COUNT(*) > 1;



-- Total Profit by Sub-Category
SELECT p.sub_category 'Sub-Category', SUM(s.profit) 'Total Profit ($)'
FROM sales s
INNER JOIN (
    SELECT DISTINCT product_id, sub_category 
    FROM products
) p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC;

-- Profit Ratio by Sub-Category
SELECT p.sub_category 'Sub-Category', round(SUM(s.profit)/SUM(s.sales)*100,2) 'Profit Ratio'
FROM sales s
INNER JOIN (
    SELECT DISTINCT product_id, sub_category 
    FROM products
) p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 desc;
```

### 3. Intermediate-level business analysis
Here, I carried out a more in-depth business analysis, using more complex SQL queries to investigate the following:
- **Profit analysis by subcategory and segment**: some subcategories and segment customers can generate a higher profit. In this analysis, each sub-category profit computation is divided for customer segment, to highlight the different customer behaviour per sub-category (e.g., a customer in the Corporate segment could buy more Chair item with respect to a Consumer customer, or vice versa.
- **Basket Analysis for shared sub-categories in the same orders**: Basket analysis analyze which product are brought togheter and in what percentage. Product of two or more subcategories could result to be bought toghether more often, resulting in a mutual profit spike.
- **Shipping performance by city**: calculated as the mean difference between the order date and the shipping date, indicating the average shipping performance by city.

```sql
-- Profit quantification by sub-category
SELECT p.sub_category 'Sub-Category', SUM(s.quantity) 'Total Quantity', round(sum(s.profit),0) 'Profit ($)'
FROM sales s
INNER JOIN (
    SELECT DISTINCT product_id, sub_category 
    FROM products
) p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC;

-- Profit quantification by sub-category and by segments
SELECT c.segment, p.sub_category 'Sub-Category', SUM(s.quantity) 'Total Quantity', round(sum(s.profit),0) 'Profit ($)'
FROM sales s
INNER JOIN (
    SELECT DISTINCT product_id, sub_category 
    FROM products
) p ON s.product_id = p.product_id
inner join customer c on c.customer_id = s.customer_id
GROUP BY 1,2
ORDER BY 1,3 DESC;


-- Basket analysis for shared sub-categories in the same orders
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
			
		
-- Shipping performance: computation of the average shipping time for each city
 * From the worst to the best performance */
select s.city City, avg(datediff(o.ship_date, o.order_date)) `Average shipping days`
		from sales s 
		join orders o on s.order_id = o.order_id
		group by City
		order by 2 desc;
```

### 3. Advanced-level business analysis
In the following section, I carried out a more advanced analysis, taking into consideration the following metrics:
- **Customer Retention analysis**: It's a complex analysis that investigates how much a customer is 'loyal' to the company. It includes the calculation of the following metrics: 1) 'Total acquired customers by year': it describes how many customers were acquired for each year. It helps understand if, for example, the current sales volume is due to a good amount of 'loyal' customers, or just to a flow of new customers, maybe acquired by advertising campaigns. 2) 'Average days to second order': it measures how many days, on average, a customer waits for a second order; it describe the risk of the customers to switch to a competitor, and it could give interesting insights about the timing for promotional email sending. 3) 'Retention rate': it is computed by the formula \text{Retention Rate (\%)} = \left( \frac{\text{Count}(\text{second\_purchase\_date})}{\text{Count}(\text{customer\_id})} \right) \times 100
- 



