USE Ecommerce_Analysis;

-- =============================================
-- 03_monthly_revenue.sql
-- Purpose:
-- Analyze monthly revenue and monthly order trend.
-- This query helps identify sales growth, decline, and seasonal trends.
-- =============================================

SELECT
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
    ROUND(SUM(p.payment_value), 2) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_payments p
    ON o.order_id = p.order_id
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY order_month;