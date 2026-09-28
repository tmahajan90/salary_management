import {
  ArrowLeftOutlined,
  EditOutlined,
  PlusOutlined,
  UserOutlined,
} from '@ant-design/icons'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Badge,
  Button,
  Card,
  Col,
  DatePicker,
  Descriptions,
  Form,
  InputNumber,
  Modal,
  Popconfirm,
  Row,
  Select,
  Space,
  Table,
  Tag,
  Typography,
  message,
} from 'antd'
import dayjs from 'dayjs'
import { useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { createSalary, deactivateEmployee, fetchEmployee, updateEmployee } from '../api/employees'

const { Title, Text } = Typography
const CURRENCIES = ['USD', 'INR', 'GBP', 'EUR', 'AUD', 'CAD', 'SGD', 'AED', 'JPY', 'BRL', 'MXN']

export default function EmployeeDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const qc = useQueryClient()
  const [salaryModal, setSalaryModal] = useState(false)
  const [editModal, setEditModal] = useState(false)
  const [salaryForm] = Form.useForm()
  const [editForm] = Form.useForm()

  const { data, isLoading } = useQuery({
    queryKey: ['employee', id],
    queryFn: () => fetchEmployee(id),
  })

  const employee = data?.employee

  const addSalaryMutation = useMutation({
    mutationFn: (values) =>
      createSalary(id, { ...values, effective_from: values.effective_from.format('YYYY-MM-DD') }),
    onSuccess: () => {
      message.success('Salary added')
      qc.invalidateQueries(['employee', id])
      setSalaryModal(false)
      salaryForm.resetFields()
    },
    onError: (err) =>
      message.error(err.response?.data?.errors?.join(', ') || 'Failed to add salary'),
  })

  const updateMutation = useMutation({
    mutationFn: (values) => updateEmployee(id, values),
    onSuccess: () => {
      message.success('Employee updated')
      qc.invalidateQueries(['employee', id])
      setEditModal(false)
    },
    onError: () => message.error('Update failed'),
  })

  const deactivateMutation = useMutation({
    mutationFn: () => deactivateEmployee(id),
    onSuccess: () => {
      message.success('Employee deactivated')
      navigate('/employees')
    },
  })

  const salaryColumns = [
    {
      title: 'Amount',
      key: 'amount',
      render: (_, r) => (
        <strong>
          {r.currency} {Number(r.amount).toLocaleString()}
        </strong>
      ),
    },
    { title: 'Effective From', dataIndex: 'effective_from' },
    {
      title: 'Effective To',
      dataIndex: 'effective_to',
      render: (v) => v || <Tag color="green">Current</Tag>,
    },
    { title: 'Notes', dataIndex: 'notes', ellipsis: true },
  ]

  if (isLoading) return <div>Loading...</div>
  if (!employee) return <div>Employee not found</div>

  return (
    <div>
      <Space style={{ marginBottom: 16 }}>
        <Button icon={<ArrowLeftOutlined />} onClick={() => navigate('/employees')}>
          Back
        </Button>
        <Title level={3} style={{ margin: 0 }}>
          {employee.full_name}
        </Title>
        <Badge status={employee.status === 'active' ? 'success' : 'default'} text={employee.status} />
      </Space>

      <Row gutter={16}>
        <Col xs={24} lg={14}>
          <Card
            title={<><UserOutlined /> Employee Details</>}
            extra={
              <Button icon={<EditOutlined />} size="small" onClick={() => {
                editForm.setFieldsValue({
                  ...employee,
                  hire_date: employee.hire_date ? dayjs(employee.hire_date) : null,
                })
                setEditModal(true)
              }}>
                Edit
              </Button>
            }
            style={{ marginBottom: 16 }}
          >
            <Descriptions column={2} size="small">
              <Descriptions.Item label="Employee Code">
                <code>{employee.employee_code}</code>
              </Descriptions.Item>
              <Descriptions.Item label="Email">{employee.email}</Descriptions.Item>
              <Descriptions.Item label="Department">{employee.department}</Descriptions.Item>
              <Descriptions.Item label="Job Title">{employee.job_title}</Descriptions.Item>
              <Descriptions.Item label="Country">{employee.country}</Descriptions.Item>
              <Descriptions.Item label="Hire Date">{employee.hire_date || '—'}</Descriptions.Item>
            </Descriptions>
          </Card>

          {employee.status === 'active' && (
            <Popconfirm
              title="Deactivate this employee?"
              description="This will mark them as inactive."
              onConfirm={() => deactivateMutation.mutate()}
              okText="Deactivate"
              okButtonProps={{ danger: true }}
            >
              <Button danger>Deactivate Employee</Button>
            </Popconfirm>
          )}
        </Col>

        <Col xs={24} lg={10}>
          <Card
            title="Current Salary"
            style={{ marginBottom: 16 }}
          >
            {employee.current_salary ? (
              <div>
                <Title level={2} style={{ marginBottom: 4 }}>
                  {employee.current_salary.currency}{' '}
                  {Number(employee.current_salary.amount).toLocaleString()}
                </Title>
                <Text type="secondary">Since {employee.current_salary.effective_from}</Text>
              </div>
            ) : (
              <Text type="secondary">No salary on record</Text>
            )}
          </Card>
        </Col>
      </Row>

      <Card
        title="Salary History"
        extra={
          <Button icon={<PlusOutlined />} type="primary" size="small" onClick={() => setSalaryModal(true)}>
            Add Salary
          </Button>
        }
      >
        <Table
          rowKey="id"
          dataSource={employee.salary_history || []}
          columns={salaryColumns}
          size="small"
          pagination={false}
        />
      </Card>

      {/* Add Salary Modal */}
      <Modal
        title="Record New Salary"
        open={salaryModal}
        onCancel={() => setSalaryModal(false)}
        footer={null}
      >
        <Form form={salaryForm} layout="vertical" onFinish={(v) => addSalaryMutation.mutate(v)}>
          <Form.Item name="amount" label="Amount" rules={[{ required: true }]}>
            <InputNumber style={{ width: '100%' }} min={1} formatter={(v) => `${v}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')} />
          </Form.Item>
          <Form.Item name="currency" label="Currency" rules={[{ required: true }]}>
            <Select options={CURRENCIES.map((c) => ({ label: c, value: c }))} />
          </Form.Item>
          <Form.Item name="effective_from" label="Effective From" rules={[{ required: true }]}>
            <DatePicker style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="notes" label="Notes (reason for change)">
            <Select
              mode="tags"
              style={{ width: '100%' }}
              placeholder="e.g. Annual review, Promotion..."
              options={[
                { label: 'Annual review', value: 'Annual review' },
                { label: 'Promotion', value: 'Promotion' },
                { label: 'Market adjustment', value: 'Market adjustment' },
                { label: 'Joining salary', value: 'Joining salary' },
              ]}
            />
          </Form.Item>
          <Form.Item>
            <Button type="primary" htmlType="submit" loading={addSalaryMutation.isPending} block>
              Save Salary
            </Button>
          </Form.Item>
        </Form>
      </Modal>

      {/* Edit Employee Modal */}
      <Modal
        title="Edit Employee"
        open={editModal}
        onCancel={() => setEditModal(false)}
        footer={null}
      >
        <Form form={editForm} layout="vertical" onFinish={(v) =>
          updateMutation.mutate({ ...v, hire_date: v.hire_date?.format('YYYY-MM-DD') })
        }>
          <Row gutter={8}>
            <Col span={12}>
              <Form.Item name="first_name" label="First Name" rules={[{ required: true }]}>
                <input className="ant-input" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="last_name" label="Last Name" rules={[{ required: true }]}>
                <input className="ant-input" />
              </Form.Item>
            </Col>
          </Row>
          <Form.Item name="job_title" label="Job Title">
            <input className="ant-input" />
          </Form.Item>
          <Form.Item name="department" label="Department">
            <input className="ant-input" />
          </Form.Item>
          <Form.Item name="status" label="Status">
            <Select options={[{ label: 'Active', value: 'active' }, { label: 'Inactive', value: 'inactive' }]} />
          </Form.Item>
          <Form.Item>
            <Button type="primary" htmlType="submit" loading={updateMutation.isPending} block>
              Save Changes
            </Button>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  )
}
