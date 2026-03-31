import React from 'react';
import { useNavigate } from 'react-router-dom';
import store from '@store';
import error403 from '@assets/images/403.png';
import './index.less';

function Error() {
    const navigate = useNavigate();
    const { contentHeight } = store.getState();

    return (
        <div style={{ height: contentHeight + 'px' }} className="error403">
            <div className="error_main">
                <div className="errorImg">
                    <img src={error403} alt="" />
                </div>
                <div className="errorText">
                    <h1>403</h1>
                    <h2>很抱歉，您无权访问该页面</h2>
                    <p>别灰心，可能是内容被限制，请联系管理员或者返回首页</p>
                    <button onClick={() => navigate("/")}> 返回首页</button>
                </div>
            </div>
        </div>
    );
};

export default Error;