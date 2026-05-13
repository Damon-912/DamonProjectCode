/**
 * 组件数据转换模板
 * 将前端硬编码的 columns/formData 转换为接口所需格式
 */

// 字段类型映射表
const FIELD_TYPE_MAP = {
  'Text': 1, 'CheckBox': 2, 'Select': 3, 'DateTime': 4,
  'Input': 5, 'SelectBox': 6, 'Radio': 7, 'RadioGroup': 8,
  'CheckBoxGroup': 9, 'Switch': 10, 'InputTable': 11,
  'InputNumber': 12, 'Date': 13, 'Time': 14, 'SearchSelect': 15,
  'RangePicker': 16, 'Button': 17, 'UploadFile': 18,
  'SelectTags': 19, 'TextArea': 20, 'AutoComplete': 21,
  'PatSearch': 22, 'UploadImg': 23, 'TreeSelect': 24,
  'TreeSelectCheck': 25, 'CardTitle': 26, 'Divider': 27,
  'MonthPicker': 28, 'WeekPicker': 29, 'InputText': 30
};

/**
 * 转换单个列配置
 * @param {Object} column - 前端列配置
 * @param {Number} index - 列索引
 * @returns {Object} 接口格式的列配置
 */
function convertColumn(column, index) {
  // 过滤无效列
  if (!column.dataIndex || 
      ['operation', 'action', 'edit'].includes(column.dataIndex)) {
    return null;
  }

  // 提取宽度数值
  let width = column.width;
  if (typeof width === 'string') {
    width = parseInt(width.replace('px', ''), 10) || 100;
  }

  return {
    descripts: column.title,
    code: column.dataIndex,
    width: width,
    align: column.align || 'center',
    seqNo: column.key || index + 1,
    type: 'C',
    display: 'Y',
    print: 'Y',
    export: 'Y'
  };
}

/**
 * 转换单个表单字段配置
 * @param {Object} field - 前端表单字段配置
 * @returns {Object} 接口格式的表单字段配置
 */
function convertFormField(field) {
  // 过滤无效字段
  if (!field.dataIndex) {
    return null;
  }

  // 获取字段类型ID
  let fieldTypeID = FIELD_TYPE_MAP[field.typeCode] || 5;
  
  // 特殊字段处理
  if (['queryBtn', 'resetBtn'].includes(field.dataIndex)) {
    fieldTypeID = 17; // Button
  }

  return {
    descripts: field.title,
    code: field.dataIndex,
    fieldTypeID: fieldTypeID,
    col: field.col || 12,
    labelCol: field.labelCol || 8,
    wrapperCol: field.wrapperCol || 16,
    required: field.required || 'N',
    disabled: field.disabled || 'N',
    placeholder: field.placeholder || '',
    default: field.defaultValue || '',
    message: field.doubt || '',
    display: 'Y'
  };
}

/**
 * 转换组件数据
 * @param {Object} componentInfo - 组件信息
 * @param {String} componentInfo.code - 组件代码
 * @param {String} componentInfo.descripts - 组件描述
 * @param {Array} componentInfo.columns - 前端列配置数组
 * @param {Array} componentInfo.formData - 前端表单配置数组
 * @param {Array} componentInfo.queryFormData - 前端查询表单配置数组（可选）
 * @returns {Object} 接口格式的数据
 */
function convertComponentData(componentInfo) {
  const { code, descripts, enDesc, path, columns = [], formData = [], queryFormData = [] } = componentInfo;

  // 转换列配置
  const convertedColumns = columns
    .map((col, index) => convertColumn(col, index))
    .filter(Boolean);

  // 合并表单配置（查询表单 + 弹窗表单）
  const allFormData = [...queryFormData, ...formData];
  const convertedFormData = allFormData
    .map(field => convertFormField(field))
    .filter(Boolean);

  return {
    code,
    descripts,
    enDesc: enDesc || '',
    path: path || '',
    columns: convertedColumns,
    formData: convertedFormData
  };
}

/**
 * 构建接口请求参数
 * @param {Array} components - 组件信息数组
 * @returns {Object} 接口请求参数
 */
function buildRequestParams(components) {
  const componentArr = components.map(convertComponentData);
  return {
    params: [{
      componentArr
    }]
  };
}

// 使用示例
const exampleComponent = {
  code: 'HospitalMaintenance',
  descripts: '医院维护',
  columns: [
    { title: '医院代码', dataIndex: 'hospCode', width: '150px', align: 'center', key: 1 },
    { title: '医院名称', dataIndex: 'hospName', width: 200, align: 'center', key: 2 }
  ],
  queryFormData: [
    { title: '查询', dataIndex: 'queryBtn', typeCode: 'Button' }
  ],
  formData: [
    { title: '医院代码', dataIndex: 'hospCode', typeCode: 'Input', required: 'Y' },
    { title: '医院名称', dataIndex: 'hospName', typeCode: 'Input', required: 'Y' }
  ]
};

const requestParams = buildRequestParams([exampleComponent]);
console.log(JSON.stringify(requestParams, null, 2));

// 导出函数
module.exports = {
  convertColumn,
  convertFormField,
  convertComponentData,
  buildRequestParams,
  FIELD_TYPE_MAP
};
