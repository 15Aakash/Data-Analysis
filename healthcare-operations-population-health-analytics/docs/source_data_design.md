# RiverCare Health System
## Healthcare Operations & Population Health Analytics Platform
### Source Data Design


## Raw Source Tables

| Table | Business Purpose |
|---|---|
| patients | Stores patient demographic information used for population health and utilization analysis |
| providers | Stores healthcare provider information such as specialty and assigned department |
| departments | Stores healthcare facilities and department information |
| payers | Stores insurance and payer categories for payer-mix analysis |
| diagnoses | Stores diagnosis reference information and chronic-condition classifications |
| procedures | Stores procedure reference information |
| encounters | Stores individual patient healthcare visits and operational encounter information |
| encounter_diagnoses | Connects one or more diagnoses to each patient encounter |
| encounter_procedures | Connects procedures performed during each patient encounter |
| admissions | Stores inpatient admissions, discharges, length-of-stay information, and follow-up information |
| appointments | Stores scheduled appointments and outcomes such as completed, cancelled, or no-show |
| lab_results | Stores laboratory test results associated with patient encounters |


## Source Table Grain

| Table | Grain |
|---|---|
| patients | One row represents one unique patient |
| providers | One row represents one healthcare provider |
| departments | One row represents one healthcare department within a facility |
| payers | One row represents one insurance or payer category |
| diagnoses | One row represents one diagnosis definition |
| procedures | One row represents one procedure definition |
| encounters | One row represents one healthcare encounter or patient visit |
| encounter_diagnoses | One row represents one diagnosis assigned to one encounter |
| encounter_procedures | One row represents one procedure performed during one encounter |
| admissions | One row represents one inpatient admission |
| appointments | One row represents one scheduled patient appointment |
| lab_results | One row represents one laboratory test result for one patient encounter |


## Table Design: patients

**Business Purpose:**  
Stores synthetic patient demographic and registration information used for population health, utilization, readmission, and demographic analysis.

**Grain:**  
One row represents one unique patient.

### Columns

| Column | Data Type | Nullable? | Description | Example |
|---|---|---|---|---|
| PatientID | VARCHAR(10) | No | Unique identifier assigned to each patient | PAT000001 |
| BirthDate | DATE | No | Patient date of birth | 1965-04-12 |
| Gender | VARCHAR(20) | Yes | Patient gender category | Female |
| Race | VARCHAR(50) | Yes | Patient race category | Asian |
| Ethnicity | VARCHAR(50) | Yes | Patient ethnicity category | Not Hispanic or Latino |
| ZipCode | VARCHAR(10) | Yes | Synthetic patient ZIP code | 23220 |
| State | VARCHAR(2) | Yes | Patient state abbreviation | VA |
| Region | VARCHAR(20) | Yes | Geographic region used for analysis | Central |
| RegistrationDate | DATE | No | Date patient first registered with RiverCare | 2023-01-15 |


### Primary Key

PatientID


### Allowed Values

**Gender**
- Male
- Female
- Other
- Unknown

**Region**
- Central
- Northern
- Southern
- Eastern
- Western

**State**
- Valid two-character U.S. state abbreviation

**Race**
- White
- Black or African American
- Asian
- American Indian or Alaska Native
- Native Hawaiian or Other Pacific Islander
- Multiple
- Other
- Unknown

**Ethnicity**
- Hispanic or Latino
- Not Hispanic or Latino
- Unknown


### Business / Data Quality Rules

| Rule ID | Rule |
|---|---|
| PAT-001 | PatientID must not be NULL |
| PAT-002 | PatientID must be unique |
| PAT-003 | BirthDate must not be in the future |
| PAT-004 | BirthDate must be earlier than RegistrationDate |
| PAT-005 | RegistrationDate must not occur before BirthDate |
| PAT-006 | Gender must match an approved category |
| PAT-007 | Region must match an approved category |
| PAT-008 | State must contain a valid two-character state abbreviation when present |


## Table Design: departments

**Business Purpose:**  
Stores healthcare facility and department information used for operational, utilization, wait-time, readmission, and provider-performance analysis.

