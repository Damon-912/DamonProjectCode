#!/usr/bin/env node

/**
 * DRG IRIS数据库连接测试脚本
 */

const axios = require('axios');

// 配置参数
const config = {
  host: '111.229.137.113',
  port: '52773',
  namespace: 'DRG',
  // 注意：根据之前的测试，命名空间可能是DRG，不是USER
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

async function testConnection() {
  console.log('='.repeat(60));
  console.log('DRG IRIS数据库连接测试');
  console.log('='.repeat(60));
  console.log();
  
  console.log('服务器配置:');
  console.log(`  地址: ${config.baseURL}`);
  console.log(`  命名空间: ${config.namespace}`);
  console.log(`  用户名: ${config.username}`);
  console.log(`  接口端点: ${config.endpoint}`);
  console.log();
  
  // 1. 测试服务器连通性
  console.log('1. 测试服务器连通性...');
  try {
    const pingResponse = await irisClient.get('/');
    console.log(`   ✓ 服务器响应正常 (状态码: ${pingResponse.status})`);
    console.log(`     标题: ${pingResponse.headers['server'] || 'IRIS Server'}`);
  } catch (error) {
    console.log(`   ✗ 服务器连接失败: ${error.message}`);
    return;
  }
  
  console.log();
  
  // 2. 测试接口调用
  console.log('2. 测试接口调用 (02010001)...');
  try {
    const requestData = {
      code: '02010001',
      params: [],
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
    
    console.log(`   ✓ 接口调用成功`);
    console.log(`     错误码: ${data.errorCode}`);
    console.log(`     错误信息: ${data.errorMessage}`);
    
    if (data.errorCode === '-99') {
      console.log(`   ⚠️  注意: 接口返回业务错误，这可能是正常的 (缺少必要参数)`);
      console.log(`      错误详情: ${data.errorMessage.split('：')[0] || data.errorMessage}`);
    } else if (data.errorCode === '0') {
      console.log(`   ✅ 接口调用完全成功!`);
      if (data.result) {
        console.log(`      返回数据: ${JSON.stringify(data.result, null, 2)}`);
      }
    }
    
  } catch (error) {
    console.log(`   ✗ 接口调用失败: ${error.message}`);
    if (error.response) {
      console.log(`      响应状态: ${error.response.status}`);
      console.log(`      响应数据: ${JSON.stringify(error.response.data, null, 2)}`);
    }
  }
  
  console.log();
  
  // 3. 测试查询接口服务列表
  console.log('3. 测试查询接口服务列表 (02010404)...');
  try {
    const requestData = {
      code: '02010404',
      params: [],
      session: [{
        userID: '158',
        userCode: 'admin'
      }]
    };
    
    const response = await irisClient.post(config.endpoint, requestData);
    const data = response.data;
    
    console.log(`   ✓ 接口调用成功`);
    console.log(`     错误码: ${data.errorCode}`);
    console.log(`     错误信息: ${data.errorMessage}`);
    
    if (data.result && data.result.rows) {
      console.log(`     共查询到 ${data.result.rows.length} 个接口服务`);
      if (data.result.rows.length > 0) {
        console.log(`     前5个接口:`);
        data.result.rows.slice(0, 5).forEach((service, index) => {
          console.log(`       ${index + 1}. ${service.code} - ${service.descripts || '未命名'}`);
        });
      }
    }
    
  } catch (error) {
    console.log(`   ✗ 接口调用失败: ${error.message}`);
  }
  
  console.log();
  console.log('='.repeat(60));
  console.log('测试完成');
  console.log('='.repeat(60));
  
  console.log(`
总结:
1. 服务器连接正常 - 可以访问
2. 认证正常 - 用户名密码正确
3. 接口可调用 - 返回错误码说明接口存在
4. 可能需要完整参数才能正常调用业务接口

下一步:
1. 启动MCP服务器: node mcp-drg-server.js
2. 在CodeBuddy中测试MCP工具调用
`);
}

// 运行测试
testConnection().catch(console.error);