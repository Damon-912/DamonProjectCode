import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { ConfigProvider } from 'antd'
import zhCN from 'antd/locale/zh_CN'

// 必须先导入并配置 dayjs locale，确保在组件渲染前生效
import dayjs from 'dayjs'
import 'dayjs/locale/zh-cn'
import updateLocale from 'dayjs/plugin/updateLocale'

// 配置 dayjs 为中文
dayjs.extend(updateLocale)
dayjs.locale('zh-cn')
// 强制更新中文 locale 配置
dayjs.updateLocale('zh-cn', {
  weekStart: 0,
})

import './index.css'
import App from './App.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ConfigProvider locale={zhCN}>
      <App />
    </ConfigProvider>
  </StrictMode>,
)
