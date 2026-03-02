-- Product Performance
-- Which pizza generates highest revenue?
SELECT 
    pt.name, ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.pizza_type_id , pt.name
ORDER BY revenue DESC
LIMIT 1;

-- Which size sells most? 
SELECT 
    p.size, SUM(od.quantity) AS total_quantity
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC;

-- Which category drives volume?
SELECT 
    pt.category,
    SUM(od.quantity) AS total_quantity,
    ROUND((SUM(od.quantity) / (SELECT 
                    SUM(quantity)
                FROM
                    order_details)) * 100,
            2) AS pct_contribution
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Price vs quantity relationship?
SELECT 
    p.pizza_id, p.price, SUM(od.quantity) AS total_quantity
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.pizza_id , p.price
ORDER BY p.price;
