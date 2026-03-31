import { defineConfig } from 'vite';
import path from 'path';
import react from '@vitejs/plugin-react-swc';
import pxtovw from 'postcss-px-to-viewport';
import qiankun from 'vite-plugin-qiankun'; // 引入qiankun插件

//配置参数
const usePxtovw = pxtovw({
  viewportWidth: 1920,
  viewportUnit: 'vw'
});

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  const isDev = mode === 'development'
  return {
    plugins: [
      qiankun('qiankun-child', { // 微应用名字，与主应用注册的微应用名字保持一致
        useDevMode: true, // 如果是在主应用中加载子应用vite,必须打开这个,否则vite加载不成功, 单独运行没影响
      }),
      !isDev && react(),
    ],
    resolve: {
      alias: {
        '@assets': path.resolve(__dirname, './src/assets'),
        '@components': path.resolve(__dirname, './src/components'),
        '@pages': path.resolve(__dirname, './src/pages'),
        '@routes': path.resolve(__dirname, './src/routes'),
        '@store': path.resolve(__dirname, './src/store'),
        '@tools': path.resolve(__dirname, './src/tools'),
        '@api': path.resolve(__dirname, './src/api'),
        '@envConfig': path.resolve(__dirname, './src/envConfig'),
      },
    },
    base: '/', // /drgs
    server: {
      host: '0.0.0.0',
      port: 8090,
      https: false, // 是否开启 https
      open: false, // 项目启动时是否打开浏览器
      cors: true, // 为开发服务器配置 CORS。默认启用并允许任何源，传递一个 选项对象 来调整行为或设为 false 表示禁用。
      base: '/', // 用于代理 Vite 作为子文件夹时使用。
      headers: {
        'Access-Control-Allow-Origin': '*'
      },
      origin: 'http://localhost:8090',
      proxy: {
        '^/reactApi': {
          target: 'http://localhost:8090/',
          rewrite: path => path.replace(/^\/reactApi/, ''),
          changeOrigin: true
        },
        '/dip/sysInternalMutiple': {
          target: 'https://172.16.1.6',
          secure: false,
          ws: true,
          changeOrigin: true,
        },
      }
    },
    build: {
      outDir: 'dist', // 打包文件 默认dist
      minify: 'terser',
      chunkSizeWarningLimit: 2000, // 文件大小，默认500kb，生成的一个或多个文件的大小超过该值时，Vite 会发出警告提示
      // 打包清除console和debugger
      terserOptions: {
        compress: {
          drop_console: true,
          drop_debugger: true
        }
      },
      rollupOptions: {
        output: {
          // 最小化拆分包
          manualChunks(id) {
            if (id.includes('node_modules')) {
              return id.toString().split('node_modules/')[1].split('/')[0].toString()
            }
          },
          // 用于从入口点创建的块的打包输出格式[name]表示文件名,[hash]表示该文件内容hash值
          entryFileNames: 'js/[name].[hash].js',
          // 用于命名代码拆分时创建的共享块的输出命名
          // chunkFileNames: 'js/[name].[hash].js',
          // 用于输出静态资源的命名，[ext]表示文件扩展名
          assetFileNames: '[ext]/[name].[hash].[ext]',
          // 拆分js到模块文件夹
          chunkFileNames: (chunkInfo) => {
            const facadeModuleId = chunkInfo.facadeModuleId ? chunkInfo.facadeModuleId.split('/') : [];
            const fileName = facadeModuleId[facadeModuleId.length - 2] || '[name]';
            return `js/${fileName}/[name].[hash].js`;
          },
        }
      }
    },
    css: {
      preprocessorOptions: {
        less: {
          javascriptEnabled: true
        }
      },
      postcss: {
        plugins: [usePxtovw]
      }
    }
  }
})