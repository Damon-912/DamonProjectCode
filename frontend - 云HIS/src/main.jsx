import React from 'react';
import ReactDOM from 'react-dom/client';
import { ConfigProvider } from 'antd';
import { envConfig } from '@envConfig';
import { renderWithQiankun, qiankunWindow } from 'vite-plugin-qiankun/dist/helper';
import zh_CN from 'antd/es/locale/zh_CN';
import App from './App.jsx';
import getMenu from '@routes/routerConfig';
import 'dayjs/locale/zh-cn';
import './plugins'; // 全局方法注册

let root;

// 创建一个函数来渲染应用
function renderApp(props) {
  const { container } = props;
  let rootEle = container ? container.querySelector('#root-child') : document.querySelector('#root-child');
  root = ReactDOM.createRoot(rootEle);
  // 使用 React.memo 包装 App 组件，避免不必要的重渲染
  const MemoizedApp = React.memo(App);
  root.render(
    <ConfigProvider locale={zh_CN}>
      <MemoizedApp />
    </ConfigProvider>
  );
  return root;
}

// 初始化 Qiankun 的函数
const initQiankun = () => {
  renderWithQiankun({
    // 子应用初始化钩子
    bootstrap() {

    },
    // 子应用挂载钩子
    mount(props) {
      console.log('微应用：mount', props);
      let userInfo = props?.userData || React.$getSessionData('userData');
      // 存储用户信息 角色信息
      React.$setLocalStorageData(envConfig?.['ROOT_APP_INFO'] || 'drg-info', {
        userInfo,
        token: userInfo?.sessionID || '',
      });
      renderApp(props);

      // 调用渲染函数
      getMenu(props?.defaultMenuType || 3).then(res => {
        console.log(res);
        // 判断是否是登录页进入首页
        React.$setLocalStorageData('isLogin', 'Y', false);
      });

    },
    // 子应用卸载钩子
    unmount(props) {
      console.log('微应用：unmount', props);
      if (root) {
        root.unmount(); // 卸载 React 应用
        root = null;
      }
    },
    // 子应用更新钩子
    update(props) {
      console.log('微应用：update', props);
    }
  });
};

// 判断是否在 Qiankun 环境中
if (!qiankunWindow || !qiankunWindow.__POWERED_BY_QIANKUN__) {
  renderApp({});
} else {
  window.QIANKUN__MANAGER = qiankunWindow.__POWERED_BY_QIANKUN__;
  initQiankun();
}