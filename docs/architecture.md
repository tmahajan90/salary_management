# Architecture Notes

## Overview

Two-tier architecture: Rails API backend + React SPA. Vite's dev proxy routes `/api` to Rails during development so there are no CORS preflight issues in local dev. In production, either serve the built frontend from Rails public/ or deploy to a CDN and configure CORS.

```
Browser → React SPA (Vite :5173)
             ↓ /api/* (proxy)
         Rails API (:3000)
             ↓
         SQLite3 (db/development.sqlite3)
```

## Data Model

```
employees
  id, employee_code (unique), first_name, last_name, email (unique)
  department, job_title, country, hire_date, status
  ↑ indexed: employee_code, email, department, country, status

salaries
  id, employee_id (fk), amount (decimal 10,2), currency
  effective_from, effective_to (null = current), notes
  ↑ indexed: (employee_id, effective_from), effective_to
```

**Salary history pattern**: When a new salary is recorded, a `before_create` callback automatically sets `effective_to` on the previous active salary to `new_effective_from - 1 day`. This ensures exactly one "current" salary per employee at any time, with a complete gap-free history.

## Key Decisions

### SQLite3 over PostgreSQL

10,000 employees with ~16,000 salary records is well within SQLite's performance envelope. No concurrent writes from multiple servers are expected (single HR Manager user). Zero-config, zero-dependency — easier to deploy and assess. Indexes on all filter columns keep queries fast.

### Rails API mode

API mode strips out cookies, sessions, flash, view layer — reduces boot time and attack surface for a JSON API. CORS handled via `rack-cors` gem.

### No authentication

The requirement specifies a single HR Manager persona with no mention of multi-user or login requirements. Adding auth (Devise/JWT) would be significant scope with no stated need. Easy to add later.

### Kaminari for pagination

Standard, battle-tested Rails pagination. Returns `current_page`, `total_pages`, `total` in the meta envelope so the frontend can render page controls without a separate count query.

### Ant Design for UI

Data-heavy admin interface benefits from AntD's production-grade Table (sorting, pagination, filtering), Form, and layout primitives. Ships with everything needed without custom component development.

### insert_all for seeding

Using `insert_all` instead of `create` in the seed script bypasses ActiveRecord callbacks and validations, allowing 10,000 rows to be inserted in ~5 seconds instead of minutes. The seed data is known-valid so skipping validation is intentional and safe.

## Performance Considerations

- All filter/search columns are indexed
- Employee list returns `current_salary` via a simple scope on the already-fetched records (N+1 risk on large pages — acceptable at per_page ≤ 100 but worth addressing with `includes(:salaries)` if page sizes grow)
- Analytics queries use a single SQL JOIN + GROUP BY rather than Ruby-side aggregation
- Pagination defaults to 25 records; max is 100

## Trade-offs

| Decision | Upside | Downside |
|---|---|---|
| SQLite | Zero-config, fast | Not suitable for multi-server deploy |
| No auth | Less scope | Not production-ready without it |
| Mixed currency | Avoids FX complexity | Can't aggregate across currencies directly |
| Soft deactivation | History preserved | Needs `status` filter everywhere |
