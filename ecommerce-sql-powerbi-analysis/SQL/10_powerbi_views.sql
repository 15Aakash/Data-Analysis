USE Ecommerce_Analysis;
GO

-- =============================================
-- 10_powerbi_views.sql
-- Purpose:
-- Create clean SQL views for Power BI reporting.
-- These views will be used to build dashboard pages.
-- =============================================


-- =============================================
-- View 1: Order Summary View
-- One row per order with customer, payment, review, and delivery info
-- =============================================

DROP VIEW IF EXISTS vw_order_summary;
GO

CREATE VIEW vw_order_summary AS
WITH payment_summary AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value,
        COUNT(*) AS payment_records,
        MAX(payment_type) AS payment_type,
        AVG(CAST(payment_installments AS FLOAT)) AS avg_installments
    FROM order_payments
    GROUP BY order_id
),
review_summary AS (
    SELECT
        order_id,
        AVG(CAST(review_score AS FLOAT)) AS avg_review_score,
        COUNT(DISTINCT review_id) AS total_reviews
    FROM order_reviews
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_status,
    o.order_purchase_timestamp,
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    ps.total_payment_value,
    ps.payment_type,
    ps.payment_records,
    ps.avg_installments,

    rs.avg_review_score,
    rs.total_reviews,

    DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_days,

    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
        THEN 'Late Delivery'
        ELSE 'On-time Delivery'
    END AS delivery_status

FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN payment_summary ps
    ON o.order_id = ps.order_id
LEFT JOIN review_summary rs
    ON o.order_id = rs.order_id;
GO


-- =============================================
-- View 2: Product Sales View
-- One row per sold product item
-- Used for product category, seller, and revenue analysis
-- =============================================

DROP VIEW IF EXISTS vw_product_sales;
GO

CREATE VIEW vw_product_sales AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,

    p.product_category_name,
    t.product_category_name_english AS product_category,

    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value AS item_total_value,

    s.seller_city,
    s.seller_state,

    o.order_status,
    o.order_purchase_timestamp,
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month

FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_translation t
    ON p.product_category_name = t.product_category_name
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
LEFT JOIN orders o
    ON oi.order_id = o.order_id;
GO


-- =============================================
-- View 3: Customer Retention View
-- One row per unique customer
-- Used to analyze one-time vs repeat customers
-- =============================================

DROP VIEW IF EXISTS vw_customer_retention;
GO

CREATE VIEW vw_customer_retention AS
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,

    CASE 
        WHEN COUNT(DISTINCT o.order_id) = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,

    MIN(o.order_purchase_timestamp) AS first_order_date,
    MAX(o.order_purchase_timestamp) AS latest_order_date

FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;
GO