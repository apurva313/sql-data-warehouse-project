
# High-Level Data Architecture

This document outlines the high-level architecture for the data warehouse, detailing the flow of data from various sources through a multi-layered transformation process to final consumption by end-users and applications.

<img width="1920" height="1200" alt="data_architecture" src="https://github.com/user-attachments/assets/b488f8dd-1509-467e-afe8-83032ca11bf7" />

## Architecture Overview

The architecture follows a modern medallion pattern, organized into three distinct layers (Bronze, Silver, and Gold) within a central data warehouse hosted on **SQL Server**. This approach ensures a clear separation of concerns, from raw data ingestion to business-ready analytics.

-----

## 1\. Sources

The process begins with data from various enterprise systems.

  * **Source Systems**: Data is extracted from CRM and ERP systems.
  * **Object Type**: The data is provided in the format of CSV Files.
  * **Interface**: These files are made available in designated folders for ingestion.

-----

## 2\. Data Warehouse

The core of the architecture is the data warehouse, which processes and stores the data in three stages.

### 🥉 Bronze Layer: Raw Data

The Bronze layer is the initial landing zone for all source data. Its primary purpose is to maintain a historical archive of raw, unaltered data.

  * **Description**: Contains raw data ingested directly from the source systems.
  * **Object Type**: Tables.
  * **Load Process**: A stored procedure handles the data loading. It uses a full load, `Truncate & Insert` pattern via batch processing.
  * **Transformations**: No transformations are applied at this stage.
  * **Data Model**: The data model is as-is, mirroring the source structure.

### 🥈 Silver Layer: Cleansed & Standardized Data

Data from the Bronze layer is refined and stored in the Silver layer. This layer represents a conformed, validated, and enriched version of the data, serving as an enterprise-wide source of truth.

  * **Description**: Contains cleansed and standardized data ready for internal consumption.
  * **Object Type**: Tables.
  * **Load Process**: A stored procedure manages the `Truncate & Insert` full load in batches.
  * **Transformations**: This stage involves significant data quality improvements:
      * Data Cleansing
      * Data Standardization
      * Data Normalization
      * Creation of Derived Columns
      * Data Enrichment
  * **Data Model**: The model remains as-is structurally, but the data is of high quality.

### 🥇 Gold Layer: Business-Ready Data

The Gold layer is the final presentation layer, optimized for analytics and reporting. It provides data in a user-friendly, denormalized format.

  * **Description**: Contains business-ready data, aggregated and modeled for specific business domains.
  * **Object Type**: Views.
  * **Load Process**: There is no data movement or loading in this layer. Views query the Silver layer and apply transformations on the fly.
  * **Transformations**: Final transformations are applied to serve business needs:
      * Data Integrations (joins)
      * Aggregations
      * Application of Business Logics
  * **Data Model**: Data is presented in well-defined models for analytics, such as a **Star Schema**, Flat Table, or Aggregated Table.

-----

## 3\. Consume

The Gold layer provides clean and reliable data for various downstream applications and user groups.

  * **BI & Reporting**: Business intelligence tools connect to the Gold layer to create dashboards and reports.
  * **Ad-Hoc SQL Queries**: Analysts and data scientists can run ad-hoc queries directly against the views for exploration and deep analysis.
  * **Machine Learning**: The curated datasets in the Gold layer are used to train and run machine learning models.
