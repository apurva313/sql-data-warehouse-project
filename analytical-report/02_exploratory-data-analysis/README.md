

# Overview 📜

The primary goal of these scripts is to query a sales data warehouse to extract meaningful insights. The analyses cover database structure, dimensional data, key performance indicators (KPIs), and the ranking of entities like customers and products. The queries are organized into logical files, each serving a distinct analytical purpose.



## Scripts Description 🗂️

The analysis is broken down into the following numbered scripts, intended to be run in order for a comprehensive analysis.

### `01_database_exploration.sql`
* **Purpose**: To understand the foundational structure of the database.
* **Queries**:
    * Lists all tables and their schemas within the database using `INFORMATION_SCHEMA.TABLES`.
    * Inspects the columns, data types, and nullability for the `dim_customers` table using `INFORMATION_SCHEMA.COLUMNS`.

### `02_dimensions_exploration.sql`
* **Purpose**: To explore the unique values within the dimension tables.
* **Queries**:
    * Retrieves a distinct list of countries where customers are located.
    * Generates a unique list of product categories, subcategories, and names.

### `03_date_range_exploration.sql`
* **Purpose**: To determine the temporal boundaries of the dataset.
* **Queries**:
    * Finds the first and last order dates to understand the total time span of sales data in months.
    * Calculates the age of the youngest and oldest customers based on their birthdates.

### `04_measures_exploration.sql`
* **Purpose**: To calculate key business metrics (KPIs) for a quick overview of performance.
* **Queries**:
    * Calculates total sales revenue, total items sold, and average selling price.
    * Counts the total number of unique orders, products, and customers who have placed an order.
    * Compiles a summary report of all key metrics using `UNION ALL`.

### `05_magnitude_analysis.sql`
* **Purpose**: To quantify and group data across different dimensions to understand distribution and composition.
* **Queries**:
    * Aggregates total customers by country and gender.
    * Calculates total revenue generated per product category and per customer.
    * Determines the total number of items sold in each country.

### `06_ranking_analysis.sql`
* **Purpose**: To rank entities like products and customers based on performance metrics.
* **Queries**:
    * Identifies the top 5 products generating the highest and lowest revenue.
    * Uses the `RANK()` window function for more complex ranking scenarios.
    * Lists the top 10 customers by revenue and the 3 customers with the fewest orders.


## Key SQL Concepts Used 💡

* **Database Metadata**: Querying `INFORMATION_SCHEMA` to explore database objects.
* **Aggregate Functions**: `SUM()`, `COUNT()`, `AVG()`, `MIN()`, `MAX()`.
* **Window Functions**: `RANK()` for advanced ranking.
* **Joins**: `LEFT JOIN` to combine fact and dimension tables.
* **Clauses**: `GROUP BY`, `ORDER BY`, `WHERE` for data aggregation and filtering.
* **Date Functions**: `DATEDIFF()` to calculate durations.
* **Set Operators**: `UNION ALL` to combine result sets into a summary report.
