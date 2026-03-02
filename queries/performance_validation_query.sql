EXPLAIN
SELECT
      ROUND(SUM(od.quantity * p.price),2) AS revenue
FROM orders AS o
JOIN order_details AS od ON o.order_id = od.order_id
JOIN pizzas AS p ON p.pizza_id = od.pizza_id
WHERE o.order_datetime >= '2015-01-01'
AND o.order_datetime < '2015-02-01';
