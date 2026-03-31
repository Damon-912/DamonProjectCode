/**
 * Create:     AI生成
 * CreateDate: 2026-03-02
 * Describe:   xxx维护
 * 原型地址:    用户提供的原型图
 */
import React, { Component } from 'react';
import { Spin, Row, Col, Button, Popconfirm, Divider, Icon, message } from 'antd';
import DynamicRenderingForm from 'pages/common/DynamicRenderingForm';
import PubilcTablePagination from 'pages/common/PubilcTablePagination';
import PublicModalFormHooks from 'pages/common/PublicModalFormHooks';
import './style/XxxManagement.less';

class XxxManagement extends Component {
    // ==================== 状态定义 ====================
    constructor(props) {
        super(props);
        // 创建ref用于获取查询区域高度
        this.queryRef = React.createRef();
        this.state = {
            spinLoading: false,
            selectData: {
                statusList: [
                    { id: '0', descripts: '停用' },
                    { id: '1', descripts: '启用' }
                ]
            },
            
            // ========== 列表数据 ==========
            rowID: '',
            dataList: [],
            loading: false,
            queryHeight: 64,
            totalWidth: 650,

            // ========== 分页状态 ==========
            page: 1,
            pageSize: 10,
            pageType: 'small',
            total: 0,

            // ========== 弹窗状态 ==========
            modalRecord: {},
        };
    };

    // ==================== 写死的配置数据 ====================
    
    // 列表表头配置（写死，不从01040073获取）
    columns = [
        {
            title: 'xxx代码',
            dataIndex: 'xxxCode',
            key: 'xxxCode',
            width: 150,
            ellipsis: true
        },
        {
            title: 'xxx名称',
            dataIndex: 'xxxName',
            key: 'xxxName',
            width: 200,
            ellipsis: true
        },
        {
            title: '状态',
            dataIndex: 'status',
            key: 'status',
            width: 100,
            ellipsis: true,
            render: (text) => text === '1' ? '启用' : '停用'
        },
        {
            title: '操作',
            dataIndex: 'operation',
            key: 'operation',
            width: 150,
            fixed: 'right', // 根据实际场景添加，如果表格列很多时出现x轴滚动条则使用
            render: (text, record) => (
                <>
                    <span className="span" onClick={(e) => this.handleEdit(record, e)}>
                        <Icon type="edit" style={{ color: '#108EE9' }}></Icon>
                        编辑
                    </span>
                    <Divider type="vertical" />
                    <Popconfirm
                        title="删除不可恢复，你确定要删除吗?"
                        onCancel={React.$stopPropagation}
                        onClick={React.$stopPropagation}
                        onConfirm={(e) => this.handleDelete(record, e)}
                    >
                        <span className="span common-record-delete-span">
                            <Icon type="delete"></Icon>
                            删除
                        </span>
                    </Popconfirm>
                </>
            )
        }
    ];

    // 查询表单配置（写死，不从01040073获取）
    queryFormData = [
        {
            dataIndex: 'xxxCode',
            title: 'xxx代码',
            typeCode: 'Input',
            required: 'N',
            disabled: 'N',
            col: 8
        },
        {
            dataIndex: 'xxxName',
            title: 'xxx名称',
            typeCode: 'Input',
            required: 'N',
            disabled: 'N',
            col: 8
        },
        {
            dataIndex: 'status',
            title: '状态',
            typeCode: 'Select',
            required: 'N',
            disabled: 'N',
            col: 8,
            selectField: 'statusList'
        }
    ];

    // 弹窗表单配置（写死，不从01040073获取）
    modalFormData = [
        {
            dataIndex: 'xxxCode',
            title: 'xxx代码',
            typeCode: 'Input',
            required: 'Y',
            disabled: 'N',
            doubt: '请输入唯一的xxx代码',
            col: 12
        },
        {
            dataIndex: 'xxxName',
            title: 'xxx名称',
            typeCode: 'Input',
            required: 'Y',
            disabled: 'N',
            col: 12
        },
        {
            dataIndex: 'status',
            title: '状态',
            typeCode: 'Select',
            required: 'Y',
            disabled: 'N',
            col: 12,
            selectField: 'statusList'
        }
    ];

    // ==================== 生命周期 ====================
    componentDidMount() {
        // 获取查询区域高度（用于表格高度自适应）
        setTimeout(() => {
            this.setState({ queryHeight: this.queryRef?.current?.clientHeight || 64 });
        }, 0);
        this.fetchList();
    };

    // ==================== 数据操作 ====================

    // 获取列表数据
    fetchList = async () => {
        let values = await this.formRef.handleSave();
        if (values.error) {
            message.error('请完善必填信息');
            return;
        }
        const { page, pageSize } = this.state;
        this.setState({ loading: true });
        try {
            let params = {
                params: [{ ...values }],
                pagination: [{ pageSize, currentPage: page }]
            }
            // TODO: 替换为实际接口编号
            let res = await React.$asyncPost(this, '010XXXXX', params);
            this.setState({
                loading: false,
                dataList: React.$processingTableRequestData(res),
                total: res?.result?.total || 0
            });
        } finally {
            this.setState({ loading: false });
        }
    };

