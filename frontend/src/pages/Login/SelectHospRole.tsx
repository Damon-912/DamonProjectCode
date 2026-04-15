import React, { useState, useEffect } from 'react';
import {
  Card,
  Button,
  Select,
  message,
  Empty,
  Spin,
  Avatar
} from 'antd';
import {
  UserOutlined,
  ArrowLeftOutlined,
  LoginOutlined,
  MedicineBoxOutlined
} from '@ant-design/icons';
import './index.css';
import { getLogonGroupByUserId, logon } from '../../api/logon';
import {
  getTempUserInfo,
  clearTempUserInfo,
  setSession
} from '../../utils/auth';
import { useMenu } from '../../context/MenuContext';
import type { UserLogonLocItem } from '../../api/logon';
import type { MenuItem } from '../../api/menu';

interface SelectHospRoleProps {
  onSelectSuccess?: () => void;
  onBack?: () => void;
}

const SelectHospRole: React.FC<SelectHospRoleProps> = ({ onSelectSuccess, onBack }) => {
  const [loading, setLoading] = useState(true);
  const [logonLoading, setLogonLoading] = useState(false);
  const [selectedId, setSelectedId] = useState<number | string | null>(null);
  const [userInfo, setUserInfo] = useState<{
    userID: string;
    userCode: string;
    userName: string;
  } | null>(null);
  const [permissions, setPermissions] = useState<UserLogonLocItem[]>([]);
  const { loadMenusFromLogin } = useMenu();

  // 初始化加载
  useEffect(() => {
    const tempUser = getTempUserInfo();
    if (!tempUser) {
      message.error('请先登录');
      onBack?.();
      return;
    }
    setUserInfo(tempUser);
    fetchPermissions(tempUser.userID);
  }, []);

  // 获取用户登录权限列表
  const fetchPermissions = async (userID: string) => {
    setLoading(true);
    try {
      const res = await getLogonGroupByUserId({
        userID,
        currentLocFlag: 'Y',
        language: 'CN'
      });

      if (String(res.errorCode) === '0' && res.result) {
        const rows = res.result.rows || [];
        setPermissions(rows);

        // 如果有默认权限，自动选中
        const defaultItem = rows.find(item => item.isDefault === 'Y');
        if (defaultItem) {
          setSelectedId(defaultItem.userLogonLocID || null);
        } else if (rows.length > 0) {
          setSelectedId(rows[0].userLogonLocID || null);
        }

        // 如果只有一个权限，直接登录
        if (rows.length === 1) {
          handleLogon(rows[0]);
        }
      } else {
        message.error(res.errorMessage || '获取权限列表失败');
      }
    } catch (error) {
      console.error('获取权限列表失败:', error);
      message.error('获取权限列表失败');
    } finally {
      setLoading(false);
    }
  };

  // 完成登录
  const handleLogon = async (permission: UserLogonLocItem) => {
    if (!userInfo) return;

    setLogonLoading(true);
    try {
      const res = await logon({
        userID: userInfo.userID,
        userName: userInfo.userCode,
        passWord: '', // 第二步登录不需要密码
        loginGroupID: String(permission.groupID || ''),
        loginHospID: String(permission.hospID || ''),
        userLogonType: '03' // WEB登录
      });

      if (String(res.errorCode) === '0' && res.result && res.result.length > 0) {
        const sessionData = res.result[0] as any;
        console.log('登录接口返回的sessionData:', JSON.stringify(sessionData, null, 2));
        
        // 合并选择页面传入的角色和医院信息到sessionData
        if (permission.groupDesc && !sessionData.groupDesc) {
          sessionData.groupDesc = permission.groupDesc;
        }
        if (permission.hospDesc && !sessionData.hospDesc) {
          sessionData.hospDesc = permission.hospDesc;
        }
        if (permission.groupID && !sessionData.groupID) {
          sessionData.groupID = String(permission.groupID);
        }
        if (permission.hospID && !sessionData.hospID) {
          sessionData.hospID = String(permission.hospID);
        }
        
        console.log('合并后的sessionData:', JSON.stringify(sessionData, null, 2));
        setSession(sessionData);
        clearTempUserInfo();
        
        // 登录成功后保存用户菜单
        if (sessionData.menus && sessionData.menus.length > 0) {
          loadMenusFromLogin(sessionData.menus as MenuItem[]);
        }
        
        message.success('登录成功');
        onSelectSuccess?.();
      } else {
        message.error(res.errorMessage || '登录失败');
      }
    } catch (error) {
      console.error('登录失败:', error);
      message.error('登录失败');
    } finally {
      setLogonLoading(false);
    }
  };

  // 选择登录权限
  const handleSelect = (value: number | string) => {
    setSelectedId(value);
  };

  // 点击进入系统
  const handleEnterSystem = () => {
    const selected = permissions.find(p => p.userLogonLocID === selectedId);
    if (!selected) {
      message.warning('请选择一个登录权限');
      return;
    }
    handleLogon(selected);
  };

  // 生成下拉选项
  const getSelectOptions = () => {
    return permissions.map(item => ({
      value: item.userLogonLocID,
      label: (
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <MedicineBoxOutlined />
          <span>{item.hospDesc}</span>
          <span style={{ color: '#999', fontSize: 12 }}>({item.hospCode})</span>
          <span style={{ marginLeft: 'auto', color: '#1890ff' }}>{item.groupDesc}</span>
          {item.isDefault === 'Y' && (
            <span style={{ color: '#52c41a', fontSize: 12 }}>[默认]</span>
          )}
        </div>
      ),
      item
    }));
  };

  // 返回登录页
  const handleBack = () => {
    clearTempUserInfo();
    onBack?.();
  };

  if (loading) {
    return (
      <div className="login-container">
        <div className="select-loading">
          <Spin size="large" tip="加载中..." />
        </div>
      </div>
    );
  }

  return (
    <div className="login-container">
      {/* 左侧装饰区域 */}
      <div className="login-left">
        <div className="login-left-content">
          <div className="welcome-section">
            <Avatar size={80} icon={<UserOutlined />} className="user-avatar" />
            <h2 className="welcome-title">欢迎回来</h2>
            <p className="welcome-name">{userInfo?.userName}</p>
            <p className="welcome-subtitle">请选择登录的医院和角色</p>
          </div>
        </div>
      </div>

      {/* 右侧选择区域 */}
      <div className="login-right">
        <Card className="select-card" bordered={false}>
          <div className="select-header">
            <Button
              type="link"
              icon={<ArrowLeftOutlined />}
              onClick={handleBack}
              className="back-btn"
            >
              返回
            </Button>
            <h2 className="select-title">选择登录权限</h2>
          </div>

          {permissions.length === 0 ? (
            <Empty
              description="您没有可用的登录权限，请联系管理员分配"
              className="empty-permissions"
            >
              <Button type="primary" onClick={handleBack}>
                返回登录页
              </Button>
            </Empty>
          ) : (
            <>
              {/* 医院角色选择下拉框 */}
              <div className="select-section" style={{ margin: '24px 0' }}>
                <div style={{ marginBottom: 8, color: '#666', fontSize: 14 }}>
                  请选择登录的医院和角色：
                </div>
                <Select
                  style={{ width: '100%' }}
                  size="large"
                  placeholder="请选择登录权限"
                  value={selectedId}
                  onChange={handleSelect}
                  options={getSelectOptions()}
                  optionLabelProp="label"
                />
              </div>

              {/* 底部操作按钮 */}
              <div className="select-footer" style={{ marginTop: 24 }}>
                <Button
                  type="primary"
                  size="large"
                  icon={<LoginOutlined />}
                  loading={logonLoading}
                  disabled={!selectedId}
                  onClick={handleEnterSystem}
                  block
                >
                  进入系统
                </Button>
              </div>
            </>
          )}
        </Card>
      </div>
    </div>
  );
};

export default SelectHospRole;
