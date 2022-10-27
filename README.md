# Mini Project -- ETL and Data Loads using Snowflake via DBeaver

## 1. Project Description
- Step 1: Based on the business requierments, build the schema for the original system datasets & Create a data warehouse model in Snowflake.
- Step 2: Write the ETL script (DDL, DML) to transform the data from the original tables to the data model.
- Step 3: Load the data into Snowflake. This can be performed manually using DBeaver or using snowsql CLI commands (e.g. PUT).

## 2. About the Data
For this project, a sample Walmart datasset was used.

The dataset includes tables **store**, **product**, **inventory**, **sales** and **calendar**. These are the tables from operational databases:
![os_db_walmart](https://user-images.githubusercontent.com/74939090/198202564-00ef07a8-2f4f-4899-a6c2-66b498a0e5b4.jpg)

## 3. Business Requirements / Specification Detail
- The data model has 3 dimensions : store, date, product.
- 2 fact tables are required:
  - **Daily fact table:** At the daily level, the row grain is **date + store + product**. 
    - In addition to the existing columns from the *sales* and *inventory* tables, "low_stock_flg" will need to be derived.
    - This flag is *True* when **sales_qty** in the sales table is *less than* the **stock_on_hand_qty** in the inventory at that date.
  - **Weekly fact table:** The second fact table is weekly based. It should contain all the aggregate values from the daily fact table and the following columns:
    - **eop_stock_on_hand_qty:** This is the on hand stock qty at the end of week (Saturday) (Note: cannot be aggregated). 
    - **eop_stock_on_order_qty:** This is the on order stock qty at the end of week (Saturday).
    - **out_of_stock_times:** During one week, how many times when the out_of_stock_flg is True.
    - **in_of_stock_times:** During one week, how many times when the in_of_stock_flg is True.
    - **low_stock_times:** During one week, how many times when the low_stock_flg is True.
   
## 4. Project Model
The data model of the project has 3 dimension tables and 2 fact tables (one for daily, one for weekly):
![data_model_walmat](https://user-images.githubusercontent.com/74939090/198205038-2e4de761-4070-43a9-9889-65c9ed21e9c3.jpg)
