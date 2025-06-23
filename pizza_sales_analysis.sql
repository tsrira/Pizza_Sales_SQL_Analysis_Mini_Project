-- ====================================================================
-- Project: Pizza Sales Analysis with SQL
-- Description: SQL-based project to analyze pizza sales data.
-- ====================================================================
-- This script contains:
-- 1. Basic Analysis Queries
-- 2. Intermediate Analysis Queries
-- 3. Advanced Analysis Queries
-- ====================================================================

-- Selecting the "pizza_db" database
USE pizza_db;

-- Getting the idea about all the tables
SELECT *
FROM order_details;
SELECT *
FROM orders;
SELECT *
FROM pizza_types;
SELECT *
FROM pizzas;

-- =========================================
-- BASIC ANALYSIS QUERIES
-- =========================================

/* Question 1 ->
Retrive the total number of orders placed
*/
-- Tables - Orders or Order_Details

SELECT COUNT(order_id) order_count
FROM orders;

SELECT COUNT(DISTINCT(order_id)) order_count
FROM order_details;

/*Question 2->
Calculate the total revenue generated from pizza sales.
Objective: Calculate the total revenue generated from all pizza orders.
*/
-- Tables - Order_Details and Pizzas

SELECT 
	ROUND(SUM(od.quantity * p.price),2) total_revenue
FROM
    order_details od INNER
JOIN pizzas p
WHERE  od.pizza_id = p.pizza_id ;

/*Questions 3
Identify the highest-priced pizza.
Objective: Find out which pizza is the most expensive.
*/
-- Tables Pizzas and Pizza_Types

SELECT
    pt.name AS pizza_name,
    p.price AS price
FROM
    pizzas p
JOIN
    pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY
    p.price DESC
LIMIT 1;


/* Question 4
Identify the most common pizza size ordered.
Objective: Determine which pizza size (e.g., small, medium, large) is ordered the most.
*/
-- Tables Order_Details and Pizzas

SELECT  
	p.size,
    COUNT(p.pizza_id)  pcount    
FROM 
	order_details od 
INNER JOIN 
	pizzas p
ON 
	od.pizza_id = p.pizza_id
GROUP BY 
	p.size
ORDER BY 
	pcount DESC;

SELECT
    p.size,
    SUM(od.quantity) AS total_ordered
FROM
    order_details od
JOIN
    pizzas p
ON od.pizza_id = p.pizza_id
GROUP BY
    p.size
ORDER BY
    total_ordered DESC;

/* Question 5
List the top 5 most ordered pizza types along with their quantities.
Objective: Find out which pizza types are most frequently ordered.
*/
-- Tables Order_Details, Pizzas and Pizza_Types

SELECT
    pt.name AS pizza_type,
    SUM(od.quantity) AS total_quantity
FROM
    order_details od
JOIN
    pizzas p
ON od.pizza_id = p.pizza_id
JOIN
    pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY
    pt.name
ORDER BY
    total_quantity DESC
LIMIT 5;

-- =========================================
-- INTERMEDIATE ANALYSIS QUERIES
-- =========================================

/* Question 6
Join the necessary tables to find the total quantity of each pizza category ordered.
Objective: Explore the relationship between pizza categories and quantities ordered.
*/
-- Tables Order_Details, Pizzas and Pizza_Types

SELECT 
	pt.category, 
    SUM(od.quantity) AS Total_Quantity
FROM 
	pizzas p, 
    pizza_types pt, 
    order_details od
WHERE
    od.pizza_id = p.pizza_id 
AND
    p.pizza_type_id = pt.pizza_type_id
GROUP BY 
	pt.category
ORDER BY 
	Total_Quantity DESC;

/* Question 7
Determine the distribution of orders by hour of the day.
Objective: Analyze how orders are distributed across different times of day.
*/
-- Tables Orders

SELECT
    EXTRACT(HOUR FROM o.time) AS order_hour,
    COUNT(*) AS total_orders
FROM
    orders o
GROUP BY
    EXTRACT(HOUR FROM o.time)
ORDER BY
    order_hour;

/* Question 8
Join relevant tables to find the category-wise distribution of pizzas.
Objective: Find out how pizzas from different categories are ordered.
*/
-- Tables Order_Details, Pizzas and Pizza_Types

