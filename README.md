# # Supermarket Sales Analysis SQL Project

- **Level**: Basic-Intermediate
- **Dataset**: Supermarket_sales
- **Language**: SQL


## Abstract and research questions

This study is the first in a series of three aimed at analyzing a retail sales dataset using SQL, with each study providing a different level of depth. The dataset tracks the sales parameters of an online supermarket operating across the United States.
In this first study, I investigated whether the top-ranked cities by sales volume maintained their positions when analyzed by total profit. I performed a similar comparison at the state level. For both analyses, the results were consistent: the cities and states with the highest sales volumes also generated the highest profits.
In contrast, when analyzing the top states by profit ratio (the ratio of profit to sales revenue), a radically different list emerged. This highlights the possibility that targeted advertising campaigns could improve profit performance in specific geographic areas that display a higher profit-to-sales ratio.
In the second part of the study, I investigated which subcategories generated the highest profit, further breaking down this analysis by the segment variable (i.e., whether different customer segments spent more on specific subcategories). The top three subcategories by profit remained consistent across all three segments—Binders, Paper, and Furnishings, in that order. However, the rankings for the remaining subcategories varied across segments. This suggests that while demand for the top three subcategories is broad and stable, the performance of the remaining categories is significantly influenced by the type of customer.
Next, I examined which cities demonstrated the best overall shipping performance. Kenner, Portage, and Mentor emerged as the top performers, achieving an average shipping time of zero days (shipping on the same day the order was received). A determining factor could be the relatively small size of these urban centers; the potentially lower volume of orders may facilitate higher shipping efficiency.
Finally, I investigated whether different discount percentages were linked to higher profit values, categorizing this analysis by category and subcategory. The findings indicated that for discounts exceeding 30%, profit became negative across all categories and subcategories.

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

In this case, both null and duplicate values were absent in the raw data. For this reason, I didn't write any DELETE query.

- **Star Schema setup**: different tables have been created, each one describinig a different dimension of the data; each of these 'descriptive' tables can be linked to the principal 'fact' table through a single join.

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
- **Sales and profit by city**: Identifying cities with sales peaks can highlight locations where further investment might yield a significant increase in revenue.
- **Sales and profit by State**: This follows a similar logic to the city-level analysis but provides macroscopic data, offering a broader perspective on performance at the State level. 
- **Profit ratio by State and by sub-category**: the Profit Ratio formula is given by $$\text{Profit Ratio} = \frac{\text{Total Profit}}{\text{Total Sales}} \times 100$$
<br> This metric is crucial for understanding the profitability of current sales across different regions and product lines.
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
```
In both State and City rankings, the top three performers remained remarkably consistent across sales and profit. Specifically, the cities of New York, Los Angeles, and Seattle mirrored the dominance of their respective states: New York, California, and Washington. The only notable variance occurs in the State sales ranking, where Pennsylvania holds the third position while Washington follows in fourth. This trend indicates that profitability for these high-volume regions remains robust, showing no major disruptions. Furthermore, it suggests that the highest sales volumes are heavily concentrated within major metropolitan hubs, effectively mitigating the impact of smaller centers on the overall total profit.
<br>Something different happened when considering the Profit Ratio: the top three states are no longer the sales leaders. This divergence highlights the need to further investigate the possible reason why States with medium sales volumes are highly profitable.

```sql
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
- **Profit analysis by subcategory and segment**: some subcategories and segment customers can generate a higher profit. In this analysis, each sub-category profit computation is divided by customer segment, to highlight the different customer behaviour per subcategory (e.g., a customer in the Corporate segment could buy more Chair items with respect to a Consumer customer, or vice versa).
- **Basket Analysis for shared sub-categories in the same orders**: this analysis identifies which products are bought together and in what percentage. Products from two or more subcategories may be purchased together more frequently, resulting in a mutual profit spike.
- **Shipping performance by city**: calculated as the mean difference between the order date and the shipping date, indicating the average shipping performance by city.
- **Discount vs Profit analysis**: I investigated the profit-discount relationship, isolating the 'category' and 'subcategory' variables. Indeed, certain types of products can benefit from specific discount percentages, while others may not. This information is crucial for a company to identify the optimal discount for each category/subcategory, to maximize profit.

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

