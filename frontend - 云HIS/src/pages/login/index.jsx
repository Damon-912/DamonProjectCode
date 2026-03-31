import React, { useEffect, useState, useRef } from 'react';
import { Form, Input, Button, Row, Col, Checkbox } from 'antd';
import { BarsOutlined, UserOutlined, LockOutlined, SafetyCertificateOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import { encrypt, decrypt } from '@tools/aes';
import { setCookies, getCookies, removeCookies } from '@tools/cookies';
import { envConfig } from '@envConfig';
// import store from '@store';
import loginBg from '@assets/images/login_bg1.png'; // login_bg.svg login_bg1.png
import getMenu from '@routes/routerConfig';
import GraphicCode from '@components/graphicCode';
import DepartmentList from './component/DepartmentList';
import './style/index.less';


const Login = () => {
  const ROOT_APP_NAME = envConfig?.['ROOT_APP_NAME'] || '普瑞眼科HIS重构';
  let [form] = Form.useForm();
  let userNameRef = useRef(null);
  let passWordRef = useRef(null);
  let departmentListRef = useRef(null);
  let inputCodeRef = useRef(null);
  let graphicCodeRef = useRef(null);
  const navigate = useNavigate();
  // 登录按钮loading
  const [loading, setLoading] = useState(false);
  const [submitLoginName, setSubmitLoginName] = useState('登录');
  const [checked, setChecked] = useState(false);
  const [openSelect, setOpenSelect] = useState(false);
  const [departmentDisabled, setDepartmentDisabled] = useState(true); // 角色选择置灰
  const [userLogonType, setUserLogonType] = useState('');
  const [electedRecord, setSelectedRecord] = useState({});
  const [bakUserName, setBakUserName] = useState(''); // 缓存用户名
  const [bakPassword, setBakPassword] = useState(''); // 缓存密码 - 用户名密码一直时无需重复获取角色数据

  useEffect(() => {
    const loginChecked = getCookies('loginChecked');
    if (loginChecked) {
      const appInfo = React.$getLocalStorageData(envConfig?.['ROOT_APP_INFO'] || 'drg-info');
      let { checked, passWord, userName } = JSON.parse(decrypt(loginChecked));
      if (appInfo && JSON.stringify(appInfo) !== '{}' && checked) { // 设置免登陆则直接跳转
        navigate('/home');
      } else {
        setChecked(checked);
        form.setFieldsValue({
          userName,
          passWord
        });
      }
    }
    userNameRef && userNameRef.current?.focus(); // 用户名输入域获取焦点
  }, []);

  // 记住密码
  const handleCheckedChange = async (e) => {
    setChecked(e.target.checked);
  };

  // 验证码校验
  const validateInputCode = async (rule, value) => {
    if (value) {
      let verify = await graphicCodeRef.current.verify(value);
      if (!verify) throw new Error('验证码错误！');
    }
  };

  const handleUserNameChange = () => {
    form.setFieldsValue({
      passWord: undefined,
      department: undefined,
    });
    setDepartmentDisabled(true);
    setSelectedRecord({});
    setBakUserName(''); // 清除缓存数据
    setBakPassword('');
  };

  // 下一步
  const handleNextStep = async (type) => {
    console.log('触发了下一步')
    const { userName, passWord, department, inputCode } = form.getFieldsValue();
    if (!userName) {
      userNameRef && userNameRef.current?.focus();
    } else if (!passWord) {
      userName && passWordRef.current?.focus();
    } else if (!department) {
      getDepartmentListByLogin(type);
    } else if (!inputCode) { // 验证码获取焦点
      type === 'submit' && form.validateFields();
      inputCodeRef && inputCodeRef.current?.focus();
    } else {
      handleSubmit();
    }
  };

  // 登录密码获取科室
  const getDepartmentListByLogin = async () => {
    try {
      const { userName, passWord } = form.getFieldsValue();
      if (userName && passWord && passWord != '' && userName != '') {
        // 判断是否已经缓存了用户名、密码
        if ((userName === bakUserName) && (passWord === bakPassword)) {
          return;
        } else {
          setDepartmentDisabled(true);
        }
      }
      let data = {
        params: [{
          userName,
          passWord: encrypt(passWord)
        }],
        session: [{
          loginIp: window.location && window.location.protocol && window.location.host ? (
            window.location.host.split(':')[0]
          ) : (window.location && window.location.origin ? (window.location.origin.split(':')[0] + window.location.origin.split(':')[1]).split('//')[1] : '')
        }]
      };
      const res = await React.$asyncPost('01010001', data);
      let result = res.result[0];
      setBakUserName(userName);
      setBakPassword(passWord);
      setUserLogonType(result?.userLogonType || '');
      if (result.othLocFlag === 'Y') {
        setDepartmentDisabled(false);
      }
      const userID = result?.loginUserID || result?.logonUserID || result?.userID || '';
      const userCode = result?.loginUserCode || result?.logonUserCode || result?.userCode || '';
      setDepartmentValues({
        ...result,
        loginUserID: userID,
        loginUserCode: userCode,
        loginUserDesc: result?.userName || result?.loginUserDesc || result?.logonUserDesc || '',
        loginGroupDesc: result?.groupDesc || result?.loginGroupDesc || result?.logonGroupDesc || '',
        loginGroupID: result?.groupID || result?.loginGroupID || result?.logonGroupID || '',
        loginHospDesc: result?.hospDesc || result?.loginHospDesc || result?.logonHospDesc || '',
        loginHospID: result?.hospID || result?.loginHospID || result?.logonHospID || '',
      });
      // 加载当前用户下所有的角色列表
      departmentListRef && departmentListRef?.current?.getDepartmentList(userCode, userID);
    } catch (error) {
      console.log(error);
    }
  };

  // set 当前选择的角色
  const setDepartmentValues = (data) => {
    setOpenSelect(false);
    const userDesc = data?.userName || data?.loginUserDesc || data?.logonUserDesc || '';
    const groupDesc = data?.groupDesc || data?.loginGroupDesc || data?.logonGroupDesc || '';
    const hospDesc = data?.hospDesc || data?.loginHospDesc || data?.logonHospDesc || '';
    let department = (userDesc || '--') + ' | ' + (groupDesc || '--') + ' | ' + (hospDesc || '--');
    form.setFieldsValue({
      department
    });
    setSelectedRecord(data); // 角色数据-保存用
    inputCodeRef && inputCodeRef.current?.focus(); // 验证码获取焦点
  };

  // 确认登录
  const handleSubmit = async () => {
    let ifconfig = React.$getSessionData('ifconfig');
    form.validateFields()
      .then(async value => {
        if (!(value?.error)) {
          let data = {
            params: [{
              ...electedRecord,
              ...value,
              userLogonType,
              passWord: encrypt(value?.passWord || ''),
              deviceID: ifconfig?.hostName || '',
              IP: ifconfig?.ipv4 || '',
              mac: ifconfig?.mac || '',
            }]
          };
          const res = await React.$asyncPost('01010002', data);
          let userInfo = React.$getArrayLength(res?.result || []) > 0 ? res.result[0] : {};
          // 存储用户信息 角色信息
          React.$setLocalStorageData(envConfig?.['ROOT_APP_INFO'] || 'drg-info', {
            userInfo,
            token: userInfo?.sessionID || ''
          });
          getMenu(userInfo?.defaultMenuType || '').then(() => {
            const loginChecked = getCookies('loginChecked');
            if (checked) { // 以当前登录时间算七天免登录
              value.checked = checked;
              setCookies('loginChecked', encrypt(JSON.stringify(value)), 7); // 7天有效期
            } else if (loginChecked) {
              removeCookies('loginChecked', 7);
            }
            setTimeout(() => {
              navigate('/home');
            }, 300);
            // 判断是否是登录页进入首页
            React.$setLocalStorageData('isLogin', 'Y', false);
          })
          setLoading(false);
          setSubmitLoginName('登录');
        }
      })
  };

  return (
    <div className="login" style={{ backgroundImage: `url(${loginBg})` }}>
      <div className="login-content-box">
        {/* <div className="logo_left_top"><img src="" alt="" /></div> */}
        <div className="login-content">
          <div className="haed">
            <h2>
              {ROOT_APP_NAME}
            </h2>
          </div>
          <div>
            <Form
              name="normal_login"
              className="login-form"
              form={form}
            >
              <Form.Item
                name="userName"
                rules={[
                  { required: true, message: '请输入用户名!' },
                  { min: 3, message: '最少长度为3位' },
                  { max: 20, message: '最大长度为20位' },
                  { pattern: /^[0-9a-zA-Z@~!#$%^&*`.-_]{1,}$/, message: '包含非法字符' },
                ]}
              >
                <Input
                  size="large"
                  placeholder="用户名"
                  prefix={<UserOutlined className="site-form-item-icon" />}
                  ref={userNameRef}
                  onChange={handleUserNameChange}
                  onPressEnter={handleNextStep}
                />
              </Form.Item>
              <Form.Item
                name="passWord"
                rules={[
                  { required: true, whitespace: false, message: '请输入登录密码!' },
                  { min: 6, message: '最少长度为6位' },
                  { max: 18, message: '最大长度为18位' },
                  { pattern: /^[0-9a-zA-Z?=.*[~!@#$%^&*()_+`\-={}:";'<>?,./]{6,}$/, message: '必须为数字，字母，特殊符号组成' },
                ]}
              >
                <Input.Password
                  size="large"
                  type="password"
                  placeholder="密码"
                  prefix={<LockOutlined className="site-form-item-icon" />}
                  ref={passWordRef}
                  onPressEnter={handleNextStep}
                />
              </Form.Item>
              <div>
                <Form.Item
                  name="department"
                >
                  <Input
                    size="large"
                    readOnly="readOnly"
                    className="department"
                    prefix={<BarsOutlined />}
                    disabled={departmentDisabled}
                    placeholder="点击选择角色/医院"
                    onClick={() => setOpenSelect(nOpen => !nOpen)}
                  />
                </Form.Item>
                <div style={{ position: 'absolute', width: 420, zIndex: 999, display: openSelect ? '' : 'none' }}>
                  <DepartmentList
                    ref={departmentListRef}
                    setDepartmentValues={setDepartmentValues}
                  />
                </div>
              </div>
              <Form.Item
                name="inputCode"
                rules={[
                  { required: true, message: '请输入验证码!' },
                  { validator: validateInputCode }
                ]}
              >
                <Row justify="space-between">
                  <Col className="login-verification-code">
                    <Input
                      size="large"
                      placeholder="验证码"
                      prefix={<SafetyCertificateOutlined className="site-form-item-icon" />}
                      ref={inputCodeRef}
                      onPressEnter={() => handleNextStep('submit')}
                    />
                  </Col>
                  <Col>
                    <GraphicCode ref={graphicCodeRef} />
                  </Col>
                </Row>
              </Form.Item>
              <Form.Item>
                <Checkbox onChange={handleCheckedChange} checked={checked}>七天免登陆</Checkbox>
              </Form.Item>
              <Form.Item>
                <Button
                  type="primary"
                  className="login-form-button"
                  loading={loading}
                  disabled={loading}
                  onClick={handleSubmit}
                >
                  {submitLoginName}
                </Button>
              </Form.Item>
            </Form>
          </div>
        </div>
      </div>
      <Author />
    </div>
  );
};

function Author() {
  const ROOT_APP_COPYRIGHT = envConfig?.ROOT_APP_COPYRIGHT || 'Copyright © 2025 - 2025 普瑞数字化发展中心';

  return (
    <div className="author">
      <p>{ROOT_APP_COPYRIGHT}</p>
    </div>
  )
}

export default Login;