**Grain:**  
One row represents one healthcare department within one RiverCare facility.

### Columns

| Column | Data Type | Nullable? | Description | Example |
|---|---|---|---|---|
| DepartmentID | VARCHAR(10) | No | Unique identifier for each department | DEP001 |
| DepartmentName | VARCHAR(100) | No | Name of the healthcare department | Cardiology |
| FacilityName | VARCHAR(100) | No | RiverCare facility where the department operates | RiverCare Central Hospital |
| DepartmentType | VARCHAR(50) | No | Broad department classification | Specialty |
| City | VARCHAR(50) | No | Facility city | Richmond |
| State | VARCHAR(2) | No | Facility state abbreviation | VA |


### Primary Key

DepartmentID


### Allowed Facility Values

- RiverCare Central Hospital
- RiverCare North Hospital
- RiverCare West Medical Center
- RiverCare Downtown Clinic
- RiverCare Community Clinic


### Allowed Department Values

- Emergency Department
- General Medicine
- Cardiology
- Neurology
- Orthopedics
- Oncology
- Pediatrics
- Primary Care
- Endocrinology
- Pulmonology
- Gastroenterology
- Behavioral Health


### Allowed Department Types

- Emergency
- Inpatient
- Specialty
- Primary Care
- Outpatient
- Behavioral Health


### Business / Data Quality Rules

| Rule ID | Rule |
|---|---|
| DEP-001 | DepartmentID must not be NULL |
| DEP-002 | DepartmentID must be unique |
| DEP-003 | DepartmentName must not be NULL |
| DEP-004 | FacilityName must match an approved RiverCare facility |
| DEP-005 | DepartmentType must match an approved department category |
| DEP-006 | State must contain a valid two-character state abbreviation |
| DEP-007 | The same DepartmentID cannot belong to multiple facilities |


## Table Design: providers

**Business Purpose:**  
Stores healthcare provider information used for provider-level utilization, wait-time, department-performance, and encounter analysis.

**Grain:**  
One row represents one healthcare provider.

### Columns

| Column | Data Type | Nullable? | Description | Example |
|---|---|---|---|---|
| ProviderID | VARCHAR(10) | No | Unique identifier for each provider | PRV001 |
| DepartmentID | VARCHAR(10) | No | Department where the provider primarily works | DEP003 |
| ProviderType | VARCHAR(50) | No | Provider role or classification | Physician |
| Specialty | VARCHAR(100) | Yes | Provider clinical specialty | Cardiology |
| HireDate | DATE | No | Date provider joined RiverCare | 2019-06-17 |
| ActiveFlag | INTEGER | No | Indicates whether provider is currently active | 1 |


### Primary Key

ProviderID


### Foreign Key

DepartmentID → departments.DepartmentID


### Allowed Provider Types

- Physician
- Nurse Practitioner
- Physician Assistant
- Registered Nurse
- Therapist
- Other


### Example Specialty Values

- Emergency Medicine
- Internal Medicine
- Cardiology
- Neurology
- Orthopedics
- Oncology
- Pediatrics
- Family Medicine
- Endocrinology
- Pulmonology
- Gastroenterology
- Psychiatry


### Business / Data Quality Rules

| Rule ID | Rule |
|---|---|
| PRV-001 | ProviderID must not be NULL |
| PRV-002 | ProviderID must be unique |
| PRV-003 | DepartmentID must not be NULL |
| PRV-004 | DepartmentID must exist in the departments table |
| PRV-005 | ProviderType must match an approved provider type |
| PRV-006 | HireDate must not be in the future |
| PRV-007 | ActiveFlag must contain only 0 or 1 |
| PRV-008 | Specialty should be consistent with the provider's assigned department where applicable |


## Table Design: payers

**Business Purpose:**  
Stores insurance and payment categories used for payer-mix, utilization, cost, and patient-population analysis.

**Grain:**  
One row represents one payer or payment category.

### Columns

| Column | Data Type | Nullable? | Description | Example |
|---|---|---|---|---|
| PayerID | VARCHAR(10) | No | Unique identifier for each payer category | PAY01 |
| PayerName | VARCHAR(100) | No | Name of the payer or payment category | Medicare |
| PayerType | VARCHAR(50) | No | Broad payer classification | Government |


