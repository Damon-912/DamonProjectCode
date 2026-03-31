import axios from 'axios';
import { notification, Modal } from 'antd';
import { getLocalStorageData, removeLocalStorageData } from '@tools/systemTools/other';
import { envConfig } from '@envConfig';
let errorCodeArr = ['01040052', '01040053', '01040054', '01040055', '01040057', '01040059', '01040106']; // 固定错误提示数组

// console.log('envConfig', envConfig, (envConfig?.['API_BASE_URL'] || '') + (envConfig?.['API_BASE_PORT'] || ''))
const Server = axios.create({
    baseURL: (envConfig?.['API_BASE_URL'] || '') + (envConfig?.['API_BASE_PORT'] || ''), // 域名请求地址
    headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': envConfig?.['API_BASE_TOKEN'],
        'Access-Control-Allow-Origin': envConfig?.['API_BASE_URL'] || ''
    },
    timeout: (envConfig?.['API_BASE_TIMEOUT'] || 10) * 1000, // 超时时间
});

const codeMessage = {
    202: '已接受请求，并进入后台排队（异步任务），但未处理完成',
    203: '请求成功，非授权信息，返回的meta信息不在原始的服务器，而是一个副本',
    204: '服务器成功处理，但未返回内容',
    205: '服务器成功处理，客户端（浏览器）应重置页面视图',
    206: '服务器成功处理了部分GET请求',
    400: '发出的请求有误（客户端请求语法错误），服务器没有进行新建或修改数据的操作',
    401: '用户没有权限（令牌、用户名、密码错误）或登录过期',
    403: '用户得到授权，但访问已被禁止',
    404: '请求的资源无法找到（资源不存在或URL错误），服务器没有进行操作',
    405: '客户端请求中的方法被服务器禁止或请求方法错误',
    406: '客户端请求格式错误或服务端返回内容客户端无法解析',
    410: '请求的资源被永久删除，且不会再得到',
    412: '客户端请求信息的先决条件错误',
    413: '由于请求的实体过大，服务器无法处理，因此拒绝请求',
    414: '请求的URL过长（URL通常为网址），服务器无法处理',
    415: '服务器无法处理请求附带的媒体格式',
    416: '客户端请求的范围无效',
    422: '当创建一个对象时，发生一个验证错误',
    500: '服务器发生错误，请检查服务器',
    501: '服务器不支持请求的功能，无法完成请求',
    502: '网关错误，从远程服务器接收到了一个无效的响应',
    503: '服务不可用，服务器暂时过载或维护',
    504: '网关超时，充当网关或代理的服务器，未及时从远端服务器获取请求',
    505: '服务器不支持请求的HTTP协议的版本，无法完成处理'
};

// 添加请求拦截器
Server.interceptors.request.use(function (config) {
    // 在请求头上缀入token
    let appInfo = getLocalStorageData(envConfig?.['ROOT_APP_INFO'] || 'drg-info');
    if (appInfo && 'token' in appInfo && appInfo.token) {
        const token = appInfo?.token || '';
        config.headers['X-Access-Token'] = token;
    }
    return config;
}, function (error) {
    // 对请求错误做些什么
    return Promise.reject(error);
});

// 添加响应拦截器
Server.interceptors.response.use(function (response) {
    if (response && response.data) {
        if (response.data.errorCode && response.data.errorCode != 0) {
            const errorText = response.data.errorMessage || codeMessage[response.data.errorCode];
            if (response && response.data) {
                let errorCode = response?.data?.errorCode || '';
                if (errorCode != 0) {
                    if (errorCodeArr.includes(errorCode)) {
                        clearStorage('Token失效');
                    } else {
                        response?.config?.errTipsFlag !== 'N' && notification.error({
                            message: `请求错误 :`,
                            description: errorText,
                        });
                    }
                }
            }
        }
    }
    // 对响应数据做点什么
    return response;
}, function (error) {
    // 请求超时提示
    if (error.message.includes('timeout')) {
        notification.error({
            message: '超时错误',
            description: '请检查网络或稍后再试',
        });
        return Promise.reject(error);
    }
    // 异常处理
    const response = error.response
    if (response && response.status) {
        const errorText = codeMessage[response.status] || response.statusText;
        const { status } = response;
        notification.error({
            message: `请求错误 :`,
            // message: `请求错误 ${status} :  ${config?.url}`,
            description: errorText,
        });
        // 500及401重新登录
        // if (status == 500 || status == 401) clearStorage(response.statusText)
    } else if (!response) {
        notification.error({
            description: '您的网络发生异常，无法连接服务器，可能为跨域、无效令牌、网络未连接等相关原因',
            message: '网络异常',
        });
        // removeLocalStorageData(envConfig['ROOT_APP_INFO']);
        // setTimeout(() => {
        //     window.location.reload()
        // }, 1000)
    }
    return Promise.reject(error);
});

// 清除本地所有缓存，重新登录
const clearStorage = (errorText) => {
    if (errorText.includes('Token失效')) {
        Modal.error({
            title: '登录已过期',
            content: '很抱歉，登录已过期，请重新登录',
            okText: '重新登录',
            onOk: () => {
                removeLocalStorageData(envConfig?.['ROOT_APP_INFO'] || 'drg-info');
                setTimeout(() => {
                    window.location.reload()
                }, 500)
            }
        });
    } else {
        removeLocalStorageData(envConfig?.['ROOT_APP_INFO'] || 'drg-info');
        setTimeout(() => {
            window.location.reload()
        }, 1500)
    }
};

export default Server;
