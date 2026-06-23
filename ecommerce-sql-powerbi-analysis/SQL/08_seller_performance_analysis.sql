USE Ecommerce_Analysis;

-- =============================================
-- 08_seller_performance_analysis.sql
-- Purpose:
-- Analyze seller performance based on:
-- 1. Revenue
-- 2. Total orders
-- 3. Average review score
-- =============================================


-- 1. Top sellers by revenue
SELECT TOP 10
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.product_id) AS total_items_sold
FROM order_items oi
JOIN sellers s
    ON oi.seller_id = s.seller_id
GROUP BY 
    oi.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_revenue DESC;

-- 2. Seller performance with review score
SELECT TOP 10
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review_score
FROM order_items oi
JOIN sellers s
    ON oi.seller_id = s.seller_id
JOIN order_reviews r
    ON oi.order_id = r.order_id
GROUP BY 
    oi.seller_id,
    s.seller_city,
    s.seller_state
HAVING COUNT(DISTINCT oi.order_id) >= 50
ORDER BY total_revenue DESC;

-- 3. Low-rated sellers with meaningful order volume
SELECT TOP 10
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review_score
FROM order_items oi
JOIN sellers s
    ON oi.seller_id = s.seller_id
JOIN order_reviews r
    ON oi.order_id = r.order_id
GROUP BY 
    oi.seller_id,
    s.seller_city,
    s.seller_state
HAVING COUNT(DISTINCT oi.order_id) >= 50
ORDER BY avg_review_score ASC;