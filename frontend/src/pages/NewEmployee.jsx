import { useMutation, useQuery } from '@tanstack/react-query'
import {
  Button,
  Card,
  Col,
  DatePicker,
  Form,
  Input,
  Row,
  Select,
  Typography,
  message,
} from 'antd'
import { useNavigate } from 'react-router-dom'
import { createEmployee, fetchMeta } from '../api/employees'

const { Title } = Typography

export default function NewEmployee() {
  const navigate = useNavigate()
  const [form] = Form.useForm()
  const { data: meta } = useQuery({ queryKey: ['meta'], queryFn: fetchMeta })

  const mutation = useMutation({
    mutationFn: (values) =>
      createEmployee({ ...values, hire_date: values.hire_date?.format('YYYY-MM-DD') }),
    onSuccess: (data) => {
      message.success('Employee created')
      navigate(`/employees/${data.employee.id}`)
    },
    onError: (err) =>
      message.error(err.response?.data?.errors?.join(', ') || 'Failed to create employee'),
  })

  return (
    <div style={{ maxWidth: 720 }}>
      <Title level={3} style={{ marginBottom: 24 }}>
        Add New Employee
      </Title>

      <Card>
        <Form form={form} layout="vertical" onFinish={(v) => mutation.mutate(v)}>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="employee_code" label="Employee Code" rules={[{ required: true }]}>
                <Input placeholder="EMP-00001" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="email" label="Email" rules={[{ required: true, type: 'email' }]}>
                <Input placeholder="jane.doe@acme-corp.com" />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="first_name" label="First Name" rules={[{ required: true }]}>
                <Input />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="last_name" label="Last Name" rules={[{ required: true }]}>
                <Input />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="department" label="Department" rules={[{ required: true }]}>
                <Select
                  showSearch
                  options={(meta?.departments || []).map((d) => ({ label: d, value: d }))}
                  placeholder="Select or type"
                  mode="tags"
                  maxCount={1}
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="job_title" label="Job Title" rules={[{ required: true }]}>
                <Input />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="country" label="Country" rules={[{ required: true }]}>
                <Select
                  showSearch
                  options={(meta?.countries || []).map((c) => ({ label: c, value: c }))}
                  placeholder="Select country"
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="hire_date" label="Hire Date">
                <DatePicker style={{ width: '100%' }} />
              </Form.Item>
            </Col>
          </Row>

          <Form.Item name="status" label="Status" initialValue="active">
            <Select
              options={[
                { label: 'Active', value: 'active' },
                { label: 'Inactive', value: 'inactive' },
              ]}
            />
          </Form.Item>

          <Form.Item>
            <Button type="primary" htmlType="submit" loading={mutation.isPending}>
              Create Employee
            </Button>
            <Button style={{ marginLeft: 8 }} onClick={() => navigate('/employees')}>
              Cancel
            </Button>
          </Form.Item>
        </Form>
      </Card>
    </div>
  )
}
