import axios from 'axios';

// 创建 axios 实例
const request = axios.create({
  baseURL: '/iris-api', // 通过 Nginx 代理访问 IRIS
  timeout: 30000,
});

// 请求拦截器
request.interceptors.request.use(
  (config) => {
    // 可以在这里添加 token 等认证信息
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 响应拦截器
request.interceptors.response.use(
  (response) => {
    return response.data;
  },
  (error) => {
    console.error('API请求错误:', error);
    return Promise.reject(error);
  }
);

/**
 * Session 信息类型 - 完整字段定义
 */
export interface SessionInfo {
  userID: string;
  userCode: string;
  userName: string;
  locID: string;
  locDesc: string;
  groupID: string;
  groupDesc: string;
  hospID: string;
  hospCode: string;
  hospDesc: string;
  langID: number;
  langDesc: string;
  changeFlag: string;
  changeDesc: string;
  lastLoginDate: string;
  lastLoginTime: string;
  directorAuth: string;
  defaultMenuType: string;
  titleDesc: string;
  userYBCode: string;
  hospYBCode: string;
  path: string;
  sessionID: string;
  errorMessageTime: string;
  language: string;
  messageTime: number;
}

/**
 * 获取默认 Session 信息
 * 从 localStorage 中读取或使用默认值
 */
const getDefaultSession = (): SessionInfo => {
  try {
    const sessionStr = localStorage.getItem('session');
    if (sessionStr) {
      return JSON.parse(sessionStr);
    }
  } catch (e) {
    console.warn('读取 session 失败:', e);
  }
  // 返回默认 session（临时默认值）- 所有字段必须有值，无值传空
  return {
    userID: '158',
    userCode: 'admin',
    userName: 'admin',
    locID: '2300',
    locDesc: '信息中心',
    groupID: '3',
    groupDesc: '医院维护员',
    hospID: '25',
    hospCode: 'H03',
    hospDesc: '合肥普瑞眼科医院',
    langID: 1,
    langDesc: '简体中文',
    changeFlag: 'N',
    changeDesc: '',
    lastLoginDate: '2026-01-01',
    lastLoginTime: '00:00:00',
    directorAuth: 'N',
    defaultMenuType: '2',
    titleDesc: '',
    userYBCode: '',
    hospYBCode: 'H34010400768',
    path: '',
    sessionID: 'P9BXebxmDI',
    errorMessageTime: '',
    language: 'CN',
    messageTime: 1,
  };
};

/**
 * 通用接口调用方法
 * @param code 接口代码
 * @param params 接口参数数组
 * @param session Session 信息（可选，默认从 localStorage 读取）
 * @param pagination 分页参数（可选，仅查询接口使用）
 */
export const invoke = (
  code: string,
  params?: any[],
  session?: SessionInfo,
  pagination?: any
) => {
  const requestData: any = {
    code,
    params: params || [],
    session: [session || getDefaultSession()],
  };
  // 如果有分页参数，添加到请求中（仅查询接口使用）
  if (pagination) {
    requestData.pagination = [pagination];
  }
  return request({
    url: '/invoke',
    method: 'post',
    data: requestData,
  }).catch((error) => {
    // 如果是开发模式，返回模拟数据
    console.warn('接口调用失败，返回模拟数据:', error.message);
    return getMockResponse(code);
  });
};

/**
 * 获取模拟响应数据（用于开发预览）
 */
const getMockResponse = (code: string): any => {
  if (code === '02010001') {
    // DRG分组器模拟响应 - 最新结构
    return {
      errorCode: '0',
      errorMessage: 'success',
      result: {
        mdc: 'MDCC',
        mdcDesc: '主诊断大类入组MDCC：眼疾病及功能障碍',
        complicationInfo: [
          {
            diagCode: 'E10.700x022',
            diagName: '1型糖尿病性高血压',
            complication: 'CC',
            complicationDesc: '并发症'
          }
        ],
        drgInfo: [
          {
            code: 'CB55',
            desc: '晶状体手术：表示不伴有并发症与合并症'
          },
          {
            code: 'CW15',
            desc: '各种类型白内障：表示不伴有并发症与合并症'
          }
        ],
        checkTime: new Date().toLocaleString(),
      },
    };
  }
  return { errorCode: '-1', errorMessage: '未实现的接口' };
};

export default request;
