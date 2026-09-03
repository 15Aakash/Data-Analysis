# Data Analytics Portfolio

A collection of end-to-end data analytics projects demonstrating practical experience in **SQL, Python, Power BI, Tableau, Excel, Snowflake, AWS, dbt, ETL, data modeling, statistical analysis, experimentation, and business intelligence**.

These projects focus on solving business problems through structured analysis, cloud data workflows, KPI development, statistical testing, dashboarding, and data-driven recommendations.

---

## Projects

### 1. NovaFlow SaaS Product Growth & Experimentation Analytics

**Tools:** Python, Pandas, AWS S3, Snowflake, dbt, SQL, Tableau, Statistics, A/B Testing

Built an end-to-end SaaS product analytics platform simulating a modern cloud analytics workflow across **3.1M+ raw records, 100,000 users, 535,936 sessions, and 1.6M product events**.

Key KPIs:

- **7-Day Activation Rate:** 50.96%
- **DAU:** 2,314
- **WAU:** 11,437
- **MAU:** 31,796
- **MRR:** $445,152
- **ARR:** $5.34M
- **Active Paid Share:** 56.79%
- **Latest Full-Month Paid Churn:** 7.96%
- **Largest Onboarding Step Drop-off:** 23.61%

Highlights:

- Generated **13 interconnected synthetic SaaS datasets** using Python and Pandas
- Built a cloud ingestion workflow using **Amazon S3 and Snowflake**
- Implemented secure AWS IAM access and Snowflake external storage integration
- Developed **13 dbt staging models** for cleaning, deduplication, type conversion, and referential validation
- Built **10 analytics marts** supporting activation, onboarding, engagement, retention, feature adoption, revenue, churn, support, and experimentation
- Executed a final dbt pipeline with **108 models/tests passing and 0 errors**
- Calculated product metrics including DAU, WAU, MAU, retention, feature adoption, MRR, ARR, and paid subscription churn
- Identified the largest onboarding bottleneck between **Workspace Preferences and Tutorial Completed**, with a **23.61% drop-off**
- Performed an A/B test on a simplified onboarding flow using a two-proportion significance test and 95% confidence interval
- Found **50.92% Control vs 50.73% Treatment activation**, with **p ≈ 0.879**, indicating no statistically significant improvement
- Built **5 Tableau dashboards** covering executive KPIs, retention and product adoption, revenue and churn, support analytics, and experimentation

[View Project](./saas-product-growth-experimentation-analytics)

---

### 2. Healthcare Operations & Population Health Analytics

**Tools:** Python, Pandas, Microsoft SQL Server, Power BI, DAX, ETL, Dimensional Modeling, Statistics

Built an end-to-end healthcare BI solution using synthetic healthcare data across **90,000 encounters, 17,740 admissions, and approximately 10,000 patients**.

Highlights:

- Developed Python/Pandas ETL and validation workflows
- Built a **13-table dimensional warehouse** in Microsoft SQL Server
- Created advanced SQL analyses for operations, appointments, readmissions, and population health
- Performed hypothesis testing, regression, correlation, and root-cause analysis
- Built a **4-page Power BI dashboard**
- Documented data lineage, data classification, quality controls, and security best-practice principles
- Identified **15.48% vs 13.12% readmission rates** for incomplete vs completed required follow-up

[View Project](./healthcare-operations-population-health-analytics)

---

### 3. E-Commerce Customer & Revenue Analysis

**Tools:** SQL, Power BI, DAX, Data Modeling

Analyzed e-commerce sales, customer behavior, delivery performance, and revenue trends to build an interactive business intelligence dashboard.

Key KPIs:

- **Total Revenue:** $16M
- **Total Orders:** 99K
- **Total Customers:** 96K
- **Average Order Value:** $161
- **Average Review Score:** 4.09
- **Late Delivery Rate:** 7.87%

Highlights:

- Consolidated fragmented e-commerce data using SQL
- Developed business KPIs and analytical queries
- Built a multi-page Power BI dashboard
- Analyzed customer, revenue, order, and delivery performance

[View Project](./ecommerce-sql-powerbi-analysis)

---

### 4. HR Employee Attrition Analysis

**Tools:** Excel, PivotTables, PivotCharts, Power Query, Data Analysis

Analyzed employee attrition patterns across demographics, job roles, overtime, and workforce characteristics.

Key findings:

- **Employees:** 1,470
- **Overall Attrition Rate:** 16.12%
- **Overtime Attrition Rate:** 30.53%
- **Non-Overtime Attrition Rate:** 10.44%
- Higher-risk age group: **25–34**
- Higher-attrition roles included Laboratory Technician, Sales Executive, and Research Scientist

Highlights:

- Cleaned and analyzed HR workforce data in Excel
- Created KPI cards, PivotTables, PivotCharts, and slicers
- Identified workforce segments associated with higher attrition
- Developed an interactive HR analytics dashboard

[View Project](./HR-Employee-Attrition-Analysis-Excel)

---

## Core Skills Demonstrated

- SQL
- Microsoft SQL Server
- Snowflake
- Python
- Pandas
- Power BI
- Tableau
- DAX
- Excel
- Power Query
- dbt
- AWS S3
- AWS IAM
- ETL
- Data Cleaning
- Data Quality
- Data Modeling
- Dimensional Modeling
- Data Warehousing
- Cloud Analytics
- KPI Development
- Product Analytics
- Revenue Analytics
- Customer Analytics
- Statistical Analysis
- Hypothesis Testing
- A/B Testing
- Confidence Intervals
- Root-Cause Analysis
- Dashboard Development
- Business Intelligence
- Data Governance
- Git & GitHub

---

## Focus Areas

My projects demonstrate experience across:

**Business Problem → Requirements Gathering → Data Design → Data Preparation → Cloud Storage → Data Warehousing → ETL/dbt Transformation → SQL Analysis → Statistical Analysis → Experimentation → Dashboard Development → Business Insights**

The goal of this portfolio is to demonstrate practical, end-to-end analytical thinking rather than only individual technical exercises.

Across the portfolio, I have worked with analytics problems involving:

- SaaS product growth and experimentation
- Healthcare operations and population health
- E-commerce customer and revenue performance
- Employee attrition and workforce analytics
- User activation and onboarding funnels
- Retention and engagement analysis
- MRR, ARR, and subscription churn
- A/B testing and statistical significance
- Executive KPI reporting and business intelligence
