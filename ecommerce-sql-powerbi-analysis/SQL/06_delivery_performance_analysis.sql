USE Ecommerce_Analysis;

-- =============================================
-- 06_delivery_performance_analysis.sql
-- Purpose:
-- Analyze delivery performance:
-- 1. Average delivery days
-- 2. Late delivery percentage
-- 3. Delivery performance by customer state
-- =============================================


-- 1. Overall delivery performance
SELECT
    COUNT(DISTINCT order_id) AS total_delivered_orders,

    AVG(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS avg_delivery_days,

    SUM(
        CASE 
            WHEN order_delivered_customer_date > order_estimated_delivery_date 
            THEN 1 ELSE 0 
        END
    ) AS late_orders,

    ROUND(
        100.0 * SUM(
            CASE 
                WHEN order_delivered_customer_date > order_estimated_delivery_date 
                THEN 1 ELSE 0 
            END
        ) / COUNT(DISTINCT order_id), 
        2
    ) AS late_delivery_percentage

FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;