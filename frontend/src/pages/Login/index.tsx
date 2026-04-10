import React, { useState } from 'react';
import { Form, Input, Button, Card, Checkbox, message } from 'antd';
import { UserOutlined, LockOutlined, MedicineBoxOutlined } from '@ant-design/icons';
import './index.css';
import { isValidUser } from '../../api/logon';
import { setTempUserInfo } from '../../utils/auth';

interface LoginFormValues {
  username: string;
  password: string;
  remember: boolean;
}

interface LoginProps {
  onLoginSuccess?: () => void;
}

const Login: React.FC<LoginProps> = ({ onLoginSuccess }) => {
  const [loading, setLoading] = useState(false);

  const onFinish = async (values: LoginFormValues) => {
    setLoading(true);
    try {
      // 调用验证用户接口（直接传明文密码）
      const res = await isValidUser({
        userName: values.username,
        passWord: values.password
      });

      if (String(res.errorCode) === '0' && res.result && res.result.length > 0) {
        const userInfo = res.result[0];
        
        // 保存用户信息到临时存储（用于选择页面）
        setTempUserInfo({
          userID: userInfo.userID,
          userCode: userInfo.userCode,
          userName: userInfo.userName
        });

        message.success('验证成功');
        
        // 跳转到医院角色选择页面
        onLoginSuccess?.();
      } else {
        message.error(res.errorMessage || '用户名或密码错误');
      }
    } catch (error) {
      console.error('登录失败:', error);
      message.error('登录失败，请检查网络连接');
    } finally {
      setLoading(false);
    }
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
