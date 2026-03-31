import React, { useState, useRef, useEffect, lazy } from 'react';
import { Layout, Menu, Dropdown, Tooltip, notification, Modal, TreeSelect, Watermark } from 'antd';
import { MenuFoldOutlined, MenuUnfoldOutlined, LogoutOutlined, SettingOutlined, FullscreenExitOutlined, FullscreenOutlined, ExclamationCircleOutlined } from '@ant-design/icons';
import { Route, Routes, Navigate, useLocation, useNavigate } from 'react-router-dom';
import { getCookies } from '@tools/cookies';
import { dateState } from '@tools/moment';
import { Util } from '@tools';
import { MemoizedRoute, importLocale } from '@routes/AsyncComponent';
import { initializeRoutes } from '@routes';
import { envConfig } from '@envConfig';
import store from '@store';
import logo from '@assets/images/pr-logo.png';
import logoTransparent from '@assets/images/pr-logo-transparent.png';
import nprogress from 'nprogress';
import Setting from '@components/setting';
import Breadcrumb from './Breadcrumb';
import ChangePassword from '@components/users/changePassword/ChangePassword.jsx';
//用于获取状态
import '@components/progress/index.less';
import './style/layout.less';

const { Header, Content, Sider } = Layout;

const CommonView = () => {
    let settingRef = useRef(null)
    //路由加载进度条
    nprogress.start();
    setTimeout(() => {
        nprogress.done();
    }, 200);

    let titleH2 = envConfig?.ROOT_APP_NAME || '普瑞眼科HIS重构';
    let navigate = useNavigate();
    let location = useLocation();

    const [activeKey, setActiveKey] = useState('首页');
    const [tabs, setTabs] = useState([{
        component: lazy(importLocale('pages/home/Home.jsx')),
        path: '/home',
        title: '首页',
        icon: 'HomeOutlined'
    }]);
    // 获取当前屏幕宽度
    const clientHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
    const userData = React.$getUserData();
    const [routes, setRoutes] = useState([]);
    const [tabTemp, setTabTemp] = useState({
        首页: {
            path: '/home',
            icon: 'HomeOutlined',
            title: '首页',
            component: 'pages/home/Home',
        }
    });
    const defaultOpenKeys = location.pathname;
    let [current, setCurrent] = useState(defaultOpenKeys);
    let [collapsed, setCollapsed] = useState(false);
    let [title, setTitle] = useState(true);
    let [StyleBg, setStyleBg] = useState('dark');
    let [pattern, setPattern] = useState('broadside'); // 导航模式
    let [styWidth, setStyWidth] = useState(); // 内容宽度
    let [styNav, setStyNav] = useState(); // 固定导航
    let [fullScreen, setFullScreen] = useState(false); // 全屏
    let ThemeStyle = getCookies('ThemeStyle') || 'dark';
    let patternStyle = getCookies('pattern');
    let widthStyle = getCookies('widthStyle');
    let navStyle = getCookies('navStyle');

    useEffect(() => {
        // 判断是否是登录页进入首页
        const isLogin = React.$getLocalStorageData('isLogin', false);
        console.log('userData', userData, isLogin)
        if (isLogin === 'Y' && userData?.defaultMenuType != 3) {
            notification.success({
                message: userData?.userName || userData?.userName || '',
                description: '欢迎登录，' + dateState() + '好',
            });
        }
        // 检查是否有初始路径需要跳转 - 为子应用时
        // if (window.__INITIAL_PATH__) {
        //     const fullPath = window.__INITIAL_PATH__;
        //     // 👇 转换为主应用路径 → 子应用内部路径
        //     let internalPath = fullPath;
        //     if (fullPath.indexOf('/child-') > -1) {
        //         internalPath = '/' + fullPath.split('/child-')[1];
        //     }
        //     console.log('internalPath', internalPath)
        //     navigate(internalPath); // 使用 replace 避免后退栈污染
        //     // 清理
        //     delete window.__INITIAL_PATH__;
        // }
        handleInitRoutesData();
        setTimeout(() => {
            React.$removeLocalStorageData('isLogin');
        }, 2000);
    }, []);

    // 初始化路由数据
    const handleInitRoutesData = async () => {
        let nRoutes = await initializeRoutes();
        setRoutes(nRoutes);
    };

    useEffect(() => {
        if (fullScreen) {
            const element = document.documentElement;
            if (element.requestFullscreen) {
                element.requestFullscreen();
            } else if (element.mozRequestFullScreen) {
                element.mozRequestFullScreen();
            } else if (element.webkitRequestFullscreen) {
                element.webkitRequestFullscreen();
            } else if (element.msRequestFullscreen) {
                element.msRequestFullscreen();
            }
        } else {
            if (document.fullscreenElement ||
                document.mozFullScreenElement ||
                document.webkitFullscreenElement ||
                document.msFullscreenElement) {
                if (document.exitFullscreen) {
                    document.exitFullscreen();
                } else if (document.mozCancelFullScreen) {
                    document.mozCancelFullScreen();
                } else if (document.webkitExitFullscreen) {
                    document.webkitExitFullscreen();
                } else if (document.msExitFullscreen) {
                    document.msExitFullscreen();
                }
            }
        }
    }, [fullScreen]);

    useEffect(() => {
        setTimeout(() => {
            updateContentHeight();
        }, 100)
    }, [fullScreen, pattern])

    const updateContentHeight = () => {
        const contentHeight = clientHeight - (userData?.defaultMenuType != 3 ? (pattern === 'broadside' ? 100 : 69) : 20);
        // 更新store
        store.dispatch({
            type: 'contentHeight',
            data: contentHeight
        });
        // 更新store
        store.dispatch({
            type: 'documentHeight',
            data: clientHeight
        });
    }

    useEffect(() => {
        // 设置导航颜色
        if (ThemeStyle) {
            setStyleBg(ThemeStyle);
            const sider = document.getElementsByClassName('ant-layout-sider')[0];
            if (sider && 'style' in sider && sider.style) {
                if (ThemeStyle == 'light') {
                    sider.style.background = '#fff';
                } else {
                    const sider = document.getElementsByClassName('ant-layout-sider')[0];
                    sider.style.background = '#001529';
                }
            }
        }
        // 导航模式
        if (patternStyle) {
            setPattern(patternStyle);
            patternStyle === 'broadside' && setCurrent('/home'); // 切换到测菜单
        }
        setStyWidth(widthStyle);
        setStyNav(navStyle);
        // 获取导航模式
        store.subscribe(() => {
            const { pattern, patternUpdateFlag } = store.getState();
            if (patternUpdateFlag) {
                // 更新模式状态
                store.dispatch({
                    type: 'patternUpdateFlag',
                    data: false
                });
                setPattern(pattern);
            }
        });
    }, []);

    // 点击菜单
    const handleMenuClick = (e) => {
        handleNavigate(e?.key || e?.path || '');
    };

    // 路由跳转
    const handleNavigate = (path) => {
        let routesFlow = Util.arrayFlow(routes);
        let pathRecord = Util.returnDataCccordingToAttributes(routesFlow, path, 'path');
        if (pattern == 'broadside') {
            addSubMenuTabData(pathRecord?.menu_info || {});
        } else {
            // 头菜单参数处理
            let interfaceMenuCode = pathRecord?.code || '';
            let paramsStr = pathRecord?.params?.params || pathRecord?.params || '';
            paramsStr = paramsStr + (paramsStr ? '&' : '') + 'interfaceMenuCode:' + interfaceMenuCode; // 当前菜单代码
            store.dispatch({
                type: 'errorFlag',
                data: true
            });
            navigate(path, { state: { params: paramsStr, menuCode: interfaceMenuCode } });
        }
        setCurrent(path);
    };

    // 退出登录
    const logOut = () => {
        Modal.confirm({
            title: '确认退出登录',
            icon: <ExclamationCircleOutlined />,
            content: '退出登录后将清除账号所有本地信息及数据！',
            okText: '确认',
            cancelText: '取消',
            style: {
                top: '10vw',
                width: '20vw'
            },
            onOk: async () => {
                React.$setLocalStorageData('isLogin', 'N', false);
                React.$removeLocalStorageData(envConfig?.['ROOT_APP_INFO'] || 'drg-info');
                sessionStorage.clear();
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            }
        });
    };

    // 标签栏跳转
    const toRouter = ((item) => {
        handleNavigate(item.key);
    });

    // 后台布局设置
    const handleSetting = () => {
        settingRef.current.setSettingVisible(true);
    };

    // 添加、收集点击菜单需要打开的tab页 并存储在list
    const addSubMenuTabData = tabItem => {
        const tabList = [...tabs];
        console.log('tabTemp', tabTemp)
        let pTabTemp = tabTemp;
        console.log('tabItem', tabItem)
        if (!tabTemp[tabItem.title]) {
            tabList.push({
                ...tabItem,
                component: lazy(importLocale(tabItem.component || '')),
            });
            console.log('tabList', tabList)
            setTabs(tabList);
            setActiveKey(tabItem.title);
            tabItem.$Index = tabList.length - 1;
            pTabTemp[tabItem.title] = tabItem;
            console.log('pTabTemp', pTabTemp)
            setTabTemp(pTabTemp);
        } else {
            handleSetActiveKey(tabItem?.title || '');
        }
    };

    // 指定跳转到某个标签页
    const gotoMenuTabByActiveKey = pActiveKey => {
        setActiveKey(pActiveKey);
    };

    // 删除tab页
    const deleteSubMenuTabData = (targetKey, gotoKey) => {
        let pActiveKey = activeKey;
        let lastIndex = -1;
        tabs.forEach((pane, i) => {
            if (pane.title === targetKey) {
                lastIndex = i - 1;
            }
        });
        const tabList = tabs.filter(tab => tab.title !== targetKey);
        if (tabs && tabs.length > 0) {
            if (gotoKey) {
                pActiveKey = gotoKey;
            } else if (lastIndex >= 0) {
                pActiveKey = tabs[lastIndex].title;
            } else if (tabList.length > 0) {
                pActiveKey = tabList[0].title;
            } else {
                pActiveKey = '';
            }
        }
        delete tabTemp[targetKey];
        setTabs(tabList);
        setTabTemp(tabTemp);
        handleSetActiveKey(pActiveKey);
    };

    const handleSetActiveKey = (activeKey) => {
        let activeRecord = Util.returnDataCccordingToAttributes(tabs, activeKey, 'title');
        setActiveKey(activeKey);
        setCurrent(activeRecord?.path || '');
    };

    return (
        <Watermark
            gap={[250, 250]} // 水印间距
            content={userData?.userName || ''}
        >
            <Layout className="common-view">
                {userData?.defaultMenuType != 3 && pattern == "broadside" ? (
                    <Sider className="site-layout-background sider-menu" trigger={null} collapsible collapsed={collapsed}>
                        <div className="logo">
                            <img src={StyleBg === 'light' ? logo : logoTransparent} alt="" />
                            {title ? (
                                <span
                                    className="logoTitle"
                                    style={{
                                        color: ThemeStyle && ThemeStyle == 'light' ? '#000000D9' : ''
                                    }}
                                >
                                    {titleH2}
                                </span>
                            ) : ''
                            }
                        </div>
                        <Menu
                            theme={StyleBg}
                            style={{ width: '100%', height: clientHeight - 48 + 'px', overflow: 'auto' }}
                            defaultOpenKeys={[defaultOpenKeys]}
                            selectedKeys={[current]}
                            mode="inline"
                            items={routes}
                            onClick={handleMenuClick}
                        />
                    </Sider>
                ) : ''}
                <Layout className="site-layout">
                    {userData?.defaultMenuType != 3 && (
                        <Header
                            className={['site-layout-background', pattern == 'top' && styNav == 'true' ? 'common-bottom-shadow' : ''].join(' ')}
                            style={{
                                padding: pattern == 'broadside' ? '0 1.5vw 0 0' : 0,
                                position: pattern == 'top' && styNav == 'true' ? 'fixed' : '',
                                minWidth: pattern == 'top' && styNav == 'true' ? '100%' : '',
                                top: pattern == 'top' && styNav == 'true' ? '0' : '',
                            }}
                        >
                            {pattern == 'broadside' ? (
                                React.createElement(collapsed ? MenuUnfoldOutlined : MenuFoldOutlined, {
                                    className: 'trigger',
                                    onClick: () => { setCollapsed(!collapsed); setTitle(!title) },
                                })
                            ) : ''}
                            <div
                                className="headBox"
                                style={{
                                    background: StyleBg == 'dark' && pattern == 'top' ? '#001529' : '#fff',
                                    color: StyleBg == 'dark' && pattern == 'top' ? '#fff' : '#000',
                                    padding: pattern == 'top' && styWidth == 'true' ? `0 10vw` : '0 10px',
                                    minWidth: pattern == 'top' && styNav == 'true' ? '78.13vw' : '100%',
                                }}
                            >
                                <span>
                                    {pattern == 'broadside' ? '欢迎登录' : <img src={StyleBg === 'light' ? logo : logoTransparent} alt="" className="headBox-logo" />}
                                    {titleH2}
                                </span>
                                {pattern == 'top' ? (
                                    <Menu
                                        className="layout-header-menu"
                                        mode="horizontal"
                                        items={routes}
                                        theme={StyleBg}
                                        defaultOpenKeys={[defaultOpenKeys]}
                                        selectedKeys={[current]}
                                        style={{ borderBottom: 0, width: pattern == 'top' ? '60%' : '' }}
                                        onClick={handleMenuClick}
                                    />
                                ) : ''}
                                <div className="flex-align-items">
                                    {pattern == 'top' ? '' : <MenuSearch toRouter={(e) => { toRouter(e) }} />}
                                    <Tooltip title={fullScreen ? '退出全屏' : '全屏显示'}>
                                        <span className="user-Setting" onClick={() => setFullScreen(!fullScreen)}>
                                            {fullScreen ? <FullscreenExitOutlined /> : <FullscreenOutlined />}
                                        </span>
                                    </Tooltip>
                                    <Tooltip title="后台布局设置">
                                        <span className="user-Setting" onClick={handleSetting}>
                                            <SettingOutlined />
                                        </span>
                                    </Tooltip>
                                    <UserInfo />
                                    <span className="log-out" onClick={logOut}><LogoutOutlined />退出登录</span>
                                </div>
                            </div>
                        </Header>
                    )}
                    {/* 标签栏 */}
                    {userData?.defaultMenuType != 3 && pattern === 'broadside' ? (
                        <Breadcrumb
                            activeKey={activeKey}
                            tabs={tabs}
                            setActiveKey={handleSetActiveKey}
                            addSubMenuTabData={addSubMenuTabData}
                            deleteSubMenuTabData={deleteSubMenuTabData}
                            gotoMenuTabByActiveKey={gotoMenuTabByActiveKey}
                        />
                    ) : (
                        <Content
                            style={{
                                margin: userData?.defaultMenuType != 3 && pattern == 'top' && styWidth == 'true' ? '10px 10vw' : '10px',
                                paddingTop: userData?.defaultMenuType != 3 && pattern == 'top' && styNav == 'true' ? '48px' : ''
                            }}
                        >
                            {/* 配置路由子组件 */}
                            <Routes>
                                {getRoutes(routes)}
                            </Routes>
                        </Content>
                    )}
                    {/* 设置 */}
                    <Setting ref={settingRef} />
                </Layout>
            </Layout>
        </Watermark>
    );
};

