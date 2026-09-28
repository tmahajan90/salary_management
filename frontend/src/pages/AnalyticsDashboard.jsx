import { useQuery } from '@tanstack/react-query'
import { Card, Col, Row, Statistic, Table, Tag, Typography } from 'antd'
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Legend,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import {
  fetchAnalyticsSummary,
  fetchByCountry,
  fetchByDepartment,
  fetchRecentChanges,
  fetchSalaryDistribution,
} from '../api/employees'

const { Title } = Typography

const COLORS = ['#1677ff', '#52c41a', '#faad14', '#f5222d', '#722ed1', '#13c2c2', '#eb2f96', '#fa8c16', '#a0d911', '#2f54eb']

function StatCard({ title, value, suffix, color }) {
  return (
    <Card style={{ textAlign: 'center' }}>
      <Statistic title={title} value={value} suffix={suffix} valueStyle={{ color }} />
    </Card>
  )
}

export default function AnalyticsDashboard() {
  const { data: summary } = useQuery({ queryKey: ['analytics-summary'], queryFn: fetchAnalyticsSummary })
  const { data: deptData } = useQuery({ queryKey: ['analytics-dept'], queryFn: fetchByDepartment })
  const { data: countryData } = useQuery({ queryKey: ['analytics-country'], queryFn: fetchByCountry })
  const { data: distData } = useQuery({ queryKey: ['analytics-dist'], queryFn: fetchSalaryDistribution })
  const { data: recentData } = useQuery({ queryKey: ['analytics-recent'], queryFn: fetchRecentChanges })

  const recentColumns = [
    { title: 'Employee', dataIndex: 'employee_name', render: (n, r) => `${n} (${r.employee_code})` },
    { title: 'Department', dataIndex: 'department' },
    {
      title: 'New Salary',
      key: 'salary',
      render: (_, r) => `${r.currency} ${Number(r.amount).toLocaleString()}`,
    },
    { title: 'Effective', dataIndex: 'effective_from' },
  ]

  const deptColumns = [
    { title: 'Department', dataIndex: 'department' },
    { title: 'Headcount', dataIndex: 'headcount', sorter: (a, b) => a.headcount - b.headcount },
    {
      title: 'Avg Salary',
      dataIndex: 'avg_salary',
      render: (v) => (v ? Number(v).toLocaleString(undefined, { maximumFractionDigits: 0 }) : '—'),
      sorter: (a, b) => (a.avg_salary || 0) - (b.avg_salary || 0),
    },
  ]

  const countryColumns = [
    { title: 'Country', dataIndex: 'country' },
    { title: 'Headcount', dataIndex: 'headcount', sorter: (a, b) => a.headcount - b.headcount },
    {
      title: 'Avg Salary',
      dataIndex: 'avg_salary',
      render: (v) => (v ? Number(v).toLocaleString(undefined, { maximumFractionDigits: 0 }) : '—'),
    },
  ]

  return (
    <div>
      <Title level={3} style={{ marginBottom: 20 }}>
        Analytics Dashboard
      </Title>

      {/* KPI row */}
      <Row gutter={[16, 16]} style={{ marginBottom: 24 }}>
        <Col xs={12} sm={8} md={4}>
          <StatCard title="Total Employees" value={summary?.total_employees} color="#1677ff" />
        </Col>
        <Col xs={12} sm={8} md={4}>
          <StatCard title="Active" value={summary?.active_employees} color="#52c41a" />
        </Col>
        <Col xs={12} sm={8} md={4}>
          <StatCard title="Inactive" value={summary?.inactive_employees} color="#8c8c8c" />
        </Col>
        <Col xs={12} sm={8} md={4}>
          <StatCard title="With Salary" value={summary?.employees_with_salary} color="#722ed1" />
        </Col>
        <Col xs={12} sm={8} md={4}>
          <StatCard title="Departments" value={summary?.departments_count} color="#13c2c2" />
        </Col>
        <Col xs={12} sm={8} md={4}>
          <StatCard title="Countries" value={summary?.countries_count} color="#faad14" />
        </Col>
      </Row>

      <Row gutter={[16, 16]} style={{ marginBottom: 24 }}>
        {/* Department headcount bar chart */}
        <Col xs={24} lg={12}>
          <Card title="Headcount by Department">
            <ResponsiveContainer width="100%" height={280}>
              <BarChart
                data={(deptData?.by_department || []).sort((a, b) => b.headcount - a.headcount).slice(0, 10)}
                margin={{ top: 5, right: 10, left: 0, bottom: 60 }}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="department" angle={-35} textAnchor="end" tick={{ fontSize: 11 }} />
                <YAxis />
                <Tooltip />
                <Bar dataKey="headcount" fill="#1677ff">
                  {(deptData?.by_department || []).map((_, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </Card>
        </Col>

        {/* Country headcount bar chart */}
        <Col xs={24} lg={12}>
          <Card title="Headcount by Country">
            <ResponsiveContainer width="100%" height={280}>
              <BarChart
                data={(countryData?.by_country || []).sort((a, b) => b.headcount - a.headcount)}
                margin={{ top: 5, right: 10, left: 0, bottom: 60 }}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="country" angle={-35} textAnchor="end" tick={{ fontSize: 11 }} />
                <YAxis />
                <Tooltip />
                <Bar dataKey="headcount" fill="#52c41a">
                  {(countryData?.by_country || []).map((_, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </Card>
        </Col>
      </Row>

      <Row gutter={[16, 16]} style={{ marginBottom: 24 }}>
        {/* Salary distribution histogram */}
        <Col xs={24} lg={14}>
          <Card title="Salary Distribution (Current Salaries)">
            <ResponsiveContainer width="100%" height={260}>
              <BarChart data={distData?.distribution || []} margin={{ top: 5, right: 10, left: 0, bottom: 40 }}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="range" angle={-30} textAnchor="end" tick={{ fontSize: 10 }} />
                <YAxis />
                <Tooltip formatter={(v) => [v, 'Employees']} />
                <Bar dataKey="count" fill="#722ed1" />
              </BarChart>
            </ResponsiveContainer>
          </Card>
        </Col>

        {/* Avg salary by department */}
        <Col xs={24} lg={10}>
          <Card title="Avg Salary by Department" style={{ height: '100%' }}>
            <Table
              rowKey="department"
              dataSource={deptData?.by_department || []}
              columns={deptColumns}
              size="small"
              pagination={false}
              scroll={{ y: 220 }}
            />
          </Card>
        </Col>
      </Row>

      <Row gutter={[16, 16]}>
        {/* Country stats */}
        <Col xs={24} lg={10}>
          <Card title="Salary Stats by Country">
            <Table
              rowKey="country"
              dataSource={countryData?.by_country || []}
              columns={countryColumns}
              size="small"
              pagination={false}
              scroll={{ y: 260 }}
            />
          </Card>
        </Col>

        {/* Recent salary changes */}
        <Col xs={24} lg={14}>
          <Card title="Recent Salary Changes">
            <Table
              rowKey={(r, i) => i}
              dataSource={recentData?.recent_changes || []}
              columns={recentColumns}
              size="small"
              pagination={false}
              scroll={{ y: 260 }}
            />
          </Card>
        </Col>
      </Row>
    </div>
  )
}
