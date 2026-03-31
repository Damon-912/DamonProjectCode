/**
 * 包装组件模板 - 基于 SingleTableOperation 动态组件
 * 
 * 适用场景：标准单表增删改查界面（查询条件 + 列表 + 操作）
 * 配套文档：references/code-examples.md
 * 
 * 核心配置说明：
 * - columns: 列表表头配置
 * - queryFormData: 查询表单字段配置
 * - modalFormData: 新增/编辑弹窗表单配置
 * - categoryData: 接口编码和功能开关配置
 * - selectData: 下拉框数据源（如需要）
 */
import React, { Component } from 'react';
import SingleTableOperation from 'pages/dynamicComponent/SingleTableOperation';
import './style/XxxManagement.less';

class XxxManagement extends Component {
    // ==================== 状态定义 ====================
    constructor(props) {
        super(props);
        this.state = {
            // 下拉数据（静态配置，无需调用01040073接口）
            // 数据格式：[{ id: '值', descripts: '显示文本', descriptsSPCode: '拼音' }]
            selectData: {
                statusList: [
                    { id: '1', descripts: '启用', descriptsSPCode: '启用' },
                    { id: '0', descripts: '停用', descriptsSPCode: '停用' }
                ]
            },
        };
    };

    // ==================== 静态配置数据（写死，不从01040073获取） ====================

    /**
     * columns - 列表表头配置
     * 必填属性：title, dataIndex
     * 建议属性：align: 'center', width, ellipsis: true
     * 操作列：如需自定义操作列，设置 cancelAddOperationFlag: 'Y'
     */
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
        // ... 更多列配置
    ];

    /**
     * queryFormData - 查询表单字段配置
     * 
     * 常用属性：
     * - dataIndex: 字段名（对应接口参数）
     * - title: 显示标签
     * - typeCode: 控件类型（Input/Select/DatePicker等）
     * - col: 栅格占比（一行24份，如8表示占1/3）
     * - required: 'Y'/'N' 是否必填
     * - selectField: 下拉框关联的selectData字段名
     * 
     * 查询按钮特殊配置：
     * - labelCol: 0, wrapperCol: 24（让按钮占满整格）
     * - type: 'primary'（蓝色主按钮）
     */
    queryFormData = [
        {
            dataIndex: 'xxxCode',      // 字段名，对应接口查询参数
            title: 'xxx代码',          // 显示标签
            typeCode: 'Input',         // 控件类型
            required: 'N',             // 是否必填
            col: 6                     // 栅格占比（6/24 = 1/4行）
        },
        {
            dataIndex: 'xxxName',
            title: 'xxx名称',
            typeCode: 'Input',
            col: 6
        },
        {
            dataIndex: 'status',
            title: '状态',
            typeCode: 'Select',
            col: 6,
            selectField: 'statusList'  // 关联 this.state.selectData.statusList
        }
    ];

    /**
     * modalFormData - 新增/编辑弹窗表单配置
     * 
     * 常用属性：
     * - dataIndex, title, typeCode, col 同 queryFormData
     * - required: 'Y' 表示必填，会自动显示红色星号
     * - disabled: 'Y' 表示禁用（常用于编辑时主键不可修改）
     * - doubt: 字段下方的提示文字
     * 
     * 表单分组（使用CardTitle）：
     * { typeCode: 'CardTitle', title: '基本信息' }
     */
    modalFormData = [
        {
            dataIndex: 'xxxCode',
            title: 'xxx代码',
            typeCode: 'Input',
            required: 'Y',             // 必填
            disabled: 'N',             // 不禁用
            doubt: '请输入唯一的xxx代码', // 提示文字
            col: 12                    // 一行两列（12+12=24）
        },
        {
            dataIndex: 'xxxName',
            title: 'xxx名称',
            typeCode: 'Input',
            required: 'Y',
            col: 12
        },
        {
            dataIndex: 'status',
            title: '状态',
            typeCode: 'Select',
            required: 'Y',
            col: 12,
            selectField: 'statusList'
        }
        // ... 更多表单字段
    ];

    /**
     * categoryData - 接口编码和功能开关配置
     * 
     * 接口配置（必填）：
     * - queryCode: 列表查询接口编号
     * - addCode: 新增数据接口编号
     * - editCode: 编辑数据接口编号（可选，默认使用addCode）
     * - deleteCode: 删除数据接口编号
     * - idIndex: 主键字段名（用于删除和编辑时传参）
     * 
     * 功能开关（可选）：
     * - isRowClick: 'Y'/'N' - 是否启用行点击选中
     * - hideQueryBtnFlag: 'Y' - 隐藏自动查询按钮（已在queryFormData中手动配置）
     * - cancelAddOperationFlag: 'Y' - 取消自动操作列（已在columns中手动配置）
     * - exportBtnFlag: 'Y' - 启用导出按钮
     * - importBtnFlag: 'Y' - 启用导入按钮
     * - batchDeleteFlag: 'Y' - 启用批量删除
     * - defaultPageSize: 20 - 默认分页大小
     * 
     * ⚠️ 重要：若手动配置查询按钮或操作列，必须设置对应Flag为'Y'
     */
    categoryData = {
        queryCode: '0104XXXX',      // 【必填】列表查询接口编号
        addCode: '0104XXXX',        // 【必填】新增接口编号
        editCode: '0104XXXX',       // 【可选】编辑接口编号，默认使用addCode
        deleteCode: '0104XXXX',     // 【必填】删除接口编号
        idIndex: 'xxxID',           // 【必填】主键字段名
        
        // 功能开关
        isRowClick: 'Y',            // 启用行点击选中
        hideQueryBtnFlag: 'Y',      // 隐藏自动查询按钮（已手动配置）
        cancelAddOperationFlag: 'Y', // 取消自动操作列（已手动配置）
        
        // 可选功能
        // exportBtnFlag: 'Y',      // 启用导出按钮
        // importBtnFlag: 'Y',      // 启用导入按钮
        // batchDeleteFlag: 'Y',    // 启用批量删除
        // defaultPageSize: 20,     // 默认分页大小
    };

    // ==================== 渲染 ====================
    /**
     * SingleTableOperation Props 说明：
     * 
     * 【核心配置】
     * - skip01040073: true - 跳过01040073接口，使用下方静态配置
     * - categoryData: 接口编码和功能开关配置
     * - componentName: 组件名称（用于表格高度计算和缓存）
     * 
     * 【静态配置】（skip01040073=true时生效）
     * - hardcodedColumns: 列表表头配置
     * - hardcodedQueryFormData: 查询表单配置
     * - hardcodedModalFormData: 弹窗表单配置
     * - hardcodedSelectData: 下拉数据源
     * 
     * 【事件回调】（可选）
     * - onRowClick: 行点击事件回调
     * - customRender: 自定义渲染函数
     */
    render() {
        const { selectData } = this.state;

        return (
            <div className="xxx-management">
                <SingleTableOperation
                    // 核心配置
                    skip01040073={true}                    // 使用静态配置，不调用01040073
                    categoryData={this.categoryData}       // 接口编码和功能开关
                    componentName="XxxManagement"          // 组件标识
                    
                    // 静态配置数据
                    hardcodedColumns={this.columns}        // 表头配置
                    hardcodedQueryFormData={this.queryFormData}   // 查询表单
                    hardcodedModalFormData={this.modalFormData}   // 弹窗表单
                    hardcodedSelectData={selectData}       // 下拉数据
                />
            </div>
        );
    }
};

export default XxxManagement;
