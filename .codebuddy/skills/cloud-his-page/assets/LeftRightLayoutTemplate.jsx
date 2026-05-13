/**
 * Create:     AI生成
 * CreateDate: 2026-03-04
 * Describe:   左右分栏布局组件模板（左侧列表 + 右侧详情）
 * 原型地址:    用户提供的原型图
 * 技术栈:      React 16.6.3 + Ant Design 3.x
 * 重要：
 *   - 必须使用类组件（class extends Component）
 *   - 禁止使用 Hooks（useState, useEffect等）
 *   - 使用 this.state 和 this.setState 管理状态
 *   - 左侧列表区域严格遵循 CardListTemplate 规范
 *   - 公共组件必须使用 '../common/' 相对路径导入，禁止用 '@/containers/components/'
 *   - 左右分栏比例：span={14} 列表 + span={10} 详情
 */
import React, { Component } from 'react';
import { Row, Col, Card, Button, message, Popconfirm, Divider, Icon } from 'antd';
import store from 'store';
import DynamicRenderingForm from '../common/DynamicRenderingForm';
import PubilcTablePagination from '../common/PubilcTablePagination';
import iconListVisits from 'assets/images/icon_listvisits.png';
import './style/COMPONENT_NAME_CSS_PLACEHOLDER.less';

class COMPONENT_NAME_PLACEHOLDER extends Component {
  constructor(props) {
    super(props);
    // 创建ref用于获取查询区域高度和详情表单
    this.queryRef = React.createRef();
    this.state = {
      userData: {},
      selectData: {
        statusList: [
          { id: '1', title: '启用' },
          { id: '0', title: '停用' }
        ]
      },
      queryHeight: 64,           // 查询区域高度
      rowID: '',                 // 选中行 ID
      rowData: {},               // 选中行数据（用于右侧详情展示）
      tableData: [],             // 表格数据
      loading: false,
      page: 1,
      pageSize: 10,
      pageType: 'small',
      total: 0,
    };
  }

  // ==================== 配置数据 ====================

  /**
   * 表头配置
   * 根据原型图配置列信息
   * 注意：如需自定义操作列，请配置 cancelAddOperationFlag: 'Y'
   */
  columns = [
    // {
    //     title: '代码',
    //     dataIndex: 'code',
    //     key: 'code',
    //     width: 120,
    //     align: 'center',
    //     ellipsis: true
    // },
    // {
    //     title: '名称',
    //     dataIndex: 'name',
    //     key: 'name',
    //     width: 150,
    //     align: 'center',
    //     ellipsis: true
    // },
    // {
    //     title: '状态',
    //     dataIndex: 'status',
    //     key: 'status',
    //     width: 100,
    //     align: 'center',
    //     ellipsis: true,
    //     render: (text) => text === '1' ? '启用' : '停用'
    // },
    // {
    //     title: '操作',
    //     dataIndex: 'operation',
    //     key: 'operation',
    //     width: 120,
    //     align: 'center',
    //     fixed: 'right',
    //     render: (text, record) => (
    //         <span>
    //             <Icon type="edit" style={{ color: '#108EE9' }} />
    //             <span className="span" onClick={(e) => this.handleEdit(record, e)}>编辑</span>
    //             <Divider type="vertical" />
    //             <Popconfirm title="确定删除?" onConfirm={(e) => this.handleDelete(record, e)}>
    //                 <span className="span common-record-delete-span">
    //                     <Icon type="delete" />删除
    //                 </span>
    //             </Popconfirm>
    //         </span>
    //     )
    // }
  ];

