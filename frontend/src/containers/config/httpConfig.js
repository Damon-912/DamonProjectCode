// DRG医保控费系统 - API配置
// 生产环境使用相对路径，通过Nginx代理转发
// 开发环境使用Vite代理（见 vite.config.ts）

 let ipDeault = '172.16.2.15'; // 生产环境留空，使用相对路径

// 开发环境配置（本地开发时使用）
// let ipDeault = 'http://111.229.137.113:52773'; // 云服务器IRIS

// 238测试库 【中台内测版、医保内测版、测试稳定版】
// let ipDeault = 'http://m00.puruiit.cn:3591';

// 241测试库
// let ipDeault = 'http://m00.puruiit.cn:3596';

// 测试库248
//let ipDeault = 'http://m00.puruiit.cn:3290';

 let urlAddress = '/iris-api/invoke'; // 生产环境：通过Nginx代理转发到IRIS
//let urlAddress = '/bdhealth/';
//let urlAddress = '/bdhealthEncrypt/';
//let urlAddress = '/hygservice/sysInternalMutiple'; // 测试库248

let errorCodeArr = ['01040052', '01040053', '01040054', '01040055', '01040057', '01040059', '01040106']; // 固定错误提示数组

const httpConfig = {
  // proxy: true, // 是否开启代理，本地调试时测试库不需要开启，1.6需要

  // 默认的URLIp路径
  ipDeault,

  // 默认的URL地址路径
  urlAddress,

  insuPort: '8469', // 医保平台端口号

  // AuthorizationToken值
  authorizationToken: 'Basic cHJoaXA6cHJoaXBAMjAyMA==', // 生产库
 // authorizationToken: 'Basic X3N5c3RlbTppcmlz==', // 238、241测试库
  // authorizationToken: 'Basic cHJoaXA6cHJoaXBAMjAyMA==', // 248测试库

  // 固定错误提示数组
  errorCodeArr,

  // 项目名称 document.title
  documentTitle: '普瑞眼科HIS',

  // Copyright
  Copyright: 'Copyright © 2020 - 2026 普瑞数字化发展中心',

  // DownUrl 服务下载地址
  DownUrl: 'http://172.18.100.86/xystools/setup.exe',

  // 版本号
  HISVersion: 'V 01.2026.06.11'
};

export { httpConfig };
