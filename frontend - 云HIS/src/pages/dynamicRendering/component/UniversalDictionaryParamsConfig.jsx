/*
 * Create:      柿子
 * CreateDate:  2024/07/12
 * Describe：   多级字典参数配置
 * */
import React, { useState, useRef, forwardRef, useCallback, useImperativeHandle, useEffect } from 'react';
import { Drawer } from 'antd';
import '../style/children.less';

const UniversalDictionaryParamsConfig = (props, ref) => {
    const [visible, setVisible] = useState(false);
    const [rowData, setRowData] = useState({});
    const [current, setCurrent] = useState(0);
    const [maxCurrent, setMaxCurrent] = useState(0);
    const stepsItems = [{
        title: '页面布局',
        description: '配置表格列及字段',
    }, {
        title: '接口参数配置',
        description: '配置页面的接口及参数',
    }, {
        title: '页面预览',
        description: '界面效果图预览',
    }];

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible,
    }));

    // 修改弹窗状态
    const modifyVisible = (visible, nRowData = {}) => {
        if (visible) {
            setRowData(nRowData);
        };
        setVisible(visible);
    };

    const handleStepsChange = (value) => {
        setCurrent((oldCurrent) => {
            return maxCurrent >= value ? value : oldCurrent
        });
    };

    // 下一步 | 确认
    const handleOk = () => {
        if (current === stepsItems.length - 1) { // 确认(1、保存基础参数  2、保存列及表单数据)
            handleComponentDataSave();
        } else { // 下一步
            if (current === 1) {

            } else {

            }
        };
    };

    // 上一步 | 取消
    const handleCancel = (type) => {
        if (type !== 'close' && current > 0 && current <= stepsItems.length - 1) { // 上一步
            setCurrent(oldCurrent => {
                return oldCurrent - 1;
            })
        } else { // 取消 - 关闭弹窗
            modifyVisible(false);
        }
    };

    // 组件数据保存
    const handleComponentDataSave = async () => {
        
    };

    return (
        <div>
            <Drawer
                width="80vw"
                className="single-table-params-config"
                title={'界面参数配置 ( ' + (rowData?.descripts || rowData?.title || '') + ' ) '}
                open={visible}
                onClose={() => handleCancel('close')}
            >
                132
            </Drawer>
        </div>
    );
};

export default forwardRef(UniversalDictionaryParamsConfig);