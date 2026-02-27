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





