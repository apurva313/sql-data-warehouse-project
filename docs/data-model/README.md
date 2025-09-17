# Data Model: Sales Data Mart (Star Schema)

This section provides a detailed breakdown of the Sales Data Mart, which is structured as a Star Schema. This model is optimized for efficient querying and business analytics, featuring a central fact table connected to multiple descriptive dimension tables.

![data_model](https://github.com/user-attachments/assets/6f9760a2-d46b-424d-b26f-ca40af4d5537)

-----

## Dimension Tables

Dimension tables contain the descriptive attributes of the business entities, providing context to the factual data.

### `gold.dim_customers`

This dimension table holds all the descriptive information related to customers. The primary key is `customer_key`.

| Column Name | Description |
| :--- | :--- |
| `customer_key` | **Primary Key**. A unique surrogate key for each customer. |
| `customer_id` | The original customer ID from the source system. |
| `customer_number` | The original customer's business key. |
| `first_name` | The customer's first name. |
| `last_name` | The customer's last name. |
| `country` | The country where the customer resides. |
| `marital_status` | The customer's marital status. |
| `gender` | The customer's gender. |
| `birthdate` | The customer's date of birth. |

### `gold.dim_products`

This dimension table contains all the attributes related to the products. The primary key is `product_key`.

| Column Name | Description |
| :--- | :--- |
| `product_key` | **Primary Key**. A unique surrogate key for each product. |
| `product_id` | The original product ID from the source system. |
| `product_number` | The original product's business key. |
| `product_name` | The name of the product. |
| `category_id` | The identifier for the product's category. |
| `category` | The main category of the product. |
| `subcategory` | The subcategory of the product. |
| `maintenance` | Maintenance information for the product. |
| `cost` | The cost of the product. |
| `product_line` | The product line to which the product belongs. |
| `start_date` | The date the product became available. |

-----

## Fact Table

The fact table sits at the center of the star schema and contains the quantitative measures of the business process.

### `gold.fact_sales`

This table stores the numerical metrics for each sales transaction. It connects to the dimension tables through foreign keys.

| Column Name | Description |
| :--- | :--- |
| `order_number` | The unique identifier for the sales order. |
| `product_key` | **Foreign Key** that references `gold.dim_products`. |
| `customer_key` | **Foreign Key** that references `gold.dim_customers`. |
| `order_date` | The date the order was placed. |
| `shipping_date` | The date the order was shipped. |
| `due_date` | The payment due date for the order. |
| `sales_amount` | **Measure**. The total revenue from the sales transaction. |
| `quantity` | **Measure**. The number of units sold. |
| `price` | **Measure**. The price per unit of the product. |

-----

## Relationships

The model uses one-to-many relationships to link the dimension tables to the fact table.

  * `gold.dim_customers` is linked to `gold.fact_sales` via the `customer_key` column.
  * `gold.dim_products` is linked to `gold.fact_sales` via the `product_key` column.
