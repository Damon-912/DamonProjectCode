/*
 * Create:      柿子
 * CreateDate:  2024/04/29
 * Describe：   弹窗表单公共组件
 * */
import React, { useState, useRef, forwardRef, useImperativeHandle } from 'react';
import { Modal } from 'antd';
import request from '@api';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import './style/index.less';

const PublicModalFormHooks = (props, ref) => {
    let formRef = useRef(null);
    const [visible, setVisible] = useState(false);
    const [okLoading, setLoading] = useState(false);
    const [httpFormData, setHttpFormData] = useState([]);

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible,
        getFieldsValue,
        resetFields,
        handleSave,
        modifyOkLoading: (loading) => setLoading(loading),
    }));

    // 修改弹窗状态
    const modifyVisible = (visible, isReset) => {
        if (visible) {
            getFormData();
        }
        okLoading && setLoading(false);
        setVisible(visible);
        isReset === 'Y' && resetFields();
    };

    // 获取表单数据
    const getFormData = async () => {
        try {
            if (currentFormData && Array.isArray(currentFormData) && currentFormData.length > 0) return;
            const { componentName, componentInfo = {} } = props;
            let nComponentInfo = componentInfo;
            if (!(nComponentInfo?.componentCode || '')) { // 如果根据菜单代码没有取到组件相关信息由弹窗自己获取
                if (!componentName) return;
                const res = await request.getComponentInfo(componentName);
                nComponentInfo = { ...(res?.result), totalWidth: res?.totalWidth || 0 };
            }
            setHttpFormData(nComponentInfo?.formData || []);
        } catch (error) {
            console.log(error);
        };
    };

    // 获取数据
    const getFieldsValue = () => {
        let fromValues = formRef && formRef.current && formRef.current.getFieldsValue();
        return {
            ...fromValues,
        }
    };

    // 重置
    const resetFields = () => {
        formRef && formRef.current && formRef.current.resetFields();
    };

    // 保存
    const handleSave = () => {
        let autoLoading = props?.autoLoading || '';
        if (autoLoading !== 'N') {
            if (okLoading) return;
            setLoading(true);
        }
        formRef && formRef.current && formRef.current.handleSave('Y')
            .then(result => {
                if (!(result?.error)) {
                    props.handleSave && props.handleSave(result)
                } else {
                    setLoading(false);
                }
            })
    };

    // 关闭弹窗
    const handleCancel = () => {
        if (props && 'recordFormInput' in props && props.recordFormInput) { // 关闭弹窗的时候记录表单输入的值
            let fieldsValue = getFieldsValue();
            props.recordFormInput && props.recordFormInput(fieldsValue);
        }
        modifyVisible(false);
    };

    const { title, okText, cancelText, className = '', width, idField, rowData, selectData, formData, formItemCol } = props;
    const currentFormData = httpFormData && Array.isArray(httpFormData) && httpFormData.length > 0 ? httpFormData : formData;
    return (
        <Modal
            open={visible}
            width={width || '800px'}
            className={[className, 'public-modal-form-hooks'].join(' ')}
            title={title || ((rowData && ((idField && rowData[idField]) || ('id' in rowData && rowData.id))) ? '编辑' : '添加')}
            okText={okText || ((rowData && ((idField && rowData[idField]) || ('id' in rowData && rowData.id))) ? '确认修改' : '保存')}
            cancelText={cancelText || ((rowData && ((idField && rowData[idField]) || ('id' in rowData && rowData.id))) ? '取消修改' : '取消')}
            okButtonProps={{
                loading: okLoading
            }}
            onOk={handleSave}
            onCancel={handleCancel}
        >
            <div style={{ maxHeight: '64vh', overflow: 'auto', paddingRight: '12px' }}>
                <DynamicRenderingForm
                    rowData={rowData || {}}
                    formData={currentFormData}
                    selectData={selectData || {}}
                    formItemCol={formItemCol ? formItemCol : { labelCol: 8, wrapperCol: 16 }}
                    ref={formRef}
                />
            </div>
        </Modal>
    )
};

export default forwardRef(PublicModalFormHooks);