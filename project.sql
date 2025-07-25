-- create database storedb ;
use storedb;
SELECT 
    *
FROM
    pizzas;

CREATE TABLE porders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);
SELECT 
    *
FROM
    porders;
CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

SELECT 
    *
FROM
    order_details;

SELECT 
    *
FROM
    porders;

SELECT 
    *
FROM
    pizza_types;
    
-- Data Analysis & Business Key Problems & Answers
# Basic:
# Retrieve the total number of orders placed.
# Calculate the total revenue generated from pizza sales.
# Identify the highest-priced pizza.
# Identify the most common pizza size ordered.
# List the top 5 most ordered pizza types along with their quantities.


# Intermediate:
# Join the necessary tables to find the total quantity of each pizza category ordered.
# Determine the distribution of orders by hour of the day.
# Join relevant tables to find the category-wise distribution of pizzas.
# Group the orders by date and calculate the average number of pizzas ordered per day.
# Determine the top 3 most ordered pizza types based on revenue.

# Advanced:
# Calculate the percentage contribution of each pizza type to total revenue.
# Analyze the cumulative revenue generated over time.
# etermine the top 3 most ordered pizza types based on revenue for each pizza category.

-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_order
FROM
    porders;
    
-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- 3. Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC	
LIMIT 1;
-- 4.  Identify the most common pizza size ordered
SELECT 
    pizzas.size, COUNT(order_details.order_details_id)
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
LIMIT 1;

-- 5. List the top 5 most ordered pizza types 
-- along with their quantities.

    SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;

-- 6 -- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- 7 -- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id)
FROM
    porders
GROUP BY HOUR(order_time);

-- 8. -- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- 9 -- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    porders.order_date, SUM(order_details.quantity)
FROM
    porders
        JOIN
    order_details ON porders.order_id = order_details.order_id
GROUP BY porders.order_date;

-- 10. Determine the top 3 most ordered pizza types based on revenue
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    (SUM(order_details.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price),
                        2) AS total_sales
        FROM
            order_details
                JOIN
            pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100 AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC
;
-- 12. Analyze the cumulative revenue generated over time.
select order_date,
 sum(revenue) over(order by order_date)
 as cum_revenue from (select porders.order_date ,
 sum(order_details.quantity * pizzas.price) as revenue
 from order_details join 
 pizzas on order_details.pizza_id = pizzas.pizza_id 
 join porders on porders.order_id = order_details.order_id
 group by porders.order_date) as sales; 
 
 
 
-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
    category,
    name,
    revenue,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
FROM (
    SELECT 
        pt.category,
        pt.name,
        SUM(od.quantity * p.price) AS revenue
    FROM 
        pizza_types pt
        JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN order_details od ON od.pizza_id = p.pizza_id
    GROUP BY 
        pt.category,
        pt.name
) AS a;


