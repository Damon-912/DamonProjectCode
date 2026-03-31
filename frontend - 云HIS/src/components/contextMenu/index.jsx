
import { forwardRef, useImperativeHandle, useState } from 'react';
import { LeftOutlined, RightOutlined, CloseOutlined } from '@ant-design/icons';
import './index.less'

const ContextMenu = forwardRef((props, ref) => {
    const [contText, setContText] = useState('');

    //将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        showContext
    }));

    const handleCloseTab = (key) => {
        switch (key) {
            case 'left':
                props.closeLeftMenu(contText)
                break;
            case 'right':
                props.closeRightMenu(contText)
                break;
            case 'other':
                props.closeElseMenu(contText)
                break;
            default:
                break;
        }
    };

    const btnList = [
        {
            text: '关闭左侧',
            key: 'left',
            icon: <LeftOutlined />,
            handleClick: handleCloseTab,
        },
        {
            text: '关闭右侧',
            key: 'right',
            icon: <RightOutlined />,
            handleClick: handleCloseTab,
        },
        {
            text: '关闭其它',
            key: 'other',
            icon: <CloseOutlined />,
            handleClick: handleCloseTab,
        },
    ];

    const showContext = (e) => {
        // 是否中文
        let re = /.*[\u4e00-\u9fa5]+.*$/;
        // 此条件下才展示弹窗
        if (e.target.nodeName === 'SPAN' && re.test(e.target.innerText)) {
            const x = e.clientX
            const y = e.clientY
            // 弹窗节点
            const rightMenu = document.getElementsByClassName('rightMenu')[0]
            rightMenu.style.display = 'block'
            rightMenu.style.position = 'absolute'
            rightMenu.style.left = x + 'px' //设置弹窗位置
            rightMenu.style.top = y + 'px'
            setContText(e.target.innerText)
            document.onclick = function () { //点击其他区域要隐藏弹窗
                rightMenu.style.display = 'none'
            }
        }
    };

    return (
        <div className="right-menu" style={{ display: 'none' }}>
            {btnList.map((item) => {
                return (
                    <li onClick={() => item.handleClick(item.key)} key={item.key}>
                        <span>  {item.icon}</span>
                        <span> {item.text}</span>
                    </li>
                )
            })}
        </div>
    )
});

export default ContextMenu;