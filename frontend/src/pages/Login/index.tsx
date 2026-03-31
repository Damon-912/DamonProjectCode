import React, { useState } from 'react';
import { Form, Input, Button, Card, Checkbox, message } from 'antd';
import { UserOutlined, LockOutlined, MedicineBoxOutlined } from '@ant-design/icons';
import './index.css';

interface LoginFormValues {
  username: string;
  password: string;
  remember: boolean;
}

const Login: React.FC = () => {
  const [loading, setLoading] = useState(false);

  const onFinish = async (values: LoginFormValues) => {
    setLoading(true);
    // 模拟登录请求（不进行实际身份验证）
    setTimeout(() => {
      setLoading(false);
      message.success('登录成功');
      // 这里后续可以添加跳转到主页面的逻辑
      window.location.href = '/'; // 跳转到主页面
    }, 1000);
  };

  return (
    <div className="login-container">
      {/* 左侧装饰区域 */}
      <div className="login-left">
        <div className="login-left-content">
          <MedicineBoxOutlined className="login-icon" />
          <h1 className="login-title">DRG/DIP医保控费预警系统</h1>
          <p className="login-subtitle">Medical Payment Control & Warning System</p>
          <div className="login-features">
            <div className="feature-item">
              <div className="feature-icon">📊</div>
              <div className="feature-text">智能分组</div>
            </div>
            <div className="feature-item">
              <div className="feature-icon">⚠️</div>
              <div className="feature-text">费用预警</div>
            </div>
            <div className="feature-item">
              <div className="feature-icon">💰</div>
              <div className="feature-text">盈亏分析</div>
            </div>
            <div className="feature-item">
              <div className="feature-icon">🔍</div>
              <div className="feature-text">病案质控</div>
            </div>
          </div>
        </div>
      </div>

      {/* 右侧登录表单 */}
      <div className="login-right">
        <Card className="login-card" bordered={false}>
          <h2 className="login-card-title">用户登录</h2>
          <p className="login-card-subtitle">欢迎使用DRG/DIP医保控费预警系统</p>

          <Form
            name="login"
            initialValues={{ remember: true }}
            onFinish={onFinish}
            autoComplete="off"
            size="large"
          >
            <Form.Item
              name="username"
              rules={[{ required: true, message: '请输入用户名' }]}
            >
              <Input
                prefix={<UserOutlined />}
                placeholder="用户名"
              />
            </Form.Item>

            <Form.Item
              name="password"
              rules={[{ required: true, message: '请输入密码' }]}
            >
              <Input.Password
                prefix={<LockOutlined />}
                placeholder="密码"
              />
            </Form.Item>

            <Form.Item>
              <Form.Item name="remember" valuePropName="checked" noStyle>
                <Checkbox>记住我</Checkbox>
              </Form.Item>
              <a className="login-forgot" href="#">
                忘记密码？
              </a>
            </Form.Item>

            <Form.Item>
              <Button type="primary" htmlType="submit" loading={loading} block>
                登录
              </Button>
            </Form.Item>
          </Form>

          <div className="login-footer">
            <p>© 2026 DRG/DIP医保控费预警系统 版权所有</p>
          </div>
        </Card>
      </div>
    </div>
  );
};

export default Login;
