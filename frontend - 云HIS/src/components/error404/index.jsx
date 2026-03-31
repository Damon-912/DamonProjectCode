import React from 'react';
import { useNavigate } from 'react-router-dom';
import store from '@store';
import error404 from '@assets/images/404.png';
import './index.less';

function Error() {
    const navigate = useNavigate();
    const { contentHeight } = store.getState();

    return (
        <div style={{ height: contentHeight + 'px' }} className="error404">
            <canvas id="error404Canvas"></canvas>
            <div className="error_main">
                <div className="errorImg">
                    <img src={error404} alt="" />
                </div>
                <div className="errorText">
                    <h1>404</h1>
                    <h2>UN ON! 页面丢失啦</h2>
                    <p>如急需使用该功能，请联系产品维护人员，抱歉。</p>
                    <button onClick={() => navigate('/')}> 返回首页</button>
                </div>
            </div>
        </div>
    );
};

export default Error;