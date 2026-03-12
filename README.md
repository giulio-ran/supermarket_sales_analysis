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
We observe that the top three sub-categories by total profit (Copiers, Phones, Accessories) differ significantly from those with the highest profit ratio (Labels, Paper, Envelopes). This discrepancy highlights a fundamental difference in product types: while Copiers generate high absolute profit due to their high unit cost, low-cost items like Labels yield a much higher profit margin. These insights make it easier to break down the sources of annual profit and understand their relative proportions.

### 3. Intermediate-level business analysis
Here, I carried out a more in-depth business analysis, using more complex SQL queries to investigate the following:
- **Profit analysis by subcategory and segment**: some subcategories and segment customers can generate a higher profit. In this analysis, each subcategory profit computation is divided by customer segment, to highlight the different customer behaviour per subcategory (e.g., a customer in the Corporate segment could buy more Chair items with respect to a Consumer customer, or vice versa).
- **Basket Analysis for shared sub-categories in the same orders**: this analysis identifies which products are bought together and in what percentage. Products from two or more subcategories may be purchased together more frequently, resulting in a mutual profit spike.
- **Shipping performance by city**: calculated as the mean difference between the order date and the shipping date, indicating the average shipping performance by city.
- **Discount vs Profit analysis**: I investigated the profit-discount relationship, isolating the 'category' and 'subcategory' variables. Indeed, certain types of products can benefit from specific discount percentages, while others may not. This information is crucial for a company to identify the optimal discount for each category/subcategory, to maximize profit.

```sql
-- Profit quantification by subcategory and by segments
SELECT c.segment, p.sub_category 'Sub-Category', SUM(s.quantity) 'Total Quantity', round(sum(s.profit),0) 'Profit ($)'
FROM sales s
INNER JOIN (
    SELECT DISTINCT product_id, sub_category 
    FROM products
) p ON s.product_id = p.product_id
inner join customer c on c.customer_id = s.customer_id
GROUP BY 1,2
ORDER BY 1,3 DESC;
```
Across all three segments — Consumer, Corporate, and Home Office — the subcategories Phones, Copiers, and Accessories were present in the top four by profit. However, the total profit from these subcategories was highest in the Consumer segment, followed by Corporate and Home Office. This data provides insights into the scale of the customer base: even if a single Corporate client buys more than an individual Consumer, the sheer number of consumers generates a higher overall profit. The same reasoning applies to the Home Office segment; although these customers might spend more on average than a single Consumer but less than a company, they rank last due to their smaller overall population. A future analysis considering the average expenditure per customer in each segment would be particularly insightful.
```sql
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
```		
The top four most frequently purchased subcategory pairs all included Binders, combined respectively with Paper, Phones, Storage, and Furnishings. This ranking is largely driven by the high average quantity of Binders units required.

```sql
-- Shipping performance: computation of the average shipping time for each city
-- From the worst to the best performance
select s.city City, avg(datediff(o.ship_date, o.order_date)) `Average shipping days`
		from sales s 
		join orders o on s.order_id = o.order_id
		group by City
		order by 2 desc;
```

Kenner, Portage, Mentor, Rock Hill, and Billings are the cities with the best shipping performance, averaging zero days between order receipt and shipping. This result could be due to the smaller size of these urban centers compared to larger cities - and therefore the lower sales volume -, but it could also stem from a highly efficient shipping logistics.

```sql
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
The 'Profit by Discount' table clearly shows that, for discount percentages exceeding 20% (0.2), profit becomes negative across all considered indicators: total profit, average profit per sale, and profit margin (%). A higher level of granularity may be required for future studies. This trend also persists across almost every category and subcategory. The only exceptions are subcategories Storage and Supplies, which yielded negative profits even at a 20% discount. These findings suggest that the company should always chose discounts equal or lower to 20% to maintain profitability.


