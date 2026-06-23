USE Ecommerce_Analysis;

-- =============================================
-- 07_review_analysis.sql
-- Purpose:
-- Analyze customer satisfaction using review scores.
-- We check:
-- 1. Overall average review score
-- 2. Review score by delivery status
-- 3. Product categories with lowest review scores
-- =============================================


-- 1. Overall average review score
SELECT
    COUNT(DISTINCT review_id) AS total_reviews,
    ROUND(AVG(CAST(review_score AS FLOAT)), 2) AS avg_review_score
FROM order_reviews;