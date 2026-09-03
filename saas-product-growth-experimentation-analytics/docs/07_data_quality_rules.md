# NovaFlow Data Quality and Business Rules

## 1. Purpose

This document defines the data quality expectations and important business rules for NovaFlow source data.

These rules will later be used during:

- Data profiling
- Data cleaning
- dbt testing
- UAT
- Data governance

---

# 2. Data Quality Dimensions

NovaFlow data will be evaluated using the following dimensions.

## Completeness

Required fields should not be missing.

Example:

user_id cannot be NULL.

---

## Uniqueness

Primary keys must uniquely identify records.

Example:

Two users cannot have the same user_id.

---

## Validity

Values must follow approved formats or allowed values.

Example:

signup_platform must be:

- Web
- iOS
- Android

---

## Consistency

Related values should not contradict each other.

Example:

A cancelled subscription should normally have a subscription end date.

---

## Referential Integrity

Foreign keys should point to valid parent records.

Example:

sessions.user_id must exist in users.user_id.

---

# 3. General Rules

## DQ-01

Every primary key must be unique.

Applies to:

- user_id
- organization_id
- plan_id
- subscription_id
- payment_id
- session_id
- feature_id
- event_id
- onboarding_event_id
- attribution_id
- ticket_id
- experiment_id
- assignment_id

---

## DQ-02

Required primary keys cannot be NULL.

---

## DQ-03

Foreign keys must reference valid parent records unless explicitly allowed to be NULL.

---

# 4. Users Rules

## DQ-04

email must contain a valid email-like format.

Example valid:

user@example.com

Example invalid:

userexample.com

---

## DQ-05

signup_platform must be one of:

- Web
- iOS
- Android

---

## DQ-06

account_status must be one of:

- Active
- Suspended
- Deleted

---

## DQ-07

registration_timestamp cannot occur in the future.

---

## DQ-08

organization_id may be NULL for individual users.

If populated, the organization must exist in the organizations table.

---

# 5. Organization Rules

## DQ-09

organization_status must be one of:

- Active
- Suspended
- Closed

---

## DQ-10

company_size should be one of:

- Small
- Medium
- Enterprise

---

# 6. Plan Rules

## DQ-11

plan_name must be one of:

- Free
- Pro
- Business

---

## DQ-12

monthly_price and annual_price cannot be negative.

---

## DQ-13

plan_status must be:

- Active
- Retired

---

# 7. Subscription Rules

## DQ-14

Every subscription must reference a valid plan.

---

## DQ-15

A subscription should belong to either:

- an individual user

OR

- an organization

but not both simultaneously.

---

## DQ-16

subscription_end_date cannot be earlier than subscription_start_date.

---

## DQ-17

billing_cycle must be:

- Monthly
- Annual

---

## DQ-18

subscription_status must be one of:

- Active
- Cancelled
- Expired
- Trial

---

## DQ-19

A cancelled or expired subscription should normally have an end date.

---

# 8. Payment Rules

## DQ-20

Every payment must reference a valid subscription.

---

## DQ-21

Payment amount cannot be negative.

Refunds should be represented using payment_status rather than invalid negative transaction amounts.

---

## DQ-22

payment_status must be:

- Successful
- Failed
- Refunded

---

## DQ-23

For this project, currency will primarily be USD.

---

# 9. Session Rules

## DQ-24

Every session must reference a valid user.

---

## DQ-25

session_end_timestamp cannot occur before session_start_timestamp.

---

## DQ-26

platform must be:

- Web
- iOS
- Android

---

# 10. Product Event Rules

## DQ-27

Every product event must reference a valid user and session.

---

## DQ-28

If feature_id is populated, it must exist in the features table.

---

## DQ-29

event_timestamp should occur within the associated user session.

---

# 11. Onboarding Rules

## DQ-30

Every onboarding event must reference a valid user.

---

## DQ-31

step_order must be a positive integer.

---

## DQ-32

completion_status must be one of:

- Started
- Completed
- Skipped
- Abandoned

---

## DQ-33

time_spent_seconds cannot be negative.

---

# 12. Marketing Attribution Rules

## DQ-34

Every marketing attribution record must reference a valid user.

---

## DQ-35

Approved acquisition channels include:

- Organic Search
- Paid Search
- Social
- Referral
- Partner
- Direct
- Email

---

# 13. Support Ticket Rules

## DQ-36

Every support ticket must reference a valid user.

---

## DQ-37

priority must be:

- Low
- Medium
- High
- Critical

---

## DQ-38

resolved_timestamp cannot occur before created_timestamp.

---

## DQ-39

satisfaction_score must be between 1 and 5 when populated.

---

## DQ-40

resolution_time_hours cannot be negative.

---

# 14. Experiment Rules

## DQ-41

experiment end date cannot occur before experiment start date.

---

## DQ-42

experiment_status must be:

- Planned
- Running
- Completed
- Cancelled

---

# 15. Experiment Assignment Rules

## DQ-43

Every assignment must reference a valid user and experiment.

---

## DQ-44

experiment_group must be:

- Control
- Treatment

---

## DQ-45

A user may only have one assignment per experiment.

The combination of:

experiment_id + user_id

must therefore be unique.

---

## DQ-46

A user cannot appear in both Control and Treatment for the same experiment.

---

# 16. Important Business Rules

## BR-01 — Activated User

A user is considered activated when the user:

1. Completes onboarding
2. Creates their first project
3. Does so within 7 days of registration

---

## BR-02 — Active User

An active user is a user who performs at least one qualifying product activity during the selected reporting period.

---

## BR-03 — Paid User

A paid user has an active Pro or Business subscription.

---

## BR-04 — Customer Churn

A customer is considered churned when a paid subscription is cancelled or expires without renewal.

---

## BR-05 — Experiment Eligibility

Only users who meet the experiment eligibility criteria and enter during the experiment period should be included in the A/B test analysis.

---

# 17. Synthetic Raw Data Strategy

The generated raw datasets will intentionally contain a small number of realistic data quality problems.

Examples may include:

- Missing values
- Duplicate records
- Invalid categories
- Broken foreign keys
- Incorrect timestamps
- Invalid email formats
- Inconsistent subscription records

These issues are intentional so that the project can demonstrate realistic:

- Data profiling
- Data quality assessment
- ETL cleaning
- Validation
- dbt testing

The cleaned analytics layer must resolve or appropriately handle these issues before reporting.