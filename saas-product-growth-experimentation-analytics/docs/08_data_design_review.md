# NovaFlow Final Data Design Review

## 1. Purpose

This review confirms the grain, key relationships, expected scale, and analytical purpose of each source table before synthetic raw data is generated.

---

## 2. Table Grain

"Grain" means what one row in a table represents.

| Table | One Row Represents |
|---|---|
| users | One registered NovaFlow user |
| organizations | One customer organization/workspace |
| plans | One subscription plan |
| subscriptions | One subscription period |
| payments | One payment transaction |
| sessions | One user session |
| features | One NovaFlow product feature |
| product_events | One user product interaction/event |
| onboarding_events | One user's interaction with one onboarding step |
| marketing_attribution | One marketing attribution record |
| support_tickets | One customer support ticket |
| experiments | One product experiment |
| experiment_assignments | One user's assignment to one experiment |

---

## 3. Expected Synthetic Data Scale

Approximate target volumes:

| Table | Approximate Rows |
|---|---:|
| users | 100,000 |
| organizations | 8,000 |
| plans | 3 |
| subscriptions | 70,000–100,000 |
| payments | 250,000–350,000 |
| sessions | 600,000–900,000 |
| features | 15–25 |
| product_events | 2,000,000+ |
| onboarding_events | 400,000–600,000 |
| marketing_attribution | ~100,000 |
| support_tickets | 30,000–50,000 |
| experiments | 3–5 |
| experiment_assignments | 40,000–80,000 |

Final row counts may vary based on the generated business behavior.

---

## 4. Core Relationship Review

Primary analytical path:

users
    ↓
sessions
    ↓
product_events

Revenue path:

users / organizations
    ↓
subscriptions
    ↓
payments

Onboarding path:

users
    ↓
onboarding_events

Marketing path:

users
    ↓
marketing_attribution

Customer Support path:

users
    ↓
support_tickets

Experiment path:

experiments
    ↓
experiment_assignments
    ↓
users

---

## 5. Important PII Fields

Sensitive fields include:

- first_name
- last_name
- email
- organization_name

These fields may exist in the raw layer but should not be unnecessarily exposed in analytical marts or executive dashboards.

---

## 6. Important Business Behaviors to Simulate

The synthetic dataset should contain realistic behavioral differences.

Examples:

- Some users never complete onboarding.
- Some users activate quickly.
- Some users rarely return after signup.
- Paid users generally engage more than inactive Free users.
- Some subscriptions cancel or expire.
- Some payment transactions fail or are refunded.
- Some acquisition channels produce better-quality users than others.
- Users with poor engagement may have higher churn.
- Support activity may vary across customer types.
- Control and Treatment experiment groups should have measurable but realistic differences.

These patterns should not be so extreme that analytical conclusions become obvious without analysis.

---

## 7. Intentional Raw Data Quality Issues

A small percentage of raw data will contain realistic issues such as:

- Missing fields
- Invalid categories
- Duplicate records
- Invalid email formats
- Timestamp inconsistencies
- Broken foreign keys
- Subscription inconsistencies

These problems will later be detected during profiling and handled through the ETL/dbt process.

---

## 8. Analytical Outcomes Supported

The data design must support calculation of:

### Acquisition
- Registrations
- Users by acquisition channel
- Activation by channel
- Paid conversion by channel

### Activation
- Onboarding completion
- Funnel drop-off
- Activation Rate
- Time to Activation

### Engagement
- DAU
- WAU
- MAU
- Stickiness
- Sessions per User
- Events per User
- Feature Adoption

### Retention
- Day 1 Retention
- Day 7 Retention
- Day 30 Retention
- Cohort Retention

### Revenue
- MRR
- ARR
- ARPU
- Revenue by Plan

### Churn
- Customer Churn
- Revenue Churn
- Churn by Plan
- Churn by Engagement

### Experimentation
- Control Conversion
- Treatment Conversion
- Absolute Lift
- Relative Lift
- Confidence Interval
- Statistical Significance

---

## 9. Design Review Decision

The NovaFlow raw data model is approved for synthetic data generation.

The next phase will generate the raw source datasets using Python while preserving the defined relationships, business rules, and intentional data-quality issues.