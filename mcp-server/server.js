#!/usr/bin/env node

/**
 * DRG医保控费预警系统 - MCP服务器主文件
 * 连接到腾讯云IRIS数据库的完整实现
 */

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const { 
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ListResourcesRequestSchema,
  ReadResourceRequestSchema
} = require('@modelcontextprotocol/sdk/types.js');

const axios = require('axios');

// 从环境变量获取配置
const IRIS_HOST = process.env.IRIS_HOST || '111.229.137.113';
const IRIS_PORT = process.env.IRIS_PORT || '52773';
const IRIS_NAMESPACE = process.env.IRIS_NAMESPACE || 'DRG';
const IRIS_USERNAME = process.env.IRIS_USERNAME || '_SYSTEM';
const IRIS_PASSWORD = process.env.IRIS_PASSWORD || '123456';
const MCP_API_KEY = process.env.MCP_API_KEY || 'drg-mcp-access-key-2026';

// IRIS服务器基础URL
const IRIS_BASE_URL = `http://${IRIS_HOST}:${IRIS_PORT}`;
const IRIS_ENDPOINT = `${IRIS_BASE_URL}/csp/${IRIS_NAMESPACE.toLowerCase()}/sysInternalMutiple`;

console.error(`[DRG MCP Server] 启动连接到IRIS服务器: ${IRIS_BASE_URL}`);
console.error(`[DRG MCP Server] 命名空间: ${IRIS_NAMESPACE}`);
console.error(`[DRG MCP Server] 用户名: ${IRIS_USERNAME}`);

// 默认Session配置
const defaultSession = {
  userID: "158",
  userCode: "admin",
  userName: "admin",
  locID: "2300",
  locDesc: "信息中心",
  groupID: "3",
  groupDesc: "医院维护员",
  hospID: "25",
  hospCode: "H03",
  hospDesc: "合肥普瑞眼科医院",
  langID: 1,
  langDesc: "简体中文",
  changeFlag: "N",
  changeDesc: "",
  lastLoginDate: "2026-01-01",
  lastLoginTime: "00:00:00",
  directorAuth: "N",
  defaultMenuType: "2",
  titleDesc: "",
  userYBCode: "",
  hospYBCode: "H34010400768",
  path: "",
  sessionID: "P9BXebxmDI",
  errorMessageTime: "",
  language: "CN",
  messageTime: 1
};

// 创建axios实例
const irisClient = axios.create({
  baseURL: IRIS_BASE_URL,
  timeout: 30000,
  auth: {
    username: IRIS_USERNAME,
    password: IRIS_PASSWORD
  },
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

/**
 * 调用IRIS接口
 */
async function invokeIRISInterface(interfaceCode, params = [], sessionData = null) {
  try {
    const requestData = {
      code: interfaceCode,
      params: params,
      session: [sessionData || defaultSession]
    };

    console.error(`[DRG MCP Server] 调用IRIS接口: ${interfaceCode}`);
    
    const response = await irisClient.post(
      `/csp/${IRIS_NAMESPACE.toLowerCase()}/sysInternalMutiple`,
      requestData
    );

    const data = response.data;
    
    if (data.errorCode === "0") {
      return {
        success: true,
        errorCode: "0",
        errorMessage: "",
        data: data.result || {}
      };
    } else {
      console.error(`[DRG MCP Server] 接口调用失败: ${data.errorMessage}`);
      return {
        success: false,
        errorCode: data.errorCode || "-1",
        errorMessage: data.errorMessage || "接口调用失败",
        data: null
      };
    }
  } catch (error) {
    console.error(`[DRG MCP Server] 接口调用异常:`, error.message);
    return {
      success: false,
      errorCode: "-99",
      errorMessage: `接口调用异常: ${error.message}`,
      data: null
    };
  }
}

// 创建MCP服务器
const server = new Server(
  {
    name: "drg-mcp-server",
    version: "1.0.0",
    description: "DRG医保控费预警系统MCP服务器 - 连接到腾讯云IRIS数据库"
  },
  {
    capabilities: {
      tools: {},
      resources: {}
    }
  }
);

// 注册工具
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "invoke_drg_interface",
        description: "调用DRG系统IRIS接口",
        inputSchema: {
          type: "object",
          properties: {
            interface_code: {
              type: "string",
              description: "接口代码，如01050103",
              required: true
            },
            params: {
              type: "array",
              description: "接口参数数组",
              required: false
            },
            session_data: {
              type: "object",
              description: "会话信息（可选，默认使用内置session）",
              required: false
            }
          },
          required: ["interface_code"]
        }
      },
      {
        name: "query_hospitals",
        description: "查询医院信息表记录",
        inputSchema: {
          type: "object",
          properties: {
            hospital_name: {
              type: "string",
              description: "医院名称（模糊查询）",
              required: false
            },
            organization_code: {
              type: "string",
              description: "机构代码",
              required: false
            },
            active: {
              type: "string",
              description: "是否有效（Y/N）",
              required: false
            },
            page: {
              type: "number",
              description: "页码",
              required: false,
              default: 1
            },
            limit: {
              type: "number",
              description: "每页数量",
              required: false,
              default: 20
            }
          }
        }
      },
      {
        name: "query_hospital_count",
        description: "查询医院信息表记录数",
        inputSchema: {
          type: "object",
          properties: {
            hospital_name: {
              type: "string",
              description: "医院名称（模糊查询）",
              required: false
            },
            active: {
              type: "string",
              description: "是否有效（Y/N）",
              required: false
            }
          }
        }
      },
      {
        name: "query_basic_data",
        description: "查询基础数据",
        inputSchema: {
          type: "object",
          properties: {
            data_type: {
              type: "string",
              description: "数据类型：province（省份）、city（城市）、area（区域）、policy（政策类型）",
              required: true
            },
            parent_code: {
              type: "string",
              description: "父级代码（用于城市、区域查询）",
              required: false
            }
          },
          required: ["data_type"]
        }
      },
      {
        name: "test_connection",
        description: "测试IRIS数据库连接",
        inputSchema: {
          type: "object",
          properties: {}
        }
      }
    ]
  };
});

