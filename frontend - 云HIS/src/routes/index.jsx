
import React, { lazy } from 'react';
import { getLocalStorageData } from '@tools/systemTools/other';
import { importLocale } from '@routes/AsyncComponent';
import { Util } from '@tools';
import { envConfig } from '@envConfig';
import getMenu from '@routes/routerConfig'; // 使用路由懒加载
import store from '@store'; // 用于获取状态
import * as Icon from '@ant-design/icons'; // 引入antd-icon

// 基础菜单
let routes = [{
    label: '首页',
    key: '/home',
    path: '/home',
    element: lazy(() => import('@pages/home/Home.jsx')),
    icon: 'HomeOutlined',
    disabled: false,
    menu_info: {
        path: '/home',
        icon: 'HomeOutlined',
        title: '首页',
        component: 'pages/home/Home.jsx',
    }
}];

// 登录后刷新页面
store.subscribe(() => {
    const { reload } = store.getState();
    if (reload) location.reload();
});

// 把接口获取的菜单重写
function setMenu(list) {
    return list && list.map(item => {
        return {
            menu_info: item,
            label: item.title,
            key: item.path,
            path: item.path,
            icon: '',
            image: item?.image || '',
            disabled: item.disabled,
            params: item?.paras || '',
            code: item?.code || '',
            element: lazy(importLocale(item?.component || '')),
            children: item && 'subs' in item && Array.isArray(item.subs) && item.subs.length > 0 ? setMenu(item.subs) : undefined,
        }
    })
}

//创建节点的方法
function iconBC(name) { return React.createElement(Icon[Util.trimString(name)]); }

function setIcon(res) {
    for (let i = 0; i < res.length; i++) {
        const element = res[i];
        let IconItem = element?.icon || element?.image || '';
        // 处理antd3.x维护的数据导致的报错
        if (IconItem) element.icon = IconItem && typeof IconItem === 'string' && IconItem.indexOf('-') < 0 && /[A-Z]/.test(IconItem) ? iconBC(IconItem) : IconItem;
        if (element && 'children' in element && Array.isArray(element.children)) setIcon(element.children);
    }
}

async function getRoutes() {
    const { token, menuList, userInfo } = getLocalStorageData(envConfig?.['ROOT_APP_INFO'] || 'drg-info');
    if (token && menuList) {
        const menu = await getMenu(userInfo?.defaultMenuType || '');
        let nRoutes = [...routes, ...setMenu(menu)];
        setIcon(nRoutes);
        return nRoutes;
    } else {
        return routes;
    }
}

// 初始化路由数据
export async function initializeRoutes() {
    return await getRoutes();
}