### Primary Key

PayerID


### Allowed Payer Names

- Medicare
- Medicaid
- Commercial Insurance
- Employer Sponsored
- Self Pay
- Other


### Allowed Payer Types

- Government
- Commercial
- Self Pay
- Other


### Business / Data Quality Rules

| Rule ID | Rule |
|---|---|
| PAY-001 | PayerID must not be NULL |
| PAY-002 | PayerID must be unique |
| PAY-003 | PayerName must not be NULL |
| PAY-004 | PayerName must match an approved payer category |
| PAY-005 | PayerType must match an approved payer type |
| PAY-006 | Each PayerName must map consistently to one PayerType |


## Table Design: diagnoses

**Business Purpose:**  
Stores standardized diagnosis reference information used to analyze patient conditions, chronic disease prevalence, healthcare utilization, readmissions, and population-health trends.

**Grain:**  
One row represents one unique diagnosis definition.

### Columns

| Column | Data Type | Nullable? | Description | Example |
|---|---|---|---|---|
| DiagnosisID | VARCHAR(10) | No | Unique internal identifier for the diagnosis | DX001 |
| DiagnosisCode | VARCHAR(20) | No | Standardized diagnosis code used for reference | E11 |
| DiagnosisName | VARCHAR(150) | No | Human-readable diagnosis description | Type 2 Diabetes |
| DiagnosisCategory | VARCHAR(100) | No | Broader analytical diagnosis grouping | Diabetes |
| ChronicConditionFlag | INTEGER | No | Indicates whether the diagnosis represents a chronic condition | 1 |

### Primary Key

DiagnosisID


### Approved Diagnosis Categories

- Diabetes
- Hypertension
- Heart Disease
- COPD
- Asthma
- Kidney Disease
- Respiratory
- Infectious Disease
- Injury
- Musculoskeletal
- Mental Health
- Neurological
- Gastrointestinal
- Cancer
- Other


### Business / Data Quality Rules

| Rule ID | Rule |
|---|---|
| DX-001 | DiagnosisID must not be NULL |
| DX-002 | DiagnosisID must be unique |
| DX-003 | DiagnosisCode must not be NULL |
| DX-004 | DiagnosisName must not be NULL |
| DX-005 | DiagnosisCategory must match an approved diagnosis category |
| DX-006 | ChronicConditionFlag must contain only 0 or 1 |
| DX-007 | The same DiagnosisCode should not map to conflicting diagnosis definitions |
| DX-008 | DiagnosisName and DiagnosisCategory should maintain a logically valid mapping |


## Table Design: procedures

**Business Purpose:**  
Stores standardized procedure reference information used to analyze healthcare utilization, procedure volume, department activity, and simulated procedure costs.

**Grain:**  
One row represents one unique procedure definition.

### Columns

| Column | Data Type | Nullable? | Description | Example |
|---|---|---|---|---|
| ProcedureID | VARCHAR(10) | No | Unique internal identifier for the procedure | PROC001 |
| ProcedureCode | VARCHAR(20) | No | Standardized procedure reference code | PR001 |
| ProcedureName | VARCHAR(150) | No | Human-readable procedure name | Echocardiogram |
| ProcedureCategory | VARCHAR(50) | No | Broad analytical category | Diagnostic |
| StandardCost | DECIMAL(10,2) | No | Simulated standard reference cost | 625.00 |

### Primary Key

ProcedureID


### Approved Procedure Categories

- Laboratory
- Imaging
- Diagnostic
- Therapeutic
- Surgical
- Rehabilitation
- Preventive


### Business / Data Quality Rules

| Rule ID | Rule |
|---|---|
| PROC-001 | ProcedureID must not be NULL |
| PROC-002 | ProcedureID must be unique |
| PROC-003 | ProcedureCode must not be NULL |
| PROC-004 | ProcedureName must not be NULL |
| PROC-005 | ProcedureCategory must match an approved procedure category |
| PROC-006 | StandardCost must be greater than or equal to 0 |
| PROC-007 | The same ProcedureCode should not map to conflicting procedure definitions |
| PROC-008 | ProcedureName and ProcedureCategory should maintain a logically valid mapping |


