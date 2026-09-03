# Requirements Elicitation Notes

## Stakeholder

VP of Product

## Business Concern

NovaFlow is receiving a high number of user registrations, but many users do not continue using the product after signup.

The Product team needs better visibility into user activation, engagement, onboarding behavior, and retention.

---

## Stakeholder Interview Questions

### 1. Active vs Inactive Users

**Question**

Would you like the dashboard to show both active and inactive users, and how do you currently define an active user?

**Stakeholder Response**

Yes. The Product team wants to compare active and inactive users.

A user may be considered active when they perform at least one meaningful product action during a defined reporting period.

For new users, the analytics team should establish a more specific activation definition.

**Requirement Identified**

The dashboard must support comparison between active and inactive users.

A formal activation metric must also be created.

---

### 2. Important Product KPIs

**Question**

Which KPIs are most important for you to monitor, and which are the primary measures of product success?

**Stakeholder Response**

Important KPIs include:

- Activation Rate
- Onboarding Completion Rate
- DAU
- WAU
- MAU
- Feature Adoption Rate
- Day 7 Retention
- Day 30 Retention
- Customer Churn Rate

Activation Rate and Retention are the highest-priority metrics.

**Requirement Identified**

Activation and retention should receive prominent placement within the Product dashboard.

Supporting engagement metrics should provide additional diagnostic context.

---

### 3. Dashboard Usage

**Question**

How do you plan to use this dashboard in your day-to-day decision-making, and what actions do you expect to take from the insights?

**Stakeholder Response**

The dashboard will primarily be used during weekly Product review meetings.

The Product team wants to:

- Monitor activation and retention trends
- Identify onboarding drop-off
- Understand feature adoption
- Compare user segments
- Detect underperforming groups
- Prioritize areas requiring product improvements

**Requirement Identified**

The dashboard must support both high-level monitoring and deeper diagnostic analysis.

Trend visuals and segmentation capabilities are required.

---

### 4. User Segmentation

**Question**

Which user segments would you like to compare?

**Stakeholder Response**

The Product team wants to analyze users by:

- Subscription Plan
- Acquisition Channel
- Country
- Platform

The team is particularly interested in comparing Free, Pro, and Business users and identifying differences between Web and Mobile behavior.

**Requirement Identified**

These attributes must be available as analytical dimensions and dashboard filters.

---

### 5. Reporting Time Period

**Question**

What reporting time periods should the dashboard support?

**Stakeholder Response**

Weekly reporting is important for Product review meetings.

The team should also be able to analyze longer-term monthly trends and select custom reporting periods when required.

**Requirement Identified**

The analytical model must support:

- Daily analysis
- Weekly analysis
- Monthly analysis
- Custom date filtering

---

## Refined Product Requirements

Based on stakeholder elicitation, the Product Analytics solution must:

1. Distinguish active and inactive users.
2. Establish a formal user activation definition.
3. Prioritize Activation Rate and Retention.
4. Track DAU, WAU, MAU, onboarding completion, feature adoption, and churn.
5. Support weekly Product review meetings.
6. Highlight trends and significant performance changes.
7. Identify onboarding funnel drop-off.
8. Allow analysis by subscription plan, acquisition channel, country, and platform.
9. Support daily, weekly, and monthly analysis.
10. Enable Product teams to move from KPI monitoring into deeper diagnostic investigation.

---

## Initial Activation Definition

For this project, an Activated User will be defined as:

> A registered user who completes onboarding and creates their first project within 7 days of registration.

This definition will be validated during later data analysis and UAT stages.

---

## Requirements Traceability

| Requirement ID | Requirement | Stakeholder |
|---|---|---|
| PR-01 | Compare active and inactive users | VP Product |
| PR-02 | Calculate Activation Rate | VP Product |
| PR-03 | Monitor user retention | VP Product |
| PR-04 | Track DAU, WAU and MAU | VP Product |
| PR-05 | Analyze onboarding completion and drop-off | VP Product |
| PR-06 | Analyze feature adoption | VP Product |
| PR-07 | Analyze customer churn | VP Product |
| PR-08 | Filter by subscription plan | VP Product |
| PR-09 | Filter by acquisition channel | VP Product |
| PR-10 | Filter by country | VP Product |
| PR-11 | Filter by platform | VP Product |
| PR-12 | Support daily, weekly and monthly analysis | VP Product |