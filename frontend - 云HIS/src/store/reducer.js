const defaultState = {
    reload: false,
    fullScreen: false, // 全屏标志
    darkTheme: false, // 深夜模式
    weakOrGray: false, // 色弱/灰色
    ThemeStyle: 'dark', // 导航风格 light | dark
    themeUpdateFlag: false, // 主题更新标志
    pattern: 'broadside', // 导航模式 - 测菜单 -   头菜单 - top
    patternUpdateFlag: false, // 导航栏更新标志
    documentHeight: 100, // 当前屏幕高度
    contentHeight: 100, // 内容区域高度
    errorFlag: false, // 菜单加载异常标志
    menuList: [], // 菜单数据 - 临时保存-刷新后需重新获取
};

const reducer = (preState = defaultState, action) => {
    const { type, data } = action;
    if (type === 'darkTheme' || type === 'weakOrGray') {
        return {
            ...preState,
            [type]: data,
            themeUpdateFlag: true
        }
    }
    if (type === 'pattern') {
        return {
            ...preState,
            [type]: data,
            patternUpdateFlag: true
        }
    }
    return {
        ...preState,
        [type]: data
    };
};

export default reducer