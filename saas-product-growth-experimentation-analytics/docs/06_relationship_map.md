# NovaFlow PK/FK Relationship Map

## 1. Purpose

This document describes the relationships between NovaFlow raw source tables.

The goal is to clearly identify Primary Keys, Foreign Keys, and one-to-many relationships before generating data.

---

# 2. Main Relationships

## Organizations to Users

organizations.organization_id
        ↓
users.organization_id

Relationship:

One organization can have many users.

organizations (1) → users (many)

---

## Users to Subscriptions

users.user_id
        ↓
subscriptions.user_id

Relationship:

One user can have multiple subscriptions over time.

users (1) → subscriptions (many)

---

## Organizations to Subscriptions

organizations.organization_id
        ↓
subscriptions.organization_id

Relationship:

One organization can have multiple subscriptions over time.

organizations (1) → subscriptions (many)

---

## Plans to Subscriptions

plans.plan_id
        ↓
subscriptions.plan_id

Relationship:

One plan can be used by many subscriptions.

plans (1) → subscriptions (many)

---

## Subscriptions to Payments

subscriptions.subscription_id
        ↓
payments.subscription_id

Relationship:

One subscription can have many payment transactions.

subscriptions (1) → payments (many)

---

## Users to Sessions

users.user_id
        ↓
sessions.user_id

Relationship:

One user can have many product sessions.

users (1) → sessions (many)

---

## Sessions to Product Events

sessions.session_id
        ↓
product_events.session_id

Relationship:

One session can contain many product events.

sessions (1) → product_events (many)

---

## Users to Product Events

users.user_id
        ↓
product_events.user_id

Relationship:

One user can generate many product events.

users (1) → product_events (many)

---

## Features to Product Events

features.feature_id
        ↓
product_events.feature_id

Relationship:

One feature can appear in many product events.

features (1) → product_events (many)

---

## Users to Onboarding Events

users.user_id
        ↓
onboarding_events.user_id

Relationship:

One user can have many onboarding events.

users (1) → onboarding_events (many)

---

## Users to Marketing Attribution

users.user_id
        ↓
marketing_attribution.user_id

Relationship:

One user may have one or multiple attribution records.

users (1) → marketing_attribution (many)

---

## Users to Support Tickets

users.user_id
        ↓
support_tickets.user_id

Relationship:

One user can create many support tickets.

users (1) → support_tickets (many)

---

## Experiments to Experiment Assignments

experiments.experiment_id
        ↓
experiment_assignments.experiment_id

Relationship:

One experiment can contain many assigned users.

experiments (1) → experiment_assignments (many)

---

## Users to Experiment Assignments

users.user_id
        ↓
experiment_assignments.user_id

Relationship:

One user can participate in multiple experiments.

users (1) → experiment_assignments (many)

---

# 3. Simplified Relationship Diagram

organizations
    |
    | 1
    |
    | many
   users
    |
    |-----------------------------------------
    |           |           |                |
    ↓           ↓           ↓                ↓
sessions   subscriptions onboarding_events support_tickets
    |           |
    ↓           ↓
product_events payments
    ↑
    |
features

users
  |
  ├── marketing_attribution
  |
  └── experiment_assignments
                ↑
                |
            experiments

plans
  |
  ↓
subscriptions