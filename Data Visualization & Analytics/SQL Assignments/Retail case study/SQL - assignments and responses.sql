use SQLCaseStudy1_Retail

select * from Customer
select * from Transactions
select * from prod_cat_info

/*DATA PREPARATION AND UNDERSTANDING
1. What is the total number of rows in each of the 3 tables in the database?*/
select 'Customer' as Table_name, count(*) as Total_Rows from Customer
union all
select 'Transaction' as Table_name, count(*) as Total_Rows from Transactions
union all 
select 'Product' as Table_name, count(*) as Total_Rows from prod_cat_info

--2. What is the total number of transactions that have a return?
select count(*) as Return_Customers
from Transactions
where Qty<0

/*3. As you would have noticed, the dates provided across the datasets are not in a correct format. As first steps, pls convert the date variables 
into valid date formats before proceeding ahead.*/
--which table to use is not clear in the question, so writing query for both tables
select 
convert(DATE, DOB, 103) AS DOB
from Customer

select convert(DATE, tran_date, 103) AS Trans_Date
from Transactions
--order by (convert(DATE, tran_date, 103)) - just to check the first and last dates for next question

/*4. What is the time range of the transaction data available for analysis? Show the output in number of days, months and years simultaneously in 
different columns.*/
select
min(convert(DATE, tran_date, 103)) as strt_date, max(convert(DATE, tran_date, 103)) as end_date,
datediff(day, min(convert(DATE, tran_date, 103)), max(convert(DATE, tran_date, 103))) as No_of_Days,
datediff(month, min(convert(DATE, tran_date, 103)), max(convert(DATE, tran_date, 103))) as No_of_Months,
datediff(year, min(convert(DATE, tran_date, 103)), max(convert(DATE, tran_date, 103))) as No_of_Years
from Transactions

--5. Which product category does the sub-category "DIY" belong to?
select count(*) as DIY_Customers
from prod_cat_info
where prod_subcat='DIY'

/*DATA ANALYSIS
1. Which channel is most frequently used for transactions?*/
-- Not clear what is to be considered as channel here, assuming it to be store_type

select Top 1 Store_type as Channel_Used--, count(Store_type)
from Transactions
group by Store_type
order by count(Store_type) desc

--2. What is the count of male and female customers in the database?
select 
case when Gender = 'M' then 'Male'
when Gender = 'F' then 'Female' END as Gender,
count(Gender) as Gender_count
from Customer
group by Gender
having Gender in ('M', 'F')

--select * from Customer where Gender is null -> 2 records have null in Gender field

--3. From which city do we have the maximum number of customers and how many?
select Top 1 
city_code, count(city_code) as No_of_customers
from Customer
group by city_code
order by count(city_code) desc

--4. How many sub-categories are there under the Books category?
select prod_cat as Category, count(prod_subcat) as No_of_SubCat
from prod_cat_info
where prod_cat = 'Books'
group by prod_cat

--5. What is the maximum quantity of products ever ordered? 
select T2.Cat_Subcat as Products, max(T1.Qty) as Max_Qty_Ordered
from Transactions T1
inner join 
(select *, concat(prod_cat_code, '-', prod_sub_cat_code) as Cat_Subcat_Code, concat(prod_cat, '-', prod_subcat) as Cat_Subcat
from prod_cat_info) T2 on T1.prod_cat_code = T2.prod_cat_code and T1.prod_subcat_code = T2.prod_sub_cat_code
group by Cat_Subcat

--6. What is the net total revenue generated in categories Electronics and Books?
select T2.prod_cat as Category, cast(sum(T1.total_amt)/100000 as decimal(5,2)) as Total_Revenue_inMillions
from Transactions T1
inner join prod_cat_info T2 on T1.prod_cat_code=T2.prod_cat_code and T1.prod_subcat_code = T2.prod_sub_cat_code
group by T2.prod_cat
having T2.prod_cat in ('Electronics', 'Books')

--7. How many customers have >10 transactions with us, excluding returns?
select count(*) as No_of_Customers from (select cust_id, count(transaction_id) as No_of_tranx from (select *
from Transactions
where Qty > 0) as T1
group by cust_id
having count(transaction_id)>10) as T2