    // ==================== 事件处理 ====================

    // 查询
    handleSearch = () => {
        this.setState({ page: 1 }, () => {
            this.fetchList();
        });
    };

    // 新增
    handleAdd = () => {
        const { modalRecord } = this.state;
        let idIndex = 'xxxID';
        if (modalRecord && idIndex in modalRecord && modalRecord[idIndex]) {
            this.setState({ modalRecord: {} })
        }
        this.modalFormRef && this.modalFormRef.modifyVisible(true);
    };

    // 编辑
    handleEdit = (record) => {
        this.setState({ modalRecord: record }, () => {
            this.modalFormRef && this.modalFormRef.modifyVisible(true);
        })
    };

    // 删除
    handleDelete = async (record) => {
        try {
            let data = {
                params: [{
                    xxxID: record?.xxxID || ''
                }]
            }
            // TODO: 替换为实际接口编号
            let res = await React.$asyncPost(this, '010XXXXX', data);
            message.success(res?.errorMessage || '删除成功');
            this.fetchList();
        } catch (error) {
            console.log(error);
        }
    };

    // 保存（新增/编辑）
    handleSave = async (values) => {
        try {
            let data = {
                params: [{
                    ...values,
                }]
            }
            // TODO: 替换为实际接口编号
            let res = await React.$asyncPost(this, '010XXXXX', data);
            message.success(res?.errorMessage || '操作成功');
            this.handleSearch();
            this.modalFormRef && this.modalFormRef.modifyVisible(false, 'Y');
        } catch (error) {
            console.log(error);
        }
    };

    // 分页变化
    handlePageChange = (page, pageSize) => {
        this.setState({ page, pageSize }, () => {
            this.fetchList();
        })
    };

    // 操作行
    onClickRowPublic = (record) => {
        return {
            onClick: () => {
                if (this.state.rowID === '' || (this.state.rowID && (this.state.rowID !== record?.xxxID || record?.key || ''))) {
                    this.setState({ rowID: record?.xxxID || record?.key || '' });
                } else {
                    this.setState({ rowID: '' });
                }
            }
        }
    };

    // 选中行操作
    setRowClassNamePublic = (record) => {
        return (record?.xxxID || record?.key || '') === this.state.rowID ? 'clickRowStyle' : '';
    };

    // ==================== 渲染 ====================
    render() {
        const {
            spinLoading, dataList, loading, modalRecord,
            page, pageSize, total, pageType, selectData, queryHeight
        } = this.state;

        return (
            <Spin tip="资源加载中..." spinning={spinLoading}>
                <div className="xxx-management dynamic-component">
                    {/* 查询表单 */}
                    <div ref={this.queryRef}>
                        <Row style={{ padding: '14px 24px 0 12px' }}>
                            <Col span={20}>
                                <DynamicRenderingForm
                                    className="dynamic-component-form"
                                    rowData={{}}
                                    selectData={selectData}
                                    formData={this.queryFormData}
                                    onRef={ref => this.formRef = ref}
                                />
                            </Col>
                            <Col span={4} style={{ textAlign: 'right' }}>
                                <Button icon="plus" className="add-btn add-btn-noHover" onClick={this.handleAdd}>
                                    新增
                                </Button>
                            </Col>
                        </Row>
                    </div>

                    {/* 查询分隔线 */}
                    <div className="common-query-split-line"></div>

                    {/* 列表表格 */}
                    <div style={{ padding: '24px' }} className="table-body-height">
                        <PubilcTablePagination
                            param={{
                                page,
                                size: pageType,
                                pageSize,
                                total,
                                loading,
                                extendFlag: 'Y',
                                componentName: 'XxxManagement',
                                data: dataList,
                                x: this.columns.reduce((sum, col) => sum + (col.width || 100), 0),
                                y: store.getState().tableHeight.y + 93 - queryHeight,
                                height: store.getState().tableHeight.y + 143 - queryHeight + 'px',
                                columns: this.columns,
                            }}
                            compilePage={this.handlePageChange}
                            onClickRowPublic={this.onClickRowPublic}
                            setRowClassNamePublic={this.setRowClassNamePublic}
                        />
                    </div>

                    {/* 新增/编辑弹窗 */}
                    <PublicModalFormHooks
                        onRef={ref => this.modalFormRef = ref}
                        formData={this.modalFormData}
                        rowData={modalRecord}
                        recordFormInput={this.recordFormInput}
                        handleSave={this.handleSave}
                    />
                </div>
            </Spin>
        );
    }
};

export default XxxManagement;
