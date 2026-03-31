import React from 'react';
import { axios } from '@api/methods';
import { notification, message } from 'antd'

// 统一导出供调用，请勿重复命名【常用请求接口可以列在这里，避免重复写】
const request = {
    /**
     * 根据组件名获取组件信息[接口代码: 01040073]
     * @param {string | array} componentName 组件名
     * @returns {string} 传入的是字符串则返回对象，栗子: 'MenuDetailMaintenance'；传入的是数组(多个)则返回数组，栗子: ['MenuDetailMaintenance', 'MenuDetailMaintenanceForm']
     */
    getComponentInfo: async (componentName) => {
        try {
            let componentInfo = {};
            if (typeof componentName === 'string') {
                componentInfo.componentName = componentName;
            } else if (componentName && Array.isArray(componentName) && componentName.length > 0) {
                componentInfo.componentArr = componentName;
            }
            const res = await React.$asyncPost('01040073', {
                params: [{
                    ...componentInfo
                }]
            });
            return res;
        } catch (error) {
            console.log(error);
            if (typeof componentName === 'string') {
                return {};
            } else if (componentName && Array.isArray(componentName) && componentName.length > 0) {
                return [];
            }
        }
    },

    /**
     * 根据菜单代码查询关联的组件信息[接口代码: 01040074]
     * @param {string} menuCode 菜单代码
     * @returns {array} 返回一个或多个组件信息
     */
    getMenuComponentInfo: async (menuCode) => {
        try {
            const res = await React.$asyncPost('01040074', {
                params: [{
                    menuDetailCode: menuCode
                }]
            });
            return res;
        } catch (error) {
            console.log(error);
            return [];
        }
    },

    //上传文件
    upLoadFileNew: (url, params) => {
        const { file } = params
        const formData = new FormData()
        formData.append('file', file)
        return axios('upLoad', url, formData)
    },

    // 下载文件
    downloadFile: (url, fileName, params) => {
        message.loading("正在下载文件，请稍后")
        return axios('download', url, params).then(response => {
            let data = response.data;
            if (!data || data.size === 0) {
                notification.error({
                    message: '请求错误',
                    description: '文件下载失败，请稍后重试',
                });
                return;
            }
            if (typeof window.navigator.msSaveBlob !== 'undefined') { // IE浏览器
                window.navigator.msSaveBlob(new Blob([data]), fileName);
            } else {
                const downloadUrl = window.URL.createObjectURL(new Blob([data]));
                const link = document.createElement('a');
                link.style.display = 'none';
                link.href = downloadUrl;
                link.setAttribute('download', fileName);
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                window.URL.revokeObjectURL(downloadUrl);
            }
            let percentCompleted = 0;
            const totalDuration = 6000; // 总共的加载时间（以毫秒为单位）
            // 创建通知
            const key = 'download-progress-notification';
            notification.open({
                key,
                message: '下载进度',
                description: `已完成 ${percentCompleted.toFixed(2)} %`,
            });
            const updateProgress = () => {
                if (percentCompleted < 100) {
                    percentCompleted += (100 / totalDuration) * 100;
                    // 更新通知内容
                    notification.open({
                        key,
                        message: '下载进度',
                        description: `已完成 ${Math.min(percentCompleted, 100).toFixed(2)} %`,
                    });
                } else {
                    clearInterval(progressInterval); // 当加载完成后停止定时器
                    // 关闭通知
                    setTimeout(() => {
                        notification.close(key);
                    }, 1000);
                }
            };
            const progressInterval = setInterval(updateProgress, totalDuration / 100);
        });
    }
};

export default request;
