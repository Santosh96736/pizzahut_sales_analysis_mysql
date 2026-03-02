-- Advanced Patterns
-- Top 10 pizzas contributing 80% revenue (Pareto)
WITH pizza_revenue AS (
    SELECT pt.pizza_type_id,
           pt.name,
           ROUND(SUM(od.quantity * p.price),2) AS revenue
    FROM pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON p.pizza_id = od.pizza_id
    GROUP BY pt.pizza_type_id, pt.name
)

SELECT name,
       revenue,
       ROUND(
           100 * SUM(revenue) OVER (ORDER BY revenue DESC)
           / SUM(revenue) OVER (),
       2) AS cumulative_pct
FROM pizza_revenue
ORDER BY revenue DESC;

-- Revenue cumulative trend (window functions)
WITH monthly_revenue AS (SELECT 
    YEAR(o.order_datetime) AS order_year,
    MONTH(o.order_datetime) AS order_month,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM
    orders AS o
        JOIN
    order_details AS od ON o.order_id = od.order_id
        JOIN
    pizzas AS p ON p.pizza_id = od.pizza_id
GROUP BY order_year , order_month)

SELECT CONCAT(order_year, '-', LPAD(order_month, 2, '0')) AS order_date,
	   revenue,
	   SUM(revenue) OVER(ORDER BY order_year, order_month) AS cumulative_revenue,
       ROUND((SUM(revenue) OVER(ORDER BY order_year, order_month)/SUM(revenue) OVER()) * 100,2) AS cumulative_pct
FROM monthly_revenue
ORDER BY order_year, order_month;


-- Order clustering by time
SELECT 
    CASE
        WHEN HOUR(order_datetime) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(order_datetime) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(order_datetime) BETWEEN 17 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_slot,
    COUNT(*) AS total_orders,
    SUM(od.quantity) AS total_quantity
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY time_slot
ORDER BY total_quantity DESC;

-- Size preference by category
EXPLAIN
WITH category_size AS (SELECT 
    pt.category, p.size, SUM(od.quantity) AS total_quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category , p.size)

SELECT category, size, total_quantity,
       ROW_NUMBER() OVER(PARTITION BY category ORDER BY total_quantity DESC) AS rn
FROM category_size;
