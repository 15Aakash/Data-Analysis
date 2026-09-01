# Business Requirements Document

## Healthcare Operations & Population Health Analytics Platform

### Organization

RiverCare Health System

### 1. Background

RiverCare Health System operates hospitals, outpatient clinics, emergency departments, and specialty-care services across multiple facilities.

Patient, encounter, appointment, provider, diagnosis, payer, laboratory, admission, and operational information currently exists across multiple source systems. Reporting teams use different extraction processes and KPI definitions, resulting in inconsistent management reporting.

Leadership has also observed increasing readmissions, long patient wait times, appointment no-shows, inconsistent utilization across departments, and increasing encounter costs.

RiverCare Health System requires a centralized analytics platform that integrates healthcare operational data and provides standardized reporting for patient outcomes, hospital operations, utilization, financial performance, and population-health trends.

---

## 2. Business Objective

The objective of the Healthcare Operations & Population Health Analytics Platform is to create a trusted analytical environment that allows leadership and operational teams to:

* Monitor patient outcomes.
* Measure hospital and departmental efficiency.
* Evaluate patient utilization patterns.
* Monitor appointment accessibility and no-show behavior.
* Analyze chronic-disease populations.
* Evaluate encounter costs and payer mix.
* Identify drivers of readmissions and operational inefficiencies.
* Standardize organizational KPI definitions.
* Improve data quality and reporting consistency.
* Support evidence-based operational decision-making.

---

## 3. Stakeholders

### Executive Leadership

Requires an enterprise view of patient volume, readmissions, operational efficiency, costs, and population-health performance.

### Hospital Operations

Requires visibility into wait times, emergency-department utilization, length of stay, patient flow, and departmental workload.

### Clinical Leadership

Requires visibility into diagnoses, readmissions, patient outcomes, follow-up performance, and utilization patterns.

### Population Health Team

Requires visibility into chronic disease prevalence, high-utilization populations, follow-up care, and demographic trends.

### Department Managers

Require department-level visibility into patient volume, wait times, utilization, length of stay, and outcomes.

### Scheduling Team

Requires visibility into appointment completion, cancellation, rescheduling, booking lead times, and no-show rates.

### Finance

Requires standardized cost-per-encounter analysis and payer-mix reporting.

### Data & Business Intelligence Team

Responsible for data integration, data modeling, KPI development, data-quality validation, analytical reporting, and testing.

### Data Governance Team

Responsible for data definitions, ownership, quality standards, access considerations, metadata, lineage, and privacy-aware analytical practices.

---

## 4. Key Business Questions

The analytics platform should support analysis of the following questions:

1. What is the organization's 30-day readmission rate?

2. Which diagnoses are associated with the highest readmission rates?

3. Which departments experience unusually high readmissions?

4. How does readmission performance vary by patient population?

5. Are patients completing recommended post-discharge follow-up care?

6. What is the average inpatient length of stay?

7. Which departments experience the longest average length of stay?

8. What is the average patient wait time?

9. Which departments and time periods experience the longest wait times?

10. What is emergency-department utilization over time?

11. Which populations have high emergency-department utilization?

12. What is the appointment no-show rate?

13. Which departments experience the highest no-show rates?

14. Does appointment booking lead time differ between completed and missed appointments?

15. What is patient volume by facility, department, provider, and encounter type?

16. What diagnoses account for the greatest number of encounters?

17. What is the prevalence of selected chronic conditions?

18. Which chronic-condition populations experience high readmission or ED utilization?

19. What is average encounter cost?

20. Which departments and encounter types have higher average costs?

21. What is the organization's payer mix?

22. How have major operational and outcome KPIs changed over time?

---

## 5. Key Performance Indicators

### Patient Outcome KPIs

* 30-Day Readmission Rate
* Average Length of Stay
* Follow-Up Rate
* Chronic Disease Prevalence

### Operational KPIs

* Patient Volume
* Total Encounters
* Average Wait Time
* Emergency Department Utilization
* Department Utilization
* Provider Utilization

### Appointment KPIs

* Appointment No-Show Rate
* Appointment Completion Rate
* Appointment Cancellation Rate
* Average Booking Lead Time

### Financial KPIs

* Total Encounter Cost
* Average Cost per Encounter
* Cost by Department
* Cost by Encounter Type
* Payer Mix

### Population Health KPIs

* Diabetes Prevalence
* Hypertension Prevalence
* COPD Prevalence
* High ED Utilization Rate
* Readmission by Chronic Condition
* Follow-Up by Chronic Condition
* Utilization by Age Group

---

## 6. Project Scope

### In Scope

The project will analyze synthetic healthcare data covering:

* Patients
* Encounters
* Diagnoses
* Procedures
* Providers
* Departments
* Admissions and discharges
* Readmissions
* Appointments
* Insurance/payer information
* Selected laboratory results
* Calendar/date information

The project will include:

* Business requirements documentation
* Data profiling
* Data-quality assessment
* Data cleansing
* ETL/ELT
* Staging-table development
* Dimensional data modeling
* Healthcare analytical warehouse design
* Advanced SQL analysis
* Statistical analysis using Python
* Power BI semantic modeling
* DAX calculations
* Dashboard development
* Root-cause analysis
* User Acceptance Testing
* Data dictionary
* KPI definitions
* Data lineage
* Data governance documentation
* Privacy-aware data-handling documentation
* Business recommendations

