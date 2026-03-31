# 接口调用规范

> **文档版本：** v1.0.0  
> **创建日期：** 2026-03-06  
> **适用范围：** CloudHIS 项目所有接口调用

---

## 1. 接口调用标准规范

### 1.1 强制要求

```yaml
接口调用方式:
  - ✅ 必须使用: React.$asyncPost(this, code, data)
  - ❌ 禁止使用: $http
  - ❌ 禁止导入: import { $http } from 'containers/config/https'

错误处理:
  - ✅ 必须包裹: try {} catch(error) {}
  - ✅ 必须日志: console.log(error)
  - ✅ 必须提示: message.error('操作失败')
  - ✅ 必须重置: this.setState({ /* 重置状态 */ })

响应数据处理:
  - ✅ 标准格式: res && 'result' in res ? res.result : res
  - ✅ 安全访问: res?.result?.field || []
  - ✅ 表格数据: React.$processingTableRequestData(res)
```

### 1.2 基本调用格式

```javascript
// ❌ 错误示例
import { $http } from 'containers/config/https';

const res = await $http({
    code: '20010008',
    params: [{}],
    session: [this.state.userData]
});

// ✅ 正确示例
getSelectData = async () => {
    try {
        let data = {
            params: [{ hospID: '' }]
        };
        let res = await React.$asyncPost(this, '20010008', data);
        this.setState({ 
            selectData: res && 'result' in res ? res.result : res 
        });
    } catch (error) {
        console.log(error);
        this.setState({ selectData: {} });
    }
}
```

---

## 2. 01040073 接口使用规范

### 2.1 接口用途

`01040073` 接口用于获取组件的表头配置和表单配置。

### 2.2 参数格式

```javascript
let data = {
    params: [{
        type: 'C',                    // 固定值 'C'
        compontName: '组件名称',       // 组件名称
        reactCode: ['组件名称'],      // 组件名称数组
    }]
};
```

### 2.3 完整示例

```javascript
/**
 * 加载组件配置
 */
loadConfig = async () => {
    try {
        let data = {
            params: [{
                type: 'C',
                compontName: 'EventReportManagement',
                reactCode: ['EventReportManagement'],
            }]
        };
        let res = await React.$asyncPost(this, '01040073', data);
        let columns = res?.result?.C || [];          // 表头配置
        let formData = res?.result?.formData || [];   // 表单配置
        this.setState({ columns, formData });
    } catch (error) {
        console.log(error);
        this.setState({ columns: [], formData: [] });
    }
}
```

### 2.4 响应数据结构

```javascript
{
    result: {
        C: [],           // 表头配置数组
        formData: []     // 表单配置数组
    }
}
```

---

## 3. 普通业务接口使用规范

### 3.1 查询列表

```javascript
/**
 * 查询列表数据
 */
getTableData = async (page = 1, pageSize = 10) => {
    try {
        this.setState({ loading: true });
        
        let data = {
            params: [{
                ...queryParams,        // 查询条件
            }],
            pagination: [{
                pageSize,              // 每页条数
                currentPage: page      // 当前页码
            }]
        };
        let res = await React.$asyncPost(this, '20010011', data);
        let tableData = React.$processingTableRequestData(res);
        this.setState({ 
            tableData, 
            total: res?.result?.total || res?.total || 0,
            loading: false 
        });
    } catch (error) {
        console.log(error);
        this.setState({ tableData: [], total: 0, loading: false });
    }
}
```

### 3.2 获取下拉数据

```javascript
/**
 * 获取下拉数据
 */
getSelectData = async () => {
    try {
        let data = {
            params: [{ hospID: '' }]
        };
        let res = await React.$asyncPost(this, categoryData.selectCode, data);
        this.setState({ 
            selectData: res && 'result' in res ? res.result : res 
        }, () => {
            this.handleInit();
        });
    } catch (error) {
        console.log(error);
        this.setState({ selectData: {} });
    }
}
```

### 3.3 新增/编辑/删除操作

```javascript
/**
 * 保存数据
 */
handleSave = async () => {
    try {
        this.setState({ saveLoading: true });
        
        let data = {
            params: [{
                ...formValues        // 表单数据
            }]
        };
        let res = await React.$asyncPost(this, '20010001', data);
        message.success(res?.errorMessage || '操作成功');
        this.handleClose();
        this.props.handleQuery && this.props.handleQuery();
    } catch (error) {
        console.log(error);
        message.error('操作失败');
    } finally {
        this.setState({ saveLoading: false });
    }
}

/**
 * 删除数据
 */
handleDelete = async (record) => {
    try {
        let data = {
            params: [{
                id: record.id
            }]
        };
        let res = await React.$asyncPost(this, '20010004', data);
        message.success(res?.errorMessage || '删除成功');
        this.getTableData();  // 刷新列表
    } catch (error) {
        console.log(error);
        message.error('删除失败');
    }
}
```

---

## 4. 响应数据处理规范

### 4.1 标准响应处理

```javascript
// 方式1: 标准格式
let res = await React.$asyncPost(this, code, data);
let result = res && 'result' in res ? res.result : res;

// 方式2: 安全访问（推荐）
let field = res?.result?.field || [];
let list = res?.result?.list || [];

// 方式3: 表格数据处理
let tableData = React.$processingTableRequestData(res);
```

### 4.2 下拉数据格式规范

```javascript
// ✅ 正确格式
selectData: {
    eventTypeList: [
        { id: '01', descripts: '跌倒/坠床', descriptsSPCode: '跌倒/坠床' },
        { id: '02', descripts: '压疮', descriptsSPCode: '压疮' }
    ]
}

// ❌ 错误格式
selectData: {
    eventTypeList: [
        { value: '01', label: '跌倒/坠床' },  // 错误
        { id: '02', title: '压疮' }            // 错误
    ]
}
```

