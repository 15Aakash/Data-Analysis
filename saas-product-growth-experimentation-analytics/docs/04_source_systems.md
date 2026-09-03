# NovaFlow Source Systems

## 1. Purpose

This document identifies the operational systems that generate the raw data used in the NovaFlow analytics platform.

---

## 2. Source Systems

### 2.1 User Management System

Stores information about registered users.

Main data:

- User ID
- Name
- Email
- Country
- Registration Date
- Platform
- Account Status

Expected raw table:

users

---

### 2.2 Organization / Workspace System

Stores information about customer organizations and workspaces.

Main data:

- Organization ID
- Organization Name
- Industry
- Company Size
- Country
- Created Date

Expected raw table:

organizations

---

### 2.3 Subscription Management System

Stores subscription details.

Main data:

- Subscription ID
- User / Organization ID
- Plan
- Start Date
- End Date
- Subscription Status
- Billing Cycle

Expected raw tables:

subscriptions
plans

---

### 2.4 Payment System

Stores payment transactions.

Main data:

- Payment ID
- Subscription ID
- Payment Date
- Amount
- Payment Status
- Currency

Expected raw table:

payments

---

### 2.5 Product Usage System

Captures how users interact with NovaFlow.

Main data:

- User ID
- Session ID
- Event
- Feature
- Timestamp
- Platform

Expected raw tables:

sessions
product_events
features

---

### 2.6 Onboarding System

Tracks user progress through onboarding.

Main data:

- User ID
- Onboarding Step
- Step Timestamp
- Completion Status

Expected raw table:

onboarding_events

---

### 2.7 Marketing System

Stores information about how users were acquired.

Main data:

- User ID
- Marketing Channel
- Campaign
- Source
- Medium

Expected raw table:

marketing_attribution

---

### 2.8 Customer Support System

Stores customer support interactions.

Main data:

- Ticket ID
- User ID
- Ticket Category
- Priority
- Created Date
- Resolved Date
- Ticket Status

Expected raw table:

support_tickets

---

### 2.9 Experimentation Platform

Stores A/B testing information.

Main data:

- Experiment ID
- Experiment Name
- Start Date
- End Date
- Experiment Status

Expected raw tables:

experiments
experiment_assignments