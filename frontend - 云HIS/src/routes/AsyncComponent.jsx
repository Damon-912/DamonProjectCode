import React from 'react';
import Loading from '@components/loading';
import ErrorBoundary from './ErrorBoundary';

/**
 * 根据传入的 locale 值动态导入对应的组件。
 * @param {string} locale - 传入的 locale 字符串，用于确定需要导入的组件路径。
 * @returns {Function} - 返回一个按照动态路径导入的组件或一个导入 302 错误页的组件。
 */
export function importLocale(locale) {
    let n = (locale.split('/')).length - 1;
    // vite动态导入方法
    let modules = import.meta.glob('@pages/*/*')
    switch (n) {
        case 0:
        case 1:
        case 2:
            modules = import.meta.glob('@pages/*/*');
            break;
        case 3:
            modules = import.meta.glob('@pages/*/*/*');
            break;
        case 4:
            modules = import.meta.glob('@pages/*/*/*/*');
            break;
        case 5:
            modules = import.meta.glob('@pages/*/*/*/*/*');
            break;
        case 6:
            modules = import.meta.glob('@pages/*/*/*/*/*/*');
            break;
        default:
            break;
    };
    let component = modules[`/src/${locale}`];
    // 一般页面找不到本地组件直接重定向302
    if (!component) component = () => import(`../components/error302`);
    //  系统组件涉及权限及隐私问题找不到本地组件重定向403
    // if (locale.includes('system') && !component) component = () => import(`../components/error403`);
    // const url = import(`../pages/${locale}`); // vite不支持
    return component;
};

/**
 * 用于包裹传入的组件以提供错误边界和悬念加载效果。
 * @param {Object} props - 组件传入的 props 对象。
 * @param {React.ReactNode} props.element - 需要被包裹的 React 元素。
 * @returns {React.ReactElement} - 具备错误边界和悬念加载功能的 React 元素。
 */
export const MemoizedRoute = React.memo(function MemoizedRoute({ element }) {
    return (
        <ErrorBoundary>
            <React.Suspense fallback={<Loading />}>
                {element}
            </React.Suspense>
        </ErrorBoundary>
    );
});