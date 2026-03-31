import { Modal } from 'antd';
import { BellOutlined } from '@ant-design/icons';

const timeData = 20 * 1000; // 检查间隔时间
let hidden = false; // 页面是否隐藏
let setTimeoutId;
let needTip = true; // 默认开启提示

let oldScript = [];
let newScript = [];

const getHtml = async () => {
    const html = await fetch('/').then(res => res.text()); // 读取index html
    return html;
};

const handleParserScript = (html) => {
    const reg = new RegExp(/<script(?:\s+[^>]*)?>(.*?)<\/script\s*>/ig); // script正则
    return html.match(reg); // 匹配script标签
};

const handleInit = async () => {
    const html = await getHtml();
    // console.log('🚀 ~ file: auto-update.js:31 ~ init ~ html:', html)
    oldScript = handleParserScript(html);
    console.log('🚀 ~ file: auto-update.js:30 ~ init ~ oldScript:', oldScript);
};

const handleCompareScript = async (oldArr, newArr) => {
    console.log('***************CompareScript**************');
    console.log('🚀 ~ file: auto-update.js:37 ~ CompareScript ~ oldArr, newArr:', oldArr, newArr);
    const base = oldArr.length;
    console.log('🚀 ~ file: auto-update.js:36 ~ CompareScript ~ base:', base);
    // 去重
    const arr = Array.from(new Set(oldArr.concat(newArr)));
    console.log('🚀 ~ file: auto-update.js:39 ~ CompareScript ~ arr:', arr, arr.length);
    let needRefresh = false;
    // 如果新旧length 一样无更新
    // 否则通知更新
    if (arr.length !== base) {
        console.warn('更新了!!!!!!, arr.length !== base', arr.length !== base);
        needRefresh = true;
    }
    return needRefresh;
};

// 自动更新
const handleAutoUpdate = async () => {
    setTimeoutId = setTimeout(async () => {
        const newHtml = await getHtml();
        // console.log('🚀 ~ file: auto-update.js:89 ~ newHtml:', newHtml)
        newScript = handleParserScript(newHtml);
        console.log('🚀 ~ file: auto-update.js:79 ~ newScript:', newScript);
        // 页面隐藏了就不检查更新
        if (!hidden) {
            const willRefresh = await handleCompareScript(oldScript, newScript);
            console.log('🚀 ~ file: auto-update.js:85 ~ setTimeoutId=setTimeout ~ willRefresh:', willRefresh);
            if (willRefresh && needTip) {
                // 延时更新，防止部署未完成用户就刷新空白
                setTimeout(() => {
                    // 右下角通知提示
                    Modal.confirm({
                        title: '版本更新提示',
                        icon: <BellOutlined />,
                        content: '发现系统版本更新，请刷新界面',
                        okText: '确认刷新',
                        cancelText: '稍后刷新',
                        onOk: () => {
                            window.location.reload();
                        }
                    });
                }, 10000)
                needTip = false; // 关闭更新提示，防止重复提醒
            };
        };
        console.log('🚀 ~ file: auto-update.js:90 ~ autoUpdate ~ needTip: ', needTip);
        if (needTip) {
            console.warn('needTip autoUpdate');
            handleAutoUpdate();
        };
    }, timeData);
};

// 停止检测更新
const handleStop = () => {
    if (setTimeoutId) {
        clearTimeout(setTimeoutId);
        setTimeoutId = '';
    };
};

// 开始检查更新
const autoUpdate = async () => {
    handleInit();
    handleAutoUpdate();
    // 监听页面是否隐藏
    document.addEventListener('visibilitychange', () => {
        hidden = document.hidden;
        console.log('🚀 ~ file: auto-update.js:64 ~ document.addEventListener ~ hidden, needTip:', hidden, needTip);
        // 页面隐藏了就不检查更新。或者已经有一个提示框了，防止重复提示。
        if (!hidden && needTip) {
            handleAutoUpdate();
        } else {
            handleStop();
        };
    });
};

export { autoUpdate };