---

## 7. Out of Scope

The initial project will not include:

* Real patient-identifiable data
* Clinical decision support
* Medical diagnosis or treatment recommendations
* Real-time hospital monitoring
* Claims adjudication
* Predictive clinical risk scoring
* Production EHR integration
* Automated medical intervention
* Machine-learning diagnosis models

---

## 8. Data Requirements

The analytical platform will use datasets representing:

Patients
Encounters
Diagnoses
Encounter Diagnoses
Procedures
Providers
Departments
Admissions
Appointments
Payers
Laboratory Results
Date/Calendar

Primary business identifiers may include:

PatientID
EncounterID
AdmissionID
ProviderID
DepartmentID
DiagnosisID
ProcedureID
AppointmentID
PayerID

These identifiers will be validated during the data-quality and ETL processes.

---

## 9. Data Quality Requirements

Source data must be assessed for:

* Missing values
* Duplicate records
* Duplicate business identifiers
* Invalid data types
* Invalid dates
* Impossible date sequences
* Referential-integrity failures
* Invalid department references
* Invalid provider references
* Missing payer information
* Invalid encounter statuses
* Impossible wait times
* Negative costs
* Inconsistent categories
* Extreme outliers
* Invalid laboratory measurements

Detected issues must be documented with:

Issue
Affected Records
Severity
Business Impact
Remediation
Validation Result

---

## 10. Functional Requirements

Users should be able to:

* View organizational KPIs.
* Filter results by date.
* Filter by facility and department.
* Filter by provider.
* Filter by encounter type.
* Filter by diagnosis.
* Filter by payer.
* Filter by patient demographic group.
* Compare KPIs across time periods.
* Investigate high and low performers.
* Drill from enterprise performance into departments and patient populations.
* Investigate drivers of readmissions, wait times, utilization, and no-shows.

---

## 11. Dashboard Requirements

### Page 1 — Executive Overview

Should display:

* Patient Volume
* Total Encounters
* 30-Day Readmission Rate
* Average Length of Stay
* Average Wait Time
* Appointment No-Show Rate
* Average Cost per Encounter
* Follow-Up Rate
* KPI trends
* Encounter mix
* Department performance
* Payer mix

### Page 2 — Healthcare Operations

Should provide analysis of:

* Patient volume
* ED utilization
* Average wait time
* Length of stay
* Department utilization
* Provider utilization
* Appointment performance

### Page 3 — Population Health

Should provide analysis of:

* Chronic disease prevalence
* Demographic utilization
* ED utilization
* Readmission by condition
* Follow-up performance
* Payer-related utilization patterns

### Page 4 — Root-Cause Analysis

Should support investigation across dimensions such as:

Facility → Department → Diagnosis → Patient Population → Provider

The page should enable analysts to identify specific contributors to poor performance rather than displaying only aggregated KPIs.

---

## 12. Non-Functional Requirements

The solution should:

* Use standardized KPI definitions.
* Maintain clearly defined fact-table grain.
* Maintain validated dimension relationships.
* Support reproducible transformations.
* Document data lineage.
* Protect against unnecessary exposure of patient-level attributes.
* Provide understandable dashboard navigation.
* Support validation against source and warehouse data.
* Maintain acceptable analytical performance.

---

## 13. Assumptions

The project assumes:

* All patient data is synthetic.
* Each patient has a unique PatientID.
* Each encounter has a unique EncounterID.
* Patient identifiers can connect encounters, appointments, admissions, and diagnoses.
* Encounter timestamps are available for wait-time calculations.
* Admission and discharge dates are available for inpatient encounters.
* Encounter costs represent simulated analytical costs and not actual billing claims.
* Diagnoses may occur multiple times across encounters.
* One encounter may contain multiple diagnoses.
* One encounter may contain multiple procedures.
* Financial values are represented in U.S. dollars.
* Calendar dates can be standardized during ETL.

---

## 14. Acceptance Criteria

The analytics solution will be accepted when:

1. Required source datasets are successfully integrated.

2. Critical data-quality issues are identified, documented, and addressed.

3. Primary and foreign-key relationships are validated.

4. Patient and encounter counts in Power BI match validated SQL calculations.

5. Readmission calculations in Power BI match validated SQL results.

6. Average length-of-stay calculations match warehouse calculations.

7. Appointment no-show calculations match source and warehouse validation.

8. Dashboard users can filter results by required dimensions.

9. Root-cause analysis allows users to move from organization-level performance to department and population-level drivers.

10. KPI definitions are documented and standardized.

11. UAT test cases for critical calculations and functionality pass successfully.

12. Data ownership, definitions, quality rules, and lineage are documented.

13. No real patient-identifiable information is used in the project.

---

## 15. Expected Business Outcome

The Healthcare Operations & Population Health Analytics Platform will provide RiverCare Health System with a centralized analytical view of healthcare operations and patient populations.

The platform will enable leadership to move beyond high-level KPI reporting and investigate operational drivers of readmissions, long wait times, appointment no-shows, high utilization, and increased encounter costs.

The project will establish consistent KPI definitions, improve reporting reliability, support root-cause analysis, strengthen data-quality practices, and demonstrate privacy-aware healthcare analytics.
