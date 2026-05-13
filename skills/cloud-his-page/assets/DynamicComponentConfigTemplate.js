/**
 * 动态组件配置模板
 * 
 * 适用场景：标准单表增删改查界面，无需编写组件代码
 * 使用方式：将以下配置数据维护到数据库，通过动态组件模板渲染
 */

// ==================== 接口配置 ====================

/**
 * 接口配置说明：
 * - selectCode: 初始化下拉数据接口（可选）
 * - queryCode: 查询列表数据接口（必填）
 * - addCode: 新增数据接口（可选）
 * - editCode: 编辑数据接口（可选，不配置则使用addCode）
 * - deleteCode: 删除数据接口（可选）
 * - exportCode: 导出数据接口（可选）
 */
export const interfaceConfig = {
    // 下拉数据接口（返回selectData对象，包含各下拉选项数组）
    selectCode: '0104XXXX',
    
    // 查询接口（支持分页）
    queryCode: '0104XXXX',
    
    // 新增接口
    addCode: '0104XXXX',
    
    // 编辑接口
    editCode: '0104XXXX',
    
    // 删除接口
    deleteCode: '0104XXXX',
};

// ==================== 组件配置 ====================

/**
 * 组件配置说明：
 * - componentName: 组件名称，需与01040073接口配置一致
 * - idIndex: 数据主键字段名
 * - groupType: 数据范围类型 H-医院级 G-集团级
 */
export const componentConfig = {
    // 组件名称（01040073接口查询key）
    componentName: 'ComponentNameMaintenance',
    
    // 主键字段名
    idIndex: 'componentID',
    
    // 数据范围类型
    groupType: 'H',
};

// ==================== 功能开关配置 ====================

/**
 * 功能开关说明：
 * - isRowClick: 是否启用行点击选中 Y/N
 * - exportBtnFlag: 是否显示导出按钮 Y/N
 * - importBtnFlag: 是否显示导入按钮 Y/N
 * - batchDeleteFlag: 是否启用批量删除 Y/N
 * - doNotAutoQueryFlag: 是否禁止自动查询 Y/N
 * - hidePaginationFlag: 是否隐藏分页 Y/N
 */
export const featureConfig = {
    // 行点击选中
    isRowClick: 'Y',
    
    // 导出按钮
    exportBtnFlag: 'N',
    
    // 导入按钮
    importBtnFlag: 'N',
    
    // 批量删除
    batchDeleteFlag: 'N',
    
    // 禁止自动查询（Y:进入界面不自动查询）
    doNotAutoQueryFlag: 'N',
    
    // 隐藏分页
    hidePaginationFlag: 'N',
};

// ==================== 分页配置 ====================

export const paginationConfig = {
    // 默认每页条数
    defaultPageSize: 10,
    
    // 分页器大小 small/default/large
    paginationSize: 'small',
};

// ==================== 01040073表头配置 ====================

/**
 * 列表表头配置（01040273接口维护）
 * 
 * 维护方式：
 * 1. 先调用01040271新增组件主数据，获取componentID
 * 2. 调用01040273维护表头数据，每条记录对应一列
 * 
 * 字段说明：
 * - reactComID: 组件ID（01040271返回）
 * - code: 字段名（对应dataIndex）
 * - descripts: 列标题
 * - width: 列宽度
 * - seqNo: 显示顺序
 * - align: 对齐方式 left/center/right
 * - display: 是否显示 Y/N
 * - fixed: 固定列 left/right/空
 */
export const columnsConfig = [
    {
        title: '字段1标题',
        dataIndex: 'field1Code',
        key: 'field1Code',
        width: 150,
        ellipsis: true,
        align: 'left'
    },
    {
        title: '字段2标题',
        dataIndex: 'field2Code',
        key: 'field2Code',
        width: 200,
        ellipsis: true,
        align: 'left'
    },
    {
        title: '状态',
        dataIndex: 'status',
        key: 'status',
        width: 100,
        ellipsis: true
    },
    {
        title: '操作',
        dataIndex: 'operation',
        key: 'operation',
        width: 150,
        fixed: 'right'
    }
];

