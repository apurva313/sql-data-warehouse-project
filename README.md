# End-to-End SQL Data Warehouse & Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository\! 🚀
This project demonstrates a complete data warehousing solution, from raw data ingestion to generating actionable business insights. It is designed to showcase industry best practices in data engineering, data modeling, and analytics.

This repository provides a step-by-step approach to building a scalable and efficient data warehouse, covering:
✅ **ETL Pipelines** (Extract, Transform, Load)
✅ **Data Modeling** (Star Schema)
✅ **SQL-based Reporting & Analytics**

-----

## 🏗️ Data Architecture

The project follows the industry-standard **Medallion Architecture**, logically organizing data into three distinct layers.

  * **🥉 Bronze Layer (Raw Data)**: Stores raw, unaltered data ingested directly from the source CSV files into SQL Server.
  * **🥈 Silver Layer (Cleansed & Transformed Data)**: This layer holds cleansed, standardized, and integrated data prepared for analysis.
  * **🥇 Gold Layer (Business-Ready Data)**: The final presentation layer, optimized for analytics and reporting using a **star schema**.

<img width="1920" height="1200" alt="data_architecture" src="https://github.com/user-attachments/assets/2147e3d8-faad-48af-8308-ec81bddaa7cd" />

➡️ **For a complete breakdown, see the [Detailed Data Architecture Documentation](https://github.com/apurva313/SQL-DataWareHouse-Project/tree/main/docs/data-architecture#high-level-data-architecture)).**

-----

## ⚙️ ETL Process

The data is moved and transformed between layers using an **ETL (Extract, Transform, Load)** process managed by stored procedures. The process includes sophisticated techniques for data cleansing, standardization, and applying business logic.

![etl_animation](https://github.com/user-attachments/assets/eb65230b-3642-47d7-96a9-8281798723e8)


➡️ **For a complete breakdown, see the [Detailed ETL Process Documentation](https://www.google.com/search?q=./docs/README.md](https://github.com/apurva313/SQL-DataWareHouse-Project/tree/main/docs/etl#etl-process-documentation)).**

-----

## 🗺️ Data Flow & Lineage

The data lineage diagram below shows how data flows from the source systems, through the Bronze and Silver layers, and is finally integrated into the Gold layer's star schema.

![data_flow](https://github.com/user-attachments/assets/a10da46a-48c6-4d60-9a11-1a7c1f94cadc)


➡️ **For more details, see the [Data Flow & Lineage Documentation](https://github.com/apurva313/SQL-DataWareHouse-Project/tree/main/docs/data-flow#data-flow--lineage).**

-----

## 🔗 Data Integration & Relationships

The data integration diagram below illustrates how tables from the CRM and ERP source systems are related. It details the key relationships used to join disparate tables and create a unified, 360-degree view of customers and products.


![data_integration](https://github.com/user-attachments/assets/ceec190c-b6c0-48c8-84f0-e0324aacfadc)


➡️ **For more details, see the [Data Integration Documentation](https://www.google.com/search?q=./docs/data_integration.md](https://github.com/apurva313/SQL-DataWareHouse-Project/tree/main/docs/data-integration#data-integration--relationships)).**

----

## ⭐ Data Model: Star Schema

The Gold Layer is modeled as a **Sales Data Mart** using a Star Schema. This model is optimized for high-performance analytics and consists of a central fact table surrounded by descriptive dimension tables.

   * **Fact Table**: `gold.fact_sales`
   * **Dimension Tables**: `gold.dim_customers`, `gold.dim_products`

![data_model](https://github.com/user-attachments/assets/4bbd1afe-5ab1-4250-af17-2f3c3757cb7c)


➡️ **For column-level details, see the [Gold Layer Data Catalog](https://github.com/apurva313/SQL-DataWareHouse-Project/tree/main/docs/data-model#data-model-sales-data-mart-star-schema).**

-----



## 🎯 Project Scope & Objectives

This project is designed to showcase expertise in the following areas:

  * SQL Development
  * Data Engineering & ETL Pipelines
  * Data Architecture & Modeling
  * Data Analytics & Reporting

### Data Engineering: Building the Warehouse

The primary objective is to develop a modern data warehouse using SQL Server to consolidate sales data from disparate sources.

  * **Data Sources**: Import and integrate data from **ERP & CRM (CSV files)**.
  * **Data Quality**: Cleanse data and resolve quality issues before analysis.
  * **Data Modeling**: Combine sources into a single, user-friendly **star schema**.
  * **Documentation**: Provide clear documentation for the data model and architecture.

### BI: Analytics & Reporting

The goal is to develop SQL-based analytics to deliver detailed insights into key business metrics.

  * **Customer Behavior Analysis**: Understand purchasing patterns.
  * **Product Performance Metrics**: Identify top-performing products and categories.
  * **Sales Trend Analysis**: Track revenue and sales patterns over time.

-----

## 🛠️ Technology Stack & Tools

  * **Database**: SQL Server
  * **ETL Processing**: Transact-SQL (T-SQL)
  * **Data Modeling & Visualization**: Draw.io
  * **Project Management**: Notion
  * **Version Control**: Git & GitHub

-----

## 📂 Repository Structure



-----

## 🚀 Setup & Installation

To deploy and run this project, follow these steps:

#### **Prerequisites:**

  * Install **SQL Server** -\> [Download Link](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
  * Install **SQL Server Management Studio (SSMS)** -\> [Download Link](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
  * Clone this repository:
    ```bash
    git clone https://github.com/apurva313/sql-data-warehouse-project.git
    ```

#### **Running the Scripts:**

1.  **Initialize Database**: In SSMS, run the DDL scripts from the `/ddl/` folder in the following order to create the warehouse structure:
      * `ddl_bronze.sql`
      * `ddl_silver.sql`
      * `ddl_gold.sql`
2.  **Load Raw Data**: Use SSMS Import/Export Wizard or BULK INSERT to load the source CSV data into the Bronze layer tables.
3.  **Run ETL Scripts**: Execute the stored procedures in the `/sp/` folder to populate the Silver layer.
      * `proc_load_silver.sql`
4.  **Start Analysis**: The Gold layer views are now ready\! You can query them directly in SSMS or connect a BI tool for reporting.

-----

## ⭐ About Me



-----

## 🛡️ License

This project is licensed under the [MIT License](https://www.google.com/search?q=LICENSE). You are free to use, modify, and share this project with proper attribution.