// 注册资源
server.setRequestHandler(ListResourcesRequestSchema, async () => {
  return {
    resources: [
      {
        uri: "iris://server-info",
        name: "IRIS服务器信息",
        description: "腾讯云IRIS数据库服务器连接信息",
        mimeType: "application/json"
      },
      {
        uri: "drg://interface-docs",
        name: "DRG接口文档",
        description: "DRG系统接口服务文档",
        mimeType: "text/markdown"
      },
      {
        uri: "drg://hospital-data",
        name: "医院数据模型",
        description: "医院信息表结构定义",
        mimeType: "application/json"
      }
    ]
  };
});

// 处理资源读取请求
server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  const { uri } = request.params;
  
  console.error(`[DRG MCP Server] 读取资源: ${uri}`);
  
  if (uri === "iris://server-info") {
    return {
      contents: [
        {
          uri: uri,
          mimeType: "application/json",
          text: JSON.stringify({
            server_type: "InterSystems IRIS",
            host: IRIS_HOST,
            port: IRIS_PORT,
            namespace: IRIS_NAMESPACE,
            username: IRIS_USERNAME,
            base_url: IRIS_BASE_URL,
            endpoint: IRIS_ENDPOINT,
            connection_status: "active",
            timestamp: new Date().toISOString()
          }, null, 2)
        }
      ]
    };
  } else if (uri === "drg://interface-docs") {
    return {
      contents: [
        {
          uri: uri,
          mimeType: "text/markdown",
          text: `# DRG医保控费预警系统 - 接口文档

## 服务器信息
- **地址**: ${IRIS_HOST}:${IRIS_PORT}
- **命名空间**: ${IRIS_NAMESPACE}
- **用户名**: ${IRIS_USERNAME}

## 医院管理接口
- **01050103**: 查询医疗机构分页
- **01050101**: 新增医疗机构
- **01050102**: 修改医疗机构
- **01050104**: 删除医疗机构

## 请求格式
\`\`\`json
{
  "code": "接口代码",
  "params": [{"参数名": "参数值"}],
  "session": [{"userID": "158", "userCode": "admin"}]
}
\`\`\`

## 响应格式
\`\`\`json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": {}
}
\`\`\`
`
        }
      ]
    };
  } else if (uri === "drg://hospital-data") {
    return {
      contents: [
        {
          uri: uri,
          mimeType: "application/json",
          text: JSON.stringify({
            table_name: "CB_Hospital",
            description: "医院信息表",
            fields: [
              { name: "ID", type: "string", description: "主键ID" },
              { name: "Code", type: "string", description: "医院代码" },
              { name: "Descripts", type: "string", description: "医院名称" },
              { name: "HospGrade_Dr", type: "number", description: "医院等级ID" },
              { name: "HospType", type: "string", description: "医院类型" },
              { name: "HospNature", type: "string", description: "医院性质" },
              { name: "ProvID_Dr", type: "number", description: "省份ID" },
              { name: "CityID_Dr", type: "number", description: "城市ID" },
              { name: "AreaID_Dr", type: "number", description: "区域ID" },
              { name: "Active", type: "string", description: "是否有效 (Y/N)" },
              { name: "OrganizationCode", type: "string", description: "组织机构代码" },
              { name: "Businesslicense", type: "string", description: "营业执照" }
            ],
            interface_code: "01050103",
            example_request: {
              code: "01050103",
              params: [{
                desc: "医院名称",
                active: "Y"
              }],
              session: [{
                userID: "158",
                userCode: "admin"
              }]
            }
          }, null, 2)
        }
      ]
    };
  }
  
  throw new Error(`Resource not found: ${uri}`);
});

