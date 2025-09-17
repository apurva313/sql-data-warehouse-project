
# Overview 📜
This repository contains a collection of advanced SQL scripts for performing in-depth data analysis on a sales data warehouse. Building upon foundational explorations, these scripts focus on dynamic, comparative, and segmented analysis to uncover deeper business insights. Each file targets a specific analytical theme, from tracking performance over time to understanding customer behavior through segmentation.

## Scripts Description 🗂️
The analysis is broken down into the following numbered scripts. They can be run independently but provide a comprehensive analytical workflow when used together.

### `07_change_over_time_analysis.sql`
* **Purpose**: To track trends, growth, and seasonality in key metrics over time.
* **Queries**:
    * Aggregates sales data by month, quarter, and day of the week to identify temporal patterns.
    * Calculates Month-over-Month (MoM) sales growth percentage using the `LAG()` window function.
    * Computes a 3-month moving average to smooth out fluctuations and identify trends.
    * Determines cumulative Year-to-Date (YTD) sales.

### `08_cumulative_analysis.sql`
* **Purpose**: To calculate running totals and moving averages to track performance cumulatively.
* **Queries**:
    * Computes a running total of sales and a moving average of price over time.
    * Tracks cumulative customer acquisition to monitor growth of the customer base.
    * Analyzes the cumulative sales contribution of each product category.
    * Calculates a rolling 3-month moving average of sales for trend analysis.

### `09_performance_analysis.sql`
* **Purpose**: To measure and compare performance across different time periods, such as Year-over-Year (YoY).
* **Queries**:
    * Analyzes YoY product performance by comparing annual sales to the previous year and the product's historical average.
    * Measures Month-over-Month (MoM) sales growth for each product category.
    * Tracks YoY growth in the active customer base for each country.
    * Analyzes the Quarter-over-Quarter (QoQ) spending changes for the top 10 customers.

### `10_data_segmentation_analysis.sql`
* **Purpose**: To group data into meaningful categories for targeted insights and strategies.
* **Queries**:
    * Segments products into cost ranges (Low-Cost, Mid-Range, etc.).
    * Groups customers into value-based segments (VIP, Regular, New) based on their tenure and total spending.
    * Segments customers by demographic data (age groups) to analyze generational spending habits.
    * Performs ABC analysis to classify products based on their revenue contribution (A-Grade, B-Grade, C-Grade).
    * Segments customers by purchase recency to identify Active, At-Risk, and Churned customers.

### `11_part_to_whole_analysis.sql`
* **Purpose**: To understand the contribution of individual segments (the "parts") to the overall total (the "whole").
* **Queries**:
    * Calculates the percentage of total sales contributed by each product category and country.
    * Analyzes the sales mix within each category by calculating a subcategory's contribution to both its parent category and the grand total.
    * Investigates the Pareto Principle (80/20 Rule) by determining the percentage of top customers who contribute to 80% of total revenue.

---
## Key SQL Concepts Used 💡
* **Advanced Window Functions**: `LAG()` for period-over-period comparisons, `SUM() OVER()` with `PARTITION BY` for grouped running totals, and `AVG() OVER()` with `ROWS BETWEEN` for moving averages.
* **Common Table Expressions (CTEs)**: Used extensively to structure complex queries into logical, readable steps.
* **Data Segmentation**: `CASE` statements are used to create custom business rules for segmenting customers and products based on behavior, value, and demographics.
* **Temporal Analysis**: A variety of date functions like `DATETRUNC()`, `YEAR()`, `MONTH()`, `DATEPART()`, and `DATEDIFF()` are used to aggregate and compare data across different time granularities.
* **Contribution Analysis**: The `SUM() OVER ()` window function with and without `PARTITION BY` is used to calculate part-to-whole percentage contributions efficiently.
