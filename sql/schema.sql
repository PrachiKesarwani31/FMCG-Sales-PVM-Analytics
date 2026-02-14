use pvm_db;

select * from raw_orders limit 10;
select * from raw_returns limit 10;

create table if not exists dim_product as
select
row_number() over(order by `Product ID`) as product_id,
`Product ID` as sku,
Category as category,
`Sub-Category` as sub_category,
`Product Name` as product_name,
substring_index(`Product Name`,' ',1) as brand
from (select distinct `Product ID`,Category,`Sub-Category`,`Product Name` from raw_orders) s;

create table if not exists dim_customer as
select
row_number() over(order by `Customer ID`) as customer_id,
`Customer ID` as customer_code,
`Customer Name` as customer_name,
Segment as segment
from (select distinct `Customer ID`,`Customer Name`,Segment from raw_orders) s;

create table if not exists dim_location as
select
row_number() over(order by Country, City, State, Region) as location_id,
Country as country,
City as city,
State as state,
Region as region
from (select distinct Country, City, State, Region from raw_orders) s;

create table if not exists dim_date
(date_key int primary key,
full_date date,
yr int,
quarter_of_yr varchar(5),
mon_of_yr int,
month_name varchar(20),
day_of_year int,
week_of_year int,
is_weekend bool,
day_of_week int,
day_name varchar(20),
month_year varchar(10),
yr_month varchar(10));

insert into dim_date
(date_key,
full_date,
yr,
quarter_of_yr,
mon_of_yr,
month_name,
day_of_year,
week_of_year,
is_weekend,
day_of_week,
day_name,
month_year,
yr_month)
with recursive dates as
(select
min(`Order Date`) as dt
from raw_orders
union all
select
date_add(dt,interval 1 day) 
from dates
where dt<=(select max(`Ship Date`) from raw_orders))
select
date_format(dt,'%Y%m%d'),
dt,
year(dt),
case
when month(dt) in (4,5,6) then 'Q1'
when month(dt) in (7,8,9) then 'Q2'
when month(dt) in (10,11,12) then 'Q3'
when month(dt) in (1,2,3) then 'Q4' end as quarter_of_yr,
month(dt),
monthname(dt),
day(dt),
week(dt),
case 
when dayofweek(dt) in (1,7) then 1
else 0 end,
dayofweek(dt),
dayname(dt),
date_format(dt, '%b-%Y'),
date_format(dt, '%Y-%m')
from dates;

create table if not exists fact_orders as
select
row_number() over(order by r.`Order ID`) as order_id,
r.`Order ID` as unique_order_no,
r.`Order Date` as order_date,
r.`Ship Date` as ship_date,
r.`Ship Mode` as ship_mode,
r.`Sales` as sales,
r.`Quantity` as quantity,
r.`Profit` as profit,
case 
when r.`Quantity`<5 then 'Low'
when r.`Quantity`<10 then 'Medium'
else 'High'
end as Pack,
p.product_id,
c.customer_id,
d1.full_date as order_key,
d2.full_date as ship_key,
l.location_id
from raw_orders r
left join dim_product p
on r.`Product ID`=p.sku
left join dim_customer c
on r.`Customer ID`=c.customer_code
left join dim_location l
on r.City=l.city
and r.State=l.state
and r.Country=l.country
and r.Region=l.region
left join dim_date d1
on r.`Order Date`=d1.full_date
left join dim_date d2
on r.`Ship Date`=d2.full_date;