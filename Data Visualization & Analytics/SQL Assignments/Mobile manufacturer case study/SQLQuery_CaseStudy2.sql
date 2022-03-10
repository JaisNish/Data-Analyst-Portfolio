use db_SQLCaseStudy2

select * from DIM_CUSTOMER
select * from DIM_DATE
select * from DIM_LOCATION
select * from DIM_MANUFACTURER
select * from DIM_MODEL
select * from FACT_TRANSACTIONS

-- 1. List all the states in which we have customers who have bought cellphones from 2005 till today?
select T2.[State] as States
from FACT_TRANSACTIONS T1
inner join DIM_LOCATION T2 on T1.IDLocation = T2.IDLocation
where Year(T1.[Date]) >= 2005
group by T2.[State]

-- 2. What state in the US is buying more 'Samsung' cell phones?
select Top 1 T4.[State] as States, count(T3.IDCustomer) as Count_Customers
from DIM_LOCATION T4
inner join FACT_TRANSACTIONS T3 on T4.IDLocation = T3.IDLocation
inner join DIM_MODEL T1 on T3.IDModel = T1.IDModel
inner join DIM_MANUFACTURER T2 on T1.IDManufacturer = T2.IDManufacturer
where T2.Manufacturer_Name = 'Samsung' and T4.Country = 'US'
group by T4.[State]
order by count(T3.IDCustomer) desc

-- 3. Show the number of transactions for each model per zip code per state.
select CONCAT(T4.Manufacturer_Name, ' ', T3.Model_Name) as Model, 
T2.[State], T2.ZipCode, count(T1.IDCustomer) as No_of_Trans
from DIM_MANUFACTURER T4
inner join DIM_MODEL T3 on T4.IDManufacturer = T3.IDManufacturer
inner join FACT_TRANSACTIONS T1 on T3.IDModel = T1.IDModel
inner join DIM_LOCATION T2 on T1.IDLocation = T2.IDLocation
group by T4.Manufacturer_Name, T3.Model_Name, T2.[State], T2.ZipCode

-- 4. Show the cheapest cellphone
select Top 1 CONCAT(T2.Manufacturer_Name, ' ', T1.Model_Name) as Cheapest_Cellphone
from DIM_MODEL T1
inner join DIM_MANUFACTURER T2 on T1.IDManufacturer = T2.IDManufacturer
order by Unit_price

-- 5. Find out the average price for each model in the top 5 manufacturers in terms of sales quantity and order by average price.
select T2.Manufacturer_Name, T2.Model_Name, T2.Avg_Price
from (select T4.Manufacturer_Name, T3.Model_Name,
cast(avg(T1.TotalPrice) as decimal(7,2)) as Avg_Price
from DIM_MANUFACTURER T4
inner join DIM_MODEL T3 on T4.IDManufacturer = T3.IDManufacturer
inner join FACT_TRANSACTIONS T1 on T3.IDModel = T1.IDModel
group by T4.Manufacturer_Name, T3.Model_Name) T2
inner join (select top 5 T4.Manufacturer_Name
from DIM_MANUFACTURER T4
inner join DIM_MODEL T3 on T4.IDManufacturer = T3.IDManufacturer
inner join FACT_TRANSACTIONS T1 on T3.IDModel = T1.IDModel
group by T4.Manufacturer_Name
order by sum(T1.Quantity) desc) T5 on T2.Manufacturer_Name = T5.Manufacturer_Name
order by Avg_Price desc

-- 6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500.
select T2.Customer_Name, avg(T1.TotalPrice) as Avg_Amt_Spent
from FACT_TRANSACTIONS T1
inner join DIM_CUSTOMER T2 on T1.IDCustomer = T2.IDCustomer
where year([Date])=2009
group by T2.Customer_Name
having avg(T1.TotalPrice) > 500
order by Avg_Amt_Spent desc

-- 7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 & 2010.
select CONCAT(T5.Manufacturer_Name, ' ', T4.Model_Name) as Common_Model
from DIM_MANUFACTURER T5
inner join DIM_MODEL T4 on T5.IDManufacturer = T4.IDManufacturer
inner join 
(select IDModel from (select Top 5 IDModel, sum(Quantity) as Tot_Qty
from FACT_TRANSACTIONS
where year([Date]) = 2008
group by IDModel
order by sum(Quantity) desc) T1
intersect
select IDModel from (select Top 5 IDModel, sum(Quantity) as Tot_Qty
from FACT_TRANSACTIONS
where year([Date]) = 2009
group by IDModel
order by sum(Quantity) desc) T2
intersect
select IDModel from (select Top 5 IDModel, sum(Quantity) as Tot_Qty
from FACT_TRANSACTIONS
where year([Date]) = 2010
group by IDModel
order by Tot_Qty desc) T3) T6 on T4.IDModel = T6.IDModel

-- 8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.
select '2009' as [Year], T2.Manufacturer_Name as SecondTopManufacturer from (select T4.Manufacturer_Name, 
sum(T1.TotalPrice) as Tot_Sales, 
ROW_NUMBER() over (order by sum(T1.TotalPrice) desc) as RNum
from DIM_MANUFACTURER T4
inner join DIM_MODEL T3 on T4.IDManufacturer = T3.IDManufacturer
inner join FACT_TRANSACTIONS T1 on T3.IDModel = T1.IDModel
where year(T1.[Date]) = 2009
group by T4.Manufacturer_Name) T2
where RNum = 2
union all
select '2010' as [Year], T2.Manufacturer_Name as SecondTopManufacturer from (select T4.Manufacturer_Name, 
sum(T1.TotalPrice) as Tot_Sales, 
ROW_NUMBER() over (order by sum(T1.TotalPrice) desc) as RNum
from DIM_MANUFACTURER T4
inner join DIM_MODEL T3 on T4.IDManufacturer = T3.IDManufacturer
inner join FACT_TRANSACTIONS T1 on T3.IDModel = T1.IDModel
where year(T1.[Date]) = 2010
group by T4.Manufacturer_Name) T2
where RNum = 2

