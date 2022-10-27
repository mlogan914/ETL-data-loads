USE DATABASE MY_LAB;

/*** DIM TABLES ***/

---- PRODUCT DIM
---- Identify and append new records to the existing product table
MERGE INTO ANL_WALMART.PRODUCT_DIM t1
USING LND_WALMART.PRODUCT t2
ON  t1.prod_key=t2.prod_key
    AND t1.prod_name=t2.prod_name 
    AND t1.vol=t2.vol 
    AND t1.wgt=t2.wgt
    AND t1.brand_name=t2.brand_name
    AND t1.status_code=t2.status_code
    AND t1.status_code_name=t2.status_code_name
    AND t1.category_key=t2.category_key
    AND t1.category_name=t2.category_name
    AND t1.subcategory_key=t2.subcategory_key
    AND t1.subcategory_name=t2.subcategory_name
WHEN NOT MATCHED 
THEN INSERT (
    prod_key,
    prod_name,
    vol,
    wgt,
    brand_name,
    status_code,
    status_code_name,
    category_key,
    category_name,
    subcategory_key,
    subcategory_name,
    tlog_active_flg,
    start_dt,
    end_dt)
VALUES (
    t2.prod_key,
    t2.prod_name,
    t2.vol,
    t2.wgt,
    t2.brand_name,
    t2.status_code,
    t2.status_code_name,
    t2.category_key,
    t2.category_name,
    t2.subcategory_key,
    t2.subcategory_name,
    TRUE,
    CURRENT_DATE(),
    NULL
);

---- Merge latest raw data to the appended product data (previous and new product records)
---- to update the previous record end_dt and tlog_active_flg
MERGE INTO ANL_WALMART.PRODUCT_DIM t1
USING LND_WALMART.PRODUCT t2
ON t1.prod_key=t2.prod_key
WHEN MATCHED
    AND (
    t1.prod_name!=t2.prod_name 
    OR t1.vol!=t2.vol 
    OR t1.wgt!=t2.wgt
    OR t1.brand_name!=t2.brand_name
    OR t1.status_code!=t2.status_code
    OR t1.status_code_name!=t2.status_code_name
    OR t1.category_key!=t2.category_key
    OR t1.category_name!=t2.category_name
    OR t1.subcategory_key!=t2.subcategory_key
    OR t1.subcategory_name!=t2.subcategory_name
)
THEN UPDATE SET end_dt= current_date(), tlog_active_flg=FALSE


---- STORE DIM
MERGE INTO ANL_WALMART.STORE_DIM t1
USING LND_WALMART.STORE t2
ON  t1.store_key=t2.store_key
	AND t1.store_name=t2.store_desc
	AND t1.addr=t2.addr
	AND t1.city=t2.city
	AND t1.cntry_cd=t2.cntry_cd
	AND t1.cntry_nm=t2.cntry_nm
	AND t1.prov_name=t2.prov_state_desc
	AND t1.prov_code=t2.prov_state_cd
	AND t1.market_key=t2.market_key
	AND t1.market_name=t2.market_name
    AND t1.submarket_key=t2.submarket_key
	AND t1.submarket_name=t2.submarket_name
	AND t1.latitude=t2.latitude
	AND t1.longitude=t2.longitude
WHEN NOT MATCHED 
THEN INSERT (
	store_key,
	store_name,
	addr,
	city,
	region,
	cntry_cd,
	cntry_nm,
	postal_zip_cd,
	prov_name,
	prov_code,
	market_key,
	market_name,
	submarket_key,
	submarket_name,
	latitude,
	longitude,
	tlog_active_flg,
	start_dt,
	end_dt)
VALUES (
	t2.store_key,
	t2.store_desc,
	t2.addr,
	t2.city,
	t2.region,
	t2.cntry_cd,
	t2.cntry_nm,
	t2.postal_zip_cd,
	t2.prov_state_desc,
	t2.prov_state_cd,
	t2.market_key,
	t2.market_name,
	t2.submarket_key,
	t2.submarket_name,
	t2.latitude,
	t2.longitude,
	TRUE,
	current_date(),
	NULL
);

MERGE INTO ANL_WALMART.STORE_DIM t1
USING LND_WALMART.STORE t2
ON t1.store_key=t2.store_key
WHEN MATCHED
    AND (
	t1.store_name!=t2.store_desc
	OR t1.addr!=t2.addr
	OR t1.city!=t2.city
	OR t1.region!=t2.region
	OR t1.cntry_cd!=t2.cntry_cd
	OR t1.cntry_nm!=t2.cntry_nm
	OR t1.postal_zip_cd!=t2.postal_zip_cd
	OR t1.prov_name!=t2.prov_state_desc
	OR t1.prov_code!=t2.prov_state_cd
	OR t1.market_key!=t2.market_key
	OR t1.market_name!=t2.market_name
    OR t1.submarket_key!=t2.submarket_key
	OR t1.submarket_name!=t2.submarket_name
	OR t1.latitude!=t2.latitude
	OR t1.longitude!=t2.longitude
)
THEN UPDATE SET end_dt= current_date(), tlog_active_flg=FALSE


---- CALENDAR DIM
---- replace existing
TRUNCATE TABLE ANL_WALMART.CALENDAR_DIM;
INSERT INTO ANL_WALMART.CALENDAR_DIM 
(	
	cal_dt,
	cal_type_name,
	day_of_wk_num,
	year_num,
	week_num,
	year_wk_num,
	month_num,
	year_month_num,
	qtr_num,
	yr_qtr_num
)
SELECT 
	cal_dt AS cal_dt,
	cal_type_desc AS cal_type_name,
	day_of_wk_num AS day_of_wk_num,
	yr_num AS year_num,
	wk_num AS week_num,
	yr_wk_num AS year_wk_num,
	mnth_num AS month_num,
	yr_mnth_num AS year_month_num,
	qtr_num AS qtr_num,
	yr_qtr_num AS yr_qtr_num