---

## 5. 错误处理规范

### 5.1 重要说明：公共层已处理错误提示

> **关键点：`$http.post` 已在公共层统一处理错误提示，业务代码 catch 中不需要重复调用 `message.error`！**

查看 `src/containers/config/https.js` 第 104-111 行：

```javascript
if (res.errorCode !== '0') {
    // 公共层已自动调用 message.error 显示错误信息
    formData?.isTips !== 'N' && message.error(res?.errorMessage || res?.summary || '接口请求异常！');
}
```

### 5.2 标准错误处理模式

```javascript
methodName = async () => {
    try {
        // 1. 设置加载状态
        this.setState({ loading: true });

        // 2. 准备请求参数
        let data = {
            params: [{}]
        };

        // 3. 发起请求
        let res = await React.$asyncPost(this, '接口代码', data);

        // 4. 处理响应数据（使用安全访问）
        const result = res?.result || {};
        this.setState({ /* 更新状态 */ });
    } catch (error) {
        // 5. 错误处理
        console.log(error);           // ✅ 记录错误日志
        // ❌ 不要再次调用 message.error，公共层已处理
        this.setState({ /* 重置状态 */ });  // 重置状态避免 UI 异常
    } finally {
        // 6. 清理加载状态
        this.setState({ loading: false });
    }
}
```

### 5.3 错误处理要点

```yaml
必须包含:
  - console.log(error): 记录错误日志
  - this.setState({}): 重置状态避免 UI 异常
  - finally: 清理加载状态（如有 loading）

禁止包含:
  - ❌ message.error(): 公共层已处理，不要重复提示

可选包含:
  - 特定错误码处理
  - 错误上报
```

---

## 6. 常见错误示例对比

### 6.1 错误示例

```javascript
// ❌ 错误1: 使用 $http
import { $http } from 'containers/config/https';
const res = await $http({ code: '20010008', params: [{}] });

// ❌ 错误2: 缺少 try-catch
let res = await React.$asyncPost(this, '20010008', data);
this.setState({ list: res.result });

// ❌ 错误3: 判断 errorCode（公共层已处理）
if (+res.errorCode === 0) {
    this.setState({ list: res.result });
}

// ❌ 错误4: catch 中重复提示（公共层已处理）
try {
    let res = await React.$asyncPost(this, code, data);
} catch (error) {
    console.log(error);
    message.error('操作失败');  // ❌ 公共层已提示，不要重复
}

// ❌ 错误5: 空 catch 块
try {
    let res = await React.$asyncPost(this, code, data);
    this.setState({ list: res.result });
} catch (error) {
    // 空 catch 块
}
```

### 6.2 正确示例

```javascript
// ✅ 正确示例
getSelectData = async () => {
    try {
        let data = {
            params: [{ hospID: '' }]
        };
        let res = await React.$asyncPost(this, '20010008', data);
        // 使用安全访问
        this.setState({ 
            selectData: res?.result || {} 
        });
    } catch (error) {
        console.log(error);
        this.setState({ selectData: {} });
        // 注意：不需要 message.error，公共层已处理
    }
}
```

---

## 7. 特殊场景处理

### 7.1 带分页的列表查询

```javascript
getTableData = async (page = 1, pageSize = 10) => {
    try {
        let data = {
            params: [{ ...queryParams }],
            pagination: [{ pageSize, currentPage: page }]
        };
        let res = await React.$asyncPost(this, '20010011', data);
        let tableData = React.$processingTableRequestData(res);
        let total = res?.result?.total || res?.total || 0;
        this.setState({ tableData, total, loading: false });
    } catch (error) {
        console.log(error);
        this.setState({ tableData: [], total: 0, loading: false });
    }
}
```

### 7.2 批量操作

```javascript
handleBatchOperation = async () => {
    try {
        let data = {
            params: [{
                ids: selectedRowKeys  // 批量 ID 数组
            }]
        };
        let res = await React.$asyncPost(this, '20010005', data);
        message.success(res?.errorMessage || '批量操作成功');
        this.getTableData();
    } catch (error) {
        console.log(error);
        message.error('批量操作失败');
    }
}
```

### 7.3 文件下载

```javascript
handleExport = async () => {
    try {
        let data = {
            params: [{ ...queryParams }]
        };
        await React.$downloadPost(this, '20010006', data);
        message.success('导出成功');
    } catch (error) {
        console.log(error);
        // 注意：不需要 message.error，公共层已处理
    }
}
```

---

## 8. 代码检查清单

### 8.1 接口调用检查项

- [ ] 使用 `React.$asyncPost` 而非 `$http`
- [ ] 无 `$http` 相关导入语句
- [ ] 使用 `try-catch` 包裹异步请求
- [ ] catch 块包含错误日志（`console.log`）
- [ ] 响应数据处理使用安全访问（`res?.result`）
- [ ] 下拉数据格式正确（`{ id, descripts, descriptsSPCode }`）

### 8.2 错误处理检查项

- [ ] 包含 `console.log(error)` 记录日志
- [ ] **不要**在 catch 中调用 `message.error`（公共层已处理）
- [ ] 包含状态重置（`this.setState`）
- [ ] 包含 finally 清理加载状态（如有 loading）

---

## 9. 参考资源

- [公共资源使用指南](./public-resources.md) - 接口工具说明
- [代码示例集合](./code-examples.md) - 完整示例代码
- [代码检查清单](./code-checklist.md) - 质量保证

---

> **文档维护：**  
> 本规范将随着项目发展持续更新。如有疑问或建议，请及时反馈。
