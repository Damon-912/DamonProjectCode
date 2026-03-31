/*
 * Create:      柿子
 * CreateDate:  2024/04/26
 * Describe：   表头数据个人配置
 * */
import React, { useState, forwardRef, useImperativeHandle, useEffect } from 'react';
import { Modal, Select, Button, Popconfirm, message } from 'antd';
import { Util } from '@tools';
import PublicTablePagination from './PublicTablePagination';

const PublicColumnAuthority = (props, ref) => {
    const propsComponentName = props?.componentName || '';
    const userData = React.$getUserData();
    const [type, setType] = useState(undefined);
    const [visible, setVisible] = useState(false);
    const [tableData, setTableData] = useState([]);
    const [authList, setAuthList] = useState([]);
    const [selectedRowKeys, setSelectedRowKeys] = useState([]);
    const columns = [{
        key: 'code',
        width: '150px',
        dataIndex: 'code',
        title: '代码',
    }, {
        key: 'descripts',
        width: '150px',
        dataIndex: 'descripts',
        title: '列名',
        typeCode: 'Input'
    }, {
        key: 'width',
        width: '90px',
        dataIndex: 'width',
        title: '列宽',
        typeCode: 'Input'
    }, {
        key: 'align',
        width: '100px',
        dataIndex: 'align',
        title: '对齐方式',
        typeCode: 'Select',
        detailItem: [{
            id: 'left',
            desc: '左对齐'
        }, {
            id: 'center',
            desc: '居中'
        }, {
            id: 'right',
            desc: '右对齐'
        }]
    }, {
        key: 'fixed',
        width: '100px',
        dataIndex: 'fixed',
        title: '固定显示',
        typeCode: 'Select',
        detailItem: [{
            id: 'left',
            desc: '左侧'
        }, {
            id: 'right',
            desc: '右侧'
        }]
    }, {
        width: '60px',
        align: 'center',
        key: 'display',
        dataIndex: 'display',
        title: '显示',
        typeCode: 'Checkbox'
    }, {
        width: '60px',
        align: 'center',
        key: 'export',
        dataIndex: 'export',
        title: '导出',
        typeCode: 'Checkbox'
    }, {
        width: '60px',
        align: 'center',
        key: 'print',
        dataIndex: 'print',
        title: '打印',
        typeCode: 'Checkbox'
    }];

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible
    }));

    // 修改弹窗状态
    const modifyVisible = (visible) => {
        visible && getEditAuth();
    }

    // 获取编辑权限
    const getEditAuth = async () => {
        try {
            let res = await React.$asyncPost('01010040');
            if (res?.result?.editFlag == 'Y') {
                const authList = res?.result?.authList || [];
                setVisible(true);
                setAuthList(authList);
                let defaultType = res?.result?.defaultType || (authList && Array.isArray(authList) && authList.length > 0 ? authList[0]?.value : undefined) || undefined;
                setType(defaultType);
            } else {
                setVisible(false);
                setAuthList([]);
                message.warning('暂无编辑权限！');
            }
        } catch (error) {
            setVisible(false);
            setAuthList([]);
            message.warning('暂无编辑权限！');
        }
    };

    useEffect(() => {
        type && getTableData();
    }, [type]);

    // 确认
    const handleOK = () => {
        setVisible(false);
        props && 'getColumns' in props && props.getColumns && props.getColumns();
    };

    // 选择权限类型
    const handleTypeChange = (type) => {
        setType(type);
    };

    // 获取列表数据
    const getTableData = async (defaultType) => {
        try {
            let data = {
                params: [{
                    businessFlag: 'Y', // 用于区分是否为维护界面
                    componentName: propsComponentName,
                    saveType: defaultType || type,
                    language: userData?.language || '',
                }]
            };
            const res = await React.$asyncPost('01040073', data);
            setTableData(Util.addKeyValueToDataSource(res.result?.C || [], '', 0));
            setSelectedRowKeys([]);
        } catch (error) {
            console.log(error);
        }
    };

    // 保存列权限
    const handleSave = async () => {
        try {
            let data = {
                params: [{
                    type,
                    tableData: Util.addKeyValueToDataSource(tableData || [], '', 1, '', 'seqNo'),
                    componentName: propsComponentName,
                    updateUser: userData?.userID || '',
                    language: userData?.language || '',
                }]
            };
            const res = await React.$asyncPost('01010038', data);
            message.success(res.errorMessage ? res.errorMessage : '保存成功');
            setSelectedRowKeys([]);
            handleOK();
        } catch (error) {
            console.log(error);
        };
    };

    // 删除列权限
    const handleDelete = async () => {
        try {
            let data = {
                params: [{
                    type,
                    componentName: propsComponentName,
                    updateUser: userData?.userID || '',
                }]
            };
            const res = await React.$asyncPost('01010039', data);
            message.success(res.errorMessage ? res.errorMessage : '删除配置成功');
            getTableData();
            handleOK();
        } catch (error) {
            console.log(error);
        };
    };

    // 上移
    const handleUp = () => {
        let keys = Util.customDeepCopy(selectedRowKeys);
        let data = Util.customDeepCopy(tableData);
        if (!(keys && keys.length > 0)) return;
        let newKeys = []
        keys = keys.sort(function (m, n) {
            if (m < n) return -1;
            else if (m > n) return 1;
            else return 0;
        });
        for (let i = 0; i < keys.length; i++) {
            let currentKey = keys[i];
            let nextKey = Number(currentKey) - 1;
            if (currentKey === 0) {
                newKeys.push(currentKey);
                continue;
            }
            let curRowData = data[currentKey];
            let upRowData = data[nextKey];
            let curRowKey = curRowData?.key || 0;
            let upRowKey = upRowData?.key || 0;
            upRowData.key = curRowKey;
            curRowData.key = upRowKey;
            data[currentKey] = upRowData;
            data[nextKey] = curRowData;
            newKeys.push(String(nextKey));
        };
        setTableData([...data]);
        setSelectedRowKeys([...newKeys]);
    };

    // 下移
    const handleDown = () => {
        let keys = Util.customDeepCopy(selectedRowKeys);
        let data = Util.customDeepCopy(tableData);
        if (!(keys && keys.length > 0)) return;
        let newKeys = [];
        keys = keys.sort(function (m, n) {
            if (m < n) return -1;
            else if (m > n) return 1;
            else return 0;
        });
        for (let i = keys.length - 1; i >= 0; i--) {
            let currentKey = keys[i];
            let nextKey = Number(currentKey) + 1;
            if (currentKey === data.length - 1) {
                newKeys.push(currentKey);
                continue;
            }
            let curRowData = data[currentKey];
            let upRowData = data[nextKey];
            let curRowKey = curRowData?.key || 0;
            let upRowKey = upRowData?.key || 0;
            upRowData.key = curRowKey;
            curRowData.key = upRowKey;
            data[currentKey] = upRowData;
            data[nextKey] = curRowData;
            newKeys.push(String(nextKey));
        };
        setTableData([...data]);
        setSelectedRowKeys([...newKeys]);
    };

    // 输入域change
    const handleInputChange = (val, index, dataIndex) => {
        setTableData(oldData => oldData.map((item, idx) =>
            idx === index ? { ...item, [dataIndex]: val } : item));
    };

    const rowSelection = {
        selectedRowKeys,
        onChange: (selectedRowKeys, selectedRows) => {
            setSelectedRowKeys(selectedRowKeys);
        },
    };
    return (
        <Modal
            width="900px"
            title={'组件信息维护(' + propsComponentName + ')'}
            footer={null}
            open={visible}
            onCancel={() => setVisible(false)}
        >
            <div style={{ margin: '12px 0' }}>
                <Select
                    allowClear
                    showSearch
                    value={type}
                    placeholder="请选择"
                    optionFilterProp="search"
                    style={{ width: 200, marginRight: 20 }}
                    onChange={handleTypeChange}
                >
                    {React.$SelectOptions(authList, 'value')}
                </Select>
                <Button type="primary" ghost onClick={handleUp} style={{ marginRight: 15 }}>向上移动</Button>
                <Button type="primary" ghost onClick={handleDown} style={{ marginRight: 15 }}>向下移动</Button>
                <Button type="primary" onClick={handleSave} style={{ marginRight: 15 }}>保存</Button>
                <Popconfirm title="删除不可恢复，你确定要删除吗?" onConfirm={handleDelete}>
                    <Button danger >删除当前配置</Button>
                </Popconfirm>
            </div>
            <PublicTablePagination
                param={{
                    columns,
                    data: tableData,
                    x: 760,
                    y: 460,
                }}
                rowSelection={rowSelection}
                onChange={handleInputChange}
            />
        </Modal>
    )
};

export default forwardRef(PublicColumnAuthority);