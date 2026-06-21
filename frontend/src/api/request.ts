import axios from 'axios';

// 创建 axios 实例
const request = axios.create({
  baseURL: '/dipapp/iris-api', // 通过 Nginx 代理访问 IRIS
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

  provID: string;
  cityID: string;
  areaCode: string;
  medinsLv: string;
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
export const getDefaultSession = (): SessionInfo => {
  try {
    const sessionStr = localStorage.getItem('drg_session');
    if (sessionStr) {
      const session = JSON.parse(sessionStr);
      return {
        userID: session.userID || '',
        userCode: session.userCode || '',
        userName: session.userName || '',
        locID: session.locID || '',
        locDesc: session.locDesc || '',
        groupID: session.groupID || '',
        groupDesc: session.groupDesc || '',
        hospID: session.hospID || '',
        hospCode: session.hospCode || '',
        hospDesc: session.hospDesc || '',
        langID: session.langID || 1,
        langDesc: session.langDesc || '简体中文',
        changeFlag: session.changeFlag || 'N',
        changeDesc: session.changeDesc || '',
        lastLoginDate: session.lastLoginDate || '',
        lastLoginTime: session.lastLoginTime || '',
        directorAuth: session.directorAuth || 'N',
        defaultMenuType: session.defaultMenuType || '',
        titleDesc: session.titleDesc || '',
        userYBCode: session.userYBCode || '',
        hospYBCode: session.hospYBCode || '',
        provID: session.provID || '',
        cityID: session.cityID || '',
        areaCode: session.areaCode || '',
        medinsLv: session.medinsLv || '',
        path: session.path || '',
        sessionID: session.sessionID || '',
        errorMessageTime: session.errorMessageTime || '',
        language: session.language || 'CN',
        messageTime: session.messageTime || 1,
      };
    }
  } catch (e) {
    console.warn('读取 session 失败:', e);
  }
  // 返回空session（未登录状态）
  return {
    userID: '',
    userCode: '',
    userName: '',
    locID: '',
    locDesc: '',
    groupID: '',
    groupDesc: '',
    hospID: '',
    hospCode: '',
    hospDesc: '',
    langID: 1,
    langDesc: '简体中文',
    changeFlag: 'N',
    changeDesc: '',
    lastLoginDate: '',
    lastLoginTime: '',
    directorAuth: 'N',
    defaultMenuType: '',
    titleDesc: '',
    userYBCode: '',
    hospYBCode: '',

    provID: '',
    cityID: '',
    areaCode: '',
    medinsLv: '',
    path: '',
    sessionID: '',
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
/** 模拟预警记录数据 */
const mockWarningRecords = () => {
  const records = [
    { id: 1, warningNo: 'W202605131400001', ruleCode: 'WR001', ruleName: '费用超支预警（严重）', warningType: '01', warningLevel: 3, hisAdmId: 'ZY20260001', patientName: '张三', deptCode: 'D001', deptName: '心内科', doctorCode: 'DR001', doctorName: '王医生', drgCode: 'ES23', drgName: '呼吸系统肿瘤', totalFee: 15800, insuranceFee: 12000, drgPayStandard: 12000, diffAmount: -3800, diffRate: -31.67, warningMessage: '费用超支预警：患者费用总额15800.00元，DRG支付标准12000.00元，超出3800.00元（-31.67%）', warningStatus: '01', warningDate: '2026-05-13', warningTime: '14:30:00', fixmedinsCode: 'H001', fixmedinsName: '测试人民医院' },
    { id: 2, warningNo: 'W202605131000002', ruleCode: 'WR003', ruleName: '高倍率预警', warningType: '03', warningLevel: 2, hisAdmId: 'ZY20260002', patientName: '李四', deptCode: 'D002', deptName: '骨科', doctorCode: 'DR002', doctorName: '张医生', drgCode: 'IC13', drgName: '关节置换', totalFee: 25000, insuranceFee: 18000, drgPayStandard: 18000, diffAmount: -7000, diffRate: -38.89, warningMessage: '高倍率预警：患者费用总额25000.00元，DRG支付标准18000.00元，超出7000.00元（-38.89%）', warningStatus: '01', warningDate: '2026-05-13', warningTime: '10:15:00', fixmedinsCode: 'H001', fixmedinsName: '测试人民医院' },
    { id: 3, warningNo: 'W202605121600003', ruleCode: 'WR002', ruleName: '费用超支预警（警告）', warningType: '01', warningLevel: 2, hisAdmId: 'ZY20260003', patientName: '王五', deptCode: 'D001', deptName: '心内科', doctorCode: 'DR003', doctorName: '陈医生', drgCode: 'FB23', drgName: '心脏介入治疗', totalFee: 18500, insuranceFee: 15000, drgPayStandard: 15000, diffAmount: -3500, diffRate: -23.33, warningMessage: '费用超支预警：患者费用总额18500.00元，DRG支付标准15000.00元，超出3500.00元（-23.33%）', warningStatus: '03', warningDate: '2026-05-12', warningTime: '16:45:00', processUser: '赵医生', processDate: '2026-05-12', processTime: '17:30:00', processRemark: '患者合并多种基础疾病，费用在合理范围', fixmedinsCode: 'H001', fixmedinsName: '测试人民医院' },
    { id: 4, warningNo: 'W202605120900004', ruleCode: 'WR004', ruleName: '低倍率预警', warningType: '02', warningLevel: 1, hisAdmId: 'ZY20260004', patientName: '赵六', deptCode: 'D003', deptName: '普外科', doctorCode: 'DR004', doctorName: '孙医生', drgCode: 'GC13', drgName: '消化系统其他手术', totalFee: 4500, insuranceFee: 8000, drgPayStandard: 8000, diffAmount: 3500, diffRate: 43.75, warningMessage: '低倍率预警：患者费用总额4500.00元，DRG支付标准8000.00元', warningStatus: '02', warningDate: '2026-05-12', warningTime: '09:30:00', processUser: '钱主任', processDate: '2026-05-12', processTime: '11:00:00', processRemark: '患者恢复良好提前出院', fixmedinsCode: 'H001', fixmedinsName: '测试人民医院' },
    { id: 5, warningNo: 'W202605111100005', ruleCode: 'WR005', ruleName: '编码异常预警', warningType: '04', warningLevel: 2, hisAdmId: 'ZY20260005', patientName: '钱七', deptCode: 'D004', deptName: '神经内科', doctorCode: 'DR005', doctorName: '周医生', drgCode: 'BR23', drgName: '神经系统肿瘤', totalFee: 12000, insuranceFee: 12000, drgPayStandard: 12000, diffAmount: 0, diffRate: 0, warningMessage: '编码异常预警：主诊断编码可能存在问题，请核查', warningStatus: '01', warningDate: '2026-05-11', warningTime: '11:20:00', fixmedinsCode: 'H001', fixmedinsName: '测试人民医院' },
    { id: 6, warningNo: 'W202605101500006', ruleCode: 'WR001', ruleName: '费用超支预警（严重）', warningType: '01', warningLevel: 3, hisAdmId: 'ZY20260006', patientName: '孙八', deptCode: 'D002', deptName: '骨科', doctorCode: 'DR006', doctorName: '吴医生', drgCode: 'IC13', drgName: '关节置换', totalFee: 32000, insuranceFee: 22000, drgPayStandard: 22000, diffAmount: -10000, diffRate: -45.45, warningMessage: '费用超支预警：患者费用总额32000.00元，DRG支付标准22000.00元，超出10000.00元（-45.45%）', warningStatus: '02', warningDate: '2026-05-10', warningTime: '15:00:00', processUser: '郑主任', processDate: '2026-05-10', processTime: '16:30:00', processRemark: '术后感染需长期抗感染治疗，费用合理', fixmedinsCode: 'H001', fixmedinsName: '测试人民医院' },
  ];
  return records.map((r, i) => ({ ...r, id: String(r.id) }));
};

/** 计算模拟统计数据 */
const mockWarningStats = () => {
  const records = mockWarningRecords();
  const statusCounts: Record<string, number> = {};
  const typeCounts: Record<string, number> = {};
  const levelCounts: Record<number, number> = { 1: 0, 2: 0, 3: 0 };
  let totalDiff = 0;
  let totalFee = 0;

  records.forEach(r => {
    statusCounts[r.warningStatus] = (statusCounts[r.warningStatus] || 0) + 1;
    typeCounts[r.warningType] = (typeCounts[r.warningType] || 0) + 1;
    levelCounts[r.warningLevel] = (levelCounts[r.warningLevel] || 0) + 1;
    totalDiff += (r.diffAmount || 0);
    totalFee += (r.totalFee || 0);
  });

  return {
    totalCount: records.length,
    pendingCount: statusCounts['01'] || 0,
    processedCount: (statusCounts['02'] || 0) + (statusCounts['03'] || 0) + (statusCounts['04'] || 0) + (statusCounts['05'] || 0),
    typeStats: Object.entries(typeCounts).map(([type, count]) => {
      const typeNames: Record<string, string> = { '01': '费用超支', '02': '低倍率', '03': '高倍率', '04': '编码异常', '05': '分解住院', '06': '费用过低' };
      return { type: typeNames[type] || type, count };
    }),
    levelStats: Object.entries(levelCounts).map(([level, count]) => ({
      level: level === '1' ? '低' : level === '2' ? '中' : level === '3' ? '高' : level,
      count,
    })),
    totalDiff,
    totalFee,
  };
};

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

  // 预警统计接口 02010106 - 开发模式模拟数据
  if (code === '02010106') {
    return {
      errorCode: '0',
      errorMessage: '(dev)',
      result: mockWarningStats(),
    };
  }

  // 预警记录查询接口 02010103 - 开发模式模拟数据
  if (code === '02010103') {
    const allRecords = mockWarningRecords();
    return {
      errorCode: '0',
      errorMessage: '(dev)',
      result: {
        rows: allRecords,
        total: allRecords.length,
      },
    };
  }

  // 预警处理接口 02010104 - 开发模式模拟响应
  if (code === '02010104') {
    return {
      errorCode: '0',
      errorMessage: '(dev) 处理成功',
      result: {},
    };
  }

  return { errorCode: '-1', errorMessage: '未实现的接口' };
};

export default request;
