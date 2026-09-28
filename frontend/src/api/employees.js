import client from './client'

export const fetchEmployees = (params) =>
  client.get('/employees', { params }).then((r) => r.data)

export const fetchEmployee = (id) =>
  client.get(`/employees/${id}`).then((r) => r.data)

export const createEmployee = (data) =>
  client.post('/employees', { employee: data }).then((r) => r.data)

export const updateEmployee = (id, data) =>
  client.patch(`/employees/${id}`, { employee: data }).then((r) => r.data)

export const deactivateEmployee = (id) =>
  client.delete(`/employees/${id}`).then((r) => r.data)

export const fetchSalaries = (employeeId) =>
  client.get(`/employees/${employeeId}/salaries`).then((r) => r.data)

export const createSalary = (employeeId, data) =>
  client.post(`/employees/${employeeId}/salaries`, { salary: data }).then((r) => r.data)

export const deleteSalary = (employeeId, salaryId) =>
  client.delete(`/employees/${employeeId}/salaries/${salaryId}`).then((r) => r.data)

export const fetchAnalyticsSummary = () =>
  client.get('/analytics/summary').then((r) => r.data)

export const fetchByDepartment = () =>
  client.get('/analytics/by_department').then((r) => r.data)

export const fetchByCountry = () =>
  client.get('/analytics/by_country').then((r) => r.data)

export const fetchSalaryDistribution = () =>
  client.get('/analytics/salary_distribution').then((r) => r.data)

export const fetchRecentChanges = () =>
  client.get('/analytics/recent_changes').then((r) => r.data)

export const fetchMeta = () =>
  client.get('/meta/filters').then((r) => r.data)
