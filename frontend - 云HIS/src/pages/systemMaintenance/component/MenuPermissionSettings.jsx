/*
 * Create:      柿子
 * CreateDate:  2024/05/20
 * Describe：   菜单权限设置
 * */
import React, { useState, useEffect, useRef } from 'react';
import { Card, Row, Col, message, Input, Divider } from 'antd';
import { DeleteOutlined, PlusOutlined, VerticalAlignTopOutlined, VerticalAlignBottomOutlined, HourglassOutlined } from '@ant-design/icons';
import { Util } from '@tools';
import request from '@api';
import store from '@store';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import RoleMenuAuthorizationHospital from './RoleMenuAuthorizationHospital';
import ComponentPermissionSettings from './ComponentPermissionSettings';

const { Search } = Input;

const MenuPermissionSettings = (props) => {
    let roleMenuAuthRef = useRef(null);
    let componentSettingsRef = useRef(null);
    const propsRowData = props?.rowData || '';
    const propsSelectData = props?.selectData || '';
    const userData = React.$getUserData();
    const { documentHeight } = store.getState();
    const [loading, setLoading] = useState(false);
    const [tableData, setTableData] = useState([]);
    const [copyTableData, setCopyTableData] = useState([]);
    const [rowID, setRowID] = useState('');
    const [selectedRowKeys, setSelectedRowKeys] = useState([]);
    const [selectedRows, setSelectedRows] = useState([]);
    const [filterVal, setFilterVal] = useState(undefined);
    const columns = [{
        key: '1',
        title: '菜单名称',
        dataIndex: 'descripts',
        width: 100,
    }, {
        key: '2',
        title: '菜单组',
        dataIndex: 'menuGroup',
        width: 80,
    }];
    // 明细列表数据
    const [detailColumns, setDetailColumns] = useState([]);
    const [detailTotalWidth, setDetailTotalWidth] = useState(0);
    const [detailLoading, setDetailLoading] = useState(false);
    const [detailTableData, setDetailTableData] = useState([]);
    const [detailRowID, setDetailRowID] = useState('');
    const [detailFilterVal, setDetailFilterVal] = useState(undefined);
    const [detailSelectedRowKeys, setDetailSelectedRowKeys] = useState([]);
    const [detailSelectedRows, setDetailSelectedRows] = useState([]);

    useEffect(() => {
        getDetailColumnsData();
    }, []);

    useEffect(() => {
        if (propsRowData && JSON.stringify(propsRowData) !== '{}') {
            getTableData();
            getDetailTableData();
        };
    }, [propsRowData]);

    const handleFilterValChange = e => {
        let nFilterVal = e.target.value;
        if (!nFilterVal) {
            setTableData(copyTableData);
        }
        setFilterVal(nFilterVal);
    };

    // 获取主菜单下拉
    const getTableData = async () => {
        try {
            const { id } = propsRowData;
            if (!id) return;
            let data = { //获取角色菜单明细授权所用到的信息
                params: [{
                    groupID: id,
                    type: '2',
                }],
            }
            const res = await React.$asyncPost('01010034', data);
            let menuDetail = Util.addKeyValueToDataSource(res?.result?.menuDetail || [], 'id');
            setTableData([...menuDetail]);
            setCopyTableData([...menuDetail]);
            handleClear();
        } catch (error) {
            console.log(error);
        }
    };

    const handleFilterTableData = () => {
        const nTableData = copyTableData && copyTableData.filter(item => item?.descripts.indexOf(filterVal) > -1);
        setTableData(nTableData);
        handleClear();
    };

    // 操作行
    const handleRowClick = (record) => {
        const { idIndex = 'id' } = props;
        let nSelectedRowKeys = [...selectedRowKeys];
        let nSelectedRows = [...selectedRows];
        return {
            // 单击行选中
            onClick: () => {
                let findFlag = false;
                let start = 0;
                let nRowID = '';
                if (nSelectedRowKeys) {
                    nSelectedRowKeys.find(function (value, key) {
                        if (value === record[idIndex]) {
                            findFlag = true;
                            start = key;
                        }
                    })
                }
                if (findFlag) {
                    //再次点击移除选中
                    nSelectedRowKeys.splice(start, 1);
                    nSelectedRows.splice(start, 1);
                } else {
                    //将点击的行添加到选中
                    nRowID = record[idIndex];
                    nSelectedRowKeys.push(record[idIndex]);
                    nSelectedRows.push(record);
                }
                setRowID(nRowID);
                setSelectedRowKeys(nSelectedRowKeys);
                setSelectedRows(nSelectedRows);
            },
        }
    };

    const handleClear = () => {
        setRowID('');
        setSelectedRowKeys([]);
        setSelectedRows([]);
    };

    // 选中行操作
    const setRowClassName = (record) => {
        return record.id === rowID ? 'common-table-select-bg' : '';
    };

    // 添加
    const handleAdd = async () => {
        try {
            const { id } = propsRowData;
            if (!id) return;
            if (selectedRows.length > 0) {
                if (detailSelectedRowKeys.length <= 1) { // 已选菜单只能加一个
                    let preMenuGroupID = detailSelectedRows[0]?.ID || detailSelectedRows[0]?.id || ''; // 需添加到的位置
                    let menuDetail = selectedRows.map(item => {
                        return {
                            menuDetailID: item.id,
                            preMenuGroupID: preMenuGroupID,
                            userID: userData?.userID || ''
                        };
                    })
                    let data = {
                        params: [{
                            type: '2',
                            groupID: id,
                            preMenuGroupID: preMenuGroupID,
                            menuDetail,
                        }]
                    }
                    const res = await React.$asyncPost('01010037', data);
                    message.success(res?.errorMessage || '新增成功');
                    getTableData();
                    getDetailTableData();
                } else {
                    message.warning('已选菜单只能选择一个');
                }
            } else {
                message.warning('请勾选后再点击增加');
            }
        } catch (error) {
            console.log(error);
        }
    };

    // 设置
    const handleAuthSetUp = (record, index, currentItem, e) => {
        React.$stopPropagation(e);
        if (currentItem?.dataIndex === 'authHosp') { // 医院授权
            roleMenuAuthRef && roleMenuAuthRef.current && roleMenuAuthRef.current.modifyVisible(true, {
                tableData: propsSelectData?.hospital || [],
                selectedRowKeys: record?.groupMenuAuthArr || [],
                groupMenuID: record?.groupMenuID || record?.id || '',
            });
        } else { // 组件权限设置
            const { id } = propsRowData;
            componentSettingsRef && componentSettingsRef.current && componentSettingsRef.current.modifyVisible(true, { ...record, groupID: id });
        }
    };

    const getDetailColumnsData = async () => {
        try {
            const res = await request.getComponentInfo('MenuPermissionSettings');
            let nDetailColumns = res.result?.C || [];
            for (let i = 0; i < nDetailColumns.length; i++) {
                let currentItem = nDetailColumns[i];
                if (currentItem?.dataIndex === 'authHosp' || currentItem?.dataIndex === 'componentAuth') { // 授权医院设置
                    nDetailColumns[i].render = (text, record, index) => {
                        if (record?.menuGroup !== '是') {
                            return (
                                <span className="common-record-span" onClick={(e) => handleAuthSetUp(record, index, currentItem, e)}>
                                    设置
                                </span>
                            )
                        }
                    }
                }
            };
            setDetailColumns(nDetailColumns);
            setDetailTotalWidth(res?.totalWidth || 0);
        } catch (error) {
            console.log(error);
        };
    };

    const mapDataToKey = arr => {
        return arr && arr.map(item => {
            if (item.children && item.children.length > 0) {
                mapDataToKey(item.children)
            }
            let renderFlag = item && 'children' in item ? 'N' : ''; // 父节点不渲染操作框
            return { ...item, key: item.id, renderFlag }
        })
    };

    const handleDetailFilterValChange = (e) => {
        let nFilterVal = e.target.value;
        if (!nFilterVal) {
            getDetailTableData(nFilterVal, 'Y');
        }
        setDetailFilterVal(nFilterVal);
    };

    // 获取授权菜单数据
    const getDetailTableData = async (pFilterVal, isPropsFilterVal) => {
        try {
            const { id } = propsRowData;
            if (!id) return;
            let data = { //获取角色菜单明细授权所用到的信息
                params: [{
                    groupID: id,
                    type: '2',
                    descripts: isPropsFilterVal === 'Y' ? pFilterVal : detailFilterVal,
                }]
            }
            const res = await React.$asyncPost('01010033', data);
            setDetailTableData(mapDataToKey(React.$processingTableRequestData(res, '', 0)));
            setDetailSelectedRowKeys([]);
            setDetailSelectedRows([]);
            setDetailRowID('');
        } catch (error) {
            console.log(error);
        }
    };

    // 操作行
    const handleDetailRowClick = (record) => {
        const { idIndex = 'key' } = props;
        let nDetailSelectedRowKeys = [...detailSelectedRowKeys];
        let nDetailSelectedRows = [...detailSelectedRows];
        return {
            // 单击行选中
            onClick: () => {
                let findFlag = false;
                let start = 0;
                let nRowID = '';
                if (nDetailSelectedRowKeys) {
                    nDetailSelectedRowKeys.find(function (value, key) {
                        if (value === record[idIndex]) {
                            findFlag = true;
                            start = key;
                        }
                    })
                }
                if (findFlag) {
                    //再次点击移除选中
                    nDetailSelectedRowKeys.splice(start, 1);
                    nDetailSelectedRows.splice(start, 1);
                } else {
                    //将点击的行添加到选中
                    nRowID = record[idIndex];
                    nDetailSelectedRowKeys.push(record[idIndex]);
                    nDetailSelectedRows.push(record);
                }
                setDetailRowID(nRowID);
                setDetailSelectedRowKeys(nDetailSelectedRowKeys);
                setDetailSelectedRows(nDetailSelectedRows);
            },
        }
    };

    // 选中行操作
    const setDetailRowClassName = (record) => {
        return record.key === detailRowID ? 'common-table-select-bg' : '';
    };

    //上移
    const handleMoveUp = (arr, index) => {
        if (index === 0) {
            message.warning('已经到顶啦');
        } else {
            arr[index] = arr.splice(index - 1, 1, arr[index])[0];
        };
        return arr;
    }

    //下移
    const handleMoveDown = (arr, index) => {
        if (index === arr.length - 1) {
            message.warning('已经到底啦');
        } else {
            arr[index] = arr.splice(index + 1, 1, arr[index])[0];
        };
        return arr;
    }

    const handleMove = status => {
        const _mapData = (arr) => {
            for (let index = 0, len = arr.length; index < len; index++) {
                const item = arr[index];
                if (detailSelectedRowKeys.some(ele => ele === item.key)) {
                    if (status === 'up') {
                        arr = handleMoveUp(arr, index);
                    } else if (status === 'down') {
                        arr = handleMoveDown(arr, index);
                        index += 1;
                    }
                }
                if (item.children && item.children.length > 0) {
                    _mapData(item.children);
                }
            };
        };
        _mapData(detailTableData);
        setDetailTableData([...detailTableData]);
    }

    // 删除
    const handleDelete = async () => {
        try {
            let IDs = detailSelectedRows && detailSelectedRows.map(item => item?.ID || item?.id || '');
            if (!(IDs && Array.isArray(IDs) && IDs.length > 0)) {
                message.warning('请勾选需要删除的数据');
                return;
            }
            let data = {
                params: [{
                    IDs,
                    userID: userData?.userID || '',
                }]
            }
            const res = await React.$asyncPost('01010035', data);
            message.success(res?.errorMessage || '删除成功');
            getTableData();
            getDetailTableData();
        } catch (error) {
            console.log(error);
        };
    };

    // 保存
    const handleDetailSave = async () => {
        try {
            let data = {
                params: [{
                    data: detailTableData
                }]
            }
            const res = await React.$asyncPost('01010036', data);
            message.success(res?.errorMessage || '保存成功');
            getDetailTableData();
        } catch (error) {
            console.log(error);
        };
    };

    // 修改table行数据
    const handleTableInputChange = (val, index, dataIndex, record) => {
        setDetailTableData(oldData => {
            let newData = JSON.parse(JSON.stringify(oldData)); // 创建数组副本
            const recursiveUpdate = (arr) => {
                arr.forEach((item) => {
                    if (item.id === record.id) {
                        item[dataIndex] = val;
                    }
                    if (item.children) {
                        recursiveUpdate(item.children);
                    }
                });
            };
            recursiveUpdate(newData); // 在新副本上进行修改
            return newData;  // 返回新数组以更新状态
        });
    };

    return (
        <div>
            <Row style={{ paddingTop: '10px' }}>
                <Col span={8} style={{ paddingRight: '12px' }}>
                    <Card size="small">
                        <div style={{ marginBottom: '6px' }}>
                            <Search
                                style={{ width: '60%' }}
                                placeholder="关键字检索"
                                enterButton
                                value={filterVal}
                                onChange={handleFilterValChange}
                                onSearch={handleFilterTableData}
                                onPressEnter={handleFilterTableData}
                            />
                            <span
                                style={{ float: 'right', marginTop: '6px' }}
                                className={[!(selectedRowKeys && selectedRowKeys.length > 0) ? 'common-no-drop' : 'common-pointer', 'flex-align-items'].join(' ')}
                                onClick={handleAdd}
                            >
                                <PlusOutlined className={selectedRowKeys && selectedRowKeys.length > 0 ? 'common-record-span' : 'common-no-drop'} />
                                批量添加
                            </span>
                        </div>
                        <PublicTablePagination
                            param={{
                                loading,
                                columns,
                                x: 180, // 表格的宽度
                                y: documentHeight - 226,
                                height: documentHeight - 186 + 'px',
                                data: tableData, // 表格数据
                            }}
                            rowSelection={{
                                selectedRowKeys,
                                onChange: (selectedRowKeys, selectedRows) => {
                                    setSelectedRowKeys(selectedRowKeys);
                                    setSelectedRows(selectedRows);
                                },
                            }}
                            onRow={handleRowClick}
                            rowClassName={setRowClassName}
                        />
                    </Card>
                </Col>
                <Col span={16}>
                    <Card size="small">
                        <Row style={{ marginBottom: '6px' }}>
                            <Col span={14} className="flex-align-items">
                                <span
                                    className={[!(detailSelectedRowKeys && detailSelectedRowKeys.length > 0) ? 'common-no-drop' : 'common-pointer', 'flex-align-items'].join(' ')}
                                    onClick={() => handleMove('up')}
                                >
                                    <VerticalAlignTopOutlined className={detailSelectedRowKeys && detailSelectedRowKeys.length > 0 ? 'common-record-span' : 'common-no-drop'} />
                                    上移
                                </span>
                                <Divider type="vertical" />
                                <span
                                    className={[!(detailSelectedRowKeys && detailSelectedRowKeys.length > 0) ? 'common-no-drop' : 'common-pointer', 'flex-align-items'].join(' ')}
                                    onClick={() => handleMove('down')}
                                >
                                    <VerticalAlignBottomOutlined className={detailSelectedRowKeys && detailSelectedRowKeys.length > 0 ? 'common-record-span' : 'common-no-drop'} />
                                    下移
                                </span>
                                <Divider type="vertical" />
                                <span
                                    className={[!(detailSelectedRowKeys && detailSelectedRowKeys.length > 0) ? 'common-no-drop' : 'common-pointer', 'flex-align-items'].join(' ')}
                                    onClick={handleDelete}
                                >
                                    <DeleteOutlined className={detailSelectedRowKeys && detailSelectedRowKeys.length > 0 ? 'common-record-delete-span' : 'common-no-drop'} />
                                    删除
                                </span>
                                <Divider type="vertical" />
                                <span
                                    className={[props.saveFlag === 'N' ? 'common-no-drop' : 'common-pointer', 'flex-align-items'].join(' ')}
                                    onClick={handleDetailSave}
                                >
                                    <HourglassOutlined className={props.saveFlag !== 'N' ? 'common-record-span' : 'common-no-drop'} />
                                    保存
                                </span>
                            </Col>
                            <Col span={10}>
                                <Search
                                    style={{ width: '100%' }}
                                    placeholder="关键字检索"
                                    enterButton
                                    value={detailFilterVal}
                                    onChange={handleDetailFilterValChange}
                                    onPressEnter={getDetailTableData}
                                    onSearch={getDetailTableData}
                                />
                            </Col>
                        </Row>
                        <PublicTablePagination
                            param={{
                                loading: detailLoading,
                                componentName: 'MenuPermissionSettings',
                                columns: detailColumns,
                                x: detailTotalWidth, // 表格的宽度
                                y: documentHeight - 226,
                                height: documentHeight - 186 + 'px',
                                data: detailTableData, // 表格数据
                                selectData: propsSelectData
                            }}
                            rowSelection={{
                                selectedRowKeys: detailSelectedRowKeys,
                                onChange: (selectedRowKeys, selectedRows) => {
                                    setDetailSelectedRowKeys(selectedRowKeys);
                                    setDetailSelectedRows(selectedRows);
                                },
                            }}
                            getColumns={getDetailColumnsData}
                            onRow={handleDetailRowClick}
                            rowClassName={setDetailRowClassName}
                            onChange={handleTableInputChange}
                        />
                    </Card>
                </Col>
            </Row>

            {/* 角色菜单授权医院 */}
            <RoleMenuAuthorizationHospital ref={roleMenuAuthRef} handleQuery={getDetailTableData} />

            {/* 组件列、表单及按钮权限控制 */}
            <ComponentPermissionSettings ref={componentSettingsRef} />
        </div>
    );
};

export default MenuPermissionSettings;