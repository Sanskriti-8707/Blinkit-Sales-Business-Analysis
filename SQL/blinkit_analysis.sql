
-- Blinkit Sales and Business Performance Analysis
-- Database: blinkit_analytics

-- 1. MONTHLY SALES, ORDERS AND AVERAGE ORDER VALUE

SELECT
    DATE_TRUNC('month', order_date)::date AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_total)::numeric, 2) AS total_sales,
    ROUND(AVG(order_total)::numeric, 2) AS avg_order_value
FROM public.blinkit_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;


-- 2. SALES BY PRODUCT CATEGORY

SELECT
    p.category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2) AS category_sales
FROM public.blinkit_order_items oi
JOIN public.blinkit_products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_sales DESC;


-- 3. TOP 10 PRODUCTS BY SALES

SELECT
    p.product_name,
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2) AS product_sales
FROM public.blinkit_order_items oi
JOIN public.blinkit_products p
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY product_sales DESC
LIMIT 10;


-- 4. DELIVERY STATUS BREAKDOWN

SELECT
    delivery_status,
    COUNT(*) AS total_orders
FROM public.blinkit_delivery_performance
GROUP BY delivery_status
ORDER BY total_orders DESC;


-- 5. CUSTOMER RATING BREAKDOWN

SELECT
    rating,
    COUNT(*) AS total_reviews
FROM public.blinkit_customer_feedback
GROUP BY rating
ORDER BY rating;


-- 6. OVERALL BUSINESS KPIs

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_total)::numeric, 2) AS total_sales,
    ROUND(AVG(order_total)::numeric, 2) AS average_order_value,
    COUNT(DISTINCT customer_id) AS ordering_customers
FROM public.blinkit_orders;


-- 7. SALES BY PAYMENT METHOD

SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_total)::numeric, 2) AS total_sales
FROM public.blinkit_orders
GROUP BY payment_method
ORDER BY total_sales DESC;


-- 8. CUSTOMER SEGMENTATION

SELECT
    c.customer_segmentation,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_total)::numeric, 2) AS total_sales
FROM public.blinkit_customers c
LEFT JOIN public.blinkit_orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_segmentation
ORDER BY total_sales DESC NULLS LAST;


-- 9. CUSTOMER ORDER FREQUENCY

SELECT
    order_count,
    COUNT(*) AS number_of_customers
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM public.blinkit_orders
    GROUP BY customer_id
) customer_orders
GROUP BY order_count
ORDER BY order_count;


-- 10. CUSTOMER SENTIMENT ANALYSIS

SELECT
    sentiments,
    COUNT(*) AS total_feedback,
    ROUND(AVG(rating)::numeric, 2) AS average_rating
FROM public.blinkit_customer_feedback
GROUP BY sentiments
ORDER BY total_feedback DESC;


-- 11. DELAYED ORDER ANALYSIS

SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE delivery_status IN ('Slightly Delayed', 'Significantly Delayed')
    ) AS delayed_orders,
    ROUND(
        COUNT(*) FILTER (
            WHERE delivery_status IN ('Slightly Delayed', 'Significantly Delayed')
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS delayed_order_percentage
FROM public.blinkit_delivery_performance;


-- 12. AVERAGE DELIVERY TIME DIFFERENCE BY STATUS
-- Note: delivery_time_minutes represents the difference
-- between actual and promised delivery time, not total
-- journey duration.

SELECT
    delivery_status,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_time_minutes)::numeric, 2)
        AS avg_minutes_vs_promised,
    ROUND(MAX(delivery_time_minutes)::numeric, 2)
        AS max_minutes_vs_promised
FROM public.blinkit_delivery_performance
GROUP BY delivery_status
ORDER BY avg_minutes_vs_promised;


-- 13. CATEGORY-WISE SALES CONTRIBUTION

SELECT
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2)
        AS category_sales,
    ROUND(
        SUM(oi.quantity * oi.unit_price) * 100.0 /
        NULLIF(SUM(SUM(oi.quantity * oi.unit_price)) OVER (), 0),
        2
    ) AS sales_contribution_percentage
FROM public.blinkit_order_items oi
JOIN public.blinkit_products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_sales DESC;


-- 14. TOP 10 CUSTOMERS BY PURCHASE VALUE

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_total)::numeric, 2) AS total_purchase_value
FROM public.blinkit_customers c
JOIN public.blinkit_orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_purchase_value DESC
LIMIT 10;


-- 15. INVENTORY DAMAGE ANALYSIS

SELECT
    product_id,
    SUM(stock_received) AS total_stock_received,
    SUM(damaged_stock) AS total_damaged_stock,
    ROUND(
        SUM(damaged_stock) * 100.0 /
        NULLIF(SUM(stock_received), 0),
        2
    ) AS damage_percentage
FROM public.blinkit_inventory_clean
GROUP BY product_id
ORDER BY damage_percentage DESC NULLS LAST;
