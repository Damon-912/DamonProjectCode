Class User.CBNationalDataElement Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_NationalDataElement ]
{

Parameter %JSONREFERENCE = "ID";

/// 国家标准数据元值域代码
Property Code As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code;

/// 国家标准数据元值域代码名称
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 200, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts;

/// 国家标准数据元值域值
Property Value As %String(MAXLEN = 50) [ Required, SqlColumnNumber = 4, SqlFieldName = Value ];

/// 国家标准数据元值域值含义
Property Definition As %String(COLLATION = "Exact", MAXLEN = 200, TRUNCATE = 1) [ Required, SqlColumnNumber = 5, SqlFieldName = Definition ];

/// 国家标准数据元目录 
Property DataCatalogueDr As %String [ SqlColumnNumber = 6, SqlFieldName = DataCatalogue_Dr ];

/// 备注
Property Remarks As %String(COLLATION = "Exact", MAXLEN = 500, TRUNCATE = 1) [ SqlColumnNumber = 7, SqlFieldName = Remarks ];

/// 国标版本
Property StandardVersion As %String [ SqlColumnNumber = 8, SqlFieldName = StandardVersion ];

/// 生效日期 
Property StartDate As %Date [ Required, SqlColumnNumber = 9, SqlFieldName = StartDate ];

/// 失效日期 
Property StopDate As %Date [ SqlColumnNumber = 10, SqlFieldName = StopDate ];

/// 创建人 指向 人员表 HB_User
Property CreatedUserDr As HBUser [ Required, SqlColumnNumber = 11, SqlFieldName = CreatedUser_Dr ];

/// 创建日期 
Property CreatedDate As %Date [ Required, SqlColumnNumber = 12, SqlFieldName = CreatedDate ];

/// 创建时间 
Property CreatedTime As %Time [ Required, SqlColumnNumber = 13, SqlFieldName = CreatedTime ];

/// 最后修改人 指向 人员表 HB_User
Property UpdateUserDr As HBUser [ Required, SqlColumnNumber = 14, SqlFieldName = UpdateUser_Dr ];

/// 最后修改日期 
Property UpdateDate As %Date [ Required, SqlColumnNumber = 15, SqlFieldName = UpdateDate ];

/// 最后修改时间 
Property UpdateTime As %Time [ Required, SqlColumnNumber = 16, SqlFieldName = UpdateTime ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 17, SqlFieldName = ENDesc ];

/// 内部代码 和元属性的保持一致
Property InternalCode As %String [ SqlColumnNumber = 18, SqlFieldName = InternalCode ];

Storage Default
{
<Data name="CBNationalDataElementDefaultData">
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
<Value>Value</Value>
</Value>
<Value name="5">
<Value>Definition</Value>
</Value>
<Value name="6">
<Value>DataCatalogueDr</Value>
</Value>
<Value name="7">
<Value>Remarks</Value>
</Value>
<Value name="8">
<Value>StandardVersion</Value>
</Value>
<Value name="9">
<Value>StartDate</Value>
</Value>
<Value name="10">
<Value>StopDate</Value>
</Value>
<Value name="11">
<Value>CreatedUserDr</Value>
</Value>
<Value name="12">
<Value>CreatedDate</Value>
</Value>
<Value name="13">
<Value>CreatedTime</Value>
</Value>
<Value name="14">
<Value>UpdateUserDr</Value>
</Value>
<Value name="15">
<Value>UpdateDate</Value>
</Value>
<Value name="16">
<Value>UpdateTime</Value>
</Value>
<Value name="17">
<Value>ENDesc</Value>
</Value>
<Value name="18">
<Value>InternalCode</Value>
</Value>
</Data>
<DataLocation>^User.CBNationalDataElementD</DataLocation>
<DefaultData>CBNationalDataElementDefaultData</DefaultData>
<IdLocation>^User.CBNationalDataElementD</IdLocation>
<IndexLocation>^User.CBNationalDataElementI</IndexLocation>
<StreamLocation>^User.CBNationalDataElementS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
