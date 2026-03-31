import { axios } from '@api/methods';
import { notification } from 'antd';
/**
 * Purpose：    用途：同步请求
 * Params：     方法入参
	Nothis：      当前组件this
	code：        请求代码
	data：        请求体 - 没有参数默认可以不传入
	type：        urlDeault - 默认地址   urlADS - 增删改地址    urlS - 查询地址

	* 使用示例：

	getData = async () => {
		let res = await React.$asyncPost(this, '10000', { params: [{....}] });
		console.log(res);
	}
*/
export const asyncPost = function (code, paramsData = {}) {
	if (!code) {
		notification.error({
			message: `系统提醒 :`,
			description: '请求接口异常，请检查接口代码是否正确！',
		});
		return;
	}
	let initData = {
		params: [{}]
	};
	paramsData = paramsData && 'params' in paramsData ? paramsData : initData;
	return new Promise(async (resolve, reject) => {
		let res = await axios('post', code, paramsData);
		let responseData = res?.data || {}
		if (responseData && 'errorCode' in responseData && responseData.errorCode == 0) {
			resolve(responseData);
		} else {
			reject(responseData);
		}
	});
};