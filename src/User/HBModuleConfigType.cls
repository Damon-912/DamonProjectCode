Class User.HBModuleConfigType Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_ModuleConfigType ]
{

Parameter %JSONREFERENCE = "ID";

/// 医院
Property HospitalDr As CBHospital [ SqlColumnNumber = 2, SqlFieldName = Hospital_Dr ];

Index Hospital On HospitalDr;

/// 代码 非空  
Property Code As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Code ];

Index Code On Code;

Index HospCode On (HospitalDr, Code) [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 200, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Descripts ];

Index Desc On Descripts;

/// 模块分类
Property ModuleDr As CBProductModule [ Required, SqlColumnNumber = 5, SqlFieldName = Module_Dr ];

Index Module On ModuleDr;

Index HospModule On (HospitalDr, ModuleDr);

/// 字段类型
Property FieldTypeDr As CBConfigFieldType [ Required, SqlColumnNumber = 6, SqlFieldName = FieldType_Dr ];

/// 当字段类型是select  表名
Property SelectUser As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 7, SqlFieldName = SelectUser ];

/// 多选标志
Property MultipleType As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 8, SqlFieldName = MultipleType ];

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 9, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 10, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 11, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 12, SqlFieldName = CreateUser_Dr ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 13, SqlFieldName = ENDesc ];

/// 字段关联
Property ConfigTypeDr As HBModuleConfigType [ SqlColumnNumber = 14, SqlFieldName = ConfigType_Dr ];

Storage Default
{
<Data name="HBModuleConfigTypeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>HospitalDr</Value>
</Value>
<Value name="3">
<Value>Code</Value>
</Value>
<Value name="4">
<Value>Descripts</Value>
</Value>
<Value name="5">
<Value>ModuleDr</Value>
</Value>
<Value name="6">
<Value>FieldTypeDr</Value>
</Value>
<Value name="7">
<Value>SelectUser</Value>
</Value>
<Value name="8">
<Value>MultipleType</Value>
</Value>
<Value name="9">
<Value>StartDate</Value>
</Value>
<Value name="10">
<Value>StopDate</Value>
</Value>
<Value name="11">
<Value>CreateDate</Value>
</Value>
<Value name="12">
<Value>CreateUserDr</Value>
</Value>
<Value name="13">
<Value>ENDesc</Value>
</Value>
<Value name="14">
<Value>ConfigTypeDr</Value>
</Value>
</Data>
<DataLocation>^HBModuleConfigTypeD</DataLocation>
<DefaultData>HBModuleConfigTypeDefaultData</DefaultData>
<IdLocation>^HBModuleConfigTypeD</IdLocation>
<IndexLocation>^HBModuleConfigTypeI</IndexLocation>
<StreamLocation>^HBModuleConfigTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
