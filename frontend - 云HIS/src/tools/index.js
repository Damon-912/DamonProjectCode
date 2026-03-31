import Pinyin from 'tiny-pinyin';

const Util = {
    // 生成唯一的uuid
    uuid() {
        const res = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
            const r = Math.random() * 16 | 0;
            const v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
        return `uuid${res}`;
    },

    // 判断是否是为空
    isEmpty(str) {
        let type = typeof str;
        switch (type) {
            case 'object': //如果是对象用stringify转成str 排除 {} 和 null
                if (str instanceof Array) {
                    return str.length > 0 ? false : true;
                } else {
                    let template = JSON.stringify(str);
                    return template === 'null' || template === '{}' ? true : false;
                }
            default: //其他
                str = str + '';
                if (str.length === 0 || str == 'undefined' || str == 'null') {
                    return true;
                }
        }
        return false;
    },

    // 数组去重
    unique(arr, dataIndex = 'id') {
        if (Object.prototype.toString.call(arr) !== '[object Array]') {
            return arr;
        }
        var result = [];
        var obj = {};
        for (var i = 0; i < arr.length; i++) {
            if (!obj[arr[i][dataIndex]]) {
                result.push(arr[i]);
                obj[arr[i][dataIndex]] = true;
            }
        }
        return result;
    },

    // 数组排序 - sortOrder排序方式，默认正序
    arraySort(arr, sortOrder) {
        if (arr && Array.isArray(arr) && arr.length > 0) {
            return arr.sort((a, b) => sortOrder === 'reverse' ? b - a : a - b);
        }
        return arr;
    },

    // 数组扁平化
    arrayFlow(data, arrIndex = 'children') {
        let flowData = [];
        function flow(data) {
            for (var i = 0; i < data.length; i++) {
                flowData.push(data[i]);
                if (data[i] && data[i][arrIndex] && data[i][arrIndex].length > 0) {
                    flow(data[i][arrIndex])
                }
            }
        }
        flow(data);
        return flowData;
    },

    /*
     * fn [function] 需要防抖的函数
     * interval [number] 毫秒，防抖期限值
     */
    debounce(func, interval) {
        let timeout;
        return function () {
            const context = this;
            const args = arguments;
            clearTimeout(timeout);
            timeout = setTimeout(function () {
                func.apply(context, args);
            }, interval ? interval : 300);
        };
    },

    /*
    * Purpose：    给数据源添加key值
    * Params：     参数
            data [array] 数据源
            dataIndex [string] key值需要赋值对象对于的哪个字段
            startNum [number] key值从几开始向上累加
    * */
    addKeyValueToDataSource(data, dataIndex, startNum = 1, accumulationType = 'string', addDataIndex = 'key') {
        if (data && Array.isArray(data) && data.length > 0) {
            return data && data.map((item, index) => {
                return {
                    ...item,
                    [addDataIndex]: item && dataIndex && item[dataIndex] ? item[dataIndex] : accumulationType === 'number' ? (index + startNum) : String(index + startNum)
                }
            })
        }
        return [];
    },

    /*
    * Purpose：    根据数据中的某个属性返回相对应的这条数据
    * Params：     参数
        arr [array] 数据源
        dataIndex [string] 对象中的字段名
        attrVal 具体的值
    * */
    returnDataCccordingToAttributes(arr, attrVal, dataIndex = 'id') {
        let filterObj = {};
        if (arr && Array.isArray(arr) && arr.length > 0) {
            let copyArr = JSON.parse(JSON.stringify(arr));
            copyArr = copyArr.filter(item => (item[dataIndex] === attrVal || (dataIndex === 'dataIndex' && item[dataIndex] && item[dataIndex].indexOf(attrVal) > -1)))
            filterObj = copyArr && copyArr.length > 0 ? copyArr[0] : {}
        }
        return filterObj;
    },

    /*
    * Purpose：    根据名称获取路径中对应的值
    * Params：     参数
            urlStr [string] 数据源
            dataIndex [string] 对应的字段名
    * */
    getValueByUrlStr(urlStr, dataIndex) {
        let paramValue = '';
        if (urlStr && typeof (urlStr) === 'string' && urlStr.indexOf('&') > -1) {
            let paramsData = urlStr.split('&');
            for (var i = 0; i < paramsData.length; i++) {
                if ((paramsData[i].indexOf(dataIndex) > -1) && paramsData[i].indexOf(':') > -1) {
                    let valueData = paramsData[i].split(':');
                    if (valueData[0] === dataIndex) {
                        paramValue = valueData[1];
                        break
                    }
                }
            }
        } else if (dataIndex && typeof (urlStr) === 'string' && urlStr.indexOf(dataIndex) > -1 && urlStr && urlStr.indexOf(':') > -1) {
            paramValue = urlStr.split(':')[1];
        }
        return paramValue;
    },

    /*
    * Purpose：    获取路径中所有的参数并以对象返回
    * Params：     参数
            urlStr [string] 数据源
    * */
    getObjByUrlStr(urlStr, separator = ':') {
        let paramObj = {};
        urlStr = urlStr.indexOf('params=') > -1 ? urlStr.split('params=')[1] : urlStr;
        if (urlStr && urlStr.indexOf('&') > -1) {
            let paramsData = urlStr.split('&');
            for (var i = 0; i < paramsData.length; i++) {
                if (paramsData[i].indexOf(separator) > -1) {
                    let valueData = paramsData[i].split(separator);
                    paramObj[valueData[0]] = valueData[1];
                }
            }
        } else if (urlStr && urlStr.indexOf(separator) > -1) {
            let valueData = urlStr.split(separator);
            paramObj[valueData[0]] = valueData[1];
        }
        return paramObj;
    },

    /*
        * Purpose：    获取菜单扁平化后的数据
        * Params：     参数
            resultType [string] 返回类型
            dataIndex [string] 匹配字段
            value [string] 数据对应的值
            data [array] 数据源
        * */
    getFlowData(data, arrIndex = 'children') {
        let menusData = [];
        function flow(data) {
            for (var i = 0; i < data.length; i++) {
                menusData.push(data[i]);
                if (data[i] && data[i][arrIndex] && data[i][arrIndex].length > 0) {
                    flow(data[i][arrIndex])
                }
            }
        }
        flow(data);
        return menusData;
    },

    /*
        * Purpose：    将对象中的value值转换为字符串
        * Params：     参数
            dataSource [数组/对象] 数据源
            resultType [字符串/数字] 返回类型
        * */
    dataConversion(dataSource, resultType = 'string') {
        if (Object.prototype.toString.call(dataSource) === '[object Object]') { // 对象
            for (var keys in dataSource) {
                if (typeof (dataSource[keys]) !== resultType) {
                    dataSource[keys] = resultType === 'number' ? Number(dataSource[keys]) : String(dataSource[keys]);
                }
            }
        } else if (Object.prototype.toString.call(dataSource) === '[object Array]') { // 数组
            for (var i = 0; i < dataSource.length; i++) {
                if (Object.prototype.toString.call(dataSource[i]) === '[object Object]') {
                    for (var keys in dataSource[i]) {
                        if (typeof (dataSource[i][keys]) !== resultType) {
                            dataSource[i][keys] = resultType === 'number' ? Number(dataSource[i][keys]) : String(dataSource[i][keys]);
                        }
                    }
                }
            }
        }
        return dataSource;
    },

    /*
        * Purpose：    将字符串转换成大写
        * Params：     参数
            uppercaseStr [string] 字符串数据源
            num [number] 需要转换字符串中的前num个字符 
        * */
    toUpperCase(uppercaseStr, num) {
        if (uppercaseStr && typeof (uppercaseStr) === 'string') {
            if (num) {
                uppercaseStr = uppercaseStr.slice(0, num);
            }
            return uppercaseStr.toUpperCase();
        } else {
            return uppercaseStr;
        }
    },

    /*
        * Purpose：    将字符串转换成小写
        * Params：     参数
            uppercaseStr [string] 字符串数据源
            num [number] 需要转换字符串中的前num个字符 
        * */
    toLowerCase(uppercaseStr, num) {
        if (uppercaseStr && typeof (uppercaseStr) === 'string') {
            if (num) {
                uppercaseStr = uppercaseStr.slice(0, num);
            }
            return uppercaseStr.toLowerCase();
        } else {
            return uppercaseStr;
        }
    },

    /*
        * Purpose：    判断是否为JSON串
        * Params：     参数
            str [string] - 必传
        * */
    isJsonString(str) {
        try {
            JSON.parse(str);
            return true;
        } catch (e) {
            return false;
        }
    },

    /*
    * Purpose：    自定义深拷贝
    * Params：     参数
            source [Array | Object] 数据源
    * */
    customDeepCopy(source) {
        if (typeof source != 'object') {
            return source;
        }
        if (source == null) {
            return source;
        }
        var newObj = source.constructor === Array ? [] : {};  //开辟一块新的内存空间
        for (var i in source) {
            newObj[i] = Util.customDeepCopy(source[i]);
        }
        return newObj;
    },

    // 去除字符串前后空格
    trimString(str) {
        if (str && typeof (str) === 'string') {
            return str.trim();
        } else if (typeof (str) === 'number') {
            return String(str).trim();
        } else {
            return str;
        }
    },

    /**
     * 将汉字转换为驼峰命名的英文，默认是大驼峰
     * @param {string} str 输入的汉字字符串
     * @param {boolean} pascalCase 是否使用大驼峰（PascalCase）
     * @returns {string} 转换后的驼峰命名英文
     */
    chineseToCamelCase(str, pascalCase = true) {
        // 使用tiny-pinyin将汉字转换为拼音数组
        const pinyinArray = str.split('').map(char => Pinyin.convertToPinyin(char, '', true));
        // 将拼音数组转换为驼峰或大驼峰命名格式
        const camelCaseString = pinyinArray
            .map((word, index) =>
                index === 0 && !pascalCase
                    ? word.toLowerCase()
                    : word.charAt(0).toUpperCase() + word.substring(1).toLowerCase()
            )
            .join('');
        return pascalCase
            ? camelCaseString.charAt(0).toUpperCase() + camelCaseString.substring(1)
            : camelCaseString;
    },

    // 数组按指定长度分割
    cutArray(source, subLength) {
        if (Array.isArray(source) && source.length > 0) {
            let count = 1;
            let newArr = [];
            let resultArr = [];
            source.forEach(function (item) {
                newArr.push(item);
                if (count % subLength == 0) {
                    resultArr.push(newArr);
                    newArr = [];
                }
                if (count == source.length - 1) {
                    resultArr.push(newArr);
                }
                count++;
            });
            return resultArr;
        }
        return source;
    },
};

// 导出方法
export {
    Util
};