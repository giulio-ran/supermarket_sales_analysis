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
- **Star Schema setup**: different tables have been created, each one describinig a different dimension of the data; each of these 'descriptive' table can be linked to the principal 'fact' table through a single join.