  /**
   * 查询表单配置
   * 注意：Card模式下表单字段建议使用 labelCol 和 wrapperCol 控制布局
   *
   * ⚠️ 查询按钮配置规范（重要）：
   * - typeCode 必须是 'Button'，不能是 'Btn' 或 'btn'
   * - title 必须是按钮显示文字，如 '查询'
   * - 不要使用 titleText 属性（规范中不存在）
   * - 查询按钮前一个字段的 labelCol + wrapperCol 应为 23，保留空隙
   */
  queryFormData = [
    // {
    //     dataIndex: 'code',
    //     title: '代码',
    //     typeCode: 'Input',
    //     col: 6,
    //     labelCol: 8,
    //     wrapperCol: 16
    // },
    // {
    //     dataIndex: 'name',
    //     title: '名称',
    //     typeCode: 'Input',
    //     col: 6,
    //     labelCol: 6,
    //     wrapperCol: 17    // 6 + 17 = 23，保留1份空隙给按钮
    // },
    // ✅ 正确的查询按钮配置示例（必填项）
    // {
    //     dataIndex: 'queryBtn',
    //     title: '查询',
    //     typeCode: 'Button',
    //     type: 'primary',
    //     col: 6,
    //     labelCol: 0,
    //     wrapperCol: 24,
    //     onClick: 'handleQuery'
    // }
  ];

  /**
   * 详情表单配置（右侧）
   * 用于展示选中行的详细信息
   */
  detailFormData = [
    // {
    //     dataIndex: 'code',
    //     title: '代码',
    //     typeCode: 'Input',
    //     col: 24,
    //     labelCol: 6,
    //     wrapperCol: 18,
    //     disabled: true
    // },
    // {
    //     dataIndex: 'name',
    //     title: '名称',
    //     typeCode: 'Input',
    //     col: 24,
    //     labelCol: 6,
    //     wrapperCol: 18,
    //     disabled: true
    // },
    // {
    //     dataIndex: 'status',
    //     title: '状态',
    //     typeCode: 'Select',
    //     col: 24,
    //     labelCol: 6,
    //     wrapperCol: 18,
    //     selectField: 'statusList',
    //     disabled: true
    // }
  ];

  // ==================== 生命周期 ====================

  componentDidMount() {
    // 获取查询区域高度（用于表格高度自适应）- 使用ref替代document.getElementById
    setTimeout(() => {
      this.setState({ queryHeight: this.queryRef?.current?.clientHeight || 64 });
    }, 0);
    this.fetchList();
  }

  // ==================== 数据请求 ====================

