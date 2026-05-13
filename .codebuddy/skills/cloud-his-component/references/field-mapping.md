# 字段类型映射表

## 完整映射

| ID | Code | 描述 |
|----|------|------|
| 1 | Text | 文本 |
| 2 | CheckBox | 复选框 |
| 3 | Select | 下拉框 |
| 4 | DateTime | 日期时间 |
| 5 | Input | 输入框 |
| 6 | SelectBox | 下拉框* |
| 7 | Radio | 单选 |
| 8 | RadioGroup | Radio组 |
| 9 | CheckBoxGroup | CheckBox组 |
| 10 | Switch | Switch类型 |
| 11 | InputTable | 下拉列表 |
| 12 | InputNumber | 数字框 |
| 13 | Date | 日期选择 |
| 14 | Time | 时间选择 |
| 15 | SearchSelect | 远程搜索 |
| 16 | RangePicker | 日期范围 |
| 17 | Button | 按钮 |
| 18 | UploadFile | 文件上传 |
| 19 | SelectTags | 下拉标签 |
| 20 | TextArea | 文本域 |
| 21 | AutoComplete | 自动完成 |
| 22 | PatSearch | 人员搜索 |
| 23 | UploadImg | 图片上传 |
| 24 | TreeSelect | 树选择 |
| 25 | TreeSelectCheck | 树选择【check多选】 |
| 26 | CardTitle | 卡片标题 |
| 27 | Divider | 分割线 |
| 28 | MonthPicker | 选择月(YYYY-MM) |
| 29 | WeekPicker | 选择周(YYYY-周) |
| 30 | InputText | 输入框(无边框) |

## 映射对象

```javascript
const FIELD_TYPE_MAP = {
  'Text': 1,
  'CheckBox': 2,
  'Select': 3,
  'DateTime': 4,
  'Input': 5,
  'SelectBox': 6,
  'Radio': 7,
  'RadioGroup': 8,
  'CheckBoxGroup': 9,
  'Switch': 10,
  'InputTable': 11,
  'InputNumber': 12,
  'Date': 13,
  'Time': 14,
  'SearchSelect': 15,
  'RangePicker': 16,
  'Button': 17,
  'UploadFile': 18,
  'SelectTags': 19,
  'TextArea': 20,
  'AutoComplete': 21,
  'PatSearch': 22,
  'UploadImg': 23,
  'TreeSelect': 24,
  'TreeSelectCheck': 25,
  'CardTitle': 26,
  'Divider': 27,
  'MonthPicker': 28,
  'WeekPicker': 29,
  'InputText': 30
};
```

## 使用方法

```javascript
function convertTypeCode(typeCode) {
  return FIELD_TYPE_MAP[typeCode] || 5; // 默认为Input(5)
}
```
