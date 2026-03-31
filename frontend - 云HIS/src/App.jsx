import React from 'react';
import { HashRouter, Routes, Route, Navigate } from 'react-router-dom';
import { getCookies } from '@tools/cookies';
import { envConfig } from '@envConfig';
import AuthToken from '@components/authToken';
import Layout from '@pages/home/Layout';
import Login from '@pages/login';
import Error from '@components/error404';
import useTheme from './hooks/useTheme';
import '@assets/styles/App.less';

function App() {
  useTheme();
  // 主题配色
  let configROOT_APP_COLOR = envConfig?.['ROOT_APP_COLOR'] || '#1890ff';
  let ThemeBgColor = getCookies('ThemeBgColor') || configROOT_APP_COLOR;
  // 如果本地没有主题色字段，默认加载
  if (!ThemeBgColor) {
    import('@assets/styles/root.less');
  } else {
    switch (ThemeBgColor) {
      case '#2f54eb': // 深海蓝
        import('@assets/styles/theme/2f54eb.less');
        break;
      case '#f5222d': // 火山红
        import('@assets/styles/theme/f5222d.less');
        break;
      case '#fa541c': // 浅红
        import('@assets/styles/theme/fa541c.less');
        break;
      case '#faad14': // 日暮
        import('@assets/styles/theme/faad14.less');
        break;
      case '#13C2C2': // 明青
        import('@assets/styles/theme/13C2C2.less');
        break;
      case '#52c41a': // 草绿
        import('@assets/styles/theme/52c41a.less');
        break;
      case '#a876ed': // 熏紫
        import('@assets/styles/theme/a876ed.less');
        break;
      default:
        break;
    }
  }

  return (
    <HashRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/home" />} />
        <Route path="/login" element={<Login />}></Route>
        <Route path="/*" element={<AuthToken><Layout /></AuthToken>}></Route>
        <Route path="/error404" element={<Error />}></Route>
      </Routes>
    </HashRouter>
  );
}

export default App;
