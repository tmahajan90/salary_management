# Salary Management System

Web-based salary management for ACME org — 10,000 employees, multiple countries and currencies.

## Stack

| Layer | Technology |
|---|---|
| Backend | Ruby on Rails 8 (API mode) |
| Database | SQLite3 |
| Frontend | React 19 + Vite |
| UI Library | Ant Design 5 |
| Charts | Recharts |
| Data Fetching | TanStack React Query |
| Routing | React Router v7 |
| Tests | RSpec + FactoryBot + Shoulda Matchers |

## Setup

### Backend

```bash
cd salary_management
bundle install
rails db:migrate
rails db:seed        # seeds 10,000 employees + salary history (~5 seconds)
rails server         # starts on :3000
```

### Frontend

```bash
cd frontend
npm install
npm run dev          # starts on :5173, proxies /api to :3000
```

Open http://localhost:5173

## Running Tests

```bash
bundle exec rspec    # 56 examples
```

## Features

- **Employee Directory** — paginated table with search (name/email/code), filter by department, country, status; sortable columns
- **Employee Detail** — full profile, current salary, salary history timeline, inline edit, deactivate
- **Salary Management** — add salary increments that auto-close the previous record; full audit trail
- **Analytics Dashboard** — KPI tiles, department/country headcount charts, salary distribution histogram, recent changes feed
- **Add Employee** — form with validation, department/country pickers backed by live meta API

## API Endpoints

```
GET  /api/v1/employees            # list with filtering, search, pagination
POST /api/v1/employees            # create
GET  /api/v1/employees/:id        # show with salary history
PATCH /api/v1/employees/:id       # update
DELETE /api/v1/employees/:id      # deactivate (soft delete)

GET  /api/v1/employees/:id/salaries       # salary history
POST /api/v1/employees/:id/salaries       # add salary (auto-closes previous)
PUT  /api/v1/employees/:id/salaries/:id   # update salary record
DELETE /api/v1/employees/:id/salaries/:id # delete salary record

GET  /api/v1/analytics/summary
GET  /api/v1/analytics/by_department
GET  /api/v1/analytics/by_country
GET  /api/v1/analytics/salary_distribution
GET  /api/v1/analytics/recent_changes

GET  /api/v1/meta/filters
```

## Project Structure

```
salary_management/
├── app/
│   ├── controllers/api/v1/   # employees, salaries, analytics, meta
│   └── models/               # Employee, Salary
├── db/
│   ├── migrate/
│   ├── schema.rb
│   └── seeds.rb              # 10k employee seed script
├── spec/
│   ├── factories/
│   ├── models/               # Employee, Salary specs
│   └── requests/api/v1/      # request specs for all endpoints
├── docs/
│   └── requirements.md
└── frontend/
    └── src/
        ├── api/              # axios client + endpoint helpers
        └── pages/            # EmployeeList, EmployeeDetail, NewEmployee, AnalyticsDashboard
```
