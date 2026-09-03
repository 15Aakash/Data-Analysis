# NovaFlow Raw Table Design

## Purpose

This document defines the structure of the raw source tables used in the NovaFlow analytics platform.

The raw layer represents data as it may arrive from operational source systems before cleaning and transformation.

---

# 1. users

Stores registered NovaFlow users.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| user_id | VARCHAR | PK | No | No | Unique identifier for each user |
| organization_id | VARCHAR | FK | Yes | No | Organization associated with user |
| first_name | VARCHAR | | No | Yes | User first name |
| last_name | VARCHAR | | No | Yes | User last name |
| email | VARCHAR | | No | Yes | User email address |
| country | VARCHAR | | Yes | No | User country |
| registration_timestamp | TIMESTAMP | | No | No | Date and time account was created |
| signup_platform | VARCHAR | | No | No | Web, iOS, or Android |
| account_status | VARCHAR | | No | No | Active, Suspended, or Deleted |
| acquisition_channel | VARCHAR | | Yes | No | Primary acquisition source |

---

# 2. organizations

Stores customer organization/workspace information.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| organization_id | VARCHAR | PK | No | No | Unique organization identifier |
| organization_name | VARCHAR | | No | Yes | Organization name |
| industry | VARCHAR | | Yes | No | Industry classification |
| company_size | VARCHAR | | Yes | No | Small, Medium, Enterprise |
| country | VARCHAR | | Yes | No | Organization country |
| created_timestamp | TIMESTAMP | | No | No | Workspace creation timestamp |
| organization_status | VARCHAR | | No | No | Active, Suspended, Closed |

---

# 3. plans

Stores NovaFlow subscription plan definitions.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| plan_id | VARCHAR | PK | No | No | Unique plan identifier |
| plan_name | VARCHAR | | No | No | Free, Pro, or Business |
| monthly_price | DECIMAL(10,2) | | No | No | Monthly subscription price |
| annual_price | DECIMAL(10,2) | | No | No | Annual subscription price |
| max_users | INTEGER | | Yes | No | Maximum supported users |
| storage_limit_gb | INTEGER | | Yes | No | Storage included with plan |
| plan_status | VARCHAR | | No | No | Active or Retired |

# 4. subscriptions

Stores the subscription history of NovaFlow users or organizations.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| subscription_id | VARCHAR | PK | No | No | Unique subscription identifier |
| user_id | VARCHAR | FK | Yes | No | User associated with subscription |
| organization_id | VARCHAR | FK | Yes | No | Organization associated with subscription |
| plan_id | VARCHAR | FK | No | No | Subscription plan |
| subscription_start_date | DATE | | No | No | Subscription start date |
| subscription_end_date | DATE | | Yes | No | Subscription end or cancellation date |
| billing_cycle | VARCHAR | | No | No | Monthly or Annual |
| subscription_status | VARCHAR | | No | No | Active, Cancelled, Expired, Trial |
| auto_renew_flag | BOOLEAN | | No | No | Indicates whether subscription automatically renews |
| cancellation_reason | VARCHAR | | Yes | No | Reason provided for cancellation |

---

# 5. payments

Stores NovaFlow payment transactions.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| payment_id | VARCHAR | PK | No | No | Unique payment transaction identifier |
| subscription_id | VARCHAR | FK | No | No | Subscription associated with payment |
| payment_timestamp | TIMESTAMP | | No | No | Date and time payment occurred |
| amount | DECIMAL(10,2) | | No | No | Amount charged |
| currency | VARCHAR | | No | No | Transaction currency |
| payment_status | VARCHAR | | No | No | Successful, Failed, Refunded |
| payment_method_type | VARCHAR | | Yes | No | Card, PayPal, Bank Transfer |
| invoice_id | VARCHAR | | Yes | No | Associated billing invoice |

# 6. sessions

Stores each user session in NovaFlow.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| session_id | VARCHAR | PK | No | No | Unique session identifier |
| user_id | VARCHAR | FK | No | No | User associated with session |
| session_start_timestamp | TIMESTAMP | | No | No | Session start time |
| session_end_timestamp | TIMESTAMP | | Yes | No | Session end time |
| platform | VARCHAR | | No | No | Web, iOS, or Android |
| device_type | VARCHAR | | Yes | No | Desktop, Mobile, Tablet |
| session_status | VARCHAR | | No | No | Completed or Abandoned |

---

# 7. features