## Table Design: encounters

**Business Purpose:**  
Stores individual healthcare encounters used for patient-volume, wait-time, emergency-department utilization, department utilization, provider activity, payer-mix, and encounter-cost analysis.

**Grain:**  
One row represents one unique healthcare encounter for one patient.

### Columns

| Column | Data Type | Nullable? | Description | Example |
|---|---|---|---|---|
| EncounterID | VARCHAR(12) | No | Unique identifier for each healthcare encounter | ENC000001 |
| PatientID | VARCHAR(10) | No | Patient associated with the encounter | PAT000125 |
| ProviderID | VARCHAR(10) | Yes | Primary provider associated with the encounter | PRV042 |
| DepartmentID | VARCHAR(10) | No | Department where the encounter occurred | DEP003 |
| PayerID | VARCHAR(10) | Yes | Primary payer for the encounter | PAY01 |
| EncounterDate | DATE | No | Calendar date of the encounter | 2025-03-14 |
| EncounterType | VARCHAR(30) | No | Type of healthcare encounter | Emergency |
| ArrivalDateTime | TIMESTAMP | No | Time the patient arrived | 2025-03-14 18:22:00 |
| TriageDateTime | TIMESTAMP | Yes | Time clinical triage was completed | 2025-03-14 18:32:00 |
| ProviderStartDateTime | TIMESTAMP | Yes | Time provider began seeing patient | 2025-03-14 19:07:00 |
| EncounterEndDateTime | TIMESTAMP | Yes | Time the encounter ended | 2025-03-14 22:15:00 |
| EncounterStatus | VARCHAR(30) | No | Final encounter status | Completed |
| EncounterCost | DECIMAL(12,2) | Yes | Simulated total cost associated with encounter | 1840.50 |

### Primary Key

EncounterID


### Foreign Keys

- PatientID → patients.PatientID
- ProviderID → providers.ProviderID
- DepartmentID → departments.DepartmentID
- PayerID → payers.PayerID


### Approved Encounter Types

- Emergency
- Inpatient
- Outpatient
- Urgent Care
- Primary Care
- Specialist


### Approved Encounter Status Values

- Completed
- Cancelled
- Left Without Being Seen
- Transferred


### Business / Data Quality Rules

| Rule ID | Rule |
|---|---|
| ENC-001 | EncounterID must not be NULL |
| ENC-002 | EncounterID must be unique |
| ENC-003 | PatientID must not be NULL |
| ENC-004 | PatientID must exist in the patients table |
| ENC-005 | DepartmentID must exist in the departments table |
| ENC-006 | ProviderID must exist in the providers table when present |
| ENC-007 | PayerID must exist in the payers table when present |
| ENC-008 | EncounterType must match an approved encounter type |
| ENC-009 | EncounterStatus must match an approved encounter status |
| ENC-010 | EncounterCost must be greater than or equal to 0 when present |
| ENC-011 | ArrivalDateTime must not occur after EncounterEndDateTime |
| ENC-012 | ProviderStartDateTime must not occur before ArrivalDateTime |
| ENC-013 | TriageDateTime must not occur before ArrivalDateTime |
| ENC-014 | EncounterDate should match the date component of ArrivalDateTime |


## Table Design: encounter_diagnoses

**Business Purpose:**  
Stores the diagnoses associated with each healthcare encounter, allowing one encounter to contain multiple diagnoses and supporting diagnosis-level utilization, chronic disease, readmission, and population-health analysis.

**Grain:**  
One row represents one diagnosis assigned to one encounter.

### Columns

| Column | Data Type | Nullable? | Description | Example |
|---|---|---|---|---|
| EncounterDiagnosisID | VARCHAR(15) | No | Unique identifier for the encounter-diagnosis record | ED000001 |
| EncounterID | VARCHAR(12) | No | Encounter associated with the diagnosis | ENC000125 |
| DiagnosisID | VARCHAR(10) | No | Diagnosis assigned to the encounter | DX003 |
| DiagnosisType | VARCHAR(20) | No | Indicates whether diagnosis is primary or secondary | Primary |
| PresentOnAdmissionFlag | INTEGER | Yes | Indicates whether the diagnosis was present when the patient was admitted | 1 |

