# ETL (Load)

The Load phase is a component of the ETL process. It involves different processing types, methods for loading data, and strategies for handling changes over time.

![load](https://github.com/user-attachments/assets/9868007c-4014-458e-a677-ac3dc80aaad4)

## Processing Types

There are two main types of data processing for the load phase.
* **Batch Processing**
* **Stream Processing**

---

## Load Methods

This defines how data is written into the target system.

* **Full Load**. Techniques for a full load include:
    * Truncate & Insert
    * Upsert
    * Drop, Create, Insert
* **Incremental Load**. Techniques for an incremental load include:
    * Upsert
    * Append
    * Merge

---

## Slowly Changing Dimensions (SCD)

SCDs are strategies for managing the history of data in dimension tables.

* **SCD 0**: No Historization
* **SCD 1**: Overwrite
* **SCD 2**: Historization
* An additional undefined SCD type is also noted.
