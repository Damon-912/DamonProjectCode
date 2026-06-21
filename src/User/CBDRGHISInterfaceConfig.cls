/// HIS接口服务配置表
/// 用于管理不同HIS数据类型的接口服务方法配置
Class User.CBDRGHISInterfaceConfig Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_DRGHISInterfaceConfig ]
{

Parameter %JSONREFERENCE = "ID";

/// 接口服务代码（唯一标识）
Property Code As %String(MAXLEN = 100) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

/// 接口服务描述
Property Descripts As %String(MAXLEN = 255) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

/// IRIS类名
Property ClassName As %String(MAXLEN = 255) [ Required, SqlColumnNumber = 4, SqlFieldName = ClassName ];

/// 方法名
Property MethodName As %String(MAXLEN = 255) [ Required, SqlColumnNumber = 5, SqlFieldName = MethodName ];

/// 同步频率类型（daily/weekly/monthly）
Property SyncFrequency As %String(MAXLEN = 20, VALUELIST = ",daily,weekly,monthly") [ Required, SqlColumnNumber = 6, SqlFieldName = SyncFrequency ];

/// 同步时间点（HH:mm格式）
Property SyncTime As %String(MAXLEN = 10) [ Required, SqlColumnNumber = 7, SqlFieldName = SyncTime ];

/// 是否启用（0-停用，1-启用）
Property IsEnabled As %Boolean [ InitialExpression = 0, Required, SqlColumnNumber = 8, SqlFieldName = IsEnabled ];

/// HIS数据类型
Property DataType As %String(MAXLEN = 50, VALUELIST = ",PatientInfo,AdmissionInfo,OrderInfo,ExaminationInfo,FeeInfo,DiagnosisInfo,OperationInfo,Other") [ Required, SqlColumnNumber = 9, SqlFieldName = DataType ];

/// 备注信息
Property Remark As %String(MAXLEN = 500) [ SqlColumnNumber = 10, SqlFieldName = Remark ];

/// 开始日期
Property StartDate As %Date [ SqlColumnNumber = 11, SqlFieldName = StartDate ];

/// 结束日期
Property StopDate As %Date [ SqlColumnNumber = 12, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 13, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 14, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As User.HBUser [ Required, SqlColumnNumber = 15, SqlFieldName = CreateUser_Dr ];

/// 更新日期
Property UpdateDate As %Date [ SqlColumnNumber = 16, SqlFieldName = UpdateDate ];

/// 更新时间
Property UpdateTime As %Time [ SqlColumnNumber = 17, SqlFieldName = UpdateTime ];

/// 逻辑删除标记 0:正常 1:已删除
Property Deleted As %Integer [ InitialExpression = 0, Required, SqlColumnNumber = 18, SqlFieldName = Deleted ];

/// 删除日期
Property DeleteDate As %Date [ SqlColumnNumber = 19, SqlFieldName = DeleteDate ];

/// 删除时间
Property DeleteTime As %Time [ SqlColumnNumber = 20, SqlFieldName = DeleteTime ];

/// 主键索引
Index CodeIndex On Code [ PrimaryKey ];

/// 数据类型索引
Index DataTypeIndex On DataType As Exact;

/// 启用状态索引
Index IsEnabledIndex On IsEnabled As Exact;

/// 删除标记索引
Index DeletedIndex On Deleted As Exact;

/// 同步频率索引
Index SyncFrequencyIndex On SyncFrequency As Exact;

/// 验证字段格式和完整性（使用后置条件语法，比较运算符不能有空格）
ClassMethod Validate(data As %ZEN.proxyObject) As %String
{
    // 验证Code
    Quit:data.Code="" "0^Code不能为空"
    Quit:$Length(data.Code)>100 "0^Code长度不能超过100个字符"
    
    // 验证Descripts
    Quit:data.Descripts="" "0^描述不能为空"
    Quit:$Length(data.Descripts)>255 "0^描述长度不能超过255个字符"
    
    // 验证ClassName
    Quit:data.ClassName="" "0^类名不能为空"
    Quit:$Length(data.ClassName)>255 "0^类名长度不能超过255个字符"
    
    // 验证MethodName
    Quit:data.MethodName="" "0^方法名不能为空"
    Quit:$Length(data.MethodName)>255 "0^方法名长度不能超过255个字符"
    
    // 验证SyncFrequency
    Quit:data.SyncFrequency="" "0^同步频率不能为空"
    Quit:(",daily,weekly,monthly,"'[$Find(",daily,weekly,monthly,", ","_data.SyncFrequency_",")) "0^同步频率必须是daily、weekly或monthly"
    
    // 验证SyncTime格式（HH:mm）
    Quit:data.SyncTime="" "0^同步时间不能为空"
    Quit:($Length(data.SyncTime)'=5)||($Extract(data.SyncTime,3,3)'=":") "0^同步时间格式错误，请使用HH:mm格式"
    Quit:($Piece(data.SyncTime,":",1)<0)||($Piece(data.SyncTime,":",1)>23) "0^小时必须在0-23之间"
    Quit:($Piece(data.SyncTime,":",2)<0)||($Piece(data.SyncTime,":",2)>59) "0^分钟必须在0-59之间"
    
    // 验证DataType
    Quit:data.DataType="" "0^数据类型不能为空"
    Quit:(",PatientInfo,AdmissionInfo,OrderInfo,ExaminationInfo,FeeInfo,DiagnosisInfo,OperationInfo,Other,"'[$Find(",PatientInfo,AdmissionInfo,OrderInfo,ExaminationInfo,FeeInfo,DiagnosisInfo,OperationInfo,Other,", ","_data.DataType_",")) "0^数据类型无效"
    
    // 验证IsEnabled
    Quit:($Get(data.IsEnabled)'=0)&&($Get(data.IsEnabled)'=1) "0^启用状态必须是0或1"
    
    // 验证Code唯一性（排除当前编辑的对象）
    Set tID = $Get(data.ID)
    Set tRS = ##class(%ResultSet).%New()
    Do tRS.Prepare("SELECT ID FROM CB_DRGHISInterfaceConfig WHERE Code=? AND Deleted=0")
    Do tRS.Execute(data.Code)
    If tRS.Next() {
        Set tExistID = tRS.GetData(1)
        Quit:(tExistID'=tID) "0^接口服务代码已存在"
    }
    
    Quit "1^验证通过"
}

/// 根据Code获取配置
ClassMethod GetByCode(code As %String) As User.CBDRGHISInterfaceConfig
{
    Set tRS = ##class(%ResultSet).%New()
    Do tRS.Prepare("SELECT ID FROM CB_DRGHISInterfaceConfig WHERE Code=? AND Deleted=0")
    Do tRS.Execute(code)
    If tRS.Next() {
        Set tID = tRS.GetData(1)
        Quit ##class(User.CBDRGHISInterfaceConfig).%OpenId(tID)
    }
    Quit ""
}

/// 获取所有配置列表
ClassMethod GetAllConfigs() As %ListOfObjects
{
    Set tList = ##class(%ListOfObjects).%New()
    Set tRS = ##class(%ResultSet).%New()
    Do tRS.Prepare("SELECT ID FROM CB_DRGHISInterfaceConfig WHERE Deleted=0 ORDER BY Code")
    Do tRS.Execute()
    While tRS.Next() {
        Set tID = tRS.GetData(1)
        Set tObj = ##class(User.CBDRGHISInterfaceConfig).%OpenId(tID)
        If $IsObject(tObj) {
            Do tList.Insert(tObj)
        }
    }
    Quit tList
}

Storage Default
{
<Data name="CBDRGHISInterfaceConfigDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Code</Value>
</Value>
<Value name="3">
<Value>Descripts</Value>
</Value>
<Value name="4">
<Value>ClassName</Value>
</Value>
<Value name="5">
<Value>MethodName</Value>
</Value>
<Value name="6">
<Value>SyncFrequency</Value>
</Value>
<Value name="7">
<Value>SyncTime</Value>
</Value>
<Value name="8">
<Value>IsEnabled</Value>
</Value>
<Value name="9">
<Value>DataType</Value>
</Value>
<Value name="10">
<Value>Remark</Value>
</Value>
<Value name="11">
<Value>StartDate</Value>
</Value>
<Value name="12">
<Value>StopDate</Value>
</Value>
<Value name="13">
<Value>CreateDate</Value>
</Value>
<Value name="14">
<Value>CreateTime</Value>
</Value>
<Value name="15">
<Value>CreateUserDr</Value>
</Value>
<Value name="16">
<Value>UpdateDate</Value>
</Value>
<Value name="17">
<Value>UpdateTime</Value>
</Value>
<Value name="18">
<Value>Deleted</Value>
</Value>
<Value name="19">
<Value>DeleteDate</Value>
</Value>
<Value name="20">
<Value>DeleteTime</Value>
</Value>
</Data>
<DataLocation>^CB.DRGHISInterfaceConfigD</DataLocation>
<DefaultData>CBDRGHISInterfaceConfigDefaultData</DefaultData>
<IdLocation>^CB.DRGHISInterfaceConfigD</IdLocation>
<IndexLocation>^CB.DRGHISInterfaceConfigI</IndexLocation>
<StreamLocation>^CB.DRGHISInterfaceConfigS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
