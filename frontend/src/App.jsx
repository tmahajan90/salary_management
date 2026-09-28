import {
  BarChartOutlined,
  TeamOutlined,
  UserAddOutlined,
} from '@ant-design/icons'
import { ConfigProvider, Layout, Menu, theme } from 'antd'
import { useState } from 'react'
import { Link, Route, Routes, useLocation } from 'react-router-dom'
import AnalyticsDashboard from './pages/AnalyticsDashboard'
import EmployeeDetail from './pages/EmployeeDetail'
import EmployeeList from './pages/EmployeeList'
import NewEmployee from './pages/NewEmployee'

const { Sider, Content, Header } = Layout

const menuItems = [
  { key: '/employees', icon: <TeamOutlined />, label: <Link to="/employees">Employees</Link> },
  { key: '/employees/new', icon: <UserAddOutlined />, label: <Link to="/employees/new">Add Employee</Link> },
  { key: '/analytics', icon: <BarChartOutlined />, label: <Link to="/analytics">Analytics</Link> },
]

export default function App() {
  const location = useLocation()
  const [collapsed, setCollapsed] = useState(false)

  const selectedKey = menuItems.find((i) => location.pathname.startsWith(i.key))?.key || '/employees'

  return (
    <ConfigProvider theme={{ algorithm: theme.defaultAlgorithm }}>
      <Layout style={{ minHeight: '100vh' }}>
        <Sider collapsible collapsed={collapsed} onCollapse={setCollapsed} theme="dark">
          <div style={{ padding: '16px', color: 'white', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>
            {collapsed ? 'ACME' : 'ACME HR'}
          </div>
          <Menu theme="dark" selectedKeys={[selectedKey]} items={menuItems} />
        </Sider>
        <Layout>
          <Header style={{ background: '#fff', padding: '0 24px', borderBottom: '1px solid #f0f0f0' }}>
            <h2 style={{ margin: 0, lineHeight: '64px' }}>Salary Management</h2>
          </Header>
          <Content style={{ padding: 24, background: '#f5f5f5' }}>
            <Routes>
              <Route path="/" element={<EmployeeList />} />
              <Route path="/employees" element={<EmployeeList />} />
              <Route path="/employees/new" element={<NewEmployee />} />
              <Route path="/employees/:id" element={<EmployeeDetail />} />
              <Route path="/analytics" element={<AnalyticsDashboard />} />
            </Routes>
          </Content>
        </Layout>
      </Layout>
    </ConfigProvider>
  )
}