// 处理工具调用请求
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args = {} } = request.params;
  
  console.error(`[DRG MCP Server] 调用工具: ${name}`, args);
  
  try {
    switch (name) {
      case "invoke_drg_interface": {
        const { interface_code, params = [], session_data } = args;
        
        if (!interface_code) {
          throw new Error("interface_code参数不能为空");
        }
        
        const result = await invokeIRISInterface(
          interface_code,
          params,
          session_data
        );
        
        if (result.success) {
          return {
            content: [
              {
                type: "text",
                text: `✅ 接口调用成功 (${interface_code})\n\n` +
                      `响应数据: ${JSON.stringify(result.data, null, 2)}`
              }
            ]
          };
        } else {
          return {
            content: [
              {
                type: "text",
                text: `❌ 接口调用失败 (${interface_code})\n\n` +
                      `错误代码: ${result.errorCode}\n` +
                      `错误信息: ${result.errorMessage}`
              }
            ]
          };
        }
      }
      
      case "query_hospitals": {
        const { hospital_name, organization_code, active, page = 1, limit = 20 } = args;
        
        const params = [];
        if (hospital_name || organization_code || active) {
          const filterParam = {};
          if (hospital_name) filterParam.desc = hospital_name;
          if (organization_code) filterParam.organizationCode = organization_code;
          if (active) filterParam.active = active;
          params.push(filterParam);
        }
        
        const result = await invokeIRISInterface("01050103", params);
        
        if (result.success) {
          const data = result.data;
          const total = data.total || 0;
          const rows = data.rows || [];
          
          // 分页处理
          const startIndex = (page - 1) * limit;
          const endIndex = Math.min(startIndex + limit, rows.length);
          const pageRows = rows.slice(startIndex, endIndex);
          
          let responseText = `✅ 查询到 ${total} 家医院 (第 ${page} 页，每页 ${limit} 条)\n\n`;
          
          if (pageRows.length > 0) {
            responseText += "**医院列表:**\n";
            pageRows.forEach((hospital, index) => {
              responseText += `${startIndex + index + 1}. ${hospital.code || ''} - ` +
                             `${hospital.descripts || '未知医院'} - ` +
                             `${hospital.gradeDesc || ''} - ` +
                             `${hospital.proDesc || ''}${hospital.cityDesc || ''}\n`;
            });
          } else {
            responseText += "**未找到匹配的医院**";
          }
          
          return {
            content: [
              {
                type: "text",
                text: responseText
              }
            ]
          };
        } else {
          return {
            content: [
              {
                type: "text",
                text: `❌ 查询医院信息失败\n\n` +
                      `错误代码: ${result.errorCode}\n` +
                      `错误信息: ${result.errorMessage}`
              }
            ]
          };
        }
      }
      
      case "query_hospital_count": {
        const { hospital_name, active } = args;
        
        const params = [];
        if (hospital_name || active) {
          const filterParam = {};
          if (hospital_name) filterParam.desc = hospital_name;
          if (active) filterParam.active = active;
          params.push(filterParam);
        }
        
        const result = await invokeIRISInterface("01050103", params);
        
        if (result.success) {
          const data = result.data;
          const total = data.total || 0;
          const rows = data.rows || [];
          
          let responseText = `✅ 医院信息表统计结果:\n\n`;
          responseText += `总记录数: ${total}\n`;
          responseText += `当前查询匹配数: ${rows.length}\n`;
          
          // 状态统计
          const activeCount = rows.filter(h => h.active === 'Y').length;
          const inactiveCount = rows.filter(h => h.active === 'N').length;
          responseText += `有效医院 (Active=Y): ${activeCount}\n`;
          responseText += `无效医院 (Active=N): ${inactiveCount}\n`;
          
          if (hospital_name) {
            responseText += `\n搜索关键词: "${hospital_name}"\n`;
          }
          
          return {
            content: [
              {
                type: "text",
                text: responseText
              }
            ]
          };
        } else {
          return {
            content: [
              {
                type: "text",
                text: `❌ 查询医院记录数失败\n\n` +
                      `错误代码: ${result.errorCode}\n` +
                      `错误信息: ${result.errorMessage}`
              }
            ]
          };
        }
      }
      
      case "query_basic_data": {
        const { data_type, parent_code } = args;
        
        if (!data_type) {
          throw new Error("data_type参数不能为空");
        }
        
        // 根据数据类型调用不同的接口
        let interfaceCode, params = [];
        let dataTypeName = "";
        
        switch (data_type) {
          case "province":
            interfaceCode = "03020101";  // 查询省份
            dataTypeName = "省份";
            break;
          case "city":
            interfaceCode = "03020102";  // 查询城市
            dataTypeName = "城市";
            if (parent_code) params.push({ provIDID: parent_code });
            break;
          case "area":
            interfaceCode = "03020103";  // 查询区域
            dataTypeName = "区域";
            if (parent_code) params.push({ cityIDID: parent_code });
            break;
          case "policy":
            interfaceCode = "03020104";  // 查询政策类型
            dataTypeName = "政策类型";
            break;
          default:
            throw new Error(`不支持的数据类型: ${data_type}`);
        }
        
        const result = await invokeIRISInterface(interfaceCode, params);
        
        if (result.success) {
          const data = result.data;
          const rows = data.rows || [];
          
          let responseText = `✅ 查询到 ${rows.length} 条${dataTypeName}数据\n\n`;
          
          if (rows.length > 0) {
            responseText += `**${dataTypeName}列表:**\n`;
            rows.forEach((item, index) => {
              responseText += `${index + 1}. ${item.code || ''} - ` +
                             `${item.descripts || '未知'}\n`;
            });
          } else {
            responseText += "**未找到数据**";
          }
          
          return {
            content: [
              {
                type: "text",
                text: responseText
              }
            ]
          };
        } else {
          return {
            content: [
              {
                type: "text",
                text: `❌ 查询${dataTypeName}数据失败\n\n` +
                      `错误代码: ${result.errorCode}\n` +
                      `错误信息: ${result.errorMessage}`
              }
            ]
          };
        }
      }
      
      case "test_connection": {
        const result = await invokeIRISInterface("01050103", []);
        
        if (result.success) {
          return {
            content: [
              {
                type: "text",
                text: `✅ IRIS数据库连接测试成功！\n\n` +
                      `服务器: ${IRIS_HOST}:${IRIS_PORT}\n` +
                      `命名空间: ${IRIS_NAMESPACE}\n` +
                      `用户名: ${IRIS_USERNAME}\n` +
                      `医院接口调用成功，可以正常访问`
              }
            ]
          };
        } else {
          return {
            content: [
              {
                type: "text",
                text: `❌ IRIS数据库连接测试失败\n\n` +
                      `错误代码: ${result.errorCode}\n` +
                      `错误信息: ${result.errorMessage}\n\n` +
                      `请检查:\n` +
                      `1. IRIS服务器状态 (${IRIS_HOST}:${IRIS_PORT})\n` +
                      `2. 用户名和密码是否正确\n` +
                      `3. 网络连接是否正常`
              }
            ]
          };
        }
      }
      
      default:
        throw new Error(`未知的工具: ${name}`);
    }
  } catch (error) {
    console.error(`[DRG MCP Server] 工具调用异常:`, error.message);
    
    return {
      content: [
        {
          type: "text",
          text: `❌ 工具调用失败: ${error.message}`
        }
      ]
    };
  }
});

// 启动服务器
async function main() {
  try {
    console.error('[DRG MCP Server] 启动MCP服务器...');
    
    const transport = new StdioServerTransport();
    await server.connect(transport);
    
    console.error('[DRG MCP Server] MCP服务器已启动，等待连接...');
    
    // 处理关闭信号
    process.on('SIGINT', async () => {
      console.error('[DRG MCP Server] 收到关闭信号，正在停止服务器...');
      await server.close();
      process.exit(0);
    });
    
    process.on('SIGTERM', async () => {
      console.error('[DRG MCP Server] 收到终止信号，正在停止服务器...');
      await server.close();
      process.exit(0);
    });
    
  } catch (error) {
    console.error('[DRG MCP Server] 服务器启动失败:', error);
    process.exit(1);
  }
}

// 运行主函数
if (require.main === module) {
  main().catch(console.error);
}