FROM LND_WALMART.CALENDAR 
;

/*** FACT TABLES ***/

---- get latest date
SET LAST_DATE = (SELECT MAX(cal_dt) 
				 FROM ANL_WALMART.sales_inv_store_dy);

---- Use $LAST_DATE to filter the raw data records. 
---- To avoid possibility of imcomplete records of the latest date,
---- we need to delete the original latest date records in the fact table ANL_WALMART.sales_inv_store_dy and append the new records from that date.
DELETE FROM ANL_WALMART.sales_inv_store_dy WHERE cal_dt=$LAST_DATE;

CREATE OR REPLACE TRANSIENT TABLE ANL_WALMART.daily_sales_trns AS 
SELECT 
	trans_dt AS cal_dt,
	store_key AS store_key,
	prod_key AS prod_key,
	sum(sales_qty ) AS sales_qty,
	avg(sales_price ) AS sales_price,
	sum(sales_amt ) AS sales_amt,
	avg(discount) AS discount,
	sum(sales_cost) AS sales_cost,
	sum(sales_mgrn) AS sales_mgrn,
	sum(ship_cost) AS ship_cost
FROM LND_WALMART.sales
WHERE cal_dt>=NVL($LAST_DATE, '1900-01-01') /* use early date for the initial run to ensure all records are obtained */
GROUP BY 1,2,3
ORDER BY 1,2,3
;

---- rename inventory table fields and subset by latest date
CREATE OR REPLACE TRANSIENT TABLE ANL_WALMART.daily_inventory_trns AS 
SELECT 
	cal_dt AS cal_dt,
	store_key AS store_key,
	prod_key AS prod_key,
	inventory_on_hand_qty AS stock_on_hand_qty,
	inventory_on_order_qty AS ordered_stock,
	out_of_stock_flg AS out_of_stock_flg,
	waste_qty AS waste_qty,
	promotion_flg AS promotion_flg,
	next_delivery_dt AS next_delivery_dt
FROM LND_WALMART.inventory
WHERE cal_dt>=NVL($LAST_DATE, '1900-01-01');

--- DAY
INSERT INTO ANL_WALMART.sales_inv_store_dy 
(
	cal_dt,
	store_key,
	prod_key,
	sales_qty,
	sales_price,
	sales_amt,
	discount,
	sales_cost,
	sales_mgrn,
	stock_on_hand_qty,
	ordered_stock_qty,
	out_of_stock_flg,
	in_stock_flg,
	low_stock_flg
)
SELECT
	COALESCE(s.cal_dt,i.cal_dt),
	COALESCE(s.store_key,i.store_key),
	COALESCE(s.prod_key,i.prod_key),
	nvl(s.sales_qty,0),
	nvl(s.sales_price,0),
	nvl(s.sales_amt,0),
	nvl(s.discount,0),
	nvl(s.sales_cost,0),
	nvl(s.sales_mgrn,0),
	nvl(i.stock_on_hand_qty,0),
	nvl(i.ordered_stock,0),
	nvl(i.out_of_stock_flg,False),
	case when i.out_of_stock_flg=true then false else true end as in_stock_flg,
	case when i.stock_on_hand_qty<s.sales_qty then true else false end as low_stock_flg
FROM ANL_WALMART.daily_sales_trns s
FULL OUTER JOIN ANL_WALMART.daily_inventory_trns i USING (cal_dt, store_key, prod_key)
;
SELECT * FROM ANL_WALMART.sales_inv_store_dy;

--- WEEK
TRUNCATE TABLE IF EXISTS ANL_WALMART.sales_inv_store_wk;
INSERT INTO ANL_WALMART.sales_inv_store_wk
(
	yr_num,
	wk_num,
	store_key,
	prod_key,
	wk_sales_qty,
	avg_sales_price,
	wk_sales_amt,
	wk_discount,
	wk_sales_cost,
	wk_sales_mgrn,
	eop_stock_on_hand_qty,
	eop_ordered_stock_qty,
	out_of_stock_times,
	in_stock_times,
	low_stock_times
)
SELECT
	c.year_num as yr_num,
	c.week_num as wk_num,
	s.store_key,
	s.prod_key,
	sum(sales_qty) as wk_sales_qty,
	avg(sales_price) as avg_sales_price,
	sum(sales_amt) as wk_sales_amt,
	sum(discount) as wk_discount,
	sum(sales_cost) as wk_sales_cost,
	sum(sales_mgrn) as wk_sales_mgrn,
	sum(case when c.day_of_wk_num=6 then s.stock_on_hand_qty else 0 end) as eop_stock_on_hand_qty,
	sum(case when c.day_of_wk_num=6 then s.ordered_stock_qty else 0 end) as eop_ordered_stock_qty,
	count(case when s.out_of_stock_flg=true then 1 else 0 end) as out_of_stock_times,
	count(case when s.in_stock_flg=true then 1 else 0 end) as in_stock_times,
	count(case when s.low_stock_flg=true then 1 else 0 end) as low_stock_times
FROM ANL_WALMART.sales_inv_store_dy s
JOIN ANL_WALMART.calendar_dim c USING (cal_dt)
GROUP BY 1,2,3,4
ORDER BY 1,2,3,4;
	

				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				