--8. What is the combined revenue earned from the Electronics & Clothing categories from Flagship stores?
select cast(sum(T1.total_amt)/100000 as decimal(5,2)) as Combined_Revenue_inMillions from Transactions T1
inner join prod_cat_info T2 on T1.prod_cat_code=T2.prod_cat_code and T1.prod_subcat_code = T2.prod_sub_cat_code
where T2.prod_cat in ('Electronics', 'Clothing') and T1.Store_type = 'Flagship store'

--9. What is the total revenue generated from Male customers in Electronics category? Output should display total revenue by prod sub-cat.
select T2.prod_subcat as SubCategory, cast(sum(T1.total_amt)/100000 as decimal(5,2)) as Total_Revenue_inMillions
from Transactions T1
inner join prod_cat_info T2 on T1.prod_cat_code=T2.prod_cat_code and T1.prod_subcat_code = T2.prod_sub_cat_code
inner join Customer T3 on T1.cust_id = T3.customer_Id
where T2.prod_cat = 'Electronics' and T3.Gender = 'M'
group by T2.prod_subcat

--10. What is percentage of sales and returns by product sub-category; display only top 5 sub-categories in terms of sales.
select top 5 concat(T2.prod_cat, ' - ', T2.prod_subcat) as Product_Subcategory,
cast(100*sum(case when Qty > 0 then total_amt end)/(select sum(total_amt) as Sales from Transactions
where Qty > 0) as decimal(5,2)) as Percent_Sales,
cast(100*sum(case when Qty < 0 then total_amt end)/(select sum(total_amt) as [Returns] from Transactions
where Qty < 0) as decimal(5,2)) as Percent_Returns
from Transactions T1
inner join prod_cat_info T2 on T1.prod_cat_code=T2.prod_cat_code and T1.prod_subcat_code = T2.prod_sub_cat_code
group by T2.prod_cat, T2.prod_subcat
order by sum(T1.total_amt) desc

/*11. For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions from max transaction date 
available in the data?*/
select T1.cust_id, cast(sum(T1.total_amt) as decimal(7,2)) as Net_Revenue_Generated
from Transactions T1
inner join Customer T2 on T1.cust_id = T2.customer_Id
where T1.tran_date >= dateadd(month, -3, (select max(tran_date) as End_date from Transactions)) and datediff(year, T2.DOB, getdate()) between 25 and 35
group by T1.cust_id

-- 12. Which product category has seen the max value of returns in the last 3 months of transactions?
select Top 1 T2.prod_cat as Product_Category, abs(sum(T1.Qty)) as Tot_Returns from Transactions T1
inner join prod_cat_info T2 on T1.prod_cat_code = T2.prod_cat_code and T1.prod_subcat_code = T2.prod_sub_cat_code
where T1.tran_date >= dateadd(month, -3, (select max(tran_date) as End_date from Transactions)) and T1.Qty<0
group by T2.prod_cat
order by sum(T1.Qty)

-- 13. Which store-type sells the maximum products; by value of sales amount and by quantity sold?
select 'Sales' as Max_By, Store_type from (select Top 1 Store_type
from Transactions
group by Store_type
order by sum(total_amt) desc) as T1
union all
select 'Qty' as Max_By, Store_type from (select Top 1 Store_type
from Transactions
group by Store_type
order by sum(Qty) desc) as T2

-- 14. What are the categories for which average revenue is above the overall average?
select Category from (
select T2.prod_cat as Category, avg(T1.total_amt) as Avg_Revenue
from Transactions T1
inner join prod_cat_info T2 on T1.prod_cat_code = T2.prod_cat_code
group by T2.prod_cat) T3
where Avg_Revenue > (select avg(total_amt) as Overall_Avg from Transactions)

-- 15. Find the average and total revenue by each sub-category for the categories which are among top 5 categories in terms of quantity sold?
select concat(T2.prod_cat, ' - ', T2.prod_subcat) as Product_Subcategory, cast(avg(T1.total_amt) as decimal(7,2)) as Avg_Revenue, 
cast(sum(T1.total_amt)/100000 as decimal(5,2)) as Total_Revenue_inMillions
from Transactions T1
inner join prod_cat_info T2 on T1.prod_cat_code=T2.prod_cat_code and T1.prod_subcat_code = T2.prod_sub_cat_code
inner join 
(select top 5 prod_cat_code
from Transactions
where Qty > 0
group by prod_cat_code
order by sum(Qty) desc) T3 on T1.prod_cat_code = T3.prod_cat_code
where T1.Qty>0
group by T2.prod_cat, T2.prod_subcat
order by Product_Subcategory
