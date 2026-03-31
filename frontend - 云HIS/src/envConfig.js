// 项目信息配置相关
let envConfig = {
    key: 0, // 环境地址 0:开发 1:测试  2:生产
    proxy: false, // 是否开启代理，允许跨域（只在开发环境有效 true/false)
    ROOT_APP_NAME: 'DRGs质控平台', // 项目系统名称
    API_BASE_URL: '', // 地址域名IP等(此处为空禁写，请在switch语句配置地址)
    API_BASE_TOKEN: '', // 请求token
    API_BASE_PORT: '', // 二级地址（可为空），用于拼接API_BASE_URL后面
    API_BASE_TIMEOUT: 30, // 请求超时时间（单位/s）
    ROOT_APP_INFO: 'drg-info', // 本地存储名称（用户信息、角色信息、菜单信息、token等）为避免项目冲突请给每个项目单独命名
    ROOT_APP_COLOR: '#1890ff', // 主题色（浅蓝#1890ff、深蓝#2f54eb、火红#f5222d、浅红#fa541c、橙#faad14、青#13C2C2、绿#52c41a、紫#a876ed）
    ROOT_APP_VERSION: '0.0.0.1', // 当前版本号
    ROOT_APP_COPYRIGHT: 'Copyright © 2025 - 2026 普瑞数字化发展中心', // 版权
};

const { key, proxy } = envConfig;

switch (key) {
    case 0: // 开发地址
        // 无需代理(禁止跨域)地址，如开启允许跨域，必须和vite.config.js配置文件下proxy的目标代理地址一致
        envConfig['WINDOW_HOST'] = 'https://172.16.1.6';
        envConfig['API_BASE_URL'] = proxy ? '/dip/sysInternalMutiple' : 'https://172.16.1.6';
        envConfig['API_BASE_PORT'] = proxy ? '' : '/dip/sysInternalMutiple';
        envConfig['API_BASE_TOKEN'] = 'Basic cHJkaXA6cHJkaXBAMjAyMA==';
        break;
    case 1: // 测试241
        envConfig['API_BASE_URL'] = 'http://m00.puruiit.cn:3596';
        envConfig['API_BASE_PORT'] = '/bdhealth/';
        envConfig['API_BASE_TOKEN'] = 'Basic X3N5c3RlbTppcmlz==';
        break;
    case 2: // 线上地址
        envConfig['API_BASE_URL'] = 'https://172.16.1.6'; // 正式库地址
        envConfig['API_BASE_PORT'] = '/dip/sysInternalMutiple';
        envConfig['API_BASE_TOKEN'] = 'Basic cHJkaXA6cHJkaXBAMjAyMA==';
        break;
    default:
        break;
};

const windowHost = window.location && window.location.protocol && window.location.host ? (window.location.protocol + '//' + window.location.host) : (window.location && window.location.origin ? window.location.origin : '');
envConfig['WINDOW_HOST'] = windowHost && (windowHost.indexOf('localhost') !== -1 || windowHost.indexOf('127.0.0.1') !== -1) ? (envConfig?.['WINDOW_HOST'] || envConfig?.['API_BASE_URL'] || '') : windowHost; // 当前页面地址

export {
    envConfig
};