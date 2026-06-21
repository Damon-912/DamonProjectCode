#!/usr/bin/env node

/**
 * 测试 Java MCP 服务器连接
 * 需要先启动 Java MCP 服务器: start-java-mcp.bat
 */

const axios = require('axios');

const MCP_SERVER_URL = 'http://localhost:8090';
const API_KEY = 'drg-mcp-access-key-2026';

const headers = {
  'Content-Type': 'application/json',
  'X-API-Key': API_KEY
};

async function testConnection() {
  console.log('===============================================');
  console.log('测试 Java MCP 服务器连接');
  console.log('===============================================');
  console.log('');

  try {
    // 测试 1: 检查服务器健康状态
    console.log('[测试 1] 检查服务器健康状态...');
    const healthResponse = await axios.get(`${MCP_SERVER_URL}/health`, { headers });
    console.log('✅ 服务器健康:', healthResponse.data);
    console.log('');

    // 测试 2: 列出可用工具
    console.log('[测试 2] 列出可用工具...');
    const toolsResponse = await axios.get(`${MCP_SERVER_URL}/mcp/tools`, { headers });
    console.log('✅ 可用工具:');
    toolsResponse.data.tools.forEach(tool => {
      console.log(`   - ${tool.name}: ${tool.description}`);
    });
    console.log('');

    // 测试 3: 执行 SQL 查询
    console.log('[测试 3] 执行 SQL 查询...');
    const sqlQuery = {
      tool: 'execute_sql',
      parameters: {
        sql: 'SELECT TOP 5 * FROM DRG_User.UserInfo',
        params: []
      }
    };
    const sqlResponse = await axios.post(`${MCP_SERVER_URL}/mcp/call`, sqlQuery, { headers });
    console.log('✅ SQL 查询结果:');
    console.log(JSON.stringify(sqlResponse.data, null, 2));
    console.log('');

    // 测试 4: 查询表数据
    console.log('[测试 4] 查询表数据...');
    const tableQuery = {
      tool: 'query_table',
      parameters: {
        table: 'DRG_User.UserInfo',
        fields: ['ID', 'UserCode', 'UserName'],
        limit: 5
      }
    };
    const tableResponse = await axios.post(`${MCP_SERVER_URL}/mcp/call`, tableQuery, { headers });
    console.log('✅ 表数据查询结果:');
    console.log(JSON.stringify(tableResponse.data, null, 2));
    console.log('');

    console.log('===============================================');
    console.log('✅ 所有测试通过！Java MCP 服务器工作正常');
    console.log('===============================================');

  } catch (error) {
    console.error('❌ 测试失败:', error.message);
    if (error.response) {
      console.error('错误详情:', error.response.data);
    }
    console.log('');
    console.log('请确保:');
    console.log('  1. Java MCP 服务器已启动 (运行 start-java-mcp.bat)');
    console.log('  2. IRIS 数据库可访问');
    console.log('  3. 端口 8090 未被占用');
    process.exit(1);
  }
}

testConnection();
