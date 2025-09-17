
# Naming Conventions

This document outlines the naming conventions for schemas, tables, columns, and other objects in the data warehouse.

### **Table of Contents**

1.  [General Principles](https://www.google.com/search?q=%23-general-principles)
2.  [Table Naming Conventions](https://www.google.com/search?q=%23-table-naming-conventions)
      - [Bronze Rules](https://www.google.com/search?q=%23bronze-rules)
      - [Silver Rules](https://www.google.com/search?q=%23silver-rules)
      - [Gold Rules](https://www.google.com/search?q=%23gold-rules)
3.  [Column Naming Conventions](https://www.google.com/search?q=%23-column-naming-conventions)
      - [Surrogate Keys](https://www.google.com/search?q=%23surrogate-keys)
      - [Technical Columns](https://www.google.com/search?q=%23technical-columns)
4.  [Stored Procedure Naming Conventions](https://www.google.com/search?q=%23-stored-procedure-naming-conventions)

-----

### 📜 **General Principles**

  * **Naming Conventions**: Use `snake_case`, with lowercase letters and underscores (`_`) to separate words.
  * **Language**: Use English for all names.
  * **Avoid Reserved Words**: Do not use SQL reserved words as object names.

-----

### 🗂️ **Table Naming Conventions**

#### **Bronze Rules**

All table names must begin with the source system name and match their original names.

  * **Format**: `<sourcesystem>_<entity>`
      * `<sourcesystem>`: The name of the source system (e.g., `crm`, `erp`).
      * `<entity>`: The exact table name from the source system.
  * **Example**: `crm_customer_info` represents customer information from the CRM system.

#### **Silver Rules**

All table names must begin with the source system name and match their original names.

  * **Format**: `<sourcesystem>_<entity>`
      * `<sourcesystem>`: The name of the source system (e.g., `crm`, `erp`).
      * `<entity>`: The exact table name from the source system.
  * **Example**: `crm_customer_info` represents customer information from the CRM system.

#### **Gold Rules**

All names must be meaningful and business-aligned, starting with a category prefix.

  * **Format**: `<category>_<entity>`
      * `<category>`: Describes the table's role, such as `dim` (dimension) or `fact` (fact table).
      * `<entity>`: A descriptive, business-aligned name for the table (e.g., `customers`, `products`).
  * **Examples**:
      * `dim_customers`: Dimension table for customer data.
      * `fact_sales`: Fact table for sales transactions.

**Glossary of Category Patterns**

| Pattern | Meaning | Example(s) |
| :--- | :--- | :--- |
| `dim_` | Dimension table | `dim_customer`, `dim_product` |
| `fact_` | Fact table | `fact_sales` |
| `report_`| Report table | `report_customers`, `report_sales_monthly` |

-----

### ➡️ **Column Naming Conventions**

#### **Surrogate Keys**

All primary keys in dimension tables must use the `_key` suffix.

  * **Format**: `<table_name>_key`
      * `<table_name>`: The name of the table or entity.
      * `_key`: Suffix indicating a surrogate key.
  * **Example**: `customer_key` is the surrogate key in the `dim_customers` table.

#### **Technical Columns**

All technical columns must start with the prefix `dwh_`.

  * **Format**: `dwh_<column_name>`
      * `dwh`: A prefix used only for system-generated metadata.
      * `<column_name>`: A descriptive name indicating the column's purpose.
  * **Example**: `dwh_load_date` is a system-generated column that stores the record's load date.

-----

### ⚙️ **Stored Procedure Naming Conventions**

All stored procedures for loading data must follow the `load_<layer>` pattern.

  * `<layer>`: Represents the layer being loaded (`bronze`, `silver`, or `gold`).
  * **Examples**:
      * `load_bronze`: Stored procedure for loading data into the Bronze layer.
      * `load_silver`: Stored procedure for loading data into the Silver layer.