  /**
   * 获取列表数据
   */
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
      };
      // TODO: 替换为实际接口编号
      let res = await React.$asyncPost(this, '010XXXXX', params);
      this.setState({
        loading: false,
        tableData: React.$processingTableRequestData(res),
        total: res?.result?.total || 0
      });
    } catch (error) {
      console.error(error);
      this.setState({ loading: false });
    }
  };

  // ==================== 事件处理 ====================

  /**
   * 查询按钮点击
   */
  handleQuery = () => {
    this.setState({ page: 1 }, () => this.fetchList());
  };

  /**
   * 新增按钮点击
   */
  handleAdd = () => {
    // TODO: 实现新增逻辑
  };

  /**
   * 编辑按钮点击
   */
  handleEdit = (record, e) => {
    e?.stopPropagation();
    // TODO: 实现编辑逻辑
  };

  /**
   * 删除按钮点击
   */
  handleDelete = async (record, e) => {
    e?.stopPropagation();
    // TODO: 实现删除逻辑
    // try {
    //     let data = { params: [{ id: record?.id }] };
    //     let res = await React.$asyncPost(this, '010XXXXX', data);
    //     message.success(res?.errorMessage || '删除成功');
    //     this.fetchList();
    // } catch (error) {
    //     console.error(error);
    // }
  };

  /**
   * 分页变化
   */
  handlePageChange = (page, pageSize) => {
    this.setState({ page, pageSize }, () => this.fetchList());
  };

  /**
   * 行点击事件（左右交互核心）
   * 点击行时：设置 rowData 并回显到右侧详情表单
   * 再次点击同一行：清除 rowData 并清空右侧详情表单
   */
  onClickRowPublic = (record) => ({
    onClick: () => {
      const { rowID } = this.state;
      const currentRowID = record?.id || record?.key || '';
      if (rowID === currentRowID) {
        // 再次点击同一行，取消选中并清空详情
        this.setState({ rowID: '', rowData: {} });
        this.detailFormRef && this.detailFormRef.handleClear();
      } else {
        // 点击新行，选中并回显详情
        this.setState({ rowID: currentRowID, rowData: record });
        this.detailFormRef && this.detailFormRef.handleEchoData(record);
      }
    }
  });

  /**
   * 选中行样式
   */
  setRowClassNamePublic = (record) => {
    const rowKey = record?.id || record?.key || '';
    return rowKey === this.state.rowID ? 'clickRowStyle' : '';
  };

  // ==================== 渲染 ====================

  render() {
    const { tableData, loading, page, pageSize, total, pageType, queryHeight, selectData, rowData } = this.state;

    const totalWidth = this.columns.reduce((sum, col) => sum + (col.width || 100), 0);

    return (
      <Row className="COMPONENT_NAME_CSS_PLACEHOLDER">
        {/* 左侧列表区域 - span=14 */}
        <Col span={14}>
          <div style={{ paddingRight: '8px', position: 'relative' }}>
            <Card
              size="small"
              bordered={false}
              title={
                <div className="card-title-left-img">
                  <img src={iconListVisits} alt="" />
                  LIST_TITLE_PLACEHOLDER
                </div>
              }
            >
              <div className="table-body-height dynamic-component">
                {/* 查询表单 + 新增按钮 */}
                <Row ref={this.queryRef}>
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
                    <Button
                      icon="plus"
                      className="add-btn add-btn-noHover"
                      onClick={this.handleAdd}
                    >
                      新增
                    </Button>
                  </Col>
                </Row>

                {/* 表格 */}
                <PubilcTablePagination
                  param={{
                    loading,
                    size: pageType,
                    page,
                    pageSize,
                    data: tableData,
                    total,
                    columns: this.columns,
                    x: totalWidth,
                    y: store.getState().tableHeight.y + 115 - queryHeight,
                    height: store.getState().tableHeight.y + 160 - queryHeight + 'px',
                    componentName: 'COMPONENT_NAME_PLACEHOLDER',
                    extendFlag: 'Y',
                  }}
                  compilePage={this.handlePageChange}
                  onClickRowPublic={this.onClickRowPublic}
                  setRowClassNamePublic={this.setRowClassNamePublic}
                />
              </div>
            </Card>
            <div className="common-card-right-split-line" style={{ width: 8 }}></div>
          </div>
        </Col>

        {/* 右侧详情区域 - span=10 */}
        <Col span={10}>
          <Card
            size="small"
            bordered={false}
            bodyStyle={{ paddingRight: '6px' }}
            title={
              <div className="card-title-left-img">
                <img src={iconListVisits} alt="" />
                DETAIL_TITLE_PLACEHOLDER
              </div>
            }
          >
            {/* 【重要】设置独立滚动高度，避免整个页面出现滚动条 */}
            {/* 高度计算：tableHeight.y + 179 (241 - Card head 38 - body padding 24) */}
            <div style={{ paddingRight: '6px', height: store.getState().tableHeight.y + 179 + 'px', overflow: 'auto' }}>
              <DynamicRenderingForm
                className="dynamic-component-form"
                rowData={rowData}
                selectData={selectData}
                formData={this.detailFormData}
                onRef={ref => this.detailFormRef = ref}
              />
              {/* 操作按钮（可选） */}
              {/* <div style={{ marginTop: '16px', textAlign: 'center' }}>
                <Button type="primary" style={{ marginRight: '8px' }} onClick={this.handleConfirm}>
                  确认修改
                </Button>
                <Button onClick={this.handleCancel}>取消</Button>
              </div> */}
            </div>
          </Card>
        </Col>
      </Row>
    );
  }
}

export default COMPONENT_NAME_PLACEHOLDER;
