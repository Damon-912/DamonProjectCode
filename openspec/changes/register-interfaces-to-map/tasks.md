## 1. 准备接口注册数据

- [x] 1.1 确认CB_MapInterface表中02010041-02010046编号未被占用（通过CheckExists方法检查，注册时自动跳过已存在记录）
- [x] 1.2 确认ClassName格式（大写全路径）为 SRC.DRG.BASICDATA.INTERFACE（InterFace类名为src.DRG.BasicData.InterFace，CB_MapInterface的ClassName字段COLLATION=UPPER自动大写）

## 2. 编写并执行注册SQL

- [x] 2.1 编写INSERT SQL，向CB_MapInterface表插入6条接口记录（02010041-02010046），每条记录包含Code/Descripts/ClassName/MethodName/ServiceType/SessionFlag/TokenFlag字段（创建InterfaceRegister.cls脚本类）
- [x] 2.2 执行SQL插入数据到IRIS数据库（需在IRIS终端手动执行: do ##class(src.DRG.BasicData.InterfaceRegister).RegisterAll()）
- [x] 2.3 验证6条记录已成功插入（查询CB_MapInterface表确认）
