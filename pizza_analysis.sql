create database amar_pizza;
use amar_pizza;
-- import pizzas table
describe pizzas;

-- import pizza_types table
describe pizza_types;


create table orders(
order_id int primary key not null,
order_date date not null,
order_time time not null);

describe orders;


create table order_details(
order_details_id int primary key not null,
order_id int not null,
pizza_id text not null,
quantity int not null);

describe order_details;

select * from pizzas;
select * from pizza_types;
select * from orders;
select * from order_details;
-- BASIC QUERIES:-
-- 1)Retrieve the total number of orders placed:-
SELECT COUNT(order_id) AS TOTAL_ORDERS
FROM orders;

-- 2)Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(P.price* O.quantity),0) AS TOTAL_REVENUE
FROM pizzas P
JOIN order_details O
ON P.pizza_id =O.pizza_id;

-- 3)Identify the highest-priced pizza.
SELECT PT.name,P.price
FROM pizzas P
JOIN pizza_types PT
ON P.pizza_type_id=PT.pizza_type_id
ORDER BY P.price DESC
LIMIT 1;

-- 4)Identify the most common pizza size ordered.
SELECT P.size,COUNT(O.order_details_id) AS ORDER_COUNT
FROM pizzas P
JOIN order_details O
ON P.pizza_id=O.pizza_id
GROUP BY P.size
ORDER BY ORDER_COUNT DESC
LIMIT 1;

-- 5)List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name, SUM(od.quantity) AS Total_Quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY Total_Quantity DESC
LIMIT 5;

-- Intermediate Queries:-
-- 1)Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT PT.category,SUM(O.quantity) AS TOTAL_QUANTITY
FROM order_details O
JOIN pizzas P
ON P.pizza_id=O.pizza_id
JOIN pizza_types PT
ON PT.pizza_type_id=P.pizza_type_id
GROUP BY PT.category
ORDER BY TOTAL_QUANTITY DESC;

-- 2)Determine the distribution of orders by hour of the day.
SELECT HOUR(Order_time) as Hour_sales, count(Order_id)as total_orders
from Orders
GROUP BY Hour_sales;

-- 3)Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name)
FROM pizza_types
GROUP BY category;

-- 4)Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT round(AVG(daily_total),2) AS avg_pizzas_per_day
FROM (
    SELECT o.order_date, SUM(od.quantity) AS daily_total
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date
) AS daily_orders;

-- 5)Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name, SUM(p.price * od.quantity) AS Revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY Revenue DESC
LIMIT 3;

-- Advance Queries:-
-- 1.Calculate the percentage contribution of each pizza type to total revenue.
select pt.category,round(SUM(p.price * o.quantity)/(SELECT 
round(SUM(P.price* o.quantity),0) AS TOTAL_REVENUE
FROM pizzas P
JOIN order_details o
ON P.pizza_id =o.pizza_id)*100,2) as Pizza_revenue
from pizza_types pt
join pizzas p on pt.pizza_type_id=p.pizza_type_id 
join order_details o
on o.pizza_id = p.pizza_id
group by pt.category
order by Pizza_revenue;

-- 2.Analyze the cumulative revenue generated over time.
select order_date,sum(pizza_revenue) over(order by order_date)as cumulative_revenue
from(
select o.order_date,sum(p.price* od.quantity) as pizza_revenue
from pizzas p
join order_details od
ON p.pizza_id =od.pizza_id
join orders o
on o.order_id=od.order_id
group by o.order_date) as total_sales;

-- 3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT *
FROM (
    SELECT pt.category,
           pt.name,
           SUM(p.price * od.quantity) AS revenue,
           RANK() OVER (PARTITION BY pt.category 
                        ORDER BY SUM(p.price * od.quantity) DESC) AS rnk
    FROM pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON p.pizza_id = od.pizza_id
    GROUP BY pt.category, pt.name
) t
WHERE rnk <= 3;