-- Discount vs Profit analysis
-- Average profit by discount percentage
SELECT 
    discount AS 'Discount (%)',
    COUNT(*) AS 'Number of sales',
    ROUND(AVG(sales), 2) AS 'Average sale amount ($)',
    ROUND(AVG(profit), 2) AS 'Average profit ($)',
    ROUND(SUM(profit), 2) AS 'Total profit ($)',
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS 'Margin (%)'
FROM sales
GROUP BY discount
ORDER BY discount ASC;


-- Discount and profit by category
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

-- Discount and profit by sub-category
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
```

### 3. Advanced-level business analysis
In the following section, I carried out a more advanced analysis, emploing the following techniques:
- **Customer Retention analysis**: It's a complex analysis that investigates how much a customer is 'loyal' to the company. It includes the calculation of the following metrics:
  1) 'Total acquired customers by year': it describes how many customers were acquired for each year. It helps understand if, for example, the current sales volume is due to a good amount of 'loyal' customers, or just to a flow of new customers, maybe acquired by advertising campaigns.
  2) 'Average days to second order': it measures how many days, on average, a customer waits for a second order; it describe the risk of the customers to switch to a competitor, and it could give interesting insights about the timing for promotional email sending.
  3) 'Retention rate': it is computed by the formula $$\text{Retention Rate (\\%)} = \frac{\text{Customers with ≥ 2 orders}}{\text{Total Customers}} \times 100$$
  4) 'Annual improvement': computed by the formula $$\text{Annual Improvement(\\%)}  = \frac{\text{AvgDays (t-1)} - \text{AvgDays (t)}}{\text{AvgDays (t-1)}} \times 100$$ where AvgDays (t-1) indicates the average shipping performance of the previous year, whereas AvgDays (t-1) the one of the given year. It is a metric that analyze the relative improvement, year by year, in shipping performance. I is a useful complementary information, which cuold be easily paired with the customer retention trends, to infer a causal effect.

```sql
-- Customer Retention analysis
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
```

- **RFM analysis (Recency, Frequency, Monetary)**: here, analyze each customer individualy, and the metrics are defined as follows:
  1) Recency value = last order within the dataset - last order of the customer. It measures how much time passed from the last bought (the less the better).
  2) Frequency value = total sum of unique orders by customer. It measures the number of orders within a defined period (the higher the better).
  3) Monetary value = Total sum of sales amount by customer. How much income has the single customer
generated (the higher the better).
I completed the RFM with the normalization of each value (to a score between 1 and 5, where numbers near 5 are considered optimal) and the combination, generating a syntetic score for each customer (between 1 and 15, where higher scores indicate a high quality customer).

```sql
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
```

- **Pareto Analysis**: it aims to determine wich minority of customers generates the majority of profit. It follows the Pareto 80/20 rule, according to which the 80\% of the profit is generated by the 20% of customers. This technique is useful to determine which are the 'big buyers', on which the company should focus, because losing these subject would mean to significantly reduce the averall profit of the company. 

```sql
-- Pareto Analysis
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
```
## Results and Discussion

The introductory analysis highlighted that the cities which dispays the highest sales numbers, also tend to display the highest profit numbers; indeed, we can observe that, within the top-10 cities in the ranked list, by sales and profit, we find, e.g., New York City, Los Angeles, Seattle, San Francisco, San Diego. (See in the output folder, tables "Top-30 cities by sales" and "Top-30 cities by profit"). The same holds for the State-level analysis, with States as New York, California and Washingnton in the top-5 rank for both sales and profit.
The State-wise profit ratio computation gave an unexpected result, with the top-5 States Louisiana, Distrinct of Columbia, Maine, Minnesota and Montana, meaning that the relative profit, with respect to sales, is higher for States with lower sales volumes. This highlight the possibility of intensifying the advertisement campaign in these 'high-relative profit' States. (Table 'Top-30 states by Profit Ratio').
The same discrepancy appears from the comparison between the total profit by subcategory and the profit ratio by subcategory. For the former, we see Copiers, Phones and Accessories as the top-3 profit generating, whereas Labels, Paper and Envelops contitute the top-3 in the Profit Ratio ranking. This scenario highlight that, even if higher sales volumes generate higher profit, an active advertisement campaign on high-profit ratio subcategories could generate a significant spike in profit with just a modest relative spike in sales.



