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
      '/iris-api/invoke': {
        target: 'http://111.229.137.113:52773/csp/drg/sysInternalMutiple',
        changeOrigin: true,
        rewrite: () => ''
      }
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false
  }
})
