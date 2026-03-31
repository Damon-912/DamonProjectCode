/*
 * Create:      柿子
 * CreateDate:  2023/05/30
 * Describe：   单表增删改查界面参数配置
 * */
import React, { useState, useRef, forwardRef, useCallback, useImperativeHandle, useEffect } from 'react';
import { Drawer, Steps, Row, Col, Button, Divider, Empty, Popconfirm, Menu, message } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined, ProductOutlined, EllipsisOutlined, OpenAIOutlined } from '@ant-design/icons';
import { fieldFormData, colFormData } from '@pages/systemMaintenance/js/staticData.js';
import { Util } from '@tools';
import { DndContext, PointerSensor, useSensor, useSensors } from '@dnd-kit/core';
import { restrictToVerticalAxis } from '@dnd-kit/modifiers';
import {
    arrayMove,
    SortableContext,
    useSortable,
    verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import request from '@api';
import store from '@store';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import FieldSelectionModal from '@pages/systemMaintenance/component/FieldSelectionModal';
import SingleTableOperation from '../SingleTableOperation';
import '../style/children.less';

const SingleTableParamsConfig = (props, ref) => {
    let formRef = useRef(null);
    let layoutFormRef = useRef(null);
    let fieldSelectRef = useRef(null);
    const { documentHeight } = store.getState();
    const [visible, setVisible] = useState(false);
    const [rowData, setRowData] = useState({});
    const [current, setCurrent] = useState(0);
    const [maxCurrent, setMaxCurrent] = useState(0);
    const [formData, setFormData] = useState([]);
    const [categoryData, setCategoryData] = useState({});
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
    const [loading, setLoading] = useState(false);
    const [columns, setColumns] = useState([]);
    const [totalWidth, setTotalWidth] = useState(0);
    const [tableData, setTableData] = useState([]);
    const [rowID, setRowID] = useState('');
    const [layoutRowData, setLayoutRowData] = useState({});
    const [layoutAddType, setLayoutAddType] = useState('queryFormData');
    const [layoutFormData, setLayoutFormData] = useState(fieldFormData);
    const [queryFormData, setQueryFormData] = useState([]);
    const [queryFormMode, setQueryFormMode] = useState('list');
    const [modalFormData, setModalFormData] = useState([]);
    const [modalFormMode, setModalFormMode] = useState('list');
    const [okLoading, setOkLoading] = useState(false);

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible,
    }));

    // 修改弹窗状态
    const modifyVisible = (visible, nRowData = {}) => {
        if (visible) {
            if (!(formData && Array.isArray(formData) && formData.length > 0)) {
                getModifyFormData();
            }
            if (nRowData?.code !== rowData?.code) { // 切换设置不同界面
                setRowID('');
                setCurrent(0);
                setQueryFormMode('list');
                setModalFormMode('list');
                setModalFormData([]);
                setColumns([]);
                setTotalWidth(0);
                setQueryFormData([]);
                setLayoutRowData({});
                if (nRowData && 'code' in nRowData && nRowData.code) {
                    getMenuColumnsData(nRowData);
                }
            }
            setRowData(nRowData);
        };
        setVisible(visible);
    };

    // 根据菜单代码获取组件数据
    const getMenuColumnsData = async (nRowData) => {
        try {
            let data = {
                params: [{
                    menuDetailCode: nRowData?.code || '',
                }]
            };
            const res = await React.$asyncPost('01010061', data);
            let columnsArr = React.$processingTableRequestData(res);
            if (columnsArr && Array.isArray(columnsArr) && columnsArr.length > 0) {
                for (let i = 0; i < columnsArr.length; i++) {
                    if (columnsArr[i]?.dataIndex === 'componentName') { // 主列表数据
                        getColumnsData(columnsArr[i]);
                    } else if (columnsArr[i]?.dataIndex === 'modalComponentName') { // 弹窗组件信息
                        getModalFormData(columnsArr[i]);
                    }
                }
            }
        } catch (error) {
            console.log(error);
        };
    };

    // 获取表格列数据及查询条件
    const getColumnsData = (res) => {
        let nColumns = (res?.tableData || []).map(item => {
            return {
                ...item,
                ...getColumnSearchProps(item)
            }
        });
        setColumns(nColumns);
        setTotalWidth(res?.totalWidth || 0);
        setQueryFormData(Util.addKeyValueToDataSource(res?.formData || []));
    };

    // 获取弹窗表单数据
    const getModalFormData = (res) => {
        setModalFormData(Util.addKeyValueToDataSource(res?.formData || []));
    };

    // 获取列表表头数据
    const getModifyFormData = async () => {
        try {
            const res = await request.getComponentInfo('SingleTableParamsConfig');
            setFormData(res?.result?.formData || []);
        } catch (error) {
            console.log(error);
        };
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
                formRef && formRef.current && formRef.current.handleSave('Y')
                    .then(result => {
                        if (!(result.error)) {
                            setCategoryData({ ...result });
                            setCurrent(oldCurrent => {
                                const nextCurrent = oldCurrent + 1;
                                setMaxCurrent(oldMaxCurrent => {
                                    return oldMaxCurrent < nextCurrent ? nextCurrent : oldMaxCurrent
                                });
                                return nextCurrent;
                            });
                        }
                    })
            } else {
                setCurrent(oldCurrent => {
                    if (oldCurrent === 0) {
                        if (!(columns && Array.isArray(columns) && columns.length > 0)) {
                            message.warning('不维护表格列数据的话界面渲染出来是空的哦，先去维护几个吧！');
                            handleLayoutTypeChange('colFormData');
                            return oldCurrent;
                        }
                    };
                    const nextCurrent = oldCurrent + 1;
                    setMaxCurrent(oldMaxCurrent => {
                        return oldMaxCurrent < nextCurrent ? nextCurrent : oldMaxCurrent
                    });
                    return nextCurrent;
                });
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

    // 操作行
    const handleRowClick = (record) => {
        return {
            // 单击行选中
            onClick: () => {
                if (rowID === '' || (rowID && rowID !== record.key)) {
                    setRowID(record.key);
                } else {
                    setRowID('');
                }
            }
        }
    };

    // 选中行操作
    const setRowClassName = (record) => {
        return record.key === rowID ? 'common-table-select-bg' : '';
    };

    // 切换添加类型
    const handleLayoutTypeChange = (type) => {
        if (type !== layoutAddType) {
            const nLayoutFormData = type === 'colFormData' ? colFormData : fieldFormData;
            setLayoutFormData([...nLayoutFormData]);
            modifyActiveFlag({});
            setLayoutAddType(type);
            handleLayoutReset();
        }
    };

    // 添加页面字段
    const handleLayoutAdd = (type) => {
        if (type !== 'colFormData') {
            fieldSelectRef && fieldSelectRef.current && fieldSelectRef.current.modifyVisible(true);
        }
    };

    // 编辑页面字段
    const handleLayoutCompile = (record, e) => {
        React.$stopPropagation(e)
        setLayoutRowData(record);
        setLayoutAddType(oldType => { // 如果在其他模块直接修改列数据的情况需单独处理
            if (oldType !== 'colFormData') {
                setLayoutFormData([...colFormData]);
                modifyActiveFlag({});
                return 'colFormData';
            }
            return oldType;
        })
    };

    // 删除页面字段
    const handleLayoutDelete = (record, e) => {
        React.$stopPropagation(e)
        setColumns(oldColumns => {
            return oldColumns && oldColumns.filter(item => (item?.dataIndex || item?.code || '') !== (record?.dataIndex || record?.code || ''));
        })
    };

    // 表格列维护表头添加列操作
    const getColumnSearchProps = (record) => ({
        filterDropdown: ({ close }) => (
            <div
                onKeyDown={(e) => React.$stopPropagation(e)}
            >
                <Menu
                    items={[{
                        key: '1',
                        label: (
                            <span
                                style={{ minWidth: '100px' }}
                                className="flex-align-items"
                                onClick={(e) => {
                                    handleLayoutCompile(record, e);
                                    close();
                                }}
                            >
                                <EditOutlined style={{ marginRight: '6px' }} className="common-record-span" />
                                编辑
                            </span>
                        )
                    }, {
                        key: '2',
                        label: (
                            <Popconfirm
                                title="删除后不可恢复，确定要删除吗?"
                                onClick={e => React.$stopPropagation(e)}
                                onConfirm={(e) => {
                                    handleLayoutDelete(record, e);
                                    close();
                                }}
                            >
                                <span style={{ minWidth: '100px' }} className="flex-align-items">
                                    <DeleteOutlined style={{ marginRight: '6px' }} className="common-record-delete-span" />
                                    删除
                                </span>
                            </Popconfirm>
                        )
                    }]}
                />
            </div>
        ),
        filterIcon: (filtered) => (
            <EllipsisOutlined
                style={{
                    fontSize: '20px',
                    color: filtered ? '#1677ff' : undefined,
                }}
            />
        ),
    });

    // 保存
    const handleLayoutSave = () => {
        layoutFormRef && layoutFormRef.current && layoutFormRef.current.handleSave('Y')
            .then(result => {
                if (!(result?.error)) {
                    if (layoutAddType === 'colFormData') {
                        result.dataIndex = result?.code || '';
                        result.title = result?.descripts || '';
                        setColumns(oldColumns => {
                            if (layoutRowData && 'id' in layoutRowData && layoutRowData.id) {
                                oldColumns = oldColumns.map(item => {
                                    // 如果 item 代码与 layoutRowData 的代码一致，则更新该项
                                    return item?.code === layoutRowData.code
                                        ? { ...item, ...result }
                                        : item;
                                });
                                handleLayoutReset();
                                message.success('数据修改成功');
                                return [...oldColumns];
                            }
                            // 新增
                            let addFlag = Util.returnDataCccordingToAttributes(oldColumns, result?.code || '', 'code')?.key || '';
                            if (addFlag) {
                                message.error('代码不能重复，请核对后再添加！');
                                return [...oldColumns];
                            }
                            const nColumnItem = {
                                ...result,
                                id: Util.uuid()
                            };
                            handleLayoutReset();
                            message.success('添加成功');
                            return [
                                ...oldColumns,
                                { ...nColumnItem, ...getColumnSearchProps(nColumnItem) }
                            ];
                        });
                    } else if (layoutAddType === 'queryFormData') {
                        setQueryFormData(oldFormData => {
                            return oldFormData.map(item => {
                                // 如果 item 代码与 layoutRowData 的代码一致，则更新该项
                                return item?.id === layoutRowData?.id
                                    ? { ...item, ...result }
                                    : item;
                            });
                        });
                        handleLayoutReset();
                        modifyActiveFlag();
                        message.success('数据修改成功');
                    } else {
                        setModalFormData(oldFormData => {
                            return oldFormData.map(item => {
                                // 如果 item 代码与 layoutRowData 的代码一致，则更新该项
                                return item?.id === layoutRowData.id
                                    ? { ...item, ...result }
                                    : item;
                            });
                        });
                        handleLayoutReset();
                        modifyActiveFlag();
                        message.success('数据修改成功');
                    }
                }
            })
    };

    // 重置
    const handleLayoutReset = () => {
        if (layoutRowData && 'id' in layoutRowData && layoutRowData.id) {
            setLayoutRowData({});
        };
        modifyActiveFlag({});
        layoutFormRef && layoutFormRef.current && layoutFormRef.current.resetFields();
    };

    useEffect(() => {
        columns && Array.isArray(columns) && columns.length > 0 && getTableData();
    }, [columns])

    // 获取列表数据
    const getTableData = () => {
        let nTableData = [];
        for (let i = 0; i < 3; i++) {
            let recordData = {
                key: String(i + 1)
            };
            let currentKey = i;
            for (let j = 0; j < columns.length; j++) {
                let dataIndex = columns[j]?.code || columns[j]?.dataIndex || '';
                let title = columns[j]?.descripts || columns[j]?.title || '';
                recordData[dataIndex] = title + (currentKey + 1);
            }
            nTableData.push(recordData);
        }
        setTableData(nTableData);
    };

    // 选择保存
    const handleModalSelectSave = values => {
        values.required = 'N';
        values.disabled = 'N';
        values.display = 'Y';
        if (layoutAddType === 'queryFormData') { // 查询条件
            setQueryFormData(oldData => {
                return Util.addKeyValueToDataSource([...oldData, { ...values, id: Util.uuid() }])
            });
        } else { // 新增/修改表单数据
            setModalFormData(oldData => {
                return Util.addKeyValueToDataSource([...oldData, { ...values, id: Util.uuid() }])
            });
        };
        fieldSelectRef && fieldSelectRef.current && fieldSelectRef.current.modifyVisible(false);
    };

    const handleDragEnd = ({ active, over }, type) => {
        if (active.id !== over?.id) {
            if (type === 'queryFormData') { // 查询条件
                setQueryFormData((prev) => {
                    const activeIndex = prev.findIndex((i) => i.key === active.id);
                    const overIndex = prev.findIndex((i) => i.key === over?.id);
                    return arrayMove(prev, activeIndex, overIndex);
                });
            } else { // 新增/编辑表单元素
                setModalFormData((prev) => {
                    const activeIndex = prev.findIndex((i) => i.key === active.id);
                    const overIndex = prev.findIndex((i) => i.key === over?.id);
                    return arrayMove(prev, activeIndex, overIndex);
                });
            }
        }
    };

    const SortableItem = ({ item, index, layoutType }) => {
        const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({
            id: (item?.key || ''),
        });
        const style = {
            transform: transform ? `translate3d(${transform.x}px, ${transform.y}px, 0)` : undefined,
            transition,
            ...(isDragging
                ? {
                    position: 'relative',
                    zIndex: 9999,
                    background: 'rgba(42, 46, 54, 0.06)',
                    padding: '6px 10px',
                    borderRadius: '6px'
                }
                : {}),
        };
        return (
            <Col
                key={index}
                className={`stpc-field-item ${item?.activeFlag === 'Y' ? 'stpc-field-item-active' : ''}`}
                // span={parseInt(item?.col || 24)}
                span={24}
                onClick={(e) => handleFormItemClick(item, e, layoutType)}
            >
                <div id={item?.key || ''} ref={setNodeRef} style={style} {...attributes} {...listeners}>
                    <span style={{ display: 'inline-block', width: '20%' }}>
                        {item?.title || item?.descripts || ''}
                        <span className={item?.required === 'Y' ? 'common-custom-required-style' : ''}></span>
                    </span>
                    <span style={{ display: 'inline-block', width: '18%' }}>
                        <span className="common-note">字段标识：</span>
                        {item?.code || item?.dataIndex || ''}
                    </span>
                    <span style={{ display: 'inline-block', width: '18%' }}>
                        <span className="common-note">字段类型：</span>
                        {item?.fieldTypeDesc || '输入框'}
                    </span>
                    <span style={{ display: 'inline-block', width: '12%' }}>
                        <span className="common-note">是否必填：</span>
                        {item?.required === 'Y' ? '是' : '否'}
                    </span>
                    <span style={{ display: 'inline-block', width: '12%' }}>
                        <span className="common-note">是否只读：</span>
                        {item?.disabled === 'Y' ? '是' : '否'}
                    </span>
                    <span style={{ display: 'inline-block', width: '12%' }}>
                        <span className="common-note">是否显示：</span>
                        {item?.display === 'Y' ? '是' : '否'}
                    </span>
                </div>
            </Col>
        )
    };

    const sensors = useSensors(
        useSensor(PointerSensor, {
            activationConstraint: {
                distance: 1,
            },
        }),
    );

    // 表单字段修改
    const handleFormItemClick = useCallback((record, e, layoutType) => {
        React.$stopPropagation(e);
        if (layoutType !== layoutAddType) {
            const nLayoutFormData = layoutType === 'colFormData' ? colFormData : fieldFormData;
            setLayoutFormData([...nLayoutFormData]);
            setLayoutAddType(layoutType);
            handleLayoutReset();
        }
        setLayoutRowData({ ...record });
        modifyActiveFlag(record, layoutType);
    });

    // 修改选中状态
    const modifyActiveFlag = (record, layoutType) => {
        let type = layoutType || layoutAddType;
        if (type === 'queryFormData') { // 修改查询条件选中状态
            setQueryFormData(oldData => {
                return oldData && oldData.map(item => {
                    return { ...item, activeFlag: item?.id === record?.id ? 'Y' : 'N' }
                })
            })
            setModalFormData(oldData => {
                return oldData && oldData.map(item => {
                    return { ...item, activeFlag: 'N' }
                })
            })
        } else if (type === 'modalFormData') { // 修改新增/编辑表单选中状态
            setQueryFormData(oldData => {
                return oldData && oldData.map(item => {
                    return { ...item, activeFlag: 'N' }
                })
            })
            setModalFormData(oldData => {
                return oldData && oldData.map(item => {
                    return { ...item, activeFlag: item?.id === record?.id ? 'Y' : 'N' }
                })
            })
        } else {
            setQueryFormData(oldData => {
                return oldData && oldData.map(item => {
                    return { ...item, activeFlag: 'N' }
                })
            })
            setModalFormData(oldData => {
                return oldData && oldData.map(item => {
                    return { ...item, activeFlag: 'N' }
                })
            })
        }
    };

    // 显示模式切换
    const handleModalFormModeChange = (type) => {
        if (type === 'queryFormData') {
            setQueryFormMode(oldMode => {
                return oldMode === 'form' ? 'list' : 'form';
            })
        } else {
            setModalFormMode(oldMode => {
                return oldMode === 'form' ? 'list' : 'form';
            })
        }
    };

    // 菜单参数组织
    const handleMenuParameterOrganization = (values) => {
        let paramsVal = ((values?.interfaceType || '') + '&') || 'params=';
        for (var keys in values) {
            let val = values[keys]
            if (values && val && keys !== 'interfaceType') { // 菜单类型自动拼接在最前面
                paramsVal += keys + ':' + val + '&'
            }
        }
        let endStr = paramsVal.slice(paramsVal.length - 1);
        if (endStr === '&') { // 截取最后一个&
            paramsVal = paramsVal.slice(0, paramsVal.length - 1)
        }
        return paramsVal;
    };

    // 组件数据保存
    const handleComponentDataSave = async () => {
        try {
            setOkLoading(true);
            const descripts = rowData?.descripts || rowData?.title || '';
            let componentName = 'STO' + Util.chineseToCamelCase(descripts);
            let modalComponentName = 'STO' + Util.chineseToCamelCase(descripts + '弹窗表单');
            const res = await React.$asyncPost('01010060', {
                params: [{
                    reactData: [{
                        code: componentName,
                        descripts,
                        tableData: Util.addKeyValueToDataSource(columns, '', 1, '', 'seqNo'),
                        formData: Util.addKeyValueToDataSource(queryFormData, '', 1, '', 'seqNo')
                    }, {
                        code: modalComponentName,
                        descripts: descripts + '新增/编辑表单',
                        formData: Util.addKeyValueToDataSource(modalFormData, '', 1, '', 'seqNo')
                    }]
                }]
            });
            let componentObj = res?.result || {};
            handleMenuParamsSave([{
                componentCode: componentName,
                componentDesc: descripts,
                componentID: componentObj && componentName in componentObj ? componentObj[componentName] : '',
                dataIndex: 'componentName',
            }, {
                componentCode: modalComponentName,
                componentID: componentObj && modalComponentName in componentObj ? componentObj[modalComponentName] : '',
                componentDesc: descripts + ' - 新增/编辑表单',
                dataIndex: 'modalComponentName',
            }]);
        } catch (error) {
            setOkLoading(false);
        }
    };

    // 保存菜单参数
    const handleMenuParamsSave = async (componentArr) => {
        try {
            let paras = handleMenuParameterOrganization(categoryData);
            const res = await React.$asyncPost('01040101', {
                params: [{
                    ...rowData,
                    paras,
                    componentArr
                }]
            });
            message.success(res?.errorMessage || '保存成功');
            setOkLoading(false);
            modifyVisible(false);
            getTableData();
        } catch (error) {
            console.log(error);
            setOkLoading(false);
        }
    };

    // 拖拽结束后更新数据
    const handleUpdateColumns = nColumns => {
        setColumns([...nColumns]);
    };

    // 表单内容删除
    const handleFormDelete = (dataIndex) => {
        if (dataIndex === 'queryFormData') {
            setQueryFormData(oldData => {
                return oldData.filter(item => item?.id !== layoutRowData?.id);
            });
        } else {
            setModalFormData(oldData => {
                return oldData.filter(item => item?.id !== layoutRowData?.id);
            });
        }
        setLayoutRowData({});
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
                <div style={{ height: documentHeight - 132 + 'px', overflow: 'auto' }}>
                    <div className="flex-justify-center stpc-steps">
                        <div style={{ width: '76%' }}>
                            <Steps
                                size="small"
                                current={current}
                                items={stepsItems}
                                onChange={handleStepsChange}
                            />
                        </div>
                    </div>
                    <Row style={{ display: current === 0 ? 'flex' : 'none' }}>
                        <Col span={18} className="stpc-body common-bottom-shadow">
                            <div>
                                {/* 查询条件维护 */}
                                <div
                                    className={`stpc-body-item ${layoutAddType === 'queryFormData' ? 'stpc-body-item-active' : ''}`}
                                    onClick={() => handleLayoutTypeChange('queryFormData')}
                                >
                                    <div style={{ marginBottom: '8px' }} className="flex-between-center">
                                        <div className="common-card-title-icon">
                                            <ProductOutlined />
                                            查询条件维护
                                        </div>
                                        <span style={{ float: 'right', cursor: 'pointer' }}>
                                            {queryFormData && queryFormData.length > 0 && (
                                                <>
                                                    <span onClick={() => handleModalFormModeChange('queryFormData')}>
                                                        <OpenAIOutlined style={{ marginRight: '4px' }} className="common-record-span" />
                                                        {queryFormMode === 'list' ? '效果预览' : '返回修改'}
                                                    </span>
                                                    <Divider type="vertical" />
                                                </>
                                            )}
                                            <span onClick={() => handleLayoutAdd('queryFormData')}>
                                                <PlusOutlined style={{ marginRight: '4px' }} className="common-record-span" />
                                                添加
                                            </span>
                                            {layoutAddType === 'queryFormData' && modalFormMode === 'list' && (
                                                <>
                                                    <Divider type="vertical" />
                                                    <Popconfirm
                                                        title="确定要删除吗?"
                                                        disabled={!!!(layoutRowData?.id)}
                                                        onConfirm={() => handleFormDelete('queryFormData')}
                                                    >
                                                        <span style={{ cursor: !!(layoutRowData?.id) ? 'pointer' : 'no-drop' }}>
                                                            <DeleteOutlined
                                                                style={{ marginRight: '4px' }}
                                                                className={!!(layoutRowData?.id) ? 'common-record-delete-span' : ''}
                                                            />
                                                            删除
                                                        </span>
                                                    </Popconfirm>
                                                </>
                                            )}
                                        </span>
                                    </div>
                                    <div className="stpc-field">
                                        {queryFormData && queryFormData.length > 0 ? (
                                            queryFormMode === 'list' ? (
                                                <Row>
                                                    <DndContext sensors={sensors} modifiers={[restrictToVerticalAxis]} onDragEnd={(e) => handleDragEnd(e, 'queryFormData')}>
                                                        <SortableContext
                                                            items={queryFormData.map((i) => (i?.key || ''))}
                                                            strategy={verticalListSortingStrategy}
                                                        >
                                                            {queryFormData.map((item, index) => <SortableItem key={index} item={item} index={index} layoutType="queryFormData" />)}
                                                        </SortableContext>
                                                    </DndContext>
                                                </Row>
                                            ) : (
                                                <DynamicRenderingForm
                                                    rowData={{}}
                                                    formData={queryFormData}
                                                />
                                            )
                                        ) : (
                                            <Empty description="您还未添加查询条件，请在右上角点击添加！" image={Empty.PRESENTED_IMAGE_SIMPLE} />
                                        )}
                                    </div>
                                </div>
                                {/* 表格列维护 */}
                                <div
                                    className={`stpc-body-item ${layoutAddType === 'colFormData' ? 'stpc-body-item-active' : ''}`}
                                    onClick={() => handleLayoutTypeChange('colFormData')}
                                >
                                    <div style={{ marginBottom: '8px' }} className="flex-between-center">
                                        <div className="common-card-title-icon">
                                            <ProductOutlined />
                                            表格列维护
                                        </div>
                                        {layoutAddType !== 'colFormData' ? (
                                            <span style={{ float: 'right', cursor: 'pointer' }} onClick={() => handleLayoutAdd('colFormData')}>
                                                <PlusOutlined style={{ marginRight: '4px' }} className="common-record-span" />
                                                添加
                                            </span>
                                        ) : (
                                            <span className="common-note">提醒：请在右侧录入保存</span>
                                        )}
                                    </div>
                                    {columns && columns.length > 0 ? (
                                        <PublicTablePagination
                                            param={{
                                                loading,
                                                // 表头配置
                                                columns,
                                                colDndFlag: 'Y', // 列拖拽标志
                                                x: totalWidth, // 表格的宽度
                                                data: tableData, // 表格数据
                                            }}
                                            onRow={handleRowClick}
                                            rowClassName={setRowClassName}
                                            onDragEnd={handleUpdateColumns}
                                        />
                                    ) : (
                                        <div>
                                            <Empty description="您还未添加表格列数据，请在右侧添加列数据！" image={Empty.PRESENTED_IMAGE_SIMPLE} />
                                        </div>
                                    )}
                                </div>
                                {/* 表单元素维护 */}
                                <div
                                    className={`stpc-body-item ${layoutAddType === 'modalFormData' ? 'stpc-body-item-active' : ''}`}
                                    style={{ marginBottom: '0px' }}
                                    onClick={() => handleLayoutTypeChange('modalFormData')}
                                >
                                    <div style={{ marginBottom: '8px' }} className="flex-between-center">
                                        <div className="common-card-title-icon">
                                            <ProductOutlined />
                                            表单元素维护
                                        </div>
                                        <span style={{ float: 'right', cursor: 'pointer' }}>
                                            {modalFormData && modalFormData.length > 0 && (
                                                <>
                                                    <span onClick={() => handleModalFormModeChange('modalFormData')}>
                                                        <OpenAIOutlined style={{ marginRight: '4px' }} className="common-record-span" />
                                                        {modalFormMode === 'list' ? '效果预览' : '返回修改'}
                                                    </span>
                                                    <Divider type="vertical" />
                                                </>
                                            )}
                                            <span onClick={() => handleLayoutAdd('modalFormData')}>
                                                <PlusOutlined style={{ marginRight: '4px' }} className="common-record-span" />
                                                添加
                                            </span>
                                            {layoutAddType === 'modalFormData' && modalFormMode === 'list' && (
                                                <>
                                                    <Divider type="vertical" />
                                                    <Popconfirm
                                                        title="确定要删除吗?"
                                                        disabled={!!!(layoutRowData?.id)}
                                                        onConfirm={() => handleFormDelete('modalFormData')}
                                                    >
                                                        <span style={{ cursor: !!(layoutRowData?.id) ? 'pointer' : 'no-drop' }}>
                                                            <DeleteOutlined
                                                                style={{ marginRight: '4px' }}
                                                                className={!!(layoutRowData?.id) ? 'common-record-delete-span' : ''}
                                                            />
                                                            删除
                                                        </span>
                                                    </Popconfirm>
                                                </>
                                            )}
                                        </span>
                                    </div>
                                    <div className="stpc-field">
                                        {modalFormData && modalFormData.length > 0 ? (
                                            modalFormMode === 'list' ? (
                                                <Row>
                                                    <DndContext sensors={sensors} modifiers={[restrictToVerticalAxis]} onDragEnd={(e) => handleDragEnd(e, 'modalFormData')}>
                                                        <SortableContext
                                                            items={modalFormData.map((i) => (i?.key || ''))}
                                                            strategy={verticalListSortingStrategy}
                                                        >
                                                            {modalFormData.map((item, index) => <SortableItem key={index} item={item} index={index} layoutType="modalFormData" />)}
                                                        </SortableContext>
                                                    </DndContext>
                                                </Row>
                                            ) : (
                                                <DynamicRenderingForm
                                                    rowData={{}}
                                                    formData={modalFormData}
                                                />
                                            )
                                        ) : (
                                            <Empty description="您还未添加表单元素，请在右上角点击添加！" image={Empty.PRESENTED_IMAGE_SIMPLE} />
                                        )}
                                    </div>
                                </div>
                            </div>
                        </Col>
                        <Col span={6} style={{ paddingLeft: '12px' }}>
                            <div style={{ paddingBottom: '2px' }} className="flex-between-center">
                                <div className="common-card-title-icon">
                                    <ProductOutlined />
                                    {layoutAddType === 'colFormData' ? '表格列维护' : (layoutAddType === 'queryFormData' ? '查询条件维护' : '表单元素维护')}
                                </div>
                                <span className="common-note">{layoutAddType !== 'colFormData' ? '注：添加字段只能字段管理选择！' : '注：列数据在这自定义添加'}</span>
                            </div>
                            <Divider
                                type="horizontal"
                                style={{
                                    margin: '8px 0',
                                }}
                            />
                            <div style={{ height: documentHeight - 282 + 'px', overflow: 'auto', paddingRight: '6px' }}>
                                <DynamicRenderingForm
                                    autoFocusFlag="Y"
                                    rowData={layoutRowData}
                                    formData={layoutFormData}
                                    formItemCol={{ col: 24, labelCol: 24, wrapperCol: 24 }}
                                    selectData={props?.selectData || {}}
                                    ref={layoutFormRef}
                                />
                            </div>
                            <div style={{ textAlign: 'center', paddingTop: '12px', marginTop: '6px', borderTop: '1px solid #e8e8e8' }}>
                                <Button style={{ marginRight: '16px' }} onClick={handleLayoutReset}>
                                    {layoutRowData?.id ? '取消修改' : '重置'}
                                </Button>
                                <Button type="primary" onClick={handleLayoutSave}>
                                    {layoutRowData?.id ? '确认修改' : '保存'}
                                </Button>
                            </div>
                        </Col>
                    </Row>
                    <div
                        className="stpc-body common-bottom-shadow"
                        style={{
                            overflow: 'auto',
                            border: '1px solid #e8e8e8',
                            height: documentHeight - 190 + 'px',
                            display: current === 1 ? 'block' : 'none',
                        }}
                    >
                        <div style={{ padding: '6px' }}>
                            <DynamicRenderingForm
                                rowData={rowData}
                                formData={formData}
                                selectData={props?.selectData || {}}
                                ref={formRef}
                            />
                        </div>
                    </div>
                    <div style={{ padding: '0 6px', display: current === 2 ? 'block' : 'none', border: '1px solid #e8e8e8' }} className="common-bottom-shadow">
                        <SingleTableOperation
                            previewMode="Y"
                            additionalHeight={132}
                            queryFormData={queryFormData}
                            columns={columns}
                            totalWidth={totalWidth}
                            tableData={tableData}
                            modalFormData={modalFormData}
                            categoryData={categoryData}
                        />
                    </div>
                </div>
                <div style={{ textAlign: 'center', paddingTop: '12px', marginTop: '6px', borderTop: '1px solid #e8e8e8' }}>
                    <Button style={{ marginRight: '16px' }} onClick={handleCancel}>
                        {current > 0 && current <= stepsItems.length - 1 ? '上一步' : '取消'}
                    </Button>
                    <Button
                        type="primary"
                        loading={okLoading}
                        onClick={handleOk}
                    >
                        {current === stepsItems.length - 1 ? '保存配置' : '下一步'}
                    </Button>
                </div>
            </Drawer>

            {/* 列表选择 */}
            <FieldSelectionModal
                formData={fieldFormData}
                width="1000px"
                tableHeight={450}
                title="字段选择"
                componentName="FieldManagement"
                queryCode="01010042"
                selectCode="01010050"
                paginationFlag="Y"
                ref={fieldSelectRef}
                onOk={handleModalSelectSave}
            />
        </div>
    );
};

export default forwardRef(SingleTableParamsConfig);