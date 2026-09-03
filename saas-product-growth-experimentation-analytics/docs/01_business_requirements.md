# NovaFlow SaaS Product Growth & Experimentation Analytics Platform

## 1. Business Overview

NovaFlow is a fictional SaaS productivity and work-management platform offering Free, Pro, and Business subscription plans.

The company collects data across customer registrations, onboarding, product usage, subscriptions, payments, marketing acquisition, customer support, and product experiments.

Although NovaFlow is experiencing user growth, leadership lacks a centralized analytics platform for understanding user activation, engagement, retention, churn, recurring revenue, and product experimentation.

The purpose of this project is to design and implement an end-to-end analytics platform that transforms raw SaaS operational data into trusted business insights.

---

## 2. Business Problem

NovaFlow currently faces several analytical challenges:

* A large number of registered users do not become active users.
* Leadership does not have clear visibility into where users drop out during onboarding.
* Product teams cannot easily determine which features are associated with stronger engagement and retention.
* Marketing teams need to understand which acquisition channels generate high-quality users.
* Finance needs reliable reporting for recurring subscription revenue.
* Customer Success needs visibility into customer churn patterns.
* Product managers need a statistically valid method for evaluating A/B experiments.
* Business metrics are not currently governed through consistent definitions and documented data lineage.

---

## 3. Project Objective

Build an end-to-end cloud-based SaaS analytics platform that enables NovaFlow stakeholders to analyze:

* Customer acquisition
* User activation
* Product engagement
* Feature adoption
* Customer retention
* Subscription churn
* Recurring revenue
* Product experiments

The solution will integrate Azure cloud storage, Snowflake, dbt, SQL, Python, Power BI, data quality controls, governance, security, UAT, and analytics documentation.

---

## 4. Stakeholders

### Chief Executive Officer

Primary interests:

* User growth
* Paid customer growth
* Monthly recurring revenue
* Annual recurring revenue
* Customer churn
* Overall company performance

### VP of Product

Primary interests:

* Activation
* User engagement
* Product retention
* Feature adoption
* Product usage trends

### Product Manager

Primary interests:

* Onboarding funnel performance
* Feature performance
* Product experiments
* A/B testing
* Conversion improvements

### Marketing Manager

Primary interests:

* Acquisition channels
* Registration volume
* Activation by marketing source
* Paid conversion
* Channel quality

### Finance Manager

Primary interests:

* Monthly recurring revenue
* Annual recurring revenue
* Average revenue per user
* Revenue by subscription plan
* New, expansion, and churned revenue

### Customer Success Manager

Primary interests:

* Customer churn
* Usage behavior before cancellation
* Support activity
* Customers with low product engagement

### Data Team

Primary interests:

* Data quality
* Data models
* Metadata
* Data lineage
* Testing
* Documentation

### Security Administrator

Primary interests:

* PII protection
* Access control
* Least-privilege access
* Sensitive-data governance

---

## 5. Key Business Questions

### Acquisition

1. How many new users are registering?
2. Which acquisition channels generate the most users?
3. Which channels generate the highest activation rates?
4. Which channels generate the highest paid conversion rates?
5. Do users acquired from certain channels retain better than others?

### Activation

1. What percentage of users successfully complete onboarding?
2. Where are users dropping out during onboarding?
3. What percentage of registered users become activated?
4. How long does it take users to reach activation?

### Engagement

1. How many users are active daily, weekly, and monthly?
2. How frequently do users interact with NovaFlow?
3. Which product features are used most frequently?
4. What percentage of active users adopt each feature?
5. Which features appear to be associated with stronger engagement?

### Retention

1. What percentage of users return after 1, 7, and 30 days?
2. How does retention differ between signup cohorts?
3. Which customer segments have the strongest retention?
4. How does retention differ by subscription plan or acquisition channel?

### Churn

1. What is the customer churn rate?
2. Which subscription plans experience the highest churn?
3. Do low-engagement customers churn more frequently?
4. Is support activity associated with churn?
5. Which acquisition channels generate customers with higher churn?

### Revenue

1. What is NovaFlow's Monthly Recurring Revenue?
2. What is its Annual Recurring Revenue?
3. What is Average Revenue Per User?
4. Which subscription plans generate the most recurring revenue?
5. How much MRR is gained, expanded, contracted, or lost?

### Experimentation

1. Does the redesigned onboarding experience improve activation?
2. What is the difference between control and treatment conversion rates?
3. Is the observed improvement statistically significant?
4. What is the confidence interval around the experiment lift?
5. Should NovaFlow roll out the new onboarding experience?

---

## 6. KPI Definitions

