
-- Blinkit Sales and Business Performance Analysis
-- Database: blinkit_analytics

-- 1. Monthly sales, orders and average order value
SELECT
    DATE_TRUNC('month', order_date)::date AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_total), 2) AS total_sales,
    ROUND(AVG(order_total), 2) AS avg_order_value
FROM public.blinkit_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- 2. Sales by product category
SELECT
    p.category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS category_sales
FROM public.blinkit_order_items oi
JOIN public.blinkit_products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_sales DESC;

-- 3. Top 10 products by sales
SELECT
    p.product_name,
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS product_sales
FROM public.blinkit_order_items oi
JOIN public.blinkit_products p
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY product_sales DESC
LIMIT 10;

-- 4. Delivery status breakdown
SELECT
    delivery_status,
    COUNT(*) AS total_orders
FROM public.blinkit_delivery_performance
GROUP BY delivery_status
ORDER BY total_orders DESC;

-- 5. Customer rating breakdown
SELECT
    rating,
    COUNT(*) AS total_reviews
FROM public.blinkit_customer_feedback
GROUP BY rating
ORDER BY rating;
