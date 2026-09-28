import { EyeOutlined, SearchOutlined } from '@ant-design/icons'
import { useQuery } from '@tanstack/react-query'
import {
  Badge,
  Button,
  Input,
  Select,
  Space,
  Table,
  Tag,
  Typography,
} from 'antd'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { fetchEmployees, fetchMeta } from '../api/employees'

const { Title } = Typography

export default function EmployeeList() {
  const navigate = useNavigate()
  const [params, setParams] = useState({ page: 1, per_page: 25, sort: 'first_name', dir: 'asc' })
  const [search, setSearch] = useState('')

  const { data, isLoading } = useQuery({
    queryKey: ['employees', params],
    queryFn: () => fetchEmployees(params),
    keepPreviousData: true,
  })

  const { data: meta } = useQuery({ queryKey: ['meta'], queryFn: fetchMeta })

  const columns = [
    {
      title: 'Employee Code',
      dataIndex: 'employee_code',
      width: 130,
      render: (code) => <code style={{ fontSize: 12 }}>{code}</code>,
    },
    {
      title: 'Name',
      key: 'name',
      sorter: true,
      render: (_, r) => (
        <Button type="link" onClick={() => navigate(`/employees/${r.id}`)}>
          {r.full_name}
        </Button>
      ),
    },
    { title: 'Department', dataIndex: 'department', sorter: true },
    { title: 'Job Title', dataIndex: 'job_title' },
    { title: 'Country', dataIndex: 'country', sorter: true },
    {
      title: 'Current Salary',
      key: 'salary',
      render: (_, r) =>
        r.current_salary ? (
          <span>
            <strong>{r.current_salary.currency}</strong>{' '}
            {Number(r.current_salary.amount).toLocaleString()}
          </span>
        ) : (
          <Tag color="default">No salary</Tag>
        ),
    },
    {
      title: 'Status',
      dataIndex: 'status',
      render: (s) => <Badge status={s === 'active' ? 'success' : 'default'} text={s} />,
    },
    {
      title: '',
      key: 'action',
      width: 60,
      render: (_, r) => (
        <Button icon={<EyeOutlined />} size="small" onClick={() => navigate(`/employees/${r.id}`)} />
      ),
    },
  ]

  const handleTableChange = (pagination, _filters, sorter) => {
    setParams((p) => ({
      ...p,
      page: pagination.current,
      per_page: pagination.pageSize,
      sort: sorter.field || p.sort,
      dir: sorter.order === 'descend' ? 'desc' : 'asc',
    }))
  }

  const applySearch = () => setParams((p) => ({ ...p, q: search, page: 1 }))

  return (
    <div>
      <Title level={3} style={{ marginBottom: 16 }}>
        Employees
      </Title>

      <Space wrap style={{ marginBottom: 16 }}>
        <Input
          placeholder="Search name / email / code"
          prefix={<SearchOutlined />}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          onPressEnter={applySearch}
          style={{ width: 260 }}
          allowClear
          onClear={() => setParams((p) => ({ ...p, q: undefined, page: 1 }))}
        />
        <Button type="primary" onClick={applySearch}>
          Search
        </Button>
        <Select
          placeholder="Department"
          style={{ width: 180 }}
          allowClear
          options={(meta?.departments || []).map((d) => ({ label: d, value: d }))}
          onChange={(v) => setParams((p) => ({ ...p, department: v, page: 1 }))}
        />
        <Select
          placeholder="Country"
          style={{ width: 160 }}
          allowClear
          options={(meta?.countries || []).map((c) => ({ label: c, value: c }))}
          onChange={(v) => setParams((p) => ({ ...p, country: v, page: 1 }))}
        />
        <Select
          placeholder="Status"
          style={{ width: 130 }}
          allowClear
          options={[
            { label: 'Active', value: 'active' },
            { label: 'Inactive', value: 'inactive' },
          ]}
          onChange={(v) => setParams((p) => ({ ...p, status: v, page: 1 }))}
        />
      </Space>

      <Table
        rowKey="id"
        dataSource={data?.employees || []}
        columns={columns}
        loading={isLoading}
        onChange={handleTableChange}
        pagination={{
          current: data?.meta?.page || 1,
          pageSize: data?.meta?.per_page || 25,
          total: data?.meta?.total || 0,
          showTotal: (total) => `${total} employees`,
          showSizeChanger: true,
          pageSizeOptions: ['10', '25', '50', '100'],
        }}
        scroll={{ x: 900 }}
        size="small"
      />
    </div>
  )
}
