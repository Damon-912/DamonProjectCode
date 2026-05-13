/**
 * 组件数据入库脚本
 * 用于将转换后的 columns/formData 数据写入数据库
 * 
 * 使用方式: node push-to-db.cjs <dataFilePath>
 * 示例: node push-to-db.cjs ./push-data.json
 */

const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');

// 日志文件
const logFile = path.join(__dirname, 'push-to-db.log');

// 日志函数
function log(msg) {
  const timestamp = new Date().toISOString();
  const line = `[${timestamp}] ${msg}\n`;
  console.log(msg);
  fs.appendFileSync(logFile, line);
}

// 清空日志文件
fs.writeFileSync(logFile, '');

// API配置 - 从 httpConfig.js 同步
const API_CONFIG = {
  // AI开发测试地址
  baseUrl: 'http://139.199.176.179:8090',
  path: '/bdhealth/',
  authorization: 'Basic cHJoaXA6cHJoaXBAMjAyMA=='
};

/**
 * 发送HTTP请求
 */
function sendRequest(url, options, data) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const isHttps = urlObj.protocol === 'https:';
    const lib = isHttps ? https : http;
    
    const reqOptions = {
      hostname: urlObj.hostname,
      port: urlObj.port || (isHttps ? 443 : 80),
      path: urlObj.pathname,
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': options.authorization || API_CONFIG.authorization,
        'Access-Control-Allow-Origin': API_CONFIG.baseUrl
      }
    };

    log(`请求选项: ${JSON.stringify(reqOptions, null, 2)}`);
    log(`请求体: ${JSON.stringify(data, null, 2)}`);

    const req = lib.request(reqOptions, (res) => {
      let responseData = '';
      
      log(`响应状态码: ${res.statusCode}`);
      log(`响应头: ${JSON.stringify(res.headers, null, 2)}`);
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        log(`原始响应: ${responseData}`);
        try {
          const result = JSON.parse(responseData);
          resolve({
            statusCode: res.statusCode,
            data: result
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            data: responseData,
            parseError: true
          });
        }
      });
    });

    req.on('error', (error) => {
      log(`请求错误: ${error.message}`);
      reject(error);
    });

    req.write(JSON.stringify(data));
    req.end();
  });
}

/**
 * 调用01049999接口入库
 */
async function pushToDatabase(componentData) {
  const url = API_CONFIG.baseUrl + API_CONFIG.path;
  
  // 构建请求数据
  const requestData = {
    params: [{
      componentArr: [componentData]
    }],
    code: '01049999',
    session: [{}]  // 空session，不需要登录态
  };

  log('========================================');
  log(`发送请求到: ${url}`);
  log('接口代码: 01049999');
  log(`组件名称: ${componentData.code}`);
  log(`组件描述: ${componentData.descripts}`);
  log(`表头数量: ${componentData.columns?.length || 0}`);
  log(`表单数量: ${componentData.formData?.length || 0}`);
  log('========================================');

  try {
    const response = await sendRequest(url, {}, requestData);
    
    if (response.statusCode !== 200) {
      return {
        success: false,
        error: `HTTP错误: ${response.statusCode}`,
        data: response.data
      };
    }

    if (response.parseError) {
      return {
        success: false,
        error: '响应解析失败',
        data: response.data
      };
    }

    const result = response.data;
    log(`完整响应数据: ${JSON.stringify(result, null, 2)}`);
    
    if (result.errorCode === '0' || result.errorCode === 0) {
      return {
        success: true,
        message: result.errorMessage || '入库成功',
        data: result
      };
    } else {
      return {
        success: false,
        error: result.errorMessage || '接口返回错误',
        errorCode: result.errorCode,
        data: result
      };
    }
  } catch (error) {
    return {
      success: false,
      error: error.message,
      stack: error.stack
    };
  }
}

/**
 * 主函数
 */
async function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    log('错误: 请提供数据文件路径');
    console.log('用法: node push-to-db.cjs <dataFilePath>');
    console.log('示例: node push-to-db.cjs ./push-data.json');
    process.exit(1);
  }

  const dataFilePath = args[0];
  const absolutePath = path.resolve(dataFilePath);

  // 检查文件是否存在
  if (!fs.existsSync(absolutePath)) {
    log(`错误: 文件不存在 - ${absolutePath}`);
    process.exit(1);
  }

  // 读取数据文件
  let componentData;
  try {
    const fileContent = fs.readFileSync(absolutePath, 'utf-8');
    componentData = JSON.parse(fileContent);
  } catch (error) {
    log(`错误: 解析JSON失败 - ${error.message}`);
    process.exit(1);
  }

  // 验证必要字段
  if (!componentData.code) {
    log('错误: 缺少必要字段 code (componentName)');
    process.exit(1);
  }

  // 执行入库
  const result = await pushToDatabase(componentData);

  if (result.success) {
    log('入库成功!');
    log(`消息: ${result.message}`);
    console.log('✅ 入库成功!');
    console.log('📌 消息:', result.message);
    console.log(`📄 详细日志: ${logFile}`);
    process.exit(0);
  } else {
    log(`入库失败: ${result.error}`);
    console.error('❌ 入库失败!');
    console.error('📌 错误:', result.error);
    if (result.errorCode) {
      console.error('📌 错误码:', result.errorCode);
    }
    console.log(`📄 详细日志: ${logFile}`);
    process.exit(1);
  }
}

// 执行主函数
main();
