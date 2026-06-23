USE Ecommerce_Analysis;

-- =============================================
-- 04_product_category_analysis.sql
-- Purpose:
-- Identify the top product categories by revenue.
-- This helps the business understand which categories generate the most sales.
-- =============================================

SELECT TOP 10
    t.product_category_name_english AS product_category,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.product_id) AS total_items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY total_revenue DESC;