import React from 'react';
import { useNavigate } from 'react-router-dom';
import store from '@store';
import error302 from '@assets/images/302.png';
import './index.less';

function Error() {
    const navigate = useNavigate();
    const { contentHeight } = store.getState();

    return (
        <div style={{ height: contentHeight + 'px' }} className="error302">
            <div className="error_main">
                <div className="errorImg">
                    <img src={error302} alt="" />
                </div>
                <div className="errorText">
                    <h1>302</h1>
                    <h2>临时重定向</h2>
                    <p>菜单路径已添加，但组件并未创建或正在开发中，请联系前端仔或返回首页</p>
                    <button onClick={() => navigate('/')}> 返回首页</button>
                </div>
            </div>
        </div>
    );
};

export default Error;