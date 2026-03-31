import React, { forwardRef, useEffect, useImperativeHandle, useState } from 'react';
import { Drawer, Divider, message, Tooltip, Switch, Tag } from 'antd';
import { CheckOutlined } from '@ant-design/icons';
import { setCookies, getCookies } from '@tools/cookies';
import { envConfig } from '@envConfig';
//用于获取状态
import store from '@store';
import './index.less';

const Setting = forwardRef((props, ref) => {
    let [SettingVisible, setSettingVisible] = useState(false);
    let [darkChecked, setDarkChecked] = useState(false);
    let [grayChecked, setGrayChecked] = useState(false);
    let [weakChecked, setWeakChecked] = useState(false);
    let [widthChecked, setWidthChecked] = useState(false);
    let [navChecked, setNavChecked] = useState(false);
    let [bgCheck, setBgCheck] = useState(envConfig?.['ROOT_APP_COLOR'] || '');
    let [StyleCheck, setStyleCheck] = useState('dark');
    let [pattern, setPattern] = useState('broadside');
    // 主题颜色
    const colorList = [{
        key: '极客蓝（默认）', color: '#1890ff',
    }, {
        key: '深海蓝', color: '#2f54eb',
    }, {
        key: '火山', color: '#f5222d',
    }, {
        key: '浅红', color: '#fa541c',
    }, {
        key: '日暮', color: '#faad14',
    }, {
        key: '明青', color: '#13C2C2',
    }, {
        key: '草绿', color: '#52c41a',
    }, {
        key: '熏紫', color: '#a876ed',
    }];
    const ThemeBgColor = getCookies('ThemeBgColor');
    const ThemeStyle = getCookies('ThemeStyle');
    const patternStyle = getCookies('pattern');
    const widthStyle = getCookies('widthStyle');
    const navStyle = getCookies('navStyle');

    //将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        setSettingVisible
    }));

    useEffect(() => {
        switch (getCookies('weakOrGray')) {
            case 'gray':
                setGrayChecked(true)
                break;
            case 'weak':
                setWeakChecked(true)
                break;
            default:
                break;
        }
        if (getCookies('darkTheme')) {
            setDarkChecked(true)
        }
        if (patternStyle) setPattern(patternStyle)
        if (ThemeBgColor) setBgCheck(ThemeBgColor)
        if (ThemeStyle) setStyleCheck(ThemeStyle)
        if (widthStyle == 'true') {
            setWidthChecked(true)
        } else {
            setWidthChecked(false)
        }
        if (navStyle == 'true') setNavChecked(true)
        else setNavChecked(false)
    }, []);

    // 深夜模式
    const darkChange = (e) => {
        setDarkChecked(e)
        //通知reducer页面数据变化了
        store.dispatch({
            type: 'darkTheme',
            data: e
        });
    };

    // 灰色模式
    const grayChange = (e) => {
        setGrayChecked(e)
        //通知reducer页面数据变化了
        if (e) {
            store.dispatch({
                type: 'weakOrGray',
                data: 'gray'
            })
            setWeakChecked(false)
        } else {
            store.dispatch({
                type: 'weakOrGray',
                data: false
            })
        }
    };

    // 色弱模式
    const weakChange = (e) => {
        setWeakChecked(e)
        //通知reducer页面数据变化了
        if (e) {
            store.dispatch({
                type: 'weakOrGray',
                data: 'weak'
            })
            setGrayChecked(false)
        } else {
            store.dispatch({
                type: 'weakOrGray',
                data: false
            })
        }
    };

    // 主题颜色
    const changeColor = (item) => {
        setCookies('ThemeBgColor', item.color, 365);
        message.loading('主题编译中，请稍后');
        setBgCheck(item.color);
        window.location.reload();
    };

    // 风格
    const darkOn = () => {
        setStyleCheck('dark');
        setCookies('ThemeStyle', 'dark', 365);
        store.dispatch({
            type: 'ThemeStyle',
            data: 'dark'
        });
        message.loading('风格切换中，请稍后');
        window.location.reload();
    };

    const lightOn = () => {
        setStyleCheck('light');
        setCookies('ThemeStyle', 'light', 365);
        store.dispatch({
            type: 'ThemeStyle',
            data: 'light'
        });
        message.loading('风格切换中，请稍后');
        window.location.reload();
    };

    // 导航模式
    const sidebarOn = () => {
        setPattern('broadside');
        store.dispatch({
            type: 'pattern',
            data: 'broadside'
        });
        setCookies('pattern', 'broadside', 365);
        message.loading('模式切换中，请稍后');
        window.location.reload();
    };

    const topOn = () => {
        setPattern('top');
        store.dispatch({
            type: 'pattern',
            data: 'top'
        });
        setCookies('pattern', 'top', 365);
        setWidthChecked(true);
        setCookies('widthStyle', true, 365);
        message.loading('模式切换中，请稍后');
        window.location.reload();
    };

    // 内容宽度
    const gudingChange = (e) => {
        setWidthChecked(e);
        setCookies('widthStyle', e, 365);
        window.location.reload();
    };

    // 固定导航
    const navChange = (e) => {
        setNavChecked(e);
        setCookies('navStyle', e, 365);
        window.location.reload();
    };

    return (
        <Drawer
            width="20%"
            className="setting"
            closable={true}
            open={SettingVisible}
            onClose={() => { setSettingVisible(false) }}
        >
            <Divider>模式设置</Divider>
            <div className="theme-item">
                <span>深夜模式</span>
                <Switch checked={darkChecked} checkedChildren="开启" unCheckedChildren="关闭" onChange={e => darkChange(e)} />
            </div>
            <div className="theme-item">
                <span>灰色模式</span>
                <Switch checked={grayChecked} checkedChildren="开启" unCheckedChildren="关闭" onChange={e => grayChange(e)} />
            </div>
            <div className="theme-item">
                <span>色弱模式</span>
                <Switch checked={weakChecked} checkedChildren="开启" unCheckedChildren="关闭" onChange={e => weakChange(e)} />
            </div>
            <Divider>主题颜色</Divider>
            <div className="theme-bgd">
                {colorList && colorList.map((item, index) => {
                    return (
                        <Tooltip title={item.key} key={index}>
                            <Tag color={item.color} onClick={() => changeColor(item)}>
                                {bgCheck == item.color ? < CheckOutlined /> : ""}
                            </Tag>
                        </Tooltip>
                    )
                })}
            </div>
            <Divider>导航风格</Divider>
            <div className="theme-style">
                <Tooltip title="暗色菜单风格">
                    <div className="theme-style-dark" onClick={darkOn}>
                        <div className="theme-style-dark-left"></div>
                        <div className="theme-style-dark-right">
                            <div className="theme-style-dark-right-top"></div>
                            <div className="theme-style-dark-right-bot">
                                {StyleCheck == 'dark' ? < CheckOutlined /> : ''}
                            </div>
                        </div>
                    </div>
                </Tooltip>
                <Tooltip title="高亮菜单风格">
                    <div className="theme-style-light" onClick={lightOn}>
                        <div className="theme-style-light-left"></div>
                        <div className="theme-style-light-right">
                            <div className="theme-style-light-right-top"></div>
                            <div className="theme-style-light-right-bot">
                                {StyleCheck == 'light' ? < CheckOutlined /> : ''}
                            </div>
                        </div>
                    </div>
                </Tooltip>
            </div>
            <Divider>导航模式</Divider>
            <div className="theme-style">
                <Tooltip title="侧边导航模式">
                    <div className="theme-style-dark" onClick={sidebarOn}>
                        <div className="theme-style-dark-left"></div>
                        <div className="theme-style-dark-right">
                            <div className="theme-style-dark-right-top"></div>
                            <div className="theme-style-dark-right-bot">
                                {pattern == 'broadside' ? < CheckOutlined /> : ''}
                            </div>
                        </div>
                    </div>
                </Tooltip>
                <Tooltip title="顶部导航模式">
                    <div className="ding-bu-style" onClick={topOn}>
                        <div className="ding-bu-style-top"></div>
                        <div className="ding-bu-style-bottom">
                            <div className="ding-bu-style-bottom-bot">
                                {pattern == 'top' ? < CheckOutlined /> : ''}
                            </div>
                        </div>
                    </div>
                </Tooltip>
            </div>
            <div className="theme-item">
                <span>内容区域宽度</span>
                <span style={{ fontSize: '.6vw', color: '#bbb' }}>只在顶部导航模式生效</span>
                <Switch checked={widthChecked} disabled={pattern == "broadside"} checkedChildren="固定" unCheckedChildren="流式" onChange={e => gudingChange(e)} />
            </div>
            <div className="theme-item">
                <span>固定  Header</span>
                <span style={{ fontSize: '.6vw', color: '#bbb' }}>只在顶部导航模式生效</span>
                <Switch checked={navChecked} disabled={pattern == "broadside"} checkedChildren="开启" unCheckedChildren="关闭" onChange={e => navChange(e)} />
            </div>
        </Drawer>
    )
});

export default Setting;