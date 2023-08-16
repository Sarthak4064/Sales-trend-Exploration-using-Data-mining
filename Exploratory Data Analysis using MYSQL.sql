Q.1 Import the dataset and do usual exploratory analysis
steps like checking the structure & characteristics of the
dataset.
(A) Data type of all columns in the “customers” table
  
select column_name,data_type from
sqlbussinesscase-394010.ecommerce.INFORMATION_SCHEMA.COLUMNS
where table_name='customers'
  
Q.1 (B) Get the time range between which the orders were
placed.
  
select concat('time range between first and last order
is',' ',min_time,' ','to',' ',max_time) as time_range
from(
SELECT min(order_purchase_timestamp)as
min_time,max(order_purchase_timestamp) as max_time FROM
`sqlbussinesscase-394010.ecommerce.orders`)

Q.1 (c) Count the number of Cities and States in our
dataset.

select count(distinct customer_city) as
no_of_cities,count(distinct customer_state) as no_of_states
from `sql-case-study-393919.decbatch.customers`
  
Q.2 In-depth Exploration:
(A) Is there a growing trend in the no. of orders placed
over the past years?

SELECT
EXTRACT(year FROM order_purchase_timestamp ) AS YEAR,
EXTRACT(month FROM order_purchase_timestamp ) AS
month_of_the_year,
count(distinct order_id),
FROM `sqlbussinesscase-394010.ecommerce.orders`
group by 1,2
order by 1,2

Q.2 (B) Can we see some kind of monthly seasonality in terms
of the no. of orders being placed?

SELECT EXTRACT(MONTH FROM order_purchase_timestamp) as month,
sum(p.payment_value
) as total_sales
FROM `sqlbussinesscase-394010.ecommerce.orders` as o
inner join `sqlbussinesscase-394010.ecommerce.payments` p ON
o.order_id=p.order_id
group by 1
order by 1

Q.2 (C) During what time of the day, do the Brazilian
customers mostly place their orders? (Dawn, Morning,
Afternoon or Night)
● 0-6 hrs : Dawn
● 7-12 hrs : Mornings
● 13-18 hrs : Afternoon
● 19-23 hrs : Night

SELECT
CASE WHEN EXTRACT(hour FROM order_purchase_timestamp )
BETWEEN 0 AND 6 THEN 'DAWN'
WHEN EXTRACT(hour FROM order_purchase_timestamp )
BETWEEN 7 AND 12 THEN 'MORNINGS'
WHEN EXTRACT(hour FROM order_purchase_timestamp )
BETWEEN 13 AND 18 THEN 'AFTERNOON'
WHEN EXTRACT(hour FROM order_purchase_timestamp )
BETWEEN 19 AND 23 THEN 'NIGHT'
END AS TIME_OF_DAY,COUNT(DISTINCT ORDER_ID) AS COUNTER
FROM
`sqlbussinesscase-394010.ecommerce.orders`
GROUP BY 1
ORDER BY 2 DESC

Q.3 Evolution of E-commerce orders in the Brazil region:
(A) Get the month on month no. of orders placed in each
state

select customer_state,
extract(month from order_purchase_timestamp)as
mnth,count(order_id)
from `sqlbussinesscase-394010.ecommerce.orders` as o
join `sqlbussinesscase-394010.ecommerce.customers` c
on o.customer_id=c.customer_id
group by 1,2
order by 1,2

Q.3 (B) How are the customers distributed across all the
states?

SELECT customer_state,count(customer_unique_id) as
No_of_unique_cust
from `sqlbussinesscase-394010.ecommerce.customers`
group by customer_state
  
Q.4 Impact on Economy: Analyze the money movement by
e-commerce by looking at order prices, freight and others.
(A). Get the % increase in the cost of orders from year 2017
to 2018 (include months between Jan to Aug only).

select * from(
select (lead(totalcost,1) over (order by year) -
totalcost)/totalcost * 100 as percentage_increase
from(
select year,sum(payment_value) as totalcost
from(
select order_id,
extract(year from order_purchase_timestamp) as
year,
extract(month from order_purchase_timestamp) as
month
from `sqlbussinesscase-394010.ecommerce.orders`
) as f
left join `sqlbussinesscase-394010.ecommerce.payments` as p
on f.order_id=p.order_id
where month between 1 and 8
group by 1
order by 1) as n ) as h
limit 1

Q.4 (B)
Calculate the Total & Average value of order price
for each state.

select customer_state,round(sum(price),2) as
totalvalue,round(Avg(price),2) as Average_value
from `sqlbussinesscase-394010.ecommerce.customers` as c
left join `sqlbussinesscase-394010.ecommerce.orders` as o
on c.customer_id=o.customer_id
left join `sqlbussinesscase-394010.ecommerce.order_itmes` as
oi
on o.order_id=oi.order_id
group by 1

Q.4 (C)Calculate the Total & Average value of order
freight for each state.

select customer_state,round(sum(freight_value),2) as
total_freightvalue,round(Avg(freight_value),2) as
Average_freightvalue
from `sqlbussinesscase-394010.ecommerce.customers` as c
left join `sqlbussinesscase-394010.ecommerce.orders` as o
on c.customer_id=o.customer_id
left join `sqlbussinesscase-394010.ecommerce.order_itmes` as oi
on o.order_id=oi.order_id
group by 1

Q.5 
Analysis based on sales, freight and delivery time.
(A). 
  Find the no. of days taken to deliver each order
from the order’s purchase date
as delivery time.
Also, calculate the difference (in days) between
the estimated & actual delivery
date of an order.
Do this in a single query.

select order_id, order_purchase_timestamp,
(order_delivered_carrier_date - order_purchase_timestamp)/24 as
Actual_time_taken_in_days,
(order_estimated_delivery_date - order_purchase_timestamp)/24 as
Estimated_time_taken_in_days
FROM `sqlbussinesscase-394010.ecommerce.orders`
ORDER BY order_id
limit 10

(B) Find out the top 5 states with the highest &
lowest average freight value.
  
SELECT s.seller_state, avg(oi.freight_value) as
Avg_Freight_Value
FROM `sqlbussinesscase-394010.ecommerce.sellers` s left join
`sqlbussinesscase-394010.ecommerce.order_itmes` oi ON
s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY 2 desc
limit 5;

(c) Find out the top 5 states with the highest &
lowest average delivery time.

SELECT s.seller_state, avg(x.time_to_delivery) as
Avg_time_to_delivery_in_days
FROM `sqlbussinesscase-394010.ecommerce.sellers` s left join
`sqlbussinesscase-394010.ecommerce.order_itmes` oi ON
s.seller_id = oi.seller_id
left join
(SELECT order_id, customer_id, order_purchase_timestamp,
(order_delivered_customer_date-order_purchase_timestamp)/24
as time_to_delivery,
(order_estimated_delivery_date -
order_delivered_customer_date)/24 as diff_estimated_delivery
FROM `sqlbussinesscase-394010.ecommerce.orders`
) x
ON oi.order_id = x.order_id
GROUP BY s.seller_state
ORDER BY 2
limit 5

(D)Find out the top 5 states where the order
delivery is really fast as compared to
the estimated date of delivery.
  
SELECT distinct x.seller_state, x.diff_in_days
FROM
(SELECT s.seller_state,
substr(cast((o.order_estimated_delivery_date -
o.order_delivered_carrier_date)/24 as STRING), 7, 1) as
diff_in_days
FROM `sqlbussinesscase-394010.ecommerce.sellers` s left join
`sqlbussinesscase-394010.ecommerce.order_itmes` oi ON
s.seller_id = oi.seller_id left join
`sqlbussinesscase-394010.ecommerce.orders` o
ON oi.order_id = o.order_id) x
ORDER BY 2 desc
limit 5

Q.6 Analysis based on the payments:
A. Find the month on month no. of orders placed
using different payment types.

SELECT p.payment_type, EXTRACT(MONTH FROM
order_purchase_timestamp) as Month, count
(o.order_id) as No_of_orders
FROM `sqlbussinesscase-394010.ecommerce.payments` p left join
`sqlbussinesscase-394010.ecommerce.orders` o
ON p.order_id = o.order_id
GROUP BY 1,2
ORDER BY p.payment_type, Month
limit 10;

(B) Find the no. of orders placed on the basis of
the payment installments that have
been paid.

SELECT p.payment_installments, count(o.order_id) as No_of_orders
FROM `sqlbussinesscase-394010.ecommerce.payments` p left join
`sqlbussinesscase-394010.ecommerce.orders` o
ON p.order_id = o.order_id
GROUP BY 1
ORDER BY 2 desc
limit 10;
