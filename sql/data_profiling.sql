create database pvm_db;

use pvm_db;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/raw_orders.csv"
INTO TABLE raw_orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/raw_returns.csv"
INTO TABLE raw_returns
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

--Data Analysis

#count checks
select count(*) as raw_orders_count from raw_orders;
select count(*) as raw_returns_count from raw_returns;

/*update raw_orders
set `Order Date`=str_to_date(`Order Date`,'%d-%m-%Y');

alter table raw_orders
modify column `Order Date` date;

update raw_orders
set `Ship Date`=str_to_date(`Ship Date`,'%d-%m-%Y');

alter table raw_orders
modify column `Ship Date` date;*/

--Data range check
select
max(`Order Date`) as last_date,
min(`Order Date`) as first_date
from raw_orders;

--Transaction checks
select
count(distinct `Order ID`) as count_of_transaction
from raw_orders;

--SKUs check
select
count(distinct `Product ID`) as count_product
from raw_orders;

--Country/Region check
select
region,
count(`Order ID`) as no_order
from raw_orders
group by region
order by no_order desc;

--Null checks
select
count(*) as null_count
from raw_orders
where `Order ID` is null
or `Customer ID` is null
or `Product ID` is null;

--Duplicates check
select
`Order ID`,
`Customer ID`,
`Product ID`,
count(*) as duplicate_count
from raw_orders
group by `Order ID`,`Customer ID`,`Product ID`
having count(*)>1;

--Outliers
select
`Order ID`,
State,
Sales
from raw_orders s
where Sales>(select avg(Sales)+3*stddev(Sales) from raw_orders s1 where s.State=s1.State);
