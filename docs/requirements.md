# Salary Management System — Requirements Document

## Goal

Replace ACME's Excel-based salary management process with a web application that allows the HR Manager to manage salary data for 10,000+ employees across multiple countries, and to answer analytical questions about how the organisation compensates its people.

---

## Problem Context

- The HR team currently manages salary data in spreadsheets
- With 10,000 employees across multiple countries and currencies, this is error-prone and slow
- There is no audit history when salaries change
- It is hard to answer questions like "what is the average salary in India vs. USA?" without manual pivot tables

---

## User Persona

**Primary user: HR Manager**
- Needs to add, edit, and view employee records
- Needs to record salary changes over time and see current vs. historical salary
- Needs to filter and search employees by department, country, status
- Needs to answer org-level compensation questions quickly

---

## Scope & Features

### In Scope

#### Employee Management
- Create, view, update, and deactivate employees
- Fields: name, email, employee code, department, job title, country, hire date, status
- Search by name / employee code / email
- Filter by department, country, employment status
- Sortable, paginated employee list

#### Salary Management
- Record a salary for any employee with effective date and currency
- Salary history per employee — full audit trail of all changes
- Current salary always derivable (the record with no `effective_to` date)
- Multi-currency: salary stored in the employee's local currency

#### Analytics Dashboard
- Total payroll cost (by currency / by country)
- Average, median, min, max salary by department
- Average salary by country
- Headcount by department and by country
- Salary distribution histogram
- Recent salary changes feed

#### Bulk Operations
- Seed/import 10,000 employees via script
- CSV export of employee + current salary list

### Out of Scope (and Why)

| Feature | Reason excluded |
|---|---|
| Payroll processing & tax calculations | Requires per-country tax logic, legal compliance — separate domain |
| Leave & attendance management | Out of scope for a salary tool; belongs in an HRMS |
| Performance reviews & bonuses | Complex enough to be its own product |
| Role-based access control (multi-user) | Single HR Manager persona per brief; RBAC adds significant complexity for no specified need |
| Third-party integrations (Workday, BambooHR) | No integration requirements stated |
| Real-time notifications / alerts | No stated need; adds infra complexity |
| Mobile app | Web is sufficient for desk-based HR work |

---

## Data Model

### Employee
| Column | Type | Notes |
|---|---|---|
| employee_code | string | Unique, human-readable (e.g. EMP-00042) |
| first_name | string | |
| last_name | string | |
| email | string | Unique |
| department | string | |
| job_title | string | |
| country | string | ISO country name |
| hire_date | date | |
| status | enum | active / inactive |

### Salary
| Column | Type | Notes |
|---|---|---|
| employee_id | fk | |
| amount | decimal | 10,2 precision |
| currency | string | ISO 4217 (USD, INR, GBP, …) |
| effective_from | date | When this salary became effective |
| effective_to | date | NULL = current salary |
| notes | text | Reason for change, optional |

---

## Architecture Decisions

- **Rails 8 API mode** — team expertise, excellent for data-heavy CRUD, convention over configuration reduces boilerplate
- **SQLite3** — 10,000 employees is well within SQLite's capability; zero-config, single-file, easy to deploy
- **React + Vite** — fast dev cycle, modern ecosystem
- **Ant Design** — production-grade component library well-suited to data-heavy admin dashboards (ships with Tables, Forms, Charts)
- **JSON pagination via Kaminari** — keeps API responses fast on large datasets
- **No caching layer** — not needed at this scale

---

## Non-Functional Requirements

- Employee list loads in < 500ms for any filter combination (index-backed queries)
- Seed script for 10,000 employees must complete in < 2 minutes
- All API endpoints return JSON
- Frontend communicates with backend via REST API (CORS configured)

---

## Deliberate Simplifications

- Single-tenant (one organisation, one HR manager)
- No authentication — the brief specifies a single user persona and does not require login
- Currency conversion not implemented — salaries are stored and displayed in their native currency
- No soft-delete — `status: inactive` signals a departed employee

---

*Document version: 1.0 | Author: Tarun Mahajan*
