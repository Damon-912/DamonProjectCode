// 请求封装
// urlDeault   默认地址
// urlADS    增删改地址
// urlS      查询地址
import { message } from 'antd';
import { httpConfig } from './httpConfig';
import { Aes } from 'tools/aes';
import { Keup } from 'tools/keup';
import { Util } from 'tools/util';
// import store from '../store/'

// authorizationToken token
// ipDeault  默认的URLIp地址
// urlAddress 接口地址路径
// errorCodeArr 固定错误提示数组
const {
    proxy,
    authorizationToken,
    ipDeault,
    urlAddress,
    errorCodeArr
} = httpConfig

export const $http = {
    ipDeault: ipDeault,
    UrlEncode: (obj) => {
        if (!obj || Object.prototype.toString.call(obj) !== '[object Object]') {
            return '';
        }
        let params = [];
        for (let key in obj) {
            params.push(encodeURIComponent(key) + '=' + encodeURIComponent(obj[key]));
        }
        return params.join('&');
    },

    // type: 接口类型(查询 | 插入) Objson: 参数及回调 serviceType: 服务类型(添加了消息服务器，走不同地址)
    post: (type, Nothis, Objson, otherServiceUrl) => {
        let formData = Object.assign({}, Objson.data);
        let {
            userData
        } = window.sessionStorage
        let {
            ipConfig
        } = window.sessionStorage
        formData.code = Objson.code;
        if (userData) {
            let user = JSON.parse(userData);
            let ip = ipConfig && ipConfig !== 'undefined' && JSON.parse(ipConfig);
            formData.session = [{
                locID: user?.locID || '',
                groupID: user?.groupID || '',
                hospID: user?.hospID || '',
                sessionID: user?.sessionID || '',
                hospCode: user?.hospCode || '',
                language: user?.language || '',
                userID: user?.userID || '',
                assistantCode: user?.assistantCode || '', // 医助
                assistantID: user?.assistantID || '',
                attendingCode: user?.attendingCode || '', // 上级医师
                attendingID: user?.attendingID || '',
                ipv4: ip?.ipv4 || '',
                ipv6: ip?.ipv6 || '',
                mac: ip?.mac || '',
            }]
        }
        let httpUrlAddress; // 请求地址
        let windowHost = window.location && window.location.protocol && window.location.host ? (window.location.protocol + '//' + window.location.host) : (window.location && window.location.origin ? window.location.origin : '');
        // 判断是否是本地，如果是本地的话取https配置地址，线上则取地址栏地址 （内外网）
        let url = windowHost && (windowHost.indexOf('localhost') !== -1 || windowHost.indexOf('127.0.0.1') !== -1) && !proxy ? $http.ipDeault : windowHost;
        httpUrlAddress = url + (otherServiceUrl && typeof (otherServiceUrl) === 'string' ? otherServiceUrl : urlAddress);
        if (Objson?.httpFlag === 'N') { // 测试用，获取调用接口参数并不实际调用接口
            console.log('JSON.stringify(formData)', JSON.stringify(formData));
            return;
        };
        fetch(httpUrlAddress, {
            method: 'post',
            mode: 'cors',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': authorizationToken,
                'Access-Control-Allow-Origin': ipDeault
            },
            body: httpUrlAddress.includes('Encrypt') ? Aes.Encrypt(JSON.stringify(formData)) : JSON.stringify(formData)
        }).then((res) => {
            if (res.status !== 200) {
                throw res.status
            } else {
                let Data;
                // 是否是加密请求
                httpUrlAddress.includes('Encrypt') ? Data = res.text() : Data = res.json()
                return Data
            }
        }).then((Data) => {
            let res
            httpUrlAddress.includes('Encrypt') ? res = JSON.parse(Aes.Decrypt(Data)) : res = Data;
            if (!res || !('errorCode' in res)) { // 没有返回errorCode全部当异常处理
                message.error(res?.errorMessage || res?.summary || '接口请求异常！', userData?.errorMessageTime || 3);
                Objson.error.call(Nothis, res);
                return;
            }
            res.errorCode = res && 'errorCode' in res && res.errorCode.toString(); // 转成String类型
            if (res.errorCode !== '0') {
                if (errorCodeArr.includes(res.errorCode)) {
                    Keup.ModalMessage(3, Nothis, res.errorMessage, '跳转到登录页', '/login', '现在就去', 'error')
                } else {
                    if (Util.isEmpty(res.errorFlag)) { //挂号建卡，单独处理error弹框
                        formData?.isTips !== 'N' && message.error(res?.errorMessage || res?.summary || '接口请求异常！', userData?.errorMessageTime || 3);
                    }
                }
            }
            Objson.success.call(Nothis, res)
        }).catch((error) => {
            if (Objson.error) {
                Objson.error.call(Nothis, error)
            }
        });
    },

    get: (type, Nothis, Objson) => {
        let Alldata = ''; // get后缀
        let url = $http.ipDeault;
        let httpUrlAddress; //完整地址


        if (Objson.data) {
            Objson.data.code = Objson.code;
            Alldata = '?' + $http.UrlEncode(Objson.data);
        }

        if (type !== 'urlDeault') {
            type === 'urlADS' ? url = window.sessionStorage.productIP : url = window.sessionStorage.queryIP
        }

        httpUrlAddress = url + urlAddress
        if (httpUrlAddress.indexOf('https://') >= 0) {
            httpUrlAddress
        } else {
            if (httpUrlAddress.indexOf('http://') < 0) {
                httpUrlAddress = 'http://' + httpUrlAddress
            }
        }
        fetch(`http://${httpUrlAddress}${Alldata}`, {
            method: 'get',
            mode: 'cors',
            headers: {
                'Authorization': authorizationToken,
            },
        }).then((res) => {
            console.log(res)
            // 如果http状态码正常，则直接返回数据
            if (res.status !== 200) {
                throw res.status
            } else {
                let Data;
                switch (Objson.dataType) {
                    case 'json': {
                        Data = res.json()
                    }
                        break;

                    case 'text': {
                        Data = res.test()
                    }
                        break;
                }
                return Data
            }
        }).then((res) => {
            res.errorCode = res && 'errorCode' in res && res.errorCode.toString(); //转成String类型
            if (res.errorCode !== '0') {
                message.error(res.errorMessage, 1);
            }
            Objson.success.call(Nothis, res)
        }).catch((error) => {
            if (Objson.error) {
                Objson.error.call(Nothis, error)
            }
        });
    },
}
