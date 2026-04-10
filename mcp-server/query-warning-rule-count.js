#!/usr/bin/env node

/**
 * 查询 BS_DRGWarningRule 表记录数
 */

const axios = require('axios');

// 配置参数
const config = {
  host: '111.229.137.113',
  port: '52773',
  namespace: 'DRG',
  username: '_SYSTEM',
  password: '123456',
  baseURL: 'http://111.229.137.113:52773',
  endpoint: '/csp/drg/sysInternalMutiple'
};

// 创建axios实例
const irisClient = axios.create({
  baseURL: config.baseURL,
  timeout: 30000,
  auth: {
    username: config.username,
    password: config.password
  },
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

async function queryWarningRuleCount() {
  console.log('='.repeat(60));
  console.log('查询 BS_DRGWarningRule 表记录数');
  console.log('='.repeat(60));
  console.log();
  
  console.log('服务器配置:');
  console.log(`  地址: ${config.baseURL}`);
  console.log(`  命名空间: ${config.namespace}`);
  console.log(`  接口端点: ${config.endpoint}`);
  console.log();
  
  // 调用查询预警规则接口 (02010101)
  console.log('调用接口 02010101 - 查询预警规则...');
  try {
    const requestData = {
      code: '02010101',
      params: [{}],
      session: [{
        userID: '158',
        userCode: 'admin',
        userName: 'admin',
        locID: '2300',
        locDesc: '信息中心',
        groupID: '3',
        groupDesc: '医院维护员',
        hospID: '25',
        hospCode: 'H03',
        hospDesc: '合肥普瑞眼科医院'
      }]
    };
    
    const response = await irisClient.post(config.endpoint, requestData);
    const data = response.data;
    
    console.log(`接口调用成功!`);
    console.log(`  错误码: ${data.errorCode}`);
    console.log(`  错误信息: ${data.errorMessage || '无'}`);
    console.log();
    
    if (data.errorCode === '0' && data.result) {
      const result = data.result;
      console.log('✅ 查询结果:');
      console.log(`  BS_DRGWarningRule 表总记录数: ${result.total || 0}`);
      console.log();
      
      if (result.rows && result.rows.length > 0) {
        console.log(`  返回记录数: ${result.rows.length}`);
        console.log();
        console.log('预警规则列表:');
        result.rows.forEach((rule, index) => {
          console.log(`  ${index + 1}. ID:${rule.id} | 编码:${rule.ruleCode} | 名称:${rule.ruleName} | 类型:${rule.ruleType} | 启用:${rule.isActive}`);
        });
      } else {
        console.log('  暂无预警规则数据');
      }
    } else {
      console.log('⚠️ 接口返回错误:', data.errorMessage);
    }
    
  } catch (error) {
    console.log(`❌ 接口调用失败: ${error.message}`);
    if (error.response) {
      console.log(`   响应状态: ${error.response.status}`);
      console.log(`   响应数据: ${JSON.stringify(error.response.data, null, 2)}`);
    }
  }
  
  console.log();
  console.log('='.repeat(60));
  console.log('查询完成');
  console.log('='.repeat(60));
}

// 运行查询
queryWarningRuleCount().catch(console.error);
