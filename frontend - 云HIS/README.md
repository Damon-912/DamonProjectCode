# React-vite

本项目使用前端新型构建工具vite ， 更换了以往的webpack。

开箱即用，使其开发效率提高，编译速度更快，减少复杂配置。

在正式启动项目前，请检查本地环境版本。如若启动失败，请升级node。

请仔细阅读本文档以后再进行使用！

访问地址：<a target="_blank" href="http://127.0.0.1:4000">http://127.0.0.1:4000</a>

代码仓库：<a target="_blank" href="http://app.puruiit.cn:9092/data_center_platform">http://app.puruiit.cn:9092/data_center_platform</a>

## 技术分解

- react@18
- antd@5.15
- react-dom@18
- react-router-dom@6.22
- react-Hooks
- redux
- vite
- axios
- less
- eslint
- antv

## 技术文档

- react：https://react.docschina.org/
- vite：https://cn.vitejs.dev/guide/
- antd：https://ant-design.antgroup.com/components/overview-cn/?from=msidevs.net
- antv：http://antv.antfin.com/zh-cn/g2/3.x/demo/index.htm

## 环境版本

- node：v20.11.1
- npm：v10.2.4
- vite：v5.1.6
- react：v18.2.0

## 目录说明

```
react-vite
│
└── public 
│
└── src
│   ├── api  ： 请求与接口配置文件
│   ├── assets ： 静态资源文件
│       ├── styles  ： 公共样式
│   ├── components  ： 公共组件存放文件
│   ├── hooks  ： hooks
│   └───pages  ： view视图组件文件
│       ├── home  首页
│       ├── login  登录
│   	   
│   ├── store  ： redux
│   ├── router  ： 路由菜单
│   ├── utils   ： 工具库
│   └───App.jsx  ： 入口文件
│
└── vite.config.js  ： vite配置
```

## 开始使用

git仓库

```

```

安装依赖包

```
npm i  |  cnpm i  |  yarn 
```

项目启动

```
npm run dev
```

项目打包

```
npm run build