function UserInfo() {
    const userData = React.$getUserData();
    const passwordRef = useRef(null);
    const onMenu = ({ key }) => {
        switch (key) {
            case '1':
                passwordRef.current.setIsModalVisible(true)
                passwordRef.current.form.setFieldsValue({
                    userName: userData.userName,
                });
                break;
            default:
                break;
        }
    };
    return (
        <>
            <Dropdown
                menu={{
                    items: [{
                        key: '1',
                        label: (<a> 修改密码</a>),
                    }],
                    onClick: (e) => onMenu(e),
                }}
                arrow={{
                    pointAtCenter: true,
                }}
            >
                <span className="userName">{userData?.userName || ''}</span>
            </Dropdown>
            {/* 修改密码 */}
            <ChangePassword ref={passwordRef} />
        </>
    );
}

// 遍历路由组件
function getRoutes(routes) {
    if (!Array.isArray(routes) || routes.length === 0) return null;
    const routesElement = routes.map((item, index) => {
        let currentPath = item?.path || item?.key || '';
        return (
            <React.Fragment key={currentPath || (index + 1)}>
                <Route
                    key={currentPath}
                    path={currentPath}
                    element={
                        <MemoizedRoute
                            path={currentPath}
                            params={item?.params || ''}
                            element={<item.element />}
                        />
                    }
                />
                {item.children ? getRoutes(item.children) : null}
            </React.Fragment>
        );
    });
    // 添加重定向404到末尾 
    routesElement.push(<Route key="404" path="*" element={<Navigate to="/error404" />} />);
    return routesElement;
}

