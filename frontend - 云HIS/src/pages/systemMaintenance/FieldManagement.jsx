/*
 * Create:      柿子
 * CreateDate:  2024/05/13
 * Describe：   字段管理
 * */
import React, { useEffect, useState, useRef } from 'react';
import { Card, Row, Col, Button, message, } from 'antd';
import { ProductOutlined, FormOutlined, PlusOutlined } from '@ant-design/icons';
import { Util } from '@tools';
import { addNewFieldFormData } from './js/staticData.js';
import request from '@api';
import store from '@store';
import SelectFieldType from './component/SelectFieldType';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import PublicModalFormHooks from '@pages/common/PublicModalFormHooks';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import './style/index.less';

const FieldManagement = () => {
    let formRef = useRef(null);
    let queryFormRef = useRef(null);
    let fieldTypeRef = useRef(null);
    let modalFormRef = useRef(null);
    const { contentHeight } = store.getState();
    const [selectData, setSelectData] = useState({});
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(20);
    const [columns, setColumns] = useState([]);
    const [totalWidth, setTotalWidth] = useState(0);
    const [loading, setLoading] = useState(false);
    const [tableData, setTableData] = useState([]);
    const [total, setTotal] = useState(0);
    const [rowID, setRowID] = useState('');
    const [rowData, setRowData] = useState({});
    const [modalFormData, setModalFormData] = useState([]);
    const [recordModalRowData, setRecordModalRowData] = useState({});
    const [formData, setFormData] = useState([]);
    const [queryFormData, setQueryFormData] = useState([]);

    useEffect(() => {
        getColumnsData();
        getFormData();
        getSelectData();
    }, []);

    const getSelectData = async () => {
        try {
            const res = await React.$asyncPost('01010050');
            setSelectData(res?.result || {});
        } catch (error) {
            console.log(error);
        };
    };

    // 获取列表表头数据
    const getColumnsData = async () => {
        try {
            const res = await request.getComponentInfo('FieldManagement');
            setColumns(res.result?.C || []);
            setTotalWidth(res?.totalWidth || 0);
            let nQueryFormData = res.result?.formData || [];
            for (let i = 0; i < nQueryFormData.length; i++) {
                if (nQueryFormData[i]?.typeCode === 'Input') {
                    nQueryFormData[i].onPressEnter = handleQuery;
                }
                if (nQueryFormData[i]?.dataIndex === 'queryBtn') { // 查询
                    nQueryFormData[i].onClick = handleQuery
                }
            }
            setQueryFormData(nQueryFormData);
        } catch (error) {
            console.log(error);
        };
    };

    useEffect(() => {
        getTableData();
    }, [page, pageSize]);

    // 查询
    const handleQuery = () => {
        setPage(oldPage => {
            if (oldPage === 1) {
                getTableData();
            };
            return 1
        });
    };

    // 获取列表数据
    const getTableData = async (clearFlag) => {
        try {
            let values = {};
            if (queryFormRef && queryFormRef.current) {
                values = await queryFormRef.current.handleSave();
                if (values.error) {
                    message.error('请完善必填信息');
                    return;
                }
            }
            setLoading(true);
            let data = {
                params: [{
                    ...values
                }],
                pagination: [{
                    pageSize: pageSize,
                    currentPage: page,
                }]
            };
            const res = await React.$asyncPost('01010042', data);
            setTableData(React.$processingTableRequestData(res));
            setTotal(res.result?.total || 0);
            setLoading(false);
            if (clearFlag !== 'N') {
                setRowID('');
                setRowData({});
            }
        } catch (error) {
            console.log(error);
            setLoading(false);
        };
    };

    // 提供修改page和pageSize的回调函数
    const handlePaginationChange = (page, pageSize) => {
        setPage(page);
        setPageSize(pageSize);
    };

    // 操作行
    const handleRowClick = (record) => {
        return {
            // 单击行选中
            onClick: () => {
                if (rowID === '' || (rowID && rowID !== record.key)) {
                    setRowID(record.key);
                    setRowData(record);
                } else {
                    setRowID('');
                    setRowData({});
                }
            }
        }
    };

    // 选中行操作
    const setRowClassName = (record) => {
        return record.key === rowID ? 'common-table-select-bg' : '';
    };

    // 新建字段
    const handleAdd = () => {
        fieldTypeRef && fieldTypeRef.current && fieldTypeRef.current.setVisible(true);
    };

    // 获取表单数据
    const getFormData = () => {
        const nFormData = [{
            dataIndex: 'CardTitle1',
            title: '基础信息配置',
            typeCode: 'CardTitle',
        }, {
            dataIndex: 'code',
            title: '字段标识(Code)',
            typeCode: 'Input',
            required: 'Y',
            doubt: '字段唯一标识，用于对接接口数据',
            disabled: 'Y'
        }, {
            dataIndex: 'descripts',
            title: '字段名称',
            typeCode: 'Input',
            required: 'Y',
            disabled: 'Y'
        }, {
            dataIndex: 'fieldTypeID',
            title: '字段类型',
            typeCode: 'Select',
            required: 'Y',
            className: 'configFieldType',
            disabled: 'Y'
        }, {
            dataIndex: 'fieldClassID',
            title: '字段分类',
            typeCode: 'Select',
            className: 'fieldClass',
            doubt: '设置当前字段所属分类',
            required: 'Y',
            disabled: 'Y'
        }, {
            dataIndex: 'CardTitle2',
            title: '数据绑定',
            typeCode: 'CardTitle'
        }, {
            dataIndex: 'customDataID',
            title: '数据集',
            typeCode: 'Select',
            className: 'customDataSet',
            doubt: '针对于选择框绑定的数据源',
            disabled: 'Y'
        }, {
            dataIndex: 'customDataStr',
            title: '自定义数据集',
            typeCode: 'TextArea',
            doubt: '如果同时维护了数据集和自定义数据集，优先展示数据集关联的数据',
            placeholder: 'key:value形式，可维护多个数据，多个用 & 拼接 [栗:   all:全部&Y:生效&N:失效]',
            disabled: 'Y'
        }, {
            dataIndex: 'enDesc2',
            title: '高级信息配置',
            typeCode: 'CardTitle'
        }, {
            dataIndex: 'doubt',
            title: '字段描述',
            typeCode: 'Input',
            doubt: '补充说明该字段的含义，指引用户正确填写该字段',
            disabled: 'Y'
        }];
        setFormData(nFormData);
    };

    useEffect(() => {
        if (formData && formData.length > 0) {
            modifyFormDataAttr('disabled', rowID ? 'N' : 'Y');
        }
    }, [rowID])

    // 修改表单属性
    const modifyFormDataAttr = (dataIndex, value) => {
        let nFormData = formData.map(item => {
            return {
                ...item,
                [dataIndex]: value
            }
        });
        setFormData(nFormData);
    };

    const getModalFormData = () => {
        setModalFormData(addNewFieldFormData);
    };

    // 记录价格信息表单的值
    const handleRecordModalFormInput = record => {
        setRecordModalRowData(oldData => {
            return {
                ...oldData,
                ...record
            }
        });
    };

    // 确认选择字段类型
    const handleConfirmFieldType = (values) => {
        let currentFieldTypeID = Util.returnDataCccordingToAttributes(selectData?.configFieldType || [], values?.typeCode || 'Input', 'code')?.id || '';
        console.log('currentFieldTypeID', currentFieldTypeID, values?.typeCode, selectData?.configFieldType || [])
        if (!(modalFormData && Array.isArray(modalFormData) && modalFormData.length > 0)) {
            getModalFormData();
        };
        setRecordModalRowData(oldData => {
            return {
                ...oldData,
                fieldTypeID: currentFieldTypeID
            }
        });
        modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(true);
    };

    // 创建字段
    const handleModalSave = (values) => {
        handleSave({
            ...recordModalRowData,
            ...values,
        }, 'Y');
    };

    // 确认修改
    const handleConfirmModify = () => {
        formRef && formRef.current && formRef.current.handleSave()
            .then(result => {
                if (!(result?.error)) {
                    handleSave({
                        ...rowData,
                        ...result,
                    });
                }
            })
    };

    // 保存
    const handleSave = async (values, closeModalFlag) => {
        try {
            let data = {
                params: [{
                    ...values,
                }]
            };
            const res = await React.$asyncPost('01010043', data);
            message.success(res?.errorMessage || '保存成功');
            getTableData(closeModalFlag === 'Y' ? 'Y' : 'N');
            if (closeModalFlag === 'Y') {
                modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(false, 'Y');
            } else {
                modalFormRef && modalFormRef.current && modalFormRef.current.modifyOkLoading(false);
            }
        } catch (error) {
            console.log(error);
            modalFormRef && modalFormRef.current && modalFormRef.current.modifyOkLoading(false);
        };
    };

    // 取消修改
    const handleCancel = () => {
        setRowID('');
        setRowData({});
    };

    return (
        <div className="field-management">
            <Row>
                <Col span={18}>
                    <div style={{ paddingRight: '6px', position: 'relative' }}>
                        <Card
                            size="small"
                            bordered={false}
                            title={(
                                <div className="common-card-title-icon">
                                    <ProductOutlined />
                                    字段列表
                                </div>
                            )}
                        >
                            <Row style={{ marginBottom: '6px' }}>
                                <Col span={18} style={{ display: queryFormData && queryFormData.length > 0 ? 'block' : 'none' }} className="common-dynamic-component">
                                    <DynamicRenderingForm
                                        className="common-dynamic-component-form common-dynamic-component-form-margin-bottom0"
                                        ref={queryFormRef}
                                        rowData={{}}
                                        selectData={selectData}
                                        formData={queryFormData}
                                        formItemCol={{ col: 6, labelCol: 6, wrapperCol: 17 }}
                                    />
                                </Col>
                                <Col span={6} style={{ textAlign: 'right' }}>
                                    <Button
                                        icon={<PlusOutlined className="common-record-span" />}
                                        onClick={handleAdd}
                                    >
                                        新建字段
                                    </Button>
                                </Col>
                            </Row>
                            <PublicTablePagination
                                param={{
                                    page, // 当前页数
                                    total, // 数据总条数
                                    loading,
                                    // 表头配置
                                    columns,
                                    defaultPageSize: 20,
                                    x: totalWidth, // 表格的宽度
                                    y: contentHeight - 177,
                                    height: contentHeight - 137 + 'px',
                                    data: tableData, // 表格数据
                                    componentName: 'FieldManagement',
                                }}
                                compilePage={handlePaginationChange}
                                getColumns={getColumnsData}
                                onRow={handleRowClick}
                                rowClassName={setRowClassName}
                            />
                        </Card>
                        <div className="common-card-right-split-line"></div>
                    </div>
                </Col>
                <Col span={6}>
                    <Card
                        size="small"
                        className="fm-field-detail-card"
                        bordered={false}
                        title={(
                            <div className="common-card-title-icon">
                                <FormOutlined />
                                字段明细
                            </div>
                        )}
                    >
                        <div style={{ paddingRight: '6px', height: contentHeight - 106 + 'px', overflow: 'auto' }}>
                            <DynamicRenderingForm
                                selectData={selectData}
                                rowData={rowData}
                                formData={formData}
                                formItemCol={{ labelCol: 24, wrapperCol: 24, col: 24 }}
                                ref={formRef}
                            />
                        </div>
                        <div style={{ textAlign: 'center', paddingTop: '12px', borderTop: '1px solid #e8e8e8' }}>
                            <Button type="primary" disabled={!rowID} onClick={handleConfirmModify}>确认修改</Button>
                            <Button style={{ marginLeft: '24px' }} disabled={!rowID} onClick={handleCancel}>取消</Button>
                        </div>
                    </Card>
                </Col>
            </Row>

            {/* 选择添加的字段类型 */}
            <SelectFieldType ref={fieldTypeRef} handleOk={handleConfirmFieldType} />

            {/* 新建字段 */}
            <PublicModalFormHooks
                width={600}
                title="添加字段"
                okText="创建"
                selectData={selectData}
                formData={modalFormData}
                rowData={recordModalRowData}
                formItemCol={{ labelCol: 24, wrapperCol: 24, col: 24 }}
                ref={modalFormRef}
                recordFormInput={handleRecordModalFormInput}
                handleSave={handleModalSave}
            />
        </div>
    )
};

export default FieldManagement;