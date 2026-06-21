import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src')
    }
  },
  base: './',
  server: {
    port: 5173,
    proxy: {
      // 开发环境代理：处理 /dipapp/iris-api/* 请求
      // 将所有 /dipapp/iris-api 前缀的请求转发到 IRIS 后端
      '/dipapp/iris-api': {
        target: 'http://111.229.137.113:52773',
        changeOrigin: true,
        rewrite: () => '/csp/drg/sysInternalMutiple'
      },
      // 兼容不带 /dipapp 前缀的请求（如有）
      '/iris-api': {
        target: 'http://111.229.137.113:52773',
        changeOrigin: true,
        rewrite: () => '/csp/drg/sysInternalMutiple'
      }
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false
  }
})
