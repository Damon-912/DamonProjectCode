import React, { useState, useEffect } from 'react';
import { Layout, Menu, Dropdown, Avatar, Modal, message, Form, Input, Button, Space } from 'antd';
import {
  UserOutlined,
  DownOutlined,
  LogoutOutlined,
  KeyOutlined,
  SyncOutlined
} from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import { logout, getLogonGroupByUserId, updateLogonGroupById } from '../../api/logon';
import { queryHospitals } from '../../api/hospital';
import { invoke } from '../../api/request';
import { useMenu } from '../../context/MenuContext';

const { Header, Content } = Layout;

const MainLayout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const navigate = useNavigate();
  const { menuItems, isLoaded, loadMenusFromLogin } = useMenu();
  const [currentUser, setCurrentUser] = useState<any>(null);
  const [currentHosp, setCurrentHosp] = useState<any>(null);
  const [hospitals, setHospitals] = useState<any[]>([]);
  const [hospModalVisible, setHospModalVisible] = useState(false);
  const [roleModalVisible, setRoleModalVisible] = useState(false);
  const [availableRoles, setAvailableRoles] = useState<any[]>([]);

  // 修改密码弹窗状态
  const [pwdModalVisible, setPwdModalVisible] = useState(false);
  const [pwdForm] = Form.useForm();
  const [pwdLoading, setPwdLoading] = useState(false);

  useEffect(() => {
    const userInfo = localStorage.getItem('userInfo');
    if (userInfo) {
      const user = JSON.parse(userInfo);
      setCurrentUser(user);
      setCurrentHosp({
        hospID: user.hospID,
        hospDesc: user.hospDesc
      });
      fetchHospitals();
      
      // 页面刷新后，如果菜单未加载，从 drg_session 恢复菜单
      if (!isLoaded) {
        const sessionStr = localStorage.getItem('drg_session');
        if (sessionStr) {
          const sessionData = JSON.parse(sessionStr);
          if (sessionData.menus && sessionData.menus.length > 0) {
            loadMenusFromLogin(sessionData.menus);
          }
        }
      }
    }
  }, []);

  const fetchHospitals = async () => {
    try {
      const res = await queryHospitals({ active: 'Y' }, { pageSize: 100, currentPage: 1 });
      if (String(res.errorCode) === '0' && res.result) {
        setHospitals(res.result.rows || []);
      }
    } catch (error) {
      console.error('获取医院列表失败:', error);
    }
  };

  const handleLogout = async () => {
    Modal.confirm({
      title: '确认退出',
      content: '确定要退出登录吗？',
      okText: '确定',
      cancelText: '取消',
      onOk: async () => {
        try {
          const sessionStr = localStorage.getItem('drg_session');
          if (sessionStr) {
            const { sessionID, userID } = JSON.parse(sessionStr);
            await logout({ sessionID, userID: String(userID) });
          }
        } catch (e) {
          console.error('登出失败', e);
        } finally {
          localStorage.removeItem('userInfo');
          localStorage.removeItem('drg_session');
          navigate('/login');
        }
      }
    });
  };

  const handleSwitchHosp = async (hosp: any) => {
    try {
      const userInfo = {
        ...currentUser,
        hospID: hosp.hospitalID,
        hospDesc: hosp.descripts,
        hospCode: hosp.code
      };
      localStorage.setItem('userInfo', JSON.stringify(userInfo));
      setCurrentHosp({
        hospID: hosp.hospitalID,
        hospDesc: hosp.descripts
      });
      setHospModalVisible(false);
      message.success('切换医院成功');
      window.location.reload();
    } catch (error) {
      console.error('切换医院失败:', error);
      message.error('切换医院失败');
    }
  };

  const handleSwitchRole = async (role: any) => {
    try {
      const userInfo = {
        ...currentUser,
        groupID: role.groupID,
        groupDesc: role.groupDesc,
        locID: role.userLogonLocID
      };
      localStorage.setItem('userInfo', JSON.stringify(userInfo));
      setCurrentUser(userInfo);
      setRoleModalVisible(false);
      message.success('切换角色成功');
      window.location.reload();
    } catch (error) {
      console.error('切换角色失败:', error);
      message.error('切换角色失败');
    }
  };

  const fetchLogonGroup = async () => {
    try {
      // 这里应该调用获取用户角色的API
      // 暂时使用模拟数据
      const groups: any[] = []; // 模拟数据
      if (groups.length > 1) {
        setAvailableRoles(groups);
        setRoleModalVisible(true);
      } else if (groups.length === 1) {
        handleSwitchRole(groups[0]);
      }
    } catch (error) {
      console.error('获取登录角色失败:', error);
    }
  };

  // 打开修改密码弹窗
  const handleOpenPwdModal = () => {
    pwdForm.resetFields();
    setPwdModalVisible(true);
  };

  // 修改当前用户密码
  const handleChangePassword = async () => {
    try {
      const values = await pwdForm.validateFields();

      if (values.newPassword !== values.confirmPassword) {
        message.error('两次输入的新密码不一致');
        return;
      }

      setPwdLoading(true);

      const res = await invoke('01040090', [{
        userID: currentUser?.userID || currentUser?.userID,
        originPassword: values.oldPassword,
        password: values.newPassword,
        confirmPassword: values.confirmPassword
      }]);

      if (String(res.errorCode) === '0') {
        message.success('密码修改成功');
        setPwdModalVisible(false);
      } else {
        message.error(res.errorMessage || '密码修改失败');
      }
    } catch (error) {
      console.error('修改密码失败:', error);
      message.error('修改密码失败');
    } finally {
      setPwdLoading(false);
    }
  };

  // 初始化当前用户密码
  const handleInitPassword = () => {
    Modal.confirm({
      title: '确认初始化',
      content: `确定要将您的登录密码初始化为"123456"吗？`,
      okText: '确定',
      cancelText: '取消',
      async onOk() {
        setPwdLoading(true);
        try {
          const res = await invoke('InitUserPassword', [{
            userID: currentUser?.userID
          }]);

          if (String(res.errorCode) === '0') {
            message.success('密码初始化成功，已设置为"123456"');
            setPwdModalVisible(false);
          } else {
            message.error(res.errorMessage || '密码初始化失败');
          }
        } catch (error) {
          console.error('初始化密码失败:', error);
          message.error('初始化密码失败');
        } finally {
          setPwdLoading(false);
        }
      }
    });
  };

  // 使用从 MenuContext 获取的菜单（根据角色权限动态加载）

  const handleMenuClick = (e: any) => {
    navigate(e.key);
  };

  const operationItems = [
    {
      key: 'switchHosp',
      icon: <UserOutlined />,
      label: '切换医院/角色'
    },
    {
      key: 'changePassword',
      icon: <KeyOutlined />,
      label: '修改密码'
    },
    {
      type: 'divider' as const
    },
    {
      key: 'logout',
      icon: <LogoutOutlined />,
      label: '退出登录',
      danger: true
    }
  ];

  const handleOperationClick = ({ key }: { key: string }) => {
    if (key === 'logout') {
      handleLogout();
    } else if (key === 'switchHosp') {
      setHospModalVisible(true);
    } else if (key === 'changePassword') {
      handleOpenPwdModal();
    }
  };

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Header style={{ display: 'flex', alignItems: 'center', padding: '0 16px', background: '#001529' }}>
        <div style={{ color: '#fff', fontSize: '18px', fontWeight: 'bold', marginRight: 32 }}>
          DRG医保控费预警系统
        </div>
        <Menu
          theme="dark"
          mode="horizontal"
          defaultSelectedKeys={['/DRG/Workbench']}
          items={menuItems}
          style={{ flex: 1, minWidth: 0 }}
          onClick={handleMenuClick}
        />
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <span style={{ color: '#fff' }}>
            <span style={{ marginRight: 8 }}>{currentHosp?.hospDesc || '-'}</span>
            <span style={{ color: '#888', fontSize: 12 }}>{currentUser?.groupDesc || '-'}</span>
          </span>
          <Dropdown menu={{ items: operationItems, onClick: handleOperationClick }} trigger={['click']}>
            <Space style={{ cursor: 'pointer', color: '#fff' }}>
              <Avatar size="small" icon={<UserOutlined />} />
              <span>{currentUser?.userName || '-'}</span>
              <DownOutlined />
            </Space>
          </Dropdown>
        </div>
      </Header>
      <Content style={{ padding: 16, background: '#f0f2f5', overflow: 'auto' }}>
        {children}
      </Content>

      {/* 医院选择弹窗 */}
      <Modal
        title="选择医院"
        open={hospModalVisible}
        onCancel={() => setHospModalVisible(false)}
        footer={null}
        width={400}
      >
        <Menu
          mode="inline"
          items={hospitals.map(h => ({
            key: String(h.hospitalID),
            label: h.descripts,
            onClick: () => handleSwitchHosp(h)
          }))}
        />
      </Modal>

      {/* 修改密码弹窗 */}
      <Modal
        title="修改密码"
        open={pwdModalVisible}
        onCancel={() => setPwdModalVisible(false)}
        width={400}
        footer={[
          <Button
            key="init"
            icon={<SyncOutlined />}
            onClick={handleInitPassword}
            loading={pwdLoading}
          >
            初始化登录密码
          </Button>,
          <Button key="cancel" onClick={() => setPwdModalVisible(false)}>
            取消
          </Button>,
          <Button key="submit" type="primary" onClick={handleChangePassword} loading={pwdLoading}>
            确定
          </Button>
        ]}
      >
        <Form form={pwdForm} layout="vertical">
          <Form.Item
            name="oldPassword"
            label="原密码"
            rules={[{ required: true, message: '请输入原密码' }]}
          >
            <Input.Password placeholder="请输入原密码" maxLength={20} />
          </Form.Item>
          <Form.Item
            name="newPassword"
            label="新密码"
            rules={[
              { required: true, message: '请输入新密码' },
              { min: 6, message: '密码至少6位' },
              { max: 20, message: '密码最多20位' }
            ]}
          >
            <Input.Password placeholder="请输入新密码" maxLength={20} />
          </Form.Item>
          <Form.Item
            name="confirmPassword"
            label="确认密码"
            rules={[
              { required: true, message: '请再次输入新密码' },
              ({ getFieldValue }) => ({
                validator(_, value) {
                  if (!value || getFieldValue('newPassword') === value) {
                    return Promise.resolve();
                  }
                  return Promise.reject(new Error('两次输入的密码不一致'));
                },
              }),
            ]}
          >
            <Input.Password placeholder="请再次输入新密码" maxLength={20} />
          </Form.Item>
        </Form>
      </Modal>
    </Layout>
  );
};

export default MainLayout;
