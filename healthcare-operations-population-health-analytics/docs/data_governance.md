## Data Classification

RiverCare Health System uses synthetic healthcare data for portfolio and educational analysis. The following classification framework demonstrates how healthcare information would be categorized in a real-world analytics environment.

| Data Category | Example Fields | Classification | Handling Principle |
|---|---|---|---|
| Direct Identifiers | Patient ID, Patient Name | Restricted | Limit access and avoid exposure in analytical dashboards |
| Demographic Data | Date of Birth, Gender, Location | Confidential | Use only when required for approved analysis |
| Clinical Data | Diagnoses, Procedures, Lab Results | Restricted | Limit access based on business need |
| Encounter & Admission Data | Visit dates, LOS, discharge disposition | Confidential | Use primarily for operational and analytical purposes |
| Financial/Payer Data | Encounter Cost, Insurance/Payer | Confidential | Restrict access to authorized analytical users |
| Provider/Department Data | Provider, Department, Specialty | Internal | Appropriate for operational reporting |
| Aggregated KPIs | Readmission Rate, Wait Time, ED Utilization | Internal / Analytical | Suitable for authorized dashboards and management reporting |

### Classification Principles

- Apply data minimization by exposing only fields required for analysis.
- Avoid displaying direct patient identifiers in BI dashboards.
- Use aggregated metrics whenever detailed records are unnecessary.
- Restrict sensitive healthcare information based on business need and user role.
- Maintain documented data sources, transformations, and lineage.

## Security Best Practices

The RiverCare analytics project uses synthetic healthcare data and does not represent a production clinical environment. The following practices document how sensitive healthcare analytics data should be handled in a real-world implementation.

- Apply role-based access control so users can access only the data required for their responsibilities.
- Follow the principle of least privilege for databases, analytics tools, and reporting platforms.
- Avoid exposing direct patient identifiers in Power BI dashboards unless specifically required and authorized.
- Use aggregated or de-identified data when detailed patient-level information is unnecessary.
- Protect database credentials and connection information; do not store passwords directly in source code.
- Use encryption at rest and in transit for sensitive data in a production environment.
- Maintain audit logs for important data-processing and access activities.
- Separate development, testing, and production environments where applicable.
- Document data sources, transformations, dependencies, and lineage to support traceability.
- Apply data-quality validation before information is published to analytical dashboards.
- Review access periodically and remove permissions that are no longer required.
- Follow applicable organizational information-security policies and data-retention requirements.

### Privacy and Compliance Note

This portfolio project uses entirely synthetic data. The project demonstrates privacy-aware analytics and healthcare data-governance principles but does not claim HIPAA compliance or implementation of production security controls.