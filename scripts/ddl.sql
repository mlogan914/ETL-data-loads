USE DATABASE MY_Lab;

CREATE SCHEMA IF NOT EXISTS ANL_WALMART;

------DIMENSION TABLES
CREATE OR REPLACE TABLE ANL_WALMART.product_dim
(	
	prod_key Integer,
	prod_name varchar(30),
	vol	numeric(38,3),
	wgt	numeric(38,2),
	brand_name varchar(30),
	status_code	varchar(30),
	status_code_name varchar(30),
	category_key integer,
	category_name varchar(30),
	subcategory_key	integer,
	subcategory_name varchar(30),
	start_dt date,
	end_dt date,	
	tlog_active_flg	boolean,
	update_time timestamp default CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE ANL_WALMART.store_dim
(	
	store_key integer,
	store_name	varchar(150),
	status_code	varchar(10),
	status_cd_name varchar(50),
	open_dt	date,
	close_dt date,
	addr varchar(50),
	city varchar(100),
	region varchar(30),
	cntry_cd varchar(30),
	cntry_nm varchar(30),
	postal_zip_cd varchar(10),
	prov_name varchar(50),
	prov_code varchar(50),
	market_key integer,
	market_name	varchar(150),
	submarket_key integer,
	submarket_name varchar(150),
	latitude number(38,2),
	longitude number(38,2),
	start_dt date,
	end_dt date,
	tlog_active_flg	boolean,
	update_time timestamp default CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE ANL_WALMART.calendar_dim
(	
	cal_dt	date,
	cal_type_name varchar(30),
	day_of_wk_num integer,
	year_num integer,
	week_num integer,
	year_wk_num	integer,
	month_num integer,
	year_month_num integer,
	qtr_num	integer,
	yr_qtr_num integer,
	update_time timestamp default CURRENT_TIMESTAMP()
);

------FACT TABLES
--- Daily Fact
CREATE OR REPLACE TABLE ANL_WALMART.sales_inv_store_dy
(
	cal_dt date,
	store_key integer,
	prod_key integer,
	sales_qty number(38,2),
	sales_price	number(38,2),
	sales_amt number(38,2),
	discount number(38,2),
	sales_cost number(38,2),
	sales_mgrn number(38,2),
	stock_on_hand_qty number(38,2),
	ordered_stock_qty number(38,2),
	out_of_stock_flg boolean,
	in_stock_flg boolean,
	low_stock_flg boolean,
	update_time timestamp default CURRENT_TIMESTAMP()
);

--- Weekly Fact
CREATE OR REPLACE TABLE ANL_WALMART.sales_inv_store_wk
(
	yr_num	integer,
	wk_num	integer,
	store_key integer,
	prod_key integer,
	wk_sales_qty number(38,2),
	avg_sales_price	number(38,2),
	wk_sales_amt number(38,2),
	wk_discount	number(38,2),
	wk_sales_cost number(38,2),
	wk_sales_mgrn number(38,2),
	eop_stock_on_hand_qty number(38,2),
	eop_ordered_stock_qty number(38,2),
	out_of_stock_times integer,
	in_stock_times integer,
	low_stock_times	integer,
	update_time timestamp default CURRENT_TIMESTAMP()
);

