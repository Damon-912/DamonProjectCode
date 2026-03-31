/*
 * Create:      柿子
 * CreateDate:  2024/05/23
 * Describe：   组件权限设置【组件列、表单及按钮设置】
 * */
import React, { useState, forwardRef, useImperativeHandle, useEffect } from 'react';
import { Modal, Tabs, message, Row, Col, Card, notification } from 'antd';
import request from '@api';
import store from '@store';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import '../style/children.less';

const ComponentPermissionSettings = (props, ref) => {
    const { contentHeight } = store.getState();
    const [visible, setVisible] = useState(false);
    const [rowData, setRowData] = useState({});
    const [columnsArr, setColumnsArr] = useState([]);
    const [activeKey, setActiveKey] = useState('1');
    const [activeRecordData, setActiveRecordData] = useState({});
    const [loading, setLoading] = useState(false);
    const [columns, setColumns] = useState([]);
    const [totalWidth, setTotalWidth] = useState(0);
    const [tableData, setTableData] = useState([]);
    const [formColumns, setFormColumns] = useState([]);
    const [formTotalWidth, setFormTotalWidth] = useState(0);
    const [formTableData, setFormTableData] = useState([]);
    const [buttonColumns, setButtonColumns] = useState([]);
    const [buttonTotalWidth, setButtonTotalWidth] = useState(0);
    const [buttonTableData, setButtonTableData] = useState([]);

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible
    }));

    const modifyVisible = async (visible, nRowData = {}) => {
        if (visible) {
            setRowData(nRowData);
            nRowData?.menuDetailCode !== rowData?.menuDetailCode && setActiveKey('1');
            if (nRowData && 'menuDetailCode' in nRowData && nRowData.menuDetailCode) {
                let colFlag = await getMenuColumnsData(nRowData, true);
                if (!colFlag) {
                    notification.error({
                        message: `系统提醒 :`,
                        description: '未查询到组件信息，请检查当前菜单是否关联组件！',
                    });
                    return;
                }
            } else {
                message.warning('菜单代码有误，请核对信息！');
                return;
            }
            if (!(columns && Array.isArray(columns) && columns.length > 0)) {
                getColumnsInfo();
            }
        };
        setVisible(visible);
    }

    // 根据菜单代码获取组件数据
    const getMenuColumnsData = async (nRowData, isReturnFlag) => {
        try {
            let data = {
                params: [{
                    groupID: nRowData?.groupID || '',
                    menuDetailCode: nRowData?.menuDetailCode || '',
                }]
            };
            const res = await React.$asyncPost('01010062', data);
            let nColumnsArr = React.$processingTableRequestData(res);
            setColumnsArr(nColumnsArr);
            if (isReturnFlag) {
                return !!(nColumnsArr && Array.isArray(nColumnsArr) && nColumnsArr.length)
            }
        } catch (error) {
            console.log(error);
            if (isReturnFlag) {
                return false;
            }
        };
    };

    // 根据菜单代码获取组件数据
    const getColumnsInfo = async () => {
        try {
            const res = await request.getComponentInfo(['ComponentPermissionSettingsColumns', 'ComponentPermissionSettingsFormField', 'ComponentPermissionSettingsButton']);
            let columnsInfo = res?.result || [];
            if (columnsInfo && Array.isArray(columnsInfo) && columnsInfo.length > 0) {
                for (let i = 0; i < columnsInfo.length; i++) {
                    setColumnsData(columnsInfo[i])
                }
            }
        } catch (error) {
            console.log(error);
        };
    };

    // 根据菜单代码获取组件数据
    const setColumnsData = (colInfo) => {
        if (colInfo?.componentCode === 'ComponentPermissionSettingsColumns') { // 表格列
            setColumns(colInfo?.C || []);
            setTotalWidth(colInfo?.totalWidth || 0);
        } else if (colInfo?.componentCode === 'ComponentPermissionSettingsFormField') { // 表单
            setFormColumns(colInfo?.C || []);
            setFormTotalWidth(colInfo?.totalWidth || 0);
        } else if (colInfo?.componentCode === 'ComponentPermissionSettingsButton') { // 按钮
            setButtonColumns(colInfo?.C || []);
            setButtonTotalWidth(colInfo?.totalWidth || 0);
        }
    };

    // 关闭弹窗
    const handleCancel = () => {
        setVisible(false);
    };

    // 选中tab
    const handleTabChange = (key) => {
        setActiveKey(key);
    };

    useEffect(() => {
        if (activeKey && columnsArr && columnsArr.length > 0) {
            getTableData();
        }
    }, [activeKey, columnsArr])

    // 获取授权数据
    const getTableData = () => {
        let currentData = columnsArr[activeKey - 1];
        setActiveRecordData(currentData);
        setTableData(currentData?.C || []);
        setFormTableData(currentData?.formData || [])
        setButtonTableData(currentData?.buttonData || [])
    };

    // 保存
    const handleSave = async () => {
        try {
            let data = {
                params: [{
                    groupID: rowData?.groupID || '',
                    menuDetailCode: rowData?.menuDetailCode || '',
                    componentCode: activeRecordData?.componentCode || '',
                    C: tableData,
                    formData: formTableData,
                    buttonData: buttonTableData
                }]
            };
            const res = await React.$asyncPost('01010063', data);
            message.success(res?.errorMessage || '保存成功');
            getMenuColumnsData(rowData);
        } catch (error) {
            console.log(error);
        };
    };

    // 表格列权限change
    const handleColumnsInputChange = (val, index, dataIndex) => {
        setTableData(oldData => {
            let newData = JSON.parse(JSON.stringify(oldData));
            newData[index][dataIndex] = val;
            return newData;
        });
    };

    // 表格列权限change
    const handleFormInputChange = (val, index, dataIndex) => {
        setFormTableData(oldData => {
            let newData = JSON.parse(JSON.stringify(oldData));
            newData[index][dataIndex] = val;
            return newData;
        });
    };

    // 表格列权限change
    const handleButtonInputChange = (val, index, dataIndex) => {
        setButtonTableData(oldData => {
            let newData = JSON.parse(JSON.stringify(oldData));
            newData[index][dataIndex] = val;
            return newData;
        });
    };

    // 渲染数据
    const renderItems = () => {
        return columnsArr && columnsArr.map((item, index) => {
            return {
                ...item,
                key: String(index + 1),
                label: item?.descripts || item?.title || item?.componentDesc || item?.componentCode || '',
                children: (
                    <Row className="cps-tab-body">
                        <Col span={9} className="cps-tab-item">
                            <Card
                                size="small"
                                title={(
                                    <div className="common-card-title-vertical-line">
                                        <div></div>
                                        表格列权限设置
                                    </div>
                                )}
                            >
                                <div>
                                    <PublicTablePagination
                                        param={{
                                            loading,
                                            // 表头配置
                                            columns,
                                            x: totalWidth, // 表格的宽度
                                            y: contentHeight - 360,
                                            height: contentHeight - 320 + 'px',
                                            data: tableData, // 表格数据
                                            componentName: 'ComponentPermissionSettingsColumns',
                                        }}
                                        onChange={handleColumnsInputChange}
                                    />
                                </div>
                            </Card>
                        </Col>
                        <Col span={8} className="cps-tab-item">
                            <div style={{ padding: '0 6px', position: 'relative' }}>
                                <div style={{ background: '#fff' }} className="common-card-left-split-line"></div>
                                <Card
                                    size="small"
                                    title={(
                                        <div className="common-card-title-vertical-line">
                                            <div></div>
                                            表单字段权限设置
                                        </div>
                                    )}
                                >
                                    <div>
                                        <PublicTablePagination
                                            param={{
                                                loading,
                                                // 表头配置
                                                columns: formColumns,
                                                x: formTotalWidth, // 表格的宽度
                                                y: contentHeight - 360,
                                                height: contentHeight - 320 + 'px',
                                                data: formTableData, // 表格数据
                                                componentName: 'ComponentPermissionSettingsFormField',
                                            }}
                                            onChange={handleFormInputChange}
                                        />
                                    </div>
                                </Card>
                                <div style={{ background: '#fff' }} className="common-card-right-split-line"></div>
                            </div>
                        </Col>
                        <Col span={7} className="cps-tab-item">
                            <Card
                                size="small"
                                title={(
                                    <div className="common-card-title-vertical-line">
                                        <div></div>
                                        按钮权限设置
                                    </div>
                                )}
                            >
                                <div>
                                    <PublicTablePagination
                                        param={{
                                            loading,
                                            // 表头配置
                                            columns: buttonColumns,
                                            x: buttonTotalWidth, // 表格的宽度
                                            y: contentHeight - 360,
                                            height: contentHeight - 320 + 'px',
                                            data: buttonTableData, // 表格数据
                                            componentName: 'ComponentPermissionSettingsButton',
                                        }}
                                        onChange={handleButtonInputChange}
                                    />
                                </div>
                            </Card>
                        </Col>
                    </Row>
                )
            }
        })
    };

    return (
        <Modal
            width="90vw"
            // title="组件权限设置"
            className="component-permission-settings"
            okText="保存设置"
            open={visible}
            onOk={handleSave}
            onCancel={handleCancel}
        >
            <Tabs
                items={renderItems()}
                activeKey={activeKey}
                onChange={handleTabChange}
            />
        </Modal>
    )
};

export default forwardRef(ComponentPermissionSettings);