USE Ecommerce_Analysis;

-- =============================================
-- 02_kpi_analysis.sql
-- Purpose:
-- Calculate main business KPIs for the e-commerce project.
-- KPIs:
-- 1. Total Orders
-- 2. Total Customers
-- 3. Total Revenue
-- 4. Average Order Value
-- =============================================

SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    ROUND(SUM(p.payment_value), 2) AS total_revenue,
    ROUND(SUM(p.payment_value) / COUNT(DISTINCT o.order_id), 2) AS average_order_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_payments p
    ON o.order_id = p.order_id;