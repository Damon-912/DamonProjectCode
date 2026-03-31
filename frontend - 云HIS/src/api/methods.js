import Server from '@tools/request';
import { notification } from 'antd';
import { envConfig } from '@envConfig';
import { getLocalStorageData, getSessionData } from '@tools/systemTools/other';
// 封装请求方式
// methods:请求方式   url:请求地址   params：请求参数
export function axios(methods, code, params, tipFlag) {
	// 请求参数拼接
	let postRequestParams = Object.assign({}, params);
	postRequestParams.code = code;
	let errTipsFlag = tipFlag || params?.errTipsFlag || params?.tipFlag || ''; // 报错是否直接提示
	const userInfo = getLocalStorageData(envConfig?.['ROOT_APP_INFO'] || 'drg-info')?.userInfo || {};
	const ipConfig = getSessionData('ipConfig');
	if (userInfo) {
		postRequestParams.session = [{
			userID: userInfo?.userID || '',
			locID: userInfo?.locID || '',
			groupID: userInfo?.groupID || '',
			hospID: userInfo?.hospID || '',
			sessionID: userInfo?.sessionID || '',
			hospCode: userInfo?.hospCode || '',
			language: userInfo?.language || '',
			hospDesc: userInfo?.hospDesc || '',
			ipv4: ipConfig?.ipv4 || '',
			ipv6: ipConfig?.ipv6 || '',
			mac: ipConfig?.mac || '',
		}]
	};
	switch (methods) {
		case 'get':
			return Server({
				code,
				errTipsFlag,
				method: 'get',
				params,
			});
		case 'post':
			return Server({
				code,
				errTipsFlag,
				method: 'post',
				data: postRequestParams,
			});
		case 'delete':
			return Server({
				code,
				errTipsFlag,
				method: 'delete',
				params,
			});
		case 'put':
			return Server({
				code,
				errTipsFlag,
				method: 'put',
				data: params,
			});
		case 'options':
			return Server({
				code,
				errTipsFlag,
				method: 'options',
				params,
			});
		case 'upLoad': // 上传文件
			return Server({
				code,
				errTipsFlag,
				method: 'post',
				data: params,
				headers: {
					'Content-Type': 'multipart/form-data',
				},
			});
		case 'download': // 下载文件
			let loaded = 0;
			let estimatedTotal = 0; // 估算的总大小
			// 发起下载请求
			const request = Server({
				code,
				method: 'post',
				data: params,
				responseType: 'blob',
				onDownloadProgress: (progressEvent) => {
					if (progressEvent.lengthComputable) {
						loaded = progressEvent.loaded;
						estimatedTotal = progressEvent.total;
					} else {
						// 如果服务器未提供文件大小信息，仅使用已下载的字节数来估算进度
						loaded = progressEvent.loaded;
						estimatedTotal = Math.max(estimatedTotal, loaded + 1024); // 使用已下载的字节数加上一个常数来估算总大小
					}
					const percentCompleted = Math.round((loaded / estimatedTotal) * 100);
					console.log(`下载进度：${percentCompleted}%`);
				},
			});
			return request;
		default:
			return notification.error({
				message: '请求方式错误',
				description: '找不到此方法，请认真检查是否拼写错误',
			});
	}
}