// ==================== 01040073查询表单配置 ====================

/**
 * 查询表单配置（01040279接口维护，type='C'时返回的formData）
 * 
 * 字段说明：
 * - dataIndex: 字段名
 * - title: 字段标题
 * - typeCode: 输入类型 Input/Select/DatePicker等
 * - required: 是否必填 Y/N
 * - disabled: 是否禁用 Y/N
 * - col: 占列数（一行24份）
 * - selectField: 下拉数据源key（Select类型需要）
 * - doubt: 提示信息
 */
export const queryFormConfig = [
    {
        dataIndex: 'field1Code',
        title: '字段1标题',
        typeCode: 'Input',
        required: 'N',
        disabled: 'N',
        col: 8
    },
    {
        dataIndex: 'field2Code',
        title: '字段2标题',
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

// ==================== 01040073弹窗表单配置 ====================

/**
 * 弹窗表单配置（01040279接口维护，type='F'时返回的formData）
 * 
 * 注意：弹窗表单的componentName需要加上'Form'后缀
 * 例如：ComponentNameMaintenanceForm
 */
export const modalFormConfig = [
    {
        dataIndex: 'field1Code',
        title: '字段1标题',
        typeCode: 'Input',
        required: 'Y',
        disabled: 'N',
        doubt: '请输入唯一的字段1',
        col: 12
    },
    {
        dataIndex: 'field2Code',
        title: '字段2标题',
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

// ==================== 菜单配置参数 ====================

/**
 * 菜单参数配置（menuParameter字段）
 * 
 * 格式说明：
 * params=interfaceType:singleTable
 *   &componentName:ComponentNameMaintenance
 *   &selectCode:0104XXXX
 *   &queryCode:0104XXXX
 *   &addCode:0104XXXX
 *   &editCode:0104XXXX
 *   &deleteCode:0104XXXX
 *   &idIndex:componentID
 *   &isRowClick:Y
 *   &groupType:H
 */
export const generateMenuParameter = () => {
    const params = [
        'interfaceType:singleTable',
        `componentName:${componentConfig.componentName}`,
        `selectCode:${interfaceConfig.selectCode}`,
        `queryCode:${interfaceConfig.queryCode}`,
        `addCode:${interfaceConfig.addCode}`,
        `editCode:${interfaceConfig.editCode}`,
        `deleteCode:${interfaceConfig.deleteCode}`,
        `idIndex:${componentConfig.idIndex}`,
        `isRowClick:${featureConfig.isRowClick}`,
        `groupType:${componentConfig.groupType}`,
        `exportBtnFlag:${featureConfig.exportBtnFlag}`,
        `importBtnFlag:${featureConfig.importBtnFlag}`,
        `batchDeleteFlag:${featureConfig.batchDeleteFlag}`,
        `doNotAutoQueryFlag:${featureConfig.doNotAutoQueryFlag}`,
        `hidePaginationFlag:${featureConfig.hidePaginationFlag}`,
        `defaultPageSize:${paginationConfig.defaultPageSize}`,
        `paginationSize:${paginationConfig.paginationSize}`,
    ];
    
    return 'params=' + params.join('&');
};

// ==================== 使用说明 ====================

/**
 * 使用步骤：
 * 
 * 1. 修改本文件中的配置（接口编号、字段配置等）
 * 
 * 2. 维护01040073接口数据：
 *    - 调用01040271新增组件主数据
 *    - 调用01040273维护列表表头数据（type='C'）
 *    - 调用01040273维护查询表单数据（type='C'）
 *    - 调用01040279维护弹窗表单数据（type='F'，componentName+Form后缀）
 * 
 * 3. 配置菜单：
 *    - menuUrl: /dynamicComponent/SingleTableOperation
 *    - menuParameter: 使用generateMenuParameter()生成的字符串
 * 
 * 4. 测试验证各功能
 */

export default {
    interfaceConfig,
    componentConfig,
    featureConfig,
    paginationConfig,
    columnsConfig,
    queryFormConfig,
    modalFormConfig,
    generateMenuParameter,
};
