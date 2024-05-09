create database olist_store_project;



use olist_store_project;
select count(*) from olist_orders_dataset; 
select count(*) from olist_products_dataset;  
select count(*) from olist_sellers_dataset; 
select count(*) from olist_geolocation_dataset;
select count(*) from olist_order_reviews_dataset; 
select count(*) from olist_order_payments_dataset; 
select count(*) from olist_order_items_dataset;
select count(*) from olist_customers_dataset;
select count(*) from olist_product_category_name_translation; 
------------------------------------------------------------------------------------
select * from olist_store_project.olist_orders_dataset;
select * from olist_store_project.olist_order_payments_dataset;
select * from olist_store_project.olist_products_dataset;
select * from olist_store_project.olist_customers_dataset; 
select * from olist_store_project.product_category_name_translation; 
select * from olist_store_project.olist_order_reviews_dataset;
--------------------------------------------------------------------------

# KPI 1 : Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics

select
  case when dayofweek(str_to_date(o.order_purchase_timestamp,'%Y-%m-%d')) in (1,7)
  then 'Weekend' else 'Weekday' end as Daytype,
  count(distinct o.order_id) as TotalOrders,
  round(sum(p.payment_value)) as TotalPayment,
  round(avg(p.payment_value)) as AveragePayment
  from
    olist_orders_dataset o
  join
    olist_order_payments_dataset p on o.order_id = p.order_id
  group by
    Daytype; 
    
---------------------------------------------------------------------------------------------

# KPI 2- Number of Orders with review score 5 and payment type as credit card.

select
count(pmt.order_id) as Total_Orders
from
olist_order_payments_dataset pmt
inner join olist_order_reviews_dataset rev on pmt.order_id = rev.order_id
where
rev.review_score = 5
and pmt.payment_type = 'credit_card';

-----------------------------------------------------------------------------------------------------

# KPI 3- Average number of days taken for order_delivered_customer_date for pet_shop

select 
  product_category_name,
  round(avg(datediff(order_delivered_customer_date,order_purchase_timestamp))) as Avg_delivery_time
  
  from 
    olist_orders_dataset o
  join 
    olist_order_items_dataset i on i.order_id = o.order_id
  join
    olist_products_dataset p on p.product_id = i.product_id
  where
     p.product_category_name = 'pet_shop'
     and o.order_delivered_customer_date is not null;
     
--------------------------------------------------------------------------------------------------------------------

# KPI 4- Average price and payment values from customers of sao paulo city

with orderItemsAvg as(
select round(avg(item.price)) as avg_order_item_price
from olist_order_items_dataset item
join olist_orders_dataset ord
on item.order_id = ord.order_id
join olist_customers_dataset cust on ord.customer_id = cust.customer_id
where cust.customer_city = "Sao Paulo"
)
select
(select avg_order_item_price from orderItemsAvg) as avg_order_item_price,
round(avg(pmt.payment_value))as avg_payment_value
from olist_order_payments_dataset pmt
join olist_orders_dataset ord on pmt.order_id = ord.order_id
join olist_customers_dataset cust on ord.customer_id = cust.customer_id
where
cust.customer_city = "sao Paulo";

------------------------------------------------------------------------------------------

# KPI 5- Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

select 
rew.review_score,
round(avg(datediff(ord.order_delivered_customer_date ,order_purchase_timestamp)),0) as "Avg shipping days"
from olist_orders_dataset as ord
join olist_order_reviews_dataset as rew on rew.order_id = ord.order_id
group by rew.review_score
order by rew.review_score; 