// 搜索菜单
function MenuSearch(props) {
    const [value, setValue] = useState(undefined);
    const [treeData, setTreeData] = useState([]);

    useEffect(() => {
        const menuList = React.$getLocalStorageData(envConfig?.['ROOT_APP_INFO'] || 'drg-info')?.menuList || [];
        function resetMenu(list) {
            for (let i = 0; i < list?.length; i++) {
                const element = list[i];
                element.title = element?.title || '';
                element.value = element.path;
                element.key = element.path;
                element.children = element?.subs || [];
                if (element && 'subs' in element && Array.isArray(element.subs)) resetMenu(element.subs);
            }
        }
        resetMenu(menuList);
        setTreeData(menuList);
    }, []);

    const onChange = (newValue) => {
        setValue(newValue);
        if (newValue) {
            let i = {
                key: newValue
            }
            props.toRouter(i);
        }
    };

    // 自定义筛选函数，可以筛选中文内容
    const filterTreeNode = (inputValue, treeNode) => {
        // 使用 title 和 value 属性进行筛选
        return treeNode.title.includes(inputValue);
    };

    return (
        <TreeSelect
            allowClear
            showSearch
            treeDefaultExpandAll
            className="search-menu"
            placeholder="搜索菜单"
            dropdownStyle={{
                maxHeight: 400,
                overflow: 'auto',
            }}
            value={value}
            treeData={treeData}
            filterTreeNode={filterTreeNode} // 使用自定义筛选函数
            onChange={onChange}
        />
    );
}

export default CommonView;