-- 9. Show the manufacturers that sold cellphone in 2010 but didn't in 2009.
select DISTINCT T2.Manufacturer_Name
from DIM_MANUFACTURER T2
inner join DIM_MODEL T1 on T2.IDManufacturer = T1.IDManufacturer
inner join 
(select IDModel
from FACT_TRANSACTIONS
where year([Date]) = 2010) T3 on T1.IDModel = T3.IDModel
EXCEPT
select DISTINCT T2.Manufacturer_Name
from DIM_MANUFACTURER T2
inner join DIM_MODEL T1 on T2.IDManufacturer = T1.IDManufacturer
inner join 
(select IDModel
from FACT_TRANSACTIONS
where year([Date]) = 2009) T4 on T1.IDModel = T4.IDModel

/* 10. Find top 10 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.*/

select IDCustomer as Customers,
Avg_Qty_2003, Avg_Spend_2003, Avg_Qty_2004, Avg_Spend_2004, cast((Total_Spend_2004-Total_Spend_2003)/Total_Spend_2003 as decimal(7,2)) as Percent_Change_2004,
Avg_Qty_2005, Avg_Spend_2005, cast((Total_Spend_2005-Total_Spend_2004)/Total_Spend_2004 as decimal(7,2)) as Percent_Change_2005,
Avg_Qty_2006, Avg_Spend_2006, cast((Total_Spend_2006-Total_Spend_2005)/Total_Spend_2005 as decimal(7,2)) as Percent_Change_2006,
Avg_Qty_2007, Avg_Spend_2007, cast((Total_Spend_2007-Total_Spend_2006)/Total_Spend_2006 as decimal(7,2)) as Percent_Change_2007,
Avg_Qty_2008, Avg_Spend_2008, cast((Total_Spend_2008-Total_Spend_2007)/Total_Spend_2007 as decimal(7,2)) as Percent_Change_2008,
Avg_Qty_2009, Avg_Spend_2009, cast((Total_Spend_2009-Total_Spend_2008)/Total_Spend_2008 as decimal(7,2)) as Percent_Change_2009,
Avg_Qty_2010, Avg_Spend_2010, cast((Total_Spend_2010-Total_Spend_2009)/Total_Spend_2009 as decimal(7,2)) as Percent_Change_2010
from (select top 10 IDCustomer,
cast(avg(case when year([Date])='2003' then cast(Quantity as decimal(3,1)) end) as decimal(3,1)) as Avg_Qty_2003,
cast(avg(case when year([Date])='2003' then TotalPrice end) as decimal(5,2)) as Avg_Spend_2003,
sum(case when year([Date])='2003' then TotalPrice end) as Total_Spend_2003,
cast(avg(case when year([Date])='2004' then cast(Quantity as decimal(3,1)) end) as decimal(3,1)) as Avg_Qty_2004,
cast(avg(case when year([Date])='2004' then TotalPrice end) as decimal(5,2)) as Avg_Spend_2004,
sum(case when year([Date])='2004' then TotalPrice end) as Total_Spend_2004,
cast(avg(case when year([Date])='2005' then cast(Quantity as decimal(3,1)) end) as decimal(3,1)) as Avg_Qty_2005,
cast(avg(case when year([Date])='2005' then TotalPrice end) as decimal(5,2)) as Avg_Spend_2005,
sum(case when year([Date])='2005' then TotalPrice end) as Total_Spend_2005,
cast(avg(case when year([Date])='2006' then cast(Quantity as decimal(3,1)) end) as decimal(3,1)) as Avg_Qty_2006,
cast(avg(case when year([Date])='2006' then TotalPrice end) as decimal(5,2)) as Avg_Spend_2006,
sum(case when year([Date])='2006' then TotalPrice end) as Total_Spend_2006,
cast(avg(case when year([Date])='2007' then cast(Quantity as decimal(3,1)) end) as decimal(3,1)) as Avg_Qty_2007,
cast(avg(case when year([Date])='2007' then TotalPrice end) as decimal(7,2)) as Avg_Spend_2007,
sum(case when year([Date])='2007' then TotalPrice end) as Total_Spend_2007,
cast(avg(case when year([Date])='2008' then cast(Quantity as decimal(3,1)) end) as decimal(3,1)) as Avg_Qty_2008,
cast(avg(case when year([Date])='2008' then TotalPrice end) as decimal(7,2)) as Avg_Spend_2008,
sum(case when year([Date])='2008' then TotalPrice end) as Total_Spend_2008,
cast(avg(case when year([Date])='2009' then cast(Quantity as decimal(3,1)) end) as decimal(3,1)) as Avg_Qty_2009,
cast(avg(case when year([Date])='2009' then TotalPrice end) as decimal(7,2)) as Avg_Spend_2009,
sum(case when year([Date])='2009' then TotalPrice end) as Total_Spend_2009,
cast(avg(case when year([Date])='2010' then cast(Quantity as decimal(3,1)) end) as decimal(3,1)) as Avg_Qty_2010,
cast(avg(case when year([Date])='2010' then TotalPrice end) as decimal(7,2)) as Avg_Spend_2010,
sum(case when year([Date])='2010' then TotalPrice end) as Total_Spend_2010
from FACT_TRANSACTIONS
group by IDCustomer
order by sum(TotalPrice) desc) T1