SELECT 
	pt.category, 
    SUM(od.quantity) AS Number_Of_Orders
FROM 
	pizzas p, 
    pizza_types pt, 
    order_details od
WHERE
    od.pizza_id = p.pizza_id AND
    p.pizza_type_id = pt.pizza_type_id
GROUP BY 
	pt.category
ORDER BY 
	Number_Of_Orders DESC;

/* Question 9
Group the orders by date and calculate the
average number of pizzas ordered per day.
*/
-- Tables Orders and Order_Details

SELECT 
	(AVG(Number_of_Pizzas)) AS Avg_Number
FROM
    (
		SELECT 
			o.date order_date, 
			SUM(od.quantity) Number_Of_Pizzas
		FROM 
			orders o
		JOIN 
			order_details od
		ON 
			o.order_id = od.order_id
		GROUP BY 
			o.date) tot;

  /* Question 10
Determine the top 3 most ordered pizza types based on revenue.
Objective: Identify the pizza types that generated the most revenue.
*/
-- Tables Order_Details, Pizzas and Pizza_Types

SELECT 
	pt.name, 
    ROUND(SUM(od.quantity * p.price),2) AS Total_Revenue
FROM
    order_details od
JOIN 
	pizzas p
ON 
	od.pizza_id = p.pizza_id
JOIN 
	pizza_types pt
ON 
	p.pizza_type_id = pt.pizza_type_id
GROUP BY 
	pt.name
ORDER BY 
	Total_Revenue DESC
LIMIT 3;


-- =========================================
-- ADVANCED ANALYSIS QUERIES
-- =========================================

/* Question 11
Calculate the percentage contribution of each pizza type to total revenue.
*/
-- Tables Order_Details, Pizzas and Pizza_Types
SELECT 
	t.name, 
    Total_Revenue, 
	Over_ALL_Total,
    ROUND((Total_Revenue/ Over_All_Total)*100,2) AS Percent_Contribution
FROM
    (
	SELECT 
		pt.name, 
		ROUND(SUM(od.quantity * p.price),2) AS Total_Revenue,
		ROUND(SUM(SUM(od.quantity * p.price)) OVER() ,2) AS Over_All_Total
	FROM
		order_details od
	JOIN 
		pizzas p
	ON 
		od.pizza_id = p.pizza_id
	JOIN 
		pizza_types pt
	ON 
		p.pizza_type_id = pt.pizza_type_id
	GROUP 
		BY pt.name) t
ORDER BY 
	Percent_Contribution DESC;

/* Question 12
Analyze the cumulative revenue generated over time.
Objective: Track how revenue accumulates over time.
*/
 -- Tables Orders, Order_Details and Pizzas
 
SELECT 
	o.date AS Order_Date, 
    ROUND(SUM(od.quantity * p.price),2) AS Day_Price,
    ROUND(SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.date), 2) AS Cumulative_Revenue
FROM 
	orders o
JOIN 
	order_details od
ON 
	o.order_id = od.order_id
JOIN
	pizzas p
ON 
	od.pizza_id = p.pizza_id
GROUP BY 
	o.date;

/* Question 13
Determine the top 3 most ordered pizza types based on revenue for each pizza category.
Objective: Find the highest-grossing pizzas within each category.
*/
-- Tables Order_Details, Pizzas and Pizza_Types

SELECT 
	Category, 
	Name, 
	Total_Revenue, 
    Rank_In_Category
FROM (
	SELECT 
		pt.category, 
		pt.name, 
        ROUND(SUM(od.quantity * p.price),2) AS Total_Revenue,
		ROW_NUMBER() OVER (
							PARTITION BY pt.category
							ORDER BY ROUND(SUM(od.quantity * p.price),2) DESC
							) AS Rank_In_Category
	FROM 
		pizzas p, 
		pizza_types pt, 
        order_details od
	WHERE
		od.pizza_id = p.pizza_id AND
		p.pizza_type_id = pt.pizza_type_id
	GROUP BY 
		pt.category, pt.name ) t
WHERE
    Rank_In_Category <= 3
ORDER BY category, Total_Revenue DESC;
