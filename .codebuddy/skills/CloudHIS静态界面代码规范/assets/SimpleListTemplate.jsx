/**
 * Create:     AI生成
 * CreateDate: 2026-03-02
 * Describe:   简单列表查询模板（无增删改功能）
 * 原型地址:    用户提供的原型图
 * 技术栈:      React 16.6.3 + Ant Design 3.x
 * 重要：
 *   - 必须使用类组件（class extends Component）
 *   - 禁止使用 Hooks（useState, useEffect等）
 *   - 使用 this.state 和 this.setState 管理状态
 *   - 只有查询和列表展示功能
 *   - 公共组件必须使用 '../common/' 相对路径导入，禁止用 '@/containers/components/'
 */
import React, { Component } from 'react';
import { Spin, Row, Col, Button, message } from 'antd';
import DynamicRenderingForm from '../common/DynamicRenderingForm';
import PubilcTablePagination from '../common/PubilcTablePagination';
import './style/COMPONENT_NAME_PLACEHOLDER.less';

class COMPONENT_NAME_PLACEHOLDER extends Component {
    constructor(props) {
        super(props);
        this.state = {
            spinLoading: false,
            selectData: {},
            dataList: [],
            loading: false,
            queryHeight: 125,
            totalWidth: 0,
            page: 1,
            pageSize: 10,
            pageType: 'small',
            total: 0,
        };
    };

    // ==================== 写死的配置数据 ====================
    
    /**
     * 列表表头配置
     * 根据原型图配置列信息
     */
    columns = [
        // {
        //     title: '列标题',
        //     dataIndex: 'fieldName',
        //     key: 'fieldName',
        //     width: 150,
        //     ellipsis: true,
        //     align: 'left'
        // },
        // {
        //     title: '创建时间',
        //     dataIndex: 'createTime',
        //     key: 'createTime',
        //     width: 180,
        //     render: (text) => text ? moment(text).format('YYYY-MM-DD HH:mm') : ''
        // }
    ];

    /**
     * 查询表单配置
     */
    queryFormData = [
        // {
        //     dataIndex: 'fieldName',
        //     title: '字段标题',
        //     typeCode: 'Input',
        //     required: 'N',
        //     col: 8
        // }
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
        } catch (error) {
            console.error(error);
            this.setState({ loading: false });
        }
    };

    // ==================== 事件处理 ====================

    handleSearch = () => {
        this.setState({ page: 1 }, () => this.fetchList());
    };

    handleReset = () => {
        this.formRef && this.formRef.resetFields && this.formRef.resetFields();
        this.setState({ page: 1 }, () => this.fetchList());
    };

    handlePageChange = (page, pageSize) => {
        this.setState({ page, pageSize }, () => this.fetchList());
    };

    // ==================== 渲染 ====================
    render() {
        const { spinLoading, dataList, loading, page, pageSize, total, queryHeight } = this.state;
        
        const totalWidth = this.columns.reduce((sum, col) => sum + (col.width || 100), 0);

        return (
            <Spin tip="资源加载中..." spinning={spinLoading}>
                <div className="COMPONENT_NAME_CSS_PLACEHOLDER dynamic-component">
                    {/* 查询表单 */}
                    <div ref={this.queryRef}>
                        <Row style={{ padding: '14px 24px 0 12px' }}>
                            <Col span={20}>
                                <DynamicRenderingForm
                                    className="dynamic-component-form"
                                    rowData={{}}
                                    selectData={this.state.selectData}
                                    formData={this.queryFormData}
                                    onRef={ref => this.formRef = ref}
                                />
                            </Col>
                            <Col span={4} style={{ textAlign: 'right' }}>
                                <Button type="primary" icon="search" onClick={this.handleSearch}>
                                    查询
                                </Button>
                                <Button style={{ marginLeft: 8 }} onClick={this.handleReset}>
                                    重置
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
                                size: this.state.pageType,
                                pageSize,
                                total,
                                loading,
                                extendFlag: 'Y',
                                componentName: 'COMPONENT_NAME_PLACEHOLDER',
                                data: dataList,
                                x: totalWidth,
                                y: store.getState().tableHeight.y + 93 - queryHeight,
                                height: store.getState().tableHeight.y + 143 - queryHeight + 'px',
                                columns: this.columns,
                            }}
                            compilePage={this.handlePageChange}
                        />
                    </div>
                </div>
            </Spin>
        );
    }
};

export default COMPONENT_NAME_PLACEHOLDER;
