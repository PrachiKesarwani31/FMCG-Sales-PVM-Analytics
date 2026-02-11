use pvm_db;

select * from raw_orders limit 10;

create table if not exists dim_product as
select
row_number() over(order by `Product ID`) as product_id,
Category as category,
Sub-Category as sub_category,
`Product Name` as product_name,
substring_index2(`Product Name`,' ',1) as brand,
case 
when quantity<5 then 'Low'
when quantity<10 then 'Medium'
else 'High'
end as Pack
from (select distinct `Product ID` from raw_orders);

create table if not exists dim_customer as
select
row_number() over(order by `Customer ID`) as customer_id,
`Customer ID` as customer_code,
`Customer Name` as customer_name,
Segment as segment
from (select distinct `Customer ID` from raw_orders);

create table if not exists dim_location as
select
row_number() over(order by Country, City, State, Region) as location_id,
Country as country,
City as city,
State as state,
Region as region
from (select distinct Country, City, State, Region from raw_orders);

create table if not exists dim_date as
select

create table if not exists fact_orders as
select
row_number() over(order by `Order ID`) as order_id,
`Order ID` as unique_order_no,
`Ship Mode` as ship_mode,

create table if not exists fact_returns as
SELECT
row_number() over(order by )