| KPI                   | Business Definition                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------ |
| Registered Users      | Distinct users who successfully created an account                                         |
| Activated Users       | Users who complete onboarding and create their first project within 7 days of registration |
| Activation Rate       | Activated Users / Registered Users                                                         |
| DAU                   | Distinct users performing qualifying activity during a calendar day                        |
| WAU                   | Distinct active users during the trailing 7-day period                                     |
| MAU                   | Distinct active users during the trailing 30-day period                                    |
| Stickiness            | DAU / MAU                                                                                  |
| Feature Adoption Rate | Active users using a feature / eligible active users                                       |
| Day 1 Retention       | Eligible users returning one day after registration / eligible registration cohort         |
| Day 7 Retention       | Eligible users returning seven days after registration / eligible registration cohort      |
| Day 30 Retention      | Eligible users returning thirty days after registration / eligible registration cohort     |
| Paid Conversion Rate  | Users becoming paid customers / registered users                                           |
| MRR                   | Monthly recurring subscription revenue                                                     |
| ARR                   | MRR × 12                                                                                   |
| ARPU                  | Recurring revenue / paying users                                                           |
| Customer Churn Rate   | Paying customers lost during period / customers at start of period                         |
| Revenue Churn Rate    | Recurring revenue lost during period / recurring revenue at start of period                |

---

## 7. Functional Requirements

* FR-01: The platform must provide an executive overview of major SaaS KPIs.
* FR-02: Users must be able to analyze registrations by acquisition channel.
* FR-03: Users must be able to analyze onboarding funnel conversion and drop-off.
* FR-04: The system must calculate user activation.
* FR-05: The system must calculate DAU, WAU, and MAU.
* FR-06: Users must be able to analyze product-feature adoption.
* FR-07: The platform must support cohort-based retention analysis.
* FR-08: Users must be able to analyze subscription churn.
* FR-09: The system must calculate recurring-revenue KPIs.
* FR-10: Users must be able to compare subscription-plan performance.
* FR-11: The platform must support A/B experiment analysis.
* FR-12: Power BI reports must support appropriate filters including date, plan, country, platform, and acquisition channel.
* FR-13: Sensitive customer information must be protected from unauthorized reporting access.
* FR-14: Source and transformed data must be validated using documented data-quality rules.
* FR-15: Important business metrics must have documented definitions and lineage.

---

## 8. Non-Functional Requirements

### Performance

Analytical models and dashboards should support efficient interactive analysis.

### Data Quality

Critical data should be evaluated for:

* Completeness
* Accuracy
* Validity
* Consistency
* Uniqueness
* Referential integrity

### Security

Personally identifiable information should only be available to authorized users and should not be unnecessarily exposed in reporting models.

### Scalability

The data model should be capable of handling large product-event datasets containing millions of events.

### Maintainability

Transformation logic should be modular, documented, reusable, and testable.

### Auditability

Important metrics should be traceable from dashboard output to analytics marts, transformation models, raw Snowflake tables, and original source data.

---

## 9. Acceptance Criteria

* AC-01: Registered-user totals in Power BI must reconcile with the corresponding Snowflake analytics model.
* AC-02: Every subscription must reference a valid customer.
* AC-03: Activation Rate must equal Activated Users divided by Registered Users according to the approved KPI definition.
* AC-04: A user cannot belong to both control and treatment groups for the same experiment.
* AC-05: MRR in Power BI must reconcile with the Snowflake revenue mart.
* AC-06: Executive reports must not expose unnecessary PII.
* AC-07: Primary keys in analytical dimension tables must meet uniqueness requirements.
* AC-08: Required foreign-key relationships must pass referential-integrity validation.
* AC-09: dbt tests must validate critical assumptions for production analytics models.
* AC-10: Experiment results must include control performance, treatment performance, lift, confidence interval, statistical significance, and a business recommendation.

---

## 10. Project Scope

### In Scope

* SaaS customer analytics
* Acquisition analytics
* Product onboarding
* Activation
* Engagement
* Feature adoption
* Retention
* Cohort analysis
* Subscription analytics
* Churn
* Recurring revenue
* A/B testing
* Azure Blob Storage
* Snowflake
* dbt
* SQL
* Python
* Power BI
* Data quality
* Metadata
* Data lineage
* Data governance
* Role-based security concepts
* UAT
* Agile project documentation

### Out of Scope

* Machine-learning churn prediction
* Recommendation systems
* Deep learning
* Real-time streaming
* Production web application development
* Complex Spark pipelines

---

## 11. Expected Solution Architecture

Raw SaaS Source Data
→ Azure Blob Storage
→ Snowflake Raw Layer
→ dbt Staging Models
→ dbt Intermediate Models
→ dbt Analytics Marts
→ SQL / Python Analysis
→ Power BI Dashboards

Supporting processes will include data-quality testing, metadata documentation, lineage, governance, security controls, UAT, and Agile project management.

---

## 12. Expected Business Outcome

The completed platform should provide NovaFlow stakeholders with a consistent and governed view of the customer lifecycle from acquisition through activation, engagement, retention, monetization, and churn.

The project should also demonstrate how controlled experimentation can be used to support evidence-based product decisions.
