import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Button,
  Input,
  Select,
  Modal,
  message,
  Space,
  Row,
  Col,
  DatePicker,
  Form,
  Tag,
  Popconfirm,
  Tabs,
  Switch
} from 'antd';
import {
  PlusOutlined,
  SearchOutlined,
  ReloadOutlined,
  EditOutlined,
  EyeOutlined,
  DeleteOutlined,
  SafetyOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import dayjs from 'dayjs';
import {
  queryUsers,
  saveUser,
  getUserDetail,
  saveUserLogonLoc,
  deleteUserLogonLoc,
  queryGroupOptions,
  type UserItem,
  type UserLogonLocItem,
  type SaveUserParams,
  type SaveUserLogonLocParams,
  type GroupOptionItem
} from '../../api/system';
import { queryHospitals, type HospitalItem } from '../../api/hospital';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;
const { TabPane } = Tabs;

// 分页参数
interface PaginationParams {
  current: number;
  pageSize: number;
  total: number;
}

// 性别选项
const sexOptions = [
  { value: '1', label: '男' },
  { value: '2', label: '女' },
];

// 证件类型选项
const credTypeOptions = [
  { value: '1', label: '身份证' },
  { value: '2', label: '护照' },
  { value: '3', label: '军官证' },
  { value: '4', label: '其他' },
];

const Users: React.FC = () => {
  const [modalForm] = Form.useForm();
  const [roleForm] = Form.useForm();
  const [editRoleForm] = Form.useForm();
  const [data, setData] = useState<UserItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState<PaginationParams>({
    current: 1,
    pageSize: 10,
    total: 0
  });
  const [modalVisible, setModalVisible] = useState(false);
  const [modalTitle, setModalTitle] = useState('新增用户');
  const [editingRecord, setEditingRecord] = useState<UserItem | null>(null);
  
  // 详情弹窗
  const [detailVisible, setDetailVisible] = useState(false);
  const [detailRecord, setDetailRecord] = useState<UserItem | null>(null);
  const [userRoles, setUserRoles] = useState<UserLogonLocItem[]>([]);
  const [roleLoading, setRoleLoading] = useState(false);
  
  // 角色分配弹窗
  const [roleModalVisible, setRoleModalVisible] = useState(false);
  const [editingRole, setEditingRole] = useState<UserLogonLocItem | null>(null);

  // 新增/编辑弹窗中的角色管理
  const [editUserRoles, setEditUserRoles] = useState<UserLogonLocItem[]>([]);
  const [editRoleLoading, setEditRoleLoading] = useState(false);
  const [editRoleModalVisible, setEditRoleModalVisible] = useState(false);
  const [editingEditRole, setEditingEditRole] = useState<UserLogonLocItem | null>(null);

  // 查询条件
  const [searchCode, setSearchCode] = useState('');
  const [searchName, setSearchName] = useState('');
  const [searchStatus, setSearchStatus] = useState('');
  const [searchHosp, setSearchHosp] = useState('');

  // 医院列表
  const [hospitals, setHospitals] = useState<HospitalItem[]>([]);
  const [hospitalLoading, setHospitalLoading] = useState(false);

  // 角色列表
  const [groups, setGroups] = useState<GroupOptionItem[]>([]);
  const [groupLoading, setGroupLoading] = useState(false);

  // 加载医院列表
  const fetchHospitals = async () => {
    setHospitalLoading(true);
    try {
      const res = await queryHospitals({ active: 'Y' }, { pageSize: 1000, currentPage: 1 });
      if (String(res.errorCode) === '0' && res.result) {
        setHospitals(res.result.rows || []);
      }
    } catch (error) {
      console.error('加载医院列表失败:', error);
    } finally {
      setHospitalLoading(false);
    }
  };

  // 加载角色列表
  const fetchGroups = async () => {
    setGroupLoading(true);
    try {
      const res = await queryGroupOptions({ active: 'Y' });
      if (String(res.errorCode) === '0' && res.result) {
        // 接口返回的是 result: [] 数组格式
        setGroups(res.result || []);
      }
    } catch (error) {
      console.error('加载角色列表失败:', error);
    } finally {
      setGroupLoading(false);
    }
  };

  // 表格列定义
  const columns: ColumnsType<UserItem> = [
    {
      title: '序号',
      key: 'index',
      width: 60,
      render: (_, __, index) => (pagination.current - 1) * pagination.pageSize + index + 1
    },
    {
      title: '用户编码',
      dataIndex: 'userCode',
      key: 'userCode',
      width: 120
    },
    {
      title: '用户姓名',
      dataIndex: 'userName',
      key: 'userName',
      width: 120
    },
    {
      title: '性别',
      dataIndex: 'sexDesc',
      key: 'sexDesc',
      width: 80
    },
    {
      title: '手机号',
      dataIndex: 'mobile',
      key: 'mobile',
      width: 120
    },
    {
      title: '证件类型',
      dataIndex: 'credTypeDesc',
      key: 'credTypeDesc',
      width: 100
    },
    {
      title: '证件号',
      dataIndex: 'credNo',
      key: 'credNo',
      width: 150,
      ellipsis: true
    },
    {
      title: '状态',
      dataIndex: 'statusFlag',
      key: 'statusFlag',
      width: 80,
      render: (status: string) => (
        <Tag color={status === 'Y' ? 'green' : 'red'}>
          {status === 'Y' ? '启用' : '停用'}
        </Tag>
      )
    },
    {
      title: '创建人',
      dataIndex: 'creatUserDesc',
      key: 'creatUserDesc',
      width: 100
    },
    {
      title: '创建时间',
      dataIndex: 'createdDate',
      key: 'createdDate',
      width: 120
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 180,
      render: (_, record) => (
        <Space size="small">
          <Button
            type="link"
            size="small"
            icon={<EyeOutlined />}
            onClick={() => handleView(record)}
          >
            详情
          </Button>
          <Button
            type="link"
            size="small"
            icon={<EditOutlined />}
            onClick={() => handleEdit(record)}
          >
            编辑
          </Button>
        </Space>
      )
    }
  ];

  // 查询用户列表
  const fetchData = async (page = pagination.current, size = pagination.pageSize) => {
    setLoading(true);
    try {
      const res = await queryUsers(
        {
          code: searchCode || undefined,
          descripts: searchName || undefined,
          status: searchStatus || undefined,
          hospID: searchHosp || undefined
        },
        { pageSize: size, currentPage: page }
      );

      if (String(res.errorCode) === '0' && res.result) {
        setData(res.result.rows || []);
        setPagination(prev => ({
          ...prev,
          total: res.result?.total || 0
        }));
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch (error) {
      console.error('查询用户失败:', error);
      message.error('查询用户失败');
    } finally {
      setLoading(false);
    }
  };

  // 初始化加载
  useEffect(() => {
    fetchData(1, pagination.pageSize);
    fetchHospitals();
  }, []);

  // 搜索
  const handleSearch = () => {
    setPagination(prev => ({ ...prev, current: 1 }));
    fetchData(1, pagination.pageSize);
  };

  // 重置
  const handleReset = () => {
    setSearchCode('');
    setSearchName('');
    setSearchStatus('');
    setSearchHosp('');
    setPagination(prev => ({ ...prev, current: 1 }));
    fetchData(1, pagination.pageSize);
  };

  // 新增
  const handleAdd = () => {
    setEditingRecord(null);
    setModalTitle('新增用户');
    modalForm.resetFields();
    setEditUserRoles([]); // 清空角色列表
    setModalVisible(true);
    setTimeout(() => {
      modalForm.setFieldsValue({ 
        statusFlag: 'Y',
        sexID: '1'
      });
    }, 0);
  };

  // 编辑
  const handleEdit = async (record: UserItem) => {
    setEditingRecord(record);
    setModalTitle('编辑用户');
    modalForm.resetFields();
    setModalVisible(true);
    
    // 加载用户角色信息
    setEditUserRoles([]);
    setEditRoleLoading(true);
    try {
      const res = await getUserDetail({ userID: record.userDr });
      if (String(res.errorCode) === '0' && res.result) {
        setEditUserRoles(res.result.rows || []);
      }
    } catch (error) {
      console.error('加载用户角色失败:', error);
    } finally {
      setEditRoleLoading(false);
    }
    
    setTimeout(() => {
      modalForm.setFieldsValue({
        userDr: record.userDr,
        userName: record.userName,
        mobile: record.mobile,
        sexID: record.sexID ? String(record.sexID) : '1',
        credTypeID: record.credTypeID ? String(record.credTypeID) : '',
        credNo: record.credNo,
        birthDate: record.birthDate ? dayjs(record.birthDate) : null,
        workMobile: record.workMobile,
        mail: record.mail,
        nickname: record.nickname,
        introduce: record.introduce,
        startDate: record.startDate ? dayjs(record.startDate) : dayjs(),
        stopDate: record.stopDate ? dayjs(record.stopDate) : null,
        statusFlag: record.statusFlag || 'Y',
        createdDate: record.createdDate,
        createdTime: record.createdTime
      });
    }, 0);
  };

  // 查看详情
  const handleView = async (record: UserItem) => {
    setDetailRecord(record);
    setDetailVisible(true);
    setRoleLoading(true);
    try {
      const res = await getUserDetail({ userID: record.userDr });
      if (String(res.errorCode) === '0' && res.result) {
        setUserRoles(res.result.rows || []);
      } else {
        message.error(res.errorMessage || '获取用户角色失败');
      }
    } catch (error) {
      console.error('获取用户角色失败:', error);
      message.error('获取用户角色失败');
    } finally {
      setRoleLoading(false);
    }
  };

  // 保存用户
  const handleSave = async () => {
    try {
      const values = await modalForm.validateFields();

      const params: SaveUserParams = {
        userDr: editingRecord?.userDr,
        userName: values.userName,
        mobile: values.mobile,
        sexID: values.sexID,
        credTypeID: values.credTypeID,
        credNo: values.credNo,
        birthDate: values.birthDate ? values.birthDate.format('YYYY-MM-DD') : '',
        workMobile: values.workMobile,
        mail: values.mail,
        nickname: values.nickname,
        introduce: values.introduce,
        startDate: values.startDate ? values.startDate.format('YYYY-MM-DD') : dayjs().format('YYYY-MM-DD'),
        stopDate: values.stopDate ? values.stopDate.format('YYYY-MM-DD') : '',
        statusFlag: values.statusFlag,
        createdDate: editingRecord?.createdDate,
        createdTime: editingRecord?.createdTime
      };

      const res = await saveUser(params);

      if (String(res.errorCode) === '0') {
        const savedUserDr = res.rowIDArr?.[0] || editingRecord?.userDr;
        
        // 保存用户角色信息
        if (savedUserDr && editUserRoles.length > 0) {
          await handleSaveUserRoles(savedUserDr);
        }
        
        message.success(editingRecord ? '修改成功' : '新增成功');
        setModalVisible(false);
        fetchData(pagination.current, pagination.pageSize);
      } else {
        message.error(res.errorMessage || (editingRecord ? '修改失败' : '新增失败'));
      }
    } catch (error) {
      console.error('保存用户失败:', error);
      message.error('保存用户失败');
    }
  };

  // 保存用户角色信息
  const handleSaveUserRoles = async (userDr: number) => {
    try {
      for (const role of editUserRoles) {
        if (!role.userLogonLocID) {
          // 新增角色
          const params: SaveUserLogonLocParams = {
            userID: userDr,
            hospID: String(role.hospID),
            groupID: String(role.groupID),
            isDefault: role.isDefault ? 'Y' : 'N'
          };
          await saveUserLogonLoc(params);
        }
      }
    } catch (error) {
      console.error('保存用户角色失败:', error);
    }
  };

  // 在编辑弹窗中打开添加角色弹窗
  const handleAddRoleInEdit = async () => {
    // 加载角色列表
    if (groups.length === 0) {
      await fetchGroups();
    }
    setEditingEditRole(null);
    editRoleForm.resetFields();
    setEditRoleModalVisible(true);
    setTimeout(() => {
      editRoleForm.setFieldsValue({ isDefault: false });
    }, 0);
  };

  // 在编辑弹窗中编辑角色
  const handleEditRoleInEdit = async (role: UserLogonLocItem) => {
    // 加载角色列表
    if (groups.length === 0) {
      await fetchGroups();
    }
    setEditingEditRole(role);
    editRoleForm.resetFields();
    setEditRoleModalVisible(true);
    setTimeout(() => {
      editRoleForm.setFieldsValue({
        hospID: String(role.hospID),
        groupID: String(role.groupID),
        isDefault: role.isDefault === 'Y'
      });
    }, 0);
  };

  // 在编辑弹窗中保存角色
  const handleSaveRoleInEdit = async () => {
    try {
      const values = await editRoleForm.validateFields();
      const isDefault = values.isDefault ? 'Y' : 'N';
      
      if (editingEditRole?.userLogonLocID) {
        // 编辑现有角色 - 调用API
        // 如果设置为默认，先将其他角色设为非默认
        if (isDefault === 'Y' && editingRecord) {
          for (const role of editUserRoles) {
            if (role.userLogonLocID && role.userLogonLocID !== editingEditRole.userLogonLocID && role.isDefault === 'Y') {
              await saveUserLogonLoc({
                userLogonLocID: role.userLogonLocID,
                userID: editingRecord.userDr,
                hospID: String(role.hospID),
                groupID: String(role.groupID),
                isDefault: 'N'
              });
            }
          }
        }
        
        const params: SaveUserLogonLocParams = {
          userLogonLocID: editingEditRole.userLogonLocID,
          userID: editingRecord?.userDr || 0,
          hospID: values.hospID,
          groupID: values.groupID,
          isDefault: isDefault
        };
        const res = await saveUserLogonLoc(params);
        if (String(res.errorCode) === '0') {
          // 刷新角色列表
          if (editingRecord) {
            const detailRes = await getUserDetail({ userID: editingRecord.userDr });
            if (String(detailRes.errorCode) === '0' && detailRes.result) {
              setEditUserRoles(detailRes.result.rows || []);
            }
          }
        }
      } else {
        // 新增角色到本地列表
        const newRole: UserLogonLocItem = {
          userLogonLocID: undefined,
          hospID: Number(values.hospID),
          hospDesc: hospitals.find(h => String(h.hospitalID) === values.hospID)?.descripts || '',
          hospCode: '',
          groupID: Number(values.groupID),
          groupDesc: groups.find(g => String(g.id) === values.groupID)?.descripts || '',
          isDefault: isDefault
        };
        
        // 如果设置为默认，将其他本地角色设为非默认
        if (isDefault === 'Y') {
          setEditUserRoles(prev => {
            const updated: UserLogonLocItem[] = prev.map(r => ({ ...r, isDefault: 'N' as const }));
            updated.push(newRole);
            return updated;
          });
        } else {
          setEditUserRoles(prev => [...prev, newRole]);
        }
      }
      
      setEditRoleModalVisible(false);
      message.success(editingEditRole ? '修改成功' : '添加成功');
    } catch (error) {
      console.error('保存角色失败:', error);
      message.error('保存角色失败');
    }
  };

  // 在编辑弹窗中删除角色
  const handleDeleteRoleInEdit = async (role: UserLogonLocItem) => {
    if (role.userLogonLocID) {
      // 已有ID的角色，需要调用API删除
      try {
        const res = await deleteUserLogonLoc({ userLogonLocID: role.userLogonLocID });
        if (String(res.errorCode) === '0') {
          setEditUserRoles(prev => prev.filter(r => r.userLogonLocID !== role.userLogonLocID));
          message.success('删除成功');
        } else {
          message.error(res.errorMessage || '删除失败');
        }
      } catch (error) {
        console.error('删除角色失败:', error);
        message.error('删除角色失败');
      }
    } else {
      // 本地新增的角色，直接从列表移除
      setEditUserRoles(prev => prev.filter(r => !(r.hospID === role.hospID && r.groupID === role.groupID)));
      message.success('删除成功');
    }
  };

  // 打开添加角色弹窗
  const handleAddRole = async () => {
    // 加载角色列表
    if (groups.length === 0) {
      await fetchGroups();
    }
    setEditingRole(null);
    roleForm.resetFields();
    setRoleModalVisible(true);
    setTimeout(() => {
      roleForm.setFieldsValue({ isDefault: false });
    }, 0);
  };

  // 编辑角色
  const handleEditRole = async (role: UserLogonLocItem) => {
    // 加载角色列表
    if (groups.length === 0) {
      await fetchGroups();
    }
    setEditingRole(role);
    roleForm.resetFields();
    setRoleModalVisible(true);
    setTimeout(() => {
      roleForm.setFieldsValue({
        hospID: String(role.hospID),
        groupID: String(role.groupID),
        isDefault: role.isDefault === 'Y'
      });
    }, 0);
  };

  // 保存角色
  const handleSaveRole = async () => {
    if (!detailRecord) return;
    try {
      const values = await roleForm.validateFields();
      const isDefault = values.isDefault ? 'Y' : 'N';
      
      // 如果设置为默认，先将其他角色设为非默认
      if (isDefault === 'Y' && userRoles.length > 0) {
        for (const role of userRoles) {
          if (role.userLogonLocID && role.userLogonLocID !== editingRole?.userLogonLocID && role.isDefault === 'Y') {
            await saveUserLogonLoc({
              userLogonLocID: role.userLogonLocID,
              userID: detailRecord.userDr,
              hospID: String(role.hospID),
              groupID: String(role.groupID),
              isDefault: 'N'
            });
          }
        }
      }
      
      const params: SaveUserLogonLocParams = {
        userLogonLocID: editingRole?.userLogonLocID,
        userID: detailRecord.userDr,
        hospID: values.hospID,
        groupID: values.groupID,
        isDefault: isDefault
      };

      const res = await saveUserLogonLoc(params);
      if (String(res.errorCode) === '0') {
        message.success(editingRole ? '修改成功' : '添加成功');
        setRoleModalVisible(false);
        // 刷新角色列表
        const detailRes = await getUserDetail({ userID: detailRecord.userDr });
        if (String(detailRes.errorCode) === '0' && detailRes.result) {
          setUserRoles(detailRes.result.rows || []);
        }
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch (error) {
      console.error('保存角色失败:', error);
      message.error('保存角色失败');
    }
  };

  // 删除角色
  const handleDeleteRole = async (role: UserLogonLocItem) => {
    if (!detailRecord) return;
    try {
      const res = await deleteUserLogonLoc({ userLogonLocID: role.userLogonLocID! });
      if (String(res.errorCode) === '0') {
        message.success('删除成功');
        // 刷新角色列表
        const detailRes = await getUserDetail({ userID: detailRecord.userDr });
        if (String(detailRes.errorCode) === '0' && detailRes.result) {
          setUserRoles(detailRes.result.rows || []);
        }
      } else {
        message.error(res.errorMessage || '删除失败');
      }
    } catch (error) {
      console.error('删除角色失败:', error);
      message.error('删除角色失败');
    }
  };

  // 角色列表列定义
  const roleColumns: ColumnsType<UserLogonLocItem> = [
    {
      title: '医院编码',
      dataIndex: 'hospCode',
      key: 'hospCode',
      width: 100
    },
    {
      title: '医院名称',
      dataIndex: 'hospDesc',
      key: 'hospDesc',
      width: 180
    },
    {
      title: '角色名称',
      dataIndex: 'groupDesc',
      key: 'groupDesc',
      width: 120
    },
    {
      title: '是否默认',
      dataIndex: 'isDefault',
      key: 'isDefault',
      width: 100,
      render: (isDefault: string) => (
        isDefault === 'Y' ? <Tag color="blue">默认</Tag> : '-'
      )
    },
    {
      title: '更新时间',
      key: 'updateTime',
      width: 150,
      render: (record: UserLogonLocItem) => 
        record.updateDate && record.updateTime 
          ? `${record.updateDate} ${record.updateTime}` 
          : '-'
    },
    {
      title: '操作',
      key: 'action',
      width: 150,
      render: (_, record) => (
        <Space size="small">
          <Button
            type="link"
            size="small"
            icon={<EditOutlined />}
            onClick={() => handleEditRole(record)}
          >
            编辑
          </Button>
          <Popconfirm
            title="确认删除"
            description="确定要删除该角色权限吗？"
            onConfirm={() => handleDeleteRole(record)}
            okText="确定"
            cancelText="取消"
          >
            <Button type="link" size="small" danger icon={<DeleteOutlined />}>
              删除
            </Button>
          </Popconfirm>
        </Space>
      )
    }
  ];

  return (
    <div style={{ padding: 16 }}>
      {/* 查询条件 */}
      <Card size="small" style={{ marginBottom: 16 }}>
        <Row gutter={16} align="middle">
          <Col>
            <Input
              placeholder="用户编码"
              value={searchCode}
              onChange={e => setSearchCode(e.target.value)}
              style={{ width: 140 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="用户姓名"
              value={searchName}
              onChange={e => setSearchName(e.target.value)}
              style={{ width: 140 }}
              allowClear
            />
          </Col>
          <Col>
            <Select
              placeholder="状态"
              value={searchStatus || undefined}
              onChange={v => setSearchStatus(v || '')}
              style={{ width: 100 }}
              allowClear
              options={[
                { value: 'Y', label: '启用' },
                { value: 'N', label: '停用' }
              ]}
            />
          </Col>
          <Col>
            <Select
              placeholder="所属医院"
              value={searchHosp || undefined}
              onChange={v => setSearchHosp(v || '')}
              style={{ width: 180 }}
              allowClear
              loading={hospitalLoading}
              showSearch
              filterOption={(input, option) =>
                String(option?.label ?? '').toLowerCase().includes(input.toLowerCase())
              }
              options={hospitals.map(h => ({
                value: String(h.hospitalID),
                label: h.descripts
              }))}
            />
          </Col>
          <Col>
            <Space>
              <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>查询</Button>
              <Button icon={<ReloadOutlined />} onClick={handleReset}>重置</Button>
            </Space>
          </Col>
        </Row>
      </Card>

      {/* 工具栏 + 表格 */}
      <Card size="small">
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 12 }}>
          <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增用户</Button>
          <span>共 {pagination.total} 条记录</span>
        </div>
        <Table
          columns={columns}
          dataSource={data}
          rowKey="userDr"
          loading={loading}
          scroll={{ x: 1200 }}
          size="small"
          pagination={false}
        />
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <CustomPagination
            current={pagination.current}
            pageSize={pagination.pageSize}
            total={pagination.total}
            onChange={(page, size) => {
              setPagination(prev => ({ ...prev, current: page, pageSize: size }));
              fetchData(page, size);
            }}
          />
        </div>
      </Card>

      {/* 新增/编辑弹窗 */}
      <Modal
        title={modalTitle}
        open={modalVisible}
        onOk={handleSave}
        onCancel={() => setModalVisible(false)}
        okText="确定"
        cancelText="取消"
        width={700}
      >
        <Form
          form={modalForm}
          layout="vertical"
        >
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="userName"
                label="用户姓名"
                rules={[{ required: true, message: '请输入用户姓名' }]}
              >
                <Input placeholder="请输入用户姓名" maxLength={50} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="mobile"
                label="手机号"
                rules={[
                  { required: true, message: '请输入手机号' },
                  { pattern: /^1\d{10}$/, message: '请输入正确的11位手机号' }
                ]}
              >
                <Input placeholder="请输入手机号" maxLength={11} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="sexID"
                label="性别"
                rules={[{ required: true, message: '请选择性别' }]}
              >
                <Select placeholder="请选择性别" options={sexOptions} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="statusFlag"
                label="状态"
                rules={[{ required: true, message: '请选择状态' }]}
              >
                <Select 
                  placeholder="请选择状态"
                  options={[
                    { value: 'Y', label: '启用' },
                    { value: 'N', label: '停用' }
                  ]}
                />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="credTypeID"
                label="证件类型"
              >
                <Select placeholder="请选择证件类型" options={credTypeOptions} allowClear />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="credNo"
                label="证件号"
              >
                <Input placeholder="请输入证件号" maxLength={30} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="birthDate"
                label="出生日期"
              >
                <DatePicker style={{ width: '100%' }} placeholder="请选择出生日期" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="workMobile"
                label="工作手机"
              >
                <Input placeholder="请输入工作手机" maxLength={11} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="mail"
                label="邮箱"
              >
                <Input placeholder="请输入邮箱" maxLength={50} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="nickname"
                label="昵称"
              >
                <Input placeholder="请输入昵称" maxLength={50} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="startDate"
                label="启用日期"
                rules={[{ required: true, message: '请选择启用日期' }]}
              >
                <DatePicker style={{ width: '100%' }} placeholder="请选择启用日期" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="stopDate"
                label="停用日期"
              >
                <DatePicker style={{ width: '100%' }} placeholder="请选择停用日期" />
              </Form.Item>
            </Col>
          </Row>

          <Form.Item
            name="introduce"
            label="简介"
          >
            <Input.TextArea placeholder="请输入简介" maxLength={200} rows={3} />
          </Form.Item>

          {/* 角色管理区域 */}
          <div style={{ marginTop: 24, borderTop: '1px solid #f0f0f0', paddingTop: 16 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
              <h4 style={{ margin: 0, fontWeight: 'bold' }}>医院角色信息</h4>
              <Button 
                type="primary" 
                icon={<PlusOutlined />} 
                size="small"
                onClick={handleAddRoleInEdit}
              >
                添加角色
              </Button>
            </div>
            <Table
              columns={[
                {
                  title: '医院编码',
                  dataIndex: 'hospCode',
                  key: 'hospCode',
                  width: 100,
                  render: (text: string, record: UserLogonLocItem) => {
                    if (text) return text;
                    // 从医院列表查找编码
                    const hosp = hospitals.find(h => Number(h.hospitalID) === record.hospID);
                    return hosp?.code || '-';
                  }
                },
                {
                  title: '医院名称',
                  dataIndex: 'hospDesc',
                  key: 'hospDesc',
                  width: 180,
                  render: (text: string, record: UserLogonLocItem) => {
                    if (text) return text;
                    // 从医院列表查找名称
                    const hosp = hospitals.find(h => Number(h.hospitalID) === record.hospID);
                    return hosp?.descripts || '-';
                  }
                },
                {
                  title: '角色名称',
                  dataIndex: 'groupDesc',
                  key: 'groupDesc',
                  width: 120,
                  render: (text: string, record: UserLogonLocItem) => {
                    if (text) return text;
                    // 从角色选项查找名称
                    const group = groups.find(g => g.id === record.groupID);
                    return group?.descripts || '-';
                  }
                },
                {
                  title: '是否默认',
                  dataIndex: 'isDefault',
                  key: 'isDefault',
                  width: 100,
                  render: (isDefault: string) => (
                    isDefault === 'Y' ? <Tag color="blue">默认</Tag> : '-'
                  )
                },
                {
                  title: '操作',
                  key: 'action',
                  width: 120,
                  render: (_, record) => (
                    <Space size="small">
                      <Button
                        type="link"
                        size="small"
                        icon={<EditOutlined />}
                        onClick={() => handleEditRoleInEdit(record)}
                      >
                        编辑
                      </Button>
                      <Popconfirm
                        title="确认删除"
                        description="确定要删除该角色权限吗？"
                        onConfirm={() => handleDeleteRoleInEdit(record)}
                        okText="确定"
                        cancelText="取消"
                      >
                        <Button type="link" size="small" danger icon={<DeleteOutlined />}>
                          删除
                        </Button>
                      </Popconfirm>
                    </Space>
                  )
                }
              ]}
              dataSource={editUserRoles}
              rowKey={(record) => record.userLogonLocID || `${record.hospID}-${record.groupID}`}
              loading={editRoleLoading}
              size="small"
              pagination={false}
              scroll={{ y: 200 }}
            />
          </div>
        </Form>
      </Modal>

      {/* 详情弹窗 */}
      <Modal
        title="用户详情"
        open={detailVisible}
        onCancel={() => setDetailVisible(false)}
        footer={[
          <Button key="close" onClick={() => setDetailVisible(false)}>
            关闭
          </Button>
        ]}
        width={900}
      >
        {detailRecord && (
          <Tabs defaultActiveKey="basic">
            <TabPane tab="基本信息" key="basic">
              <Row gutter={[16, 16]}>
                <Col span={12}>
                  <p><strong>用户编码：</strong>{detailRecord.userCode || '-'}</p>
                </Col>
                <Col span={12}>
                  <p><strong>用户姓名：</strong>{detailRecord.userName || '-'}</p>
                </Col>
              </Row>
              <Row gutter={[16, 16]}>
                <Col span={12}>
                  <p><strong>性别：</strong>{detailRecord.sexDesc || '-'}</p>
                </Col>
                <Col span={12}>
                  <p><strong>手机号：</strong>{detailRecord.mobile || '-'}</p>
                </Col>
              </Row>
              <Row gutter={[16, 16]}>
                <Col span={12}>
                  <p><strong>状态：</strong>
                    <Tag color={detailRecord.statusFlag === 'Y' ? 'green' : 'red'}>
                      {detailRecord.statusFlag === 'Y' ? '启用' : '停用'}
                    </Tag>
                  </p>
                </Col>
                <Col span={12}>
                  <p><strong>创建人：</strong>{detailRecord.creatUserDesc || '-'}</p>
                </Col>
              </Row>
              <Row gutter={[16, 16]}>
                <Col span={12}>
                  <p><strong>证件类型：</strong>{detailRecord.credTypeDesc || '-'}</p>
                </Col>
                <Col span={12}>
                  <p><strong>证件号：</strong>{detailRecord.credNo || '-'}</p>
                </Col>
              </Row>
              <Row gutter={[16, 16]}>
                <Col span={12}>
                  <p><strong>出生日期：</strong>{detailRecord.birthDate || '-'}</p>
                </Col>
                <Col span={12}>
                  <p><strong>工作手机：</strong>{detailRecord.workMobile || '-'}</p>
                </Col>
              </Row>
              <Row gutter={[16, 16]}>
                <Col span={12}>
                  <p><strong>邮箱：</strong>{detailRecord.mail || '-'}</p>
                </Col>
                <Col span={12}>
                  <p><strong>昵称：</strong>{detailRecord.nickname || '-'}</p>
                </Col>
              </Row>
              <Row gutter={[16, 16]}>
                <Col span={12}>
                  <p><strong>启用日期：</strong>{detailRecord.startDate || '-'}</p>
                </Col>
                <Col span={12}>
                  <p><strong>停用日期：</strong>{detailRecord.stopDate || '-'}</p>
                </Col>
              </Row>
              <Row gutter={[16, 16]}>
                <Col span={24}>
                  <p><strong>简介：</strong>{detailRecord.introduce || '-'}</p>
                </Col>
              </Row>
            </TabPane>
            <TabPane 
              tab={<span><SafetyOutlined />权限角色</span>} 
              key="roles"
            >
              <div style={{ marginBottom: 16 }}>
                <Button type="primary" icon={<PlusOutlined />} onClick={handleAddRole}>
                  添加角色
                </Button>
              </div>
              <Table
                columns={roleColumns}
                dataSource={userRoles}
                rowKey="userLogonLocID"
                loading={roleLoading}
                size="small"
                pagination={false}
              />
            </TabPane>
          </Tabs>
        )}
      </Modal>

      {/* 角色分配弹窗 */}
      <Modal
        title={editingRole ? '编辑角色' : '添加角色'}
        open={roleModalVisible}
        onOk={handleSaveRole}
        onCancel={() => setRoleModalVisible(false)}
        okText="确定"
        cancelText="取消"
        width={500}
      >
        <Form form={roleForm} layout="vertical">
          <Form.Item
            name="hospID"
            label="医院"
            rules={[{ required: true, message: '请选择医院' }]}
          >
            <Select 
              placeholder="请选择医院"
              loading={hospitalLoading}
              showSearch
              filterOption={(input, option) =>
                String(option?.label ?? '').toLowerCase().includes(input.toLowerCase())
              }
              options={hospitals.map(h => ({
                value: String(h.hospitalID),
                label: h.descripts
              }))}
            />
          </Form.Item>
          <Form.Item
            name="groupID"
            label="角色"
            rules={[{ required: true, message: '请选择角色' }]}
          >
            <Select 
              placeholder="请选择角色"
              loading={groupLoading}
              options={groups.map(g => ({
                value: String(g.id),
                label: g.descripts
              }))}
            />
          </Form.Item>
          <Form.Item
            name="isDefault"
            label="是否默认"
            valuePropName="checked"
          >
            <Switch 
              checkedChildren="是"
              unCheckedChildren="否"
            />
          </Form.Item>
        </Form>
      </Modal>

      {/* 新增/编辑弹窗中的角色分配弹窗 */}
      <Modal
        title={editingEditRole ? '编辑角色' : '添加角色'}
        open={editRoleModalVisible}
        onOk={handleSaveRoleInEdit}
        onCancel={() => setEditRoleModalVisible(false)}
        okText="确定"
        cancelText="取消"
        width={500}
      >
        <Form form={editRoleForm} layout="vertical">
          <Form.Item
            name="hospID"
            label="医院"
            rules={[{ required: true, message: '请选择医院' }]}
          >
            <Select 
              placeholder="请选择医院"
              loading={hospitalLoading}
              showSearch
              filterOption={(input, option) =>
                String(option?.label ?? '').toLowerCase().includes(input.toLowerCase())
              }
              options={hospitals.map(h => ({
                value: String(h.hospitalID),
                label: h.descripts
              }))}
            />
          </Form.Item>
          <Form.Item
            name="groupID"
            label="角色"
            rules={[{ required: true, message: '请选择角色' }]}
          >
            <Select 
              placeholder="请选择角色"
              loading={groupLoading}
              options={groups.map(g => ({
                value: String(g.id),
                label: g.descripts
              }))}
            />
          </Form.Item>
          <Form.Item
            name="isDefault"
            label="是否默认"
            valuePropName="checked"
          >
            <Switch 
              checkedChildren="是"
              unCheckedChildren="否"
            />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default Users;