Stores NovaFlow product feature definitions.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| feature_id | VARCHAR | PK | No | No | Unique feature identifier |
| feature_name | VARCHAR | | No | No | Name of product feature |
| feature_category | VARCHAR | | No | No | Collaboration, Automation, Reporting, etc. |
| minimum_plan | VARCHAR | | Yes | No | Lowest subscription plan eligible for feature |
| feature_status | VARCHAR | | No | No | Active, Beta, Retired |
| launch_date | DATE | | Yes | No | Date feature became available |

---

# 8. product_events

Stores individual user interactions with NovaFlow.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| event_id | VARCHAR | PK | No | No | Unique product event identifier |
| user_id | VARCHAR | FK | No | No | User generating the event |
| session_id | VARCHAR | FK | No | No | Session in which event occurred |
| feature_id | VARCHAR | FK | Yes | No | Feature associated with event |
| event_name | VARCHAR | | No | No | Type of user action |
| event_timestamp | TIMESTAMP | | No | No | Time event occurred |
| platform | VARCHAR | | No | No | Web, iOS, Android |
| event_value | VARCHAR | | Yes | No | Optional event-related value |

# 9. onboarding_events

Stores user progress through the NovaFlow onboarding process.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| onboarding_event_id | VARCHAR | PK | No | No | Unique onboarding event identifier |
| user_id | VARCHAR | FK | No | No | User associated with onboarding event |
| onboarding_step | VARCHAR | | No | No | Name of onboarding step |
| step_order | INTEGER | | No | No | Sequence number of onboarding step |
| event_timestamp | TIMESTAMP | | No | No | Time the onboarding event occurred |
| completion_status | VARCHAR | | No | No | Started, Completed, Skipped, Abandoned |
| time_spent_seconds | INTEGER | | Yes | No | Time spent on onboarding step |

---

# 10. marketing_attribution

Stores marketing source information associated with user acquisition.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| attribution_id | VARCHAR | PK | No | No | Unique attribution record identifier |
| user_id | VARCHAR | FK | No | No | User associated with acquisition record |
| acquisition_channel | VARCHAR | | No | No | Organic, Paid Search, Social, Referral, Partner, etc. |
| source | VARCHAR | | Yes | No | Specific traffic source |
| medium | VARCHAR | | Yes | No | Marketing medium |
| campaign_name | VARCHAR | | Yes | No | Campaign associated with signup |
| campaign_id | VARCHAR | | Yes | No | Campaign identifier |
| attributed_timestamp | TIMESTAMP | | No | No | Time attribution was recorded |
| landing_page | VARCHAR | | Yes | No | Initial landing page |

# 11. support_tickets

Stores customer support interactions.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| ticket_id | VARCHAR | PK | No | No | Unique support ticket identifier |
| user_id | VARCHAR | FK | No | No | User associated with ticket |
| ticket_category | VARCHAR | | No | No | Billing, Product Issue, Account, Feature Request, etc. |
| priority | VARCHAR | | No | No | Low, Medium, High, Critical |
| created_timestamp | TIMESTAMP | | No | No | Time ticket was created |
| resolved_timestamp | TIMESTAMP | | Yes | No | Time ticket was resolved |
| ticket_status | VARCHAR | | No | No | Open, In Progress, Resolved, Closed |
| satisfaction_score | INTEGER | | Yes | No | Customer satisfaction score |
| resolution_time_hours | DECIMAL(10,2) | | Yes | No | Time taken to resolve ticket |

---

# 12. experiments

Stores product experiment definitions.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| experiment_id | VARCHAR | PK | No | No | Unique experiment identifier |
| experiment_name | VARCHAR | | No | No | Name of experiment |
| experiment_description | VARCHAR | | Yes | No | Business purpose of experiment |
| primary_metric | VARCHAR | | No | No | Main KPI used to evaluate experiment |
| start_date | DATE | | No | No | Experiment start date |
| end_date | DATE | | Yes | No | Experiment end date |
| experiment_status | VARCHAR | | No | No | Planned, Running, Completed, Cancelled |

---

# 13. experiment_assignments

Stores user assignment to experiment groups.

| Column | Data Type | Key | Nullable | PII | Description |
|---|---|---|---|---|---|
| assignment_id | VARCHAR | PK | No | No | Unique experiment assignment |
| experiment_id | VARCHAR | FK | No | No | Experiment assigned to user |
| user_id | VARCHAR | FK | No | No | User participating in experiment |
| experiment_group | VARCHAR | | No | No | Control or Treatment |
| assigned_timestamp | TIMESTAMP | | No | No | Time user entered experiment |
| exposure_timestamp | TIMESTAMP | | Yes | No | Time user first experienced experiment |