### Primary Key

EncounterDiagnosisID

### Foreign Keys

- EncounterID → encounters.EncounterID
- DiagnosisID → diagnoses.DiagnosisID


### Approved Diagnosis Types

- Primary
- Secondary


### Business / Data Quality Rules

| Rule ID | Rule |
|---|---|
| EDX-001 | EncounterDiagnosisID must not be NULL |
| EDX-002 | EncounterDiagnosisID must be unique |
| EDX-003 | EncounterID must not be NULL |
| EDX-004 | EncounterID must exist in the encounters table |
| EDX-005 | DiagnosisID must not be NULL |
| EDX-006 | DiagnosisID must exist in the diagnoses table |
| EDX-007 | DiagnosisType must be Primary or Secondary |
| EDX-008 | PresentOnAdmissionFlag must contain only 0, 1, or NULL |
| EDX-009 | The same EncounterID–DiagnosisID pair should not appear more than once |
| EDX-010 | Each encounter should have no more than one Primary diagnosis |


## Table Design: encounter_procedures

**Business Purpose:**  
Stores procedures performed during healthcare encounters, supporting procedure-volume, utilization, department activity, and cost analysis.

**Grain:**  
One row represents one procedure performed during one encounter.

### Columns

| Column | Data Type | Nullable? | Description | Example |
|---|---|---|---|---|
| EncounterProcedureID | VARCHAR(15) | No | Unique identifier for the encounter-procedure record | EP000001 |
| EncounterID | VARCHAR(12) | No | Encounter during which the procedure was performed | ENC000125 |
| ProcedureID | VARCHAR(10) | No | Procedure performed during the encounter | PROC006 |
| ProcedureDate | DATE | No | Date the procedure was performed | 2025-03-14 |
| ProcedureCost | DECIMAL(10,2) | Yes | Simulated actual cost of the procedure | 640.00 |

### Primary Key

EncounterProcedureID

### Foreign Keys

- EncounterID → encounters.EncounterID
- ProcedureID → procedures.ProcedureID


### Business / Data Quality Rules

| Rule ID | Rule |
|---|---|
| EPR-001 | EncounterProcedureID must not be NULL |
| EPR-002 | EncounterProcedureID must be unique |
| EPR-003 | EncounterID must not be NULL |
| EPR-004 | EncounterID must exist in the encounters table |
| EPR-005 | ProcedureID must not be NULL |
| EPR-006 | ProcedureID must exist in the procedures table |
| EPR-007 | ProcedureCost must be greater than or equal to 0 when present |
| EPR-008 | ProcedureDate must not be in the future relative to the generated reporting period |
| EPR-009 | ProcedureDate should fall within the associated encounter/admission period when applicable |
| EPR-010 | Duplicate EncounterID–ProcedureID–ProcedureDate records should be investigated |


## Table Design: admissions

**Business Purpose:**  
Stores inpatient admission and discharge information used for length-of-stay, discharge, follow-up, and readmission analysis.

**Grain:**  
One row represents one unique inpatient admission.

### Columns

| Column | Data Type | Nullable? | Description | Example |
|---|---|---|---|---|
| AdmissionID | VARCHAR(12) | No | Unique identifier for the inpatient admission | ADM000001 |
| EncounterID | VARCHAR(12) | No | Healthcare encounter associated with the admission | ENC000125 |
| PatientID | VARCHAR(10) | No | Patient associated with the admission | PAT000125 |
| DepartmentID | VARCHAR(10) | No | Department responsible for the admission | DEP003 |
| AdmissionDateTime | TIMESTAMP | No | Date and time inpatient admission began | 2025-03-14 21:30:00 |
| DischargeDateTime | TIMESTAMP | Yes | Date and time patient was discharged | 2025-03-18 11:15:00 |
| AdmissionType | VARCHAR(30) | No | Type of inpatient admission | Emergency |
| DischargeDisposition | VARCHAR(50) | Yes | Patient destination/status after discharge | Home |
| FollowUpRequiredFlag | INTEGER | No | Indicates whether follow-up care was recommended | 1 |
| FollowUpCompletedFlag | INTEGER | Yes | Indicates whether required follow-up was completed | 1 |
| FollowUpDate | DATE | Yes | Date follow-up was completed | 2025-03-24 |

### Primary Key

AdmissionID

### Foreign Keys

- EncounterID → encounters.EncounterID
- PatientID → patients.PatientID
- DepartmentID → departments.DepartmentID


### Approved Admission Types

- Emergency
- Elective
- Urgent


### Approved Discharge Dispositions

- Home
- Home with Services
- Skilled Nursing Facility
- Rehabilitation Facility
- Transfer to Another Facility
- Left Against Medical Advice
- Expired
- Other


### Business / Data Quality Rules

| Rule ID | Rule |
|---|---|
| ADM-001 | AdmissionID must not be NULL |
| ADM-002 | AdmissionID must be unique |
| ADM-003 | EncounterID must not be NULL |
| ADM-004 | EncounterID must exist in the encounters table |
| ADM-005 | PatientID must not be NULL |
| ADM-006 | PatientID must exist in the patients table |
| ADM-007 | DepartmentID must exist in the departments table |
| ADM-008 | AdmissionType must match an approved admission type |
| ADM-009 | DischargeDateTime must be greater than or equal to AdmissionDateTime when present |
| ADM-010 | FollowUpRequiredFlag must contain only 0 or 1 |
| ADM-011 | FollowUpCompletedFlag must contain only 0, 1, or NULL |
| ADM-012 | FollowUpCompletedFlag cannot equal 1 when FollowUpRequiredFlag equals 0 |
| ADM-013 | FollowUpDate should be present when FollowUpCompletedFlag equals 1 |
| ADM-014 | FollowUpDate must not occur before DischargeDateTime |
| ADM-015 | DischargeDisposition must match an approved category when present |
| ADM-016 | PatientID in admissions should match the patient associated with the linked EncounterID |


## Table Design: appointments

**Business Purpose:**  
Stores scheduled outpatient and follow-up appointments used to analyze appointment completion, cancellations, no-shows, booking lead time, provider scheduling, and department-level access patterns.

**Grain:**  
One row represents one scheduled patient appointment.

### Columns

| Column | Data Type | Nullable? | Description | Example |
|---|---|---|---|---|
| AppointmentID | VARCHAR(12) | No | Unique identifier for each scheduled appointment | APT000001 |
| PatientID | VARCHAR(10) | No | Patient associated with the appointment | PAT000125 |
| ProviderID | VARCHAR(10) | Yes | Provider scheduled for the appointment | PRV042 |
| DepartmentID | VARCHAR(10) | No | Department where the appointment is scheduled | DEP008 |
| ScheduledDate | DATE | No | Date the appointment was originally booked | 2025-03-01 |
| AppointmentDateTime | TIMESTAMP | No | Scheduled date and time of the appointment | 2025-03-18 10:30:00 |
| AppointmentStatus | VARCHAR(30) | No | Final appointment status | Completed |
| AppointmentType | VARCHAR(30) | No | Type of appointment | Follow-Up |
| CancellationReason | VARCHAR(100) | Yes | Reason for cancellation when applicable | Patient Request |

### Primary Key

AppointmentID

### Foreign Keys

- PatientID → patients.PatientID
- ProviderID → providers.ProviderID
- DepartmentID → departments.DepartmentID


### Approved Appointment Status Values

- Completed
- Cancelled
- No Show
- Rescheduled


### Approved Appointment Types

- New Patient
- Follow-Up
- Routine
- Specialist
- Post-Discharge Follow-Up


### Business / Data Quality Rules

| Rule ID | Rule |
|---|---|
| APT-001 | AppointmentID must not be NULL |
| APT-002 | AppointmentID must be unique |
| APT-003 | PatientID must not be NULL |
| APT-004 | PatientID must exist in the patients table |
| APT-005 | ProviderID must exist in the providers table when present |
| APT-006 | DepartmentID must exist in the departments table |
| APT-007 | AppointmentStatus must match an approved appointment status |
| APT-008 | AppointmentType must match an approved appointment type |
| APT-009 | AppointmentDateTime must not occur before ScheduledDate |
| APT-010 | CancellationReason should be populated when AppointmentStatus = Cancelled |
| APT-011 | CancellationReason should normally be NULL when AppointmentStatus is not Cancelled |
| APT-012 | ProviderID should belong to the same DepartmentID recorded for the appointment |


## Table Design: lab_results

**Business Purpose:**  
Stores selected laboratory test results associated with patient encounters, supporting population-health analysis, chronic-condition monitoring, data-quality assessment, and clinical-utilization analysis.

**Grain:**  
One row represents one laboratory test result for one patient encounter.

### Columns

| Column | Data Type | Nullable? | Description | Example |
|---|---|---|---|---|
| LabResultID | VARCHAR(15) | No | Unique identifier for each laboratory result | LAB000001 |
| EncounterID | VARCHAR(12) | No | Encounter associated with the lab result | ENC000125 |
| PatientID | VARCHAR(10) | No | Patient associated with the result | PAT000125 |
| LabTest | VARCHAR(50) | No | Name of the laboratory test | HbA1c |
| ResultValue | DECIMAL(12,2) | Yes | Numeric result of the test | 7.80 |
| ResultUnit | VARCHAR(20) | Yes | Measurement unit for the result | % |
| ReferenceLow | DECIMAL(12,2) | Yes | Lower reference value | 4.00 |
| ReferenceHigh | DECIMAL(12,2) | Yes | Upper reference value | 5.60 |
| ResultFlag | VARCHAR(20) | Yes | Indicates whether result falls outside reference range | High |
| ResultDateTime | TIMESTAMP | No | Date and time result was recorded | 2025-03-14 20:15:00 |

### Primary Key

LabResultID

### Foreign Keys

- EncounterID → encounters.EncounterID
- PatientID → patients.PatientID


### Approved Lab Tests

- HbA1c
- Glucose
- LDL Cholesterol
- Creatinine
- Hemoglobin


### Expected Units

| Lab Test | Expected Unit |
|---|---|
| HbA1c | % |
| Glucose | mg/dL |
| LDL Cholesterol | mg/dL |
| Creatinine | mg/dL |
| Hemoglobin | g/dL |


### Approved Result Flags

- Low
- Normal
- High
- Critical


### Business / Data Quality Rules

| Rule ID | Rule |
|---|---|
| LAB-001 | LabResultID must not be NULL |
| LAB-002 | LabResultID must be unique |
| LAB-003 | EncounterID must not be NULL |
| LAB-004 | EncounterID must exist in the encounters table |
| LAB-005 | PatientID must not be NULL |
| LAB-006 | PatientID must exist in the patients table |
| LAB-007 | PatientID must match the patient associated with EncounterID |
| LAB-008 | LabTest must match an approved laboratory test |
| LAB-009 | ResultUnit should match the expected unit for the selected LabTest |
| LAB-010 | ReferenceLow must be less than or equal to ReferenceHigh when both are present |
| LAB-011 | ResultFlag must match an approved result flag when present |
| LAB-012 | ResultValue must fall within a plausible range for the selected laboratory test |
| LAB-013 | ResultDateTime should occur during or shortly after the associated encounter |


## PK/FK Relationship Matrix

| Child Table | Foreign Key | Parent Table | Parent Primary Key | Relationship |
|---|---|---|---|---|
| providers | DepartmentID | departments | DepartmentID | Many providers → one department |
| encounters | PatientID | patients | PatientID | Many encounters → one patient |
| encounters | ProviderID | providers | ProviderID | Many encounters → one provider |
| encounters | DepartmentID | departments | DepartmentID | Many encounters → one department |
| encounters | PayerID | payers | PayerID | Many encounters → one payer |
| encounter_diagnoses | EncounterID | encounters | EncounterID | Many diagnosis records → one encounter |
| encounter_diagnoses | DiagnosisID | diagnoses | DiagnosisID | Many encounter diagnoses → one diagnosis |
| encounter_procedures | EncounterID | encounters | EncounterID | Many procedure records → one encounter |
| encounter_procedures | ProcedureID | procedures | ProcedureID | Many encounter procedures → one procedure |
| admissions | EncounterID | encounters | EncounterID | Admission → associated encounter |
| admissions | PatientID | patients | PatientID | Many admissions → one patient |
| admissions | DepartmentID | departments | DepartmentID | Many admissions → one department |
| appointments | PatientID | patients | PatientID | Many appointments → one patient |
| appointments | ProviderID | providers | ProviderID | Many appointments → one provider |
| appointments | DepartmentID | departments | DepartmentID | Many appointments → one department |
| lab_results | EncounterID | encounters | EncounterID | Many lab results → one encounter |
| lab_results | PatientID | patients | PatientID | Many lab results → one patient |



## Simplified Raw Data Relationship Model

```text```
departments
     |
     ├──────── providers
     |             |
     |             |
     |             v
     |         encounters <──────── payers
     |             ^
     |             |
     |          patients
     |             |
     |             ├──────── appointments
     |             |
     |             └──────── admissions
     |
     |
encounters
     |
     ├──────── encounter_diagnoses ─────── diagnoses
     |
     ├──────── encounter_procedures ────── procedures
     |
     └──────── lab_results 
```text```


The purpose is not to make a perfect ERD yet. It is just to understand the flow.

### Check for orphan records

This relationship matrix also tells us what we will test later.

For example, if `encounters` contains:

```text```
PatientID = PAT999999
```text```


## Planned Raw Dataset Sizes

| Table | Target Row Count |
|---|---:|
| patients | 10,000 |
| departments | 25 |
| providers | 120 |
| payers | 6 |
| diagnoses | 50 |
| procedures | 40 |
| encounters | 90,000 |
| encounter_diagnoses | 150,000 |
| encounter_procedures | 70,000 |
| admissions | 15,000 |
| appointments | 50,000 |
| lab_results | 100,000 |


## Planned Intentional Data Quality Issues

| Table | Data Quality Issue | Approximate Frequency |
|---|---|---:|
| patients | Missing Region | 1.0% |
| patients | Inconsistent Gender values | 0.5% |
| patients | Invalid future BirthDate | 0.1% |
| patients | Duplicate PatientID | 0.2% |
| providers | Invalid DepartmentID | 0.5% |
| encounters | Missing ProviderID | 1.0% |
| encounters | Invalid DepartmentID | 0.3% |
| encounters | Negative EncounterCost | 0.2% |
| encounters | ProviderStartDateTime before ArrivalDateTime | 0.5% |
| encounters | Inconsistent EncounterType values | 0.5% |
| encounter_diagnoses | Invalid DiagnosisID | 0.3% |
| encounter_diagnoses | Duplicate EncounterID–DiagnosisID pair | 0.3% |
| encounter_procedures | Invalid ProcedureID | 0.2% |
| encounter_procedures | Negative ProcedureCost | 0.2% |
| admissions | DischargeDateTime before AdmissionDateTime | 0.3% |
| admissions | Missing DischargeDateTime | 0.7% |
| admissions | FollowUpCompletedFlag = 1 but FollowUpDate missing | 0.5% |
| appointments | Invalid AppointmentStatus | 0.3% |
| appointments | AppointmentDate before ScheduledDate | 0.4% |
| appointments | Missing ProviderID | 0.8% |
| lab_results | Missing ResultUnit | 0.7% |
| lab_results | Invalid ResultUnit | 0.3% |
| lab_results | Extreme ResultValue outlier | 0.3% |
| lab_results | ReferenceLow > ReferenceHigh | 0.2% |


## Data Quality Severity Definitions

| Severity | Meaning |
|---|---|
| Critical | Issue can invalidate a major KPI or relationship |
| High | Issue materially affects reporting or analysis |
| Medium | Issue reduces completeness or analytical reliability |
| Low | Minor formatting or standardization issue |





