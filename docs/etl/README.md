# ETL Process Documentation

ETL (Extract, Transform, Load) is a data integration framework that involves extracting data from various sources, transforming it into a usable and consistent format, and loading it into a target destination like a data warehouse. This process is fundamental for data analytics and business intelligence.

![etl_animation_1](https://github.com/user-attachments/assets/b14c395b-cc0e-43a8-a315-332e2824c201)

-----

## 1\. Extraction

The first phase of the ETL process is **Extraction**, which involves retrieving raw data from various source systems. The goal is to acquire the data needed for processing.

#### Extract Types

  * **Full Extraction**: This method involves retrieving the entire dataset from the source system.
      * **Example**: When setting up a new data warehouse, you perform a full extraction to copy the complete `Customers` table from your production database for the first time.
  * **Incremental Extraction**: This method retrieves only the data that has changed (new or modified records) since the last extraction process.
      * **Example**: A nightly job extracts only the sales orders from the last 24 hours by filtering on the `order_date` column, instead of copying the entire sales history every day.

#### Extraction Methods

  * **Pull Extraction**: The ETL system actively initiates a connection to the source system and pulls the required data. This is the most common method.
      * **Example**: An ETL script connects to a Salesforce database every hour and runs a query to pull new customer leads.
  * **Push Extraction**: The source system proactively sends data to the ETL system, often triggered by an event.
      * **Example**: A website's backend is configured to automatically send (push) a JSON message with order details to a data pipeline every time a customer completes a purchase.

#### Extract Techniques

  * **Manual Data Extraction**: A person manually exports data from a source.
      * **Example**: A financial analyst exports a quarterly report from a legacy system into a CSV file and uploads it to a shared folder.
  * **Database Querying**: Running SQL queries to retrieve data directly from a database.
      * **Example**: `SELECT user_id, product_name, purchase_date FROM sales.transactions WHERE status = 'completed';`
  * **File Parsing**: Reading and interpreting data from files like CSV, JSON, or XML.
      * **Example**: An ETL job reads a daily `log.csv` file, splitting each line by the comma delimiter to extract fields like `timestamp`, `user_id`, and `action`.
  * **API Calls**: Interacting with an application's API (Application Programming Interface) to request data.
      * **Example**: Calling the Google Analytics API to retrieve website traffic data for the previous day.
  * **Web Scraping**: Extracting data from websites where no API is available.
      * **Example**: A script that browses an e-commerce site to collect product names and prices.
  * **Event-Based Streaming**: Capturing data from a continuous stream of events.
      * **Example**: Collecting real-time user clickstream data from a mobile application.
  * **CDC (Change Data Capture)**: A sophisticated technique that tracks row-level changes (inserts, updates, deletes) in a source database, often by reading the database's transaction logs.
      * **Example**: Using CDC to capture the exact changes to the `inventory` table in real-time without having to constantly query the entire table for updates.

-----

## 2\. Transformation

In the **Transformation** phase, the raw extracted data is cleaned, validated, and converted into the desired format. This is often the most complex phase of the ETL process.

  * **Data Enrichment**: Enhancing the source data by adding related information from external sources.
      * **Example**: Taking a customer record with a zip code and joining it with a geographical lookup table to add `city` and `state` information.
  * **Data Integration**: Combining datasets from multiple different sources.
      * **Example**: Merging customer data from a CRM system with sales data from an e-commerce platform to create a single, unified customer view.
  * **Derived Columns**: Creating new data fields from existing data.
      * **Example**: Creating a `revenue` column by multiplying the `item_price` by the `quantity_sold`.
  * **Data Aggregations**: Summarizing data to a higher level.
      * **Example**: Calculating the total daily sales by summing up all sales for a given day.
  * **Business Rules & Logic**: Applying custom rules specific to a business process.
      * **Example**: Creating a `customer_tier` column that assigns 'Gold' to customers with over $1,000 in total purchases and 'Silver' to all others.
  * **Data Normalization & Standardization**: Conforming data to a consistent format.
      * **Example**: Converting a `country` column with mixed values like `"USA"`, `"U.S."`, and `"United States"` into a single standard value: `"United States"`.

#### Data Cleansing

Data cleansing focuses on improving data quality by fixing inconsistencies and errors.

  * **Removing Duplicates**: Identifying and deleting redundant records.
      * **Example**: Deleting a customer record that was entered twice with the same email address.
  * **Data Filtering**: Removing irrelevant data from the dataset.
      * **Example**: Filtering out all sales records that belong to internal 'test' accounts.
  * **Handling Missing Data**: Managing records with null or missing values.
      * **Example**: If a `phone_number` is missing, the field is populated with a default value like `'Not Provided'`.
  * **Handling unwanted spaces**: Removing leading, trailing, or excessive internal spaces from string data.
      * **Example**: Using a `TRIM()` function to change `"  Jane Doe  "` to `"Jane Doe"`.
  * **Data Type Casting**: Converting data from one type to another.
      * **Example**: Converting a `order_date` column stored as a text string (e.g., `"2025-09-18"`) into a proper `DATE` data type.
  * **Outlier Detection**: Identifying data points that deviate significantly from other observations.
      * **Example**: Flagging a sales order with a `quantity` of 5,000 for manual review, as typical orders are less than 50.

-----

## 3\. Load

The final phase is **Load**, where the transformed data is written into the target system, such as a data warehouse or data lake.

#### Processing Types

  * **Batch Processing**: Data is loaded in large, scheduled groups or batches.
      * **Example**: An ETL job that runs every night at 1 AM to process all of the previous day's data.
  * **Stream Processing**: Data is processed and loaded continuously, as soon as it arrives.
      * **Example**: A system that processes financial transactions in real-time and loads them into a fraud detection database within milliseconds.

#### Load Methods

  * **Full Load**: The entire dataset is loaded into the target, often overwriting what was previously there.
      * **Example**: Every week, the `product_categories` table in the data warehouse is completely wiped (`TRUNCATE`) and reloaded from the source to ensure it is perfectly in sync.
  * **Incremental Load**: Only new or updated data is added to the target.
      * **Append**: New records are added to the target table without changing existing records. **Example**: New website clickstream events are simply added to the end of a `web_logs` table.
      * **Upsert / Merge**: If a record already exists in the target, it is updated. If it does not exist, it is inserted. **Example**: When loading daily product inventory, you `UPDATE` the stock count for existing products and `INSERT` records for new products.

#### Slowly Changing Dimensions (SCD)

SCDs are techniques used to manage the history of data in dimension tables.

  * **SCD 0 (No Historization)**: Attributes are fixed and do not change.
      * **Example**: A customer's `date_of_birth`.
  * **SCD 1 (Overwrite)**: The existing record is updated with the new information, and the previous value is lost.
      * **Example**: A customer corrects a spelling mistake in their last name. The existing record is simply overwritten with the correct name.
  * **SCD 2 (Historization)**: A new record is created to store the changed data, preserving the old record for historical purposes. This is often managed with start and end dates or a version number.
      * **Example**: A customer moves to a new city. The old customer record is marked as "inactive" (e.g., by setting an `end_date`), and a new record is created with the updated city and a new `start_date`.
