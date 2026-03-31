/*
* Purpose：    获取session数据
* Params：     参数
	type [string] 需要获取的session
	isParse [bool] 是否将字符串转为对象
* */
import { envConfig } from '@envConfig';

export const getSessionData = function (key, isParse = true) {
	try {
		if (key && window.sessionStorage && key in window.sessionStorage && window.sessionStorage[key]) {
			let sessionData = window.sessionStorage.getItem(key);
			return isParse ? JSON.parse(sessionData) : sessionData;
		}
		return isParse ? {} : '';
	} catch (e) {
		return isParse ? {} : '';
	}
};

// 修改session数据，参数如上
export const setSessionData = function (key, values, isStringify = true) {
	if (window.sessionStorage && window.sessionStorage.setItem) {
		window.sessionStorage.setItem(key, isStringify ? JSON.stringify(values) : values);
	}
};

// 删除session数据，参数如上
export const removeSessionData = function (key) {
	if (key && window.sessionStorage && window.sessionStorage[key]) {
		window.sessionStorage.removeItem(key);
	}
};

/*
* Purpose：    获取localStorage数据
* Params：     参数
	type [string] 需要获取的localStorage
	isParse [bool] 是否将字符串转为对象
* */
export const getLocalStorageData = function (key, isParse = true) {
	try {
		if (key && window.localStorage && key in window.localStorage && window.localStorage[key]) {
			let sessionData = window.localStorage.getItem(key);
			return isParse ? JSON.parse(sessionData) : sessionData;
		}
		return isParse ? {} : '';
	} catch (e) {
		return isParse ? {} : '';
	}
};

// 修改localStorage数据，参数如上
export const setLocalStorageData = function (key, values, isStringify = true) {
	if (window.localStorage && window.localStorage.setItem) {
		window.localStorage.setItem(key, isStringify ? JSON.stringify(values) : values);
	}
};

// 删除localStorage数据，参数如上
export const removeLocalStorageData = function (key) {
	if (key && window.localStorage && window.localStorage[key]) {
		window.localStorage.removeItem(key);
	}
};

// 获取登录的用户信息
export const getUserData = () => {
	let ROOT_APP_INFO = envConfig?.['ROOT_APP_INFO'] || 'drg-info';
	let appInfo = getLocalStorageData(ROOT_APP_INFO);
	let userInfo = appInfo?.userInfo || {};
	return userInfo;
}

/*
	* Purpose：    阻止默认事件
	* Params：     参数
		e [event] event对象
	* */
export const stopPropagation = (e) => {
	e && Object.prototype.toString.call(e) === '[object Object]' && 'stopPropagation' in e && e.stopPropagation && e.stopPropagation();
};

/*
	* Purpose：    阻止事件冒泡
	* Params：     参数
		e [event] event对象
	* */
export const preventDefault = (e) => {
	if (e && e.preventDefault) {
		e.preventDefault();
	} else {
		e.returnValue = false;
	}
};

/*
	* Purpose：    将字符串转换成大写
	* Params：     参数
		uppercaseStr [string] 字符串数据源
		num [number] 需要转换字符串中的前num个字符 
	* */
export const toUpperCase = (uppercaseStr, num) => {
	if (uppercaseStr && typeof (uppercaseStr) === 'string') {
		if (num) {
			uppercaseStr = uppercaseStr.slice(0, num);
		}
		return uppercaseStr.toUpperCase();
	} else {
		return uppercaseStr;
	}
};

/*
	* Purpose：    将字符串转换成小写
	* Params：     参数
		uppercaseStr [string] 字符串数据源
		num [number] 需要转换字符串中的前num个字符 
	* */
export const toLowerCase = (uppercaseStr, num) => {
	if (uppercaseStr && typeof (uppercaseStr) === 'string') {
		if (num) {
			uppercaseStr = uppercaseStr.slice(0, num);
		}
		return uppercaseStr.toLowerCase();
	} else {
		return uppercaseStr;
	}
};

/*
	* Purpose：    判断是否为JSON串
	* Params：     参数
		str [string] - 必传
	* */
export const isJsonString = function (str) {
	try {
		JSON.parse(str);
		return true;
	} catch (e) {
		return false;
	}
};

/*
	* Purpose：    判断是否为数组
	* Params：     参数
		arr [array] - 必传
	* */
export const getArrayLength = function (arr) {
	return arr && Array.isArray(arr) && arr.length > 0 ? arr.length : 0;
};