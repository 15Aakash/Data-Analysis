# E-Commerce Business Performance Analysis using SQL Server and Power BI

## Project Overview

This project analyzes an e-commerce business dataset to understand sales performance, customer behavior, product category performance, delivery efficiency, payment trends, seller performance, and customer satisfaction.

The goal of this project is to answer key business questions such as:

* What is the overall business performance?
* Which product categories generate the most revenue?
* Are customers returning or purchasing only once?
* Which payment methods contribute the most revenue?
* Are late deliveries affecting customer review scores?
* Which states experience higher delivery delays?

This project was built as an end-to-end data analytics portfolio project using SQL Server for data analysis and Power BI for dashboard reporting.

---

## Tools Used

* SQL Server
* SQL Server Management Studio
* Power BI Desktop
* DAX
* Excel/CSV files
* GitHub

---

## Dataset

The project uses the Brazilian E-Commerce Public Dataset by Olist, which contains order, customer, payment, product, seller, review, and delivery-related data.

Main tables used:

* customers
* orders
* order_items
* order_payments
* order_reviews
* products
* sellers
* product_translation

---

## Business KPIs

The main KPIs created for this project are:

* Total Revenue: $16M
* Total Orders: 99K
* Total Customers: 96K
* Average Order Value: $161
* Average Review Score: 4.09
* Late Delivery Percentage: 7.87%

---

## SQL Analysis Performed

The SQL analysis includes:

1. Data validation and row count checks
2. Business KPI calculation
3. Monthly revenue trend analysis
4. Product category revenue analysis
5. Customer retention analysis
6. Delivery performance analysis
7. Review score analysis
8. Seller performance analysis
9. Payment behavior analysis
10. SQL views created for Power BI reporting

---

## Power BI Dashboard Pages

### 1. Executive Summary

This page provides a high-level overview of business performance.

It includes:

* Total Revenue
* Total Orders
* Total Customers
* Average Order Value
* Average Review Score
* Late Delivery %
* Monthly Revenue Trend
* Revenue by Customer State
* Top 10 Product Categories by Revenue

### 2. Customer & Revenue Analysis

This page focuses on customer behavior and revenue distribution.

It includes:

* One-time Customers
* Repeat Customers
* Repeat Customer %
* One-time vs Repeat Customers
* Revenue by Payment Type
* Revenue by Customer State
* Top 10 Customer Cities by Orders
* Monthly Orders Trend

### 3. Delivery & Review Analysis

This page focuses on delivery performance and customer satisfaction.

It includes:

* Delivered Orders
* Late Orders
* Late Delivery %
* Average Delivery Days
* Late vs On-time Deliveries
* Review Score by Delivery Status
* Average Delivery Days by State
* Late Delivery % by State

---

## Key Insights

* The business generated approximately $16M in total revenue from around 99K orders.
* Health & beauty, watches & gifts, and bed/bath/table were among the highest revenue-generating product categories.
* Most customers were one-time customers, with repeat customers representing only around 3% of customers.
* Credit card was the dominant payment method and contributed the largest share of revenue.
* Around 7.87% of delivered orders were late.
* Late deliveries had noticeably lower average review scores compared to on-time deliveries, showing that delivery performance has a direct impact on customer satisfaction.
* Some states showed higher average delivery days and higher late delivery percentages, indicating possible logistics improvement areas.

---

## Project Outcome

This project demonstrates the ability to:

* Import and clean real-world business data
* Write SQL queries using joins, aggregations, CTEs, CASE statements, date functions, and views
* Build business KPIs using SQL and DAX
* Create interactive Power BI dashboards
* Translate data analysis into business insights
* Present findings clearly for decision-making

