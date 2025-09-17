# Analytical Summary of Business Operations📈

This document provides a summary of the data analysis project, explaining the steps taken to analyze the sales data and the key business reports that were created.

## Data Analysis Workflow 🔍
A structured analysis was performed using a series of SQL scripts to turn raw sales data into actionable business intelligence. Each step built upon the last to provide a complete picture of the business.

The analytical process included the following stages:

1.  **Database Setup:** The first step was to build the technical foundation. This involved creating the database, defining the table structures (`customers`, `products`, `sales`), and loading the raw data from CSV files.

2.  **Database Exploration:** We examined the database structure to understand how the tables were related to each other and what information they contained.

3.  **Dimensions Exploration:** This involved looking into the non-numerical data. For example, we listed all the unique countries customers came from and all the different product categories to understand the variety in our data.

4.  **Date Range Exploration:** We identified the time period covered by our sales data, finding the first and last order dates to understand the dataset's historical scope.

5.  **Measures Exploration:** We calculated fundamental business metrics (KPIs) to get a quick snapshot of overall performance, such as total sales revenue, total items sold, and the total number of orders.

6.  **Ranking Analysis:** This step was used to identify top and bottom performers. For instance, we ranked products by sales to find our bestsellers and ranked customers by revenue to identify our most valuable clients.

7.  **Change Over Time Analysis:** We analyzed how sales and customer activity changed over time. This helps spot trends, like sales growth month-over-month, and seasonal patterns, such as higher sales during certain times of the year.

8.  **Cumulative Analysis:** This involved calculating running totals to track progress over time. For example, we calculated the year-to-date (YTD) sales each month to see how we were tracking toward annual goals.

9.  **Performance Analysis:** We compared business performance between different time periods. A key part of this was the Year-over-Year (YoY) analysis, which helps measure true growth by comparing a month's performance to the same month in the previous year.

10. **Data Segmentation:** We grouped customers and products into meaningful categories. Customers were segmented by their spending habits (VIP, Regular, New) and demographics (age groups), while products were categorized by cost and sales volume. This allows for more targeted marketing and inventory management.

11. **Part-to-Whole Analysis:** We analyzed how different parts of the business contribute to the whole. For example, we calculated the percentage of total revenue that comes from each product category or each country, which helps identify the most important areas of the business.

## Final Analytical Reports 📝
Two primary, reusable reports were created as SQL views. These reports summarize the complex analysis into a simple, easy-to-use format for business users.

### 1. Customer Report (`gold.report_customers`)
This report provides a complete profile for every customer by combining their personal information with their full purchasing history.

**Key Information in the Report:**
* **Customer Details:** Includes full name, current age, and location.
* **Purchasing Behavior:** Summarizes their total number of orders, total money spent, and total items purchased.
* **Value Segments:** Automatically categorizes customers as **VIP** (high value, long-term), **Regular**, or **New**, allowing for tailored engagement strategies.
* **Calculated Metrics (KPIs):**
    * **Recency:** Shows the number of months since the customer's last purchase, which helps identify at-risk customers.
    * **Average Order Value (AOV):** Calculates the average amount a customer spends per transaction.
    * **Average Monthly Spend:** Shows a customer's average spending over their active lifetime.

**Business Value:** This report enables the company to move beyond generic marketing. For example, the marketing team can create a specific campaign targeting "Regular" customers with high recency (who haven't purchased in a while) to prevent churn, or offer exclusive perks to the "VIP" segment to increase loyalty.

### 2. Product Report (`gold.report_products`)
This report provides a detailed summary of every product's performance from a sales and inventory perspective.

**Key Information in the Report:**
* **Product Information:** Includes the product's name, category, subcategory, and its unit cost.
* **Sales Metrics:** Summarizes the total revenue generated, total units sold, and the number of unique customers who have purchased the product.
* **Performance Segments:** Automatically classifies products as **High-Performer**, **Mid-Range**, or **Low-Performer** based on their revenue contribution.
* **Calculated Metrics (KPIs):**
    * **Recency:** Shows the number of months since the product was last sold, which can indicate declining popularity.
    * **Average Order Revenue (AOR):** Calculates how much revenue the product generates on an average order.
    * **Average Monthly Revenue:** Shows the product's average revenue generation during its active sales period.

**Business Value:** This report helps managers make smarter inventory and marketing decisions. By identifying "Low-Performer" products that also have a high cost, the business can decide whether to discontinue them. Conversely, "High-Performer" products can be prioritized for marketing campaigns and stock allocation.
