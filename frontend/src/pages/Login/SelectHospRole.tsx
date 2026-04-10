import React, { useState, useEffect } from 'react';
import {
  Card,
  Button,
  Input,
  message,
  Row,
  Col,
  Tag,
  Empty,
  Spin,
  Avatar
} from 'antd';
import {
  SearchOutlined,
  MedicineBoxOutlined,
  SafetyOutlined,
  UserOutlined,
  ArrowLeftOutlined,
  LoginOutlined
} from '@ant-design/icons';
import './index.css';
import { getLogonGroupByUserId, logon } from '../../api/logon';
import {
  getTempUserInfo,
  clearTempUserInfo,
  setSession
} from '../../utils/auth';
import type { UserLogonLocItem } from '../../api/logon';

interface SelectHospRoleProps {
  onSelectSuccess?: () => void;
  onBack?: () => void;
}

const SelectHospRole: React.FC<SelectHospRoleProps> = ({ onSelectSuccess, onBack }) => {
  const [loading, setLoading] = useState(true);
  const [logonLoading, setLogonLoading] = useState(false);
  const [searchText, setSearchText] = useState('');
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [userInfo, setUserInfo] = useState<{
    userID: string;
    userCode: string;
    userName: string;
  } | null>(null);
  const [permissions, setPermissions] = useState<UserLogonLocItem[]>([]);
  const [filteredPermissions, setFilteredPermissions] = useState<UserLogonLocItem[]>([]);

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

  // 搜索过滤
  useEffect(() => {
    if (!searchText.trim()) {
      setFilteredPermissions(permissions);
      return;
    }
    const filtered = permissions.filter(
      item =>
        (item.hospDesc && item.hospDesc.includes(searchText)) ||
        (item.groupDesc && item.groupDesc.includes(searchText)) ||
        (item.hospCode && item.hospCode.includes(searchText))
    );
    setFilteredPermissions(filtered);
  }, [searchText, permissions]);

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
        setFilteredPermissions(rows);

        // 如果只有一个权限，自动选择并登录
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
        const session = res.result[0];
        setSession(session);
        clearTempUserInfo();
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

  // 点击权限卡片
  const handleSelect = (permission: UserLogonLocItem) => {
    setSelectedId(permission.userLogonLocID || null);
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
              {/* 搜索框 */}
              <div className="search-section">
                <Input
                  prefix={<SearchOutlined />}
                  placeholder="搜索医院或角色名称"
                  value={searchText}
                  onChange={e => setSearchText(e.target.value)}
                  allowClear
                  size="large"
                />
              </div>

              {/* 权限卡片列表 */}
              <div className="permissions-list">
                <Row gutter={[16, 16]}>
                  {filteredPermissions.map(permission => (
                    <Col xs={24} sm={12} key={permission.userLogonLocID}>
                      <Card
                        className={`permission-card ${selectedId === permission.userLogonLocID ? 'selected' : ''}`}
                        onClick={() => handleSelect(permission)}
                        hoverable
                      >
                        <div className="permission-content">
                          <div className="permission-icon">
                            <MedicineBoxOutlined />
                          </div>
                          <div className="permission-info">
                            <div className="hospital-name">
                              {permission.hospDesc || '未知医院'}
                              {permission.isDefault === 'Y' && (
                                <Tag color="blue" className="default-tag">默认</Tag>
                              )}
                            </div>
                            <div className="hospital-code">
                              编码: {permission.hospCode || '-'}
                            </div>
                            <div className="group-name">
                              <SafetyOutlined /> {permission.groupDesc || '未知角色'}
                            </div>
                          </div>
                        </div>
                      </Card>
                    </Col>
                  ))}
                </Row>
              </div>

              {/* 底部操作按钮 */}
              <div className="select-footer">
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
