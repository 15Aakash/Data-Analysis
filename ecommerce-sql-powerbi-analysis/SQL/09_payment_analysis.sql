USE Ecommerce_Analysis;

-- =============================================
-- 09_payment_analysis.sql
-- Purpose:
-- Analyze customer payment behavior:
-- 1. Most used payment methods
-- 2. Revenue by payment type
-- 3. Average installments by payment type
-- =============================================


-- 1. Payment method usage
SELECT
    payment_type,
    COUNT(*) AS total_payment_records,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM order_payments
GROUP BY payment_type
ORDER BY total_orders DESC;

-- 2. Payment type revenue contribution
SELECT
    payment_type,
    ROUND(SUM(payment_value), 2) AS total_revenue,
    ROUND(
        100.0 * SUM(payment_value) / 
        (SELECT SUM(payment_value) FROM order_payments), 
        2
    ) AS revenue_percentage
FROM order_payments
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- 2. Payment type revenue contribution
SELECT
    payment_type,
    ROUND(SUM(payment_value), 2) AS total_revenue,
    ROUND(
        100.0 * SUM(payment_value) / 
        (SELECT SUM(payment_value) FROM order_payments), 
        2
    ) AS revenue_percentage
FROM order_payments
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- 3. Average installment count by payment type
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(CAST(payment_installments AS FLOAT)), 2) AS avg_installments,
    ROUND(AVG(payment_value), 2) AS avg_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY avg_installments DESC;

