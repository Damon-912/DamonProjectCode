/*
 * Create:      柿子
 * CreateDate:  2024/05/29
 * Describe：   图片预览 - 查看图片
 * */
import React, { useState, useImperativeHandle, forwardRef } from 'react';
import { Modal } from 'antd';
import './style/index.less';

const PublicImagePreview = (props, ref) => {
    const [visible, setVisible] = useState(false);
    const [imgUrl, setImgUrl] = useState('');

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible,
    }));

    const modifyVisible = (nVisible, nUrl) => {
        if (nVisible) {
            setImgUrl(nUrl);
        }
        setVisible(nVisible);
    };

    return (
        <Modal
            open={visible}
            footer={false}
            className="public-image-preview"
            width={props?.width || '72vw'}
            title={props?.title || '图片预览'}
            onCancel={() => modifyVisible(false)}
        >
            <div className="pip-body" style={{ height: props?.height || '70vh', background: 'url(' + imgUrl + ') no-repeat' }}></div>
        </Modal>
    )
};

export default forwardRef(PublicImagePreview);