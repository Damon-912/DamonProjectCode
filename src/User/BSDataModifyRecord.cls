/// 数据修改记录表
Class User.BSDataModifyRecord Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DataModifyRecord ]
{

Parameter %JSONREFERENCE = "ID";

/// 操作类型 "操作说明：I=新增,U=更新,D=删除"
Property OperateType As %String(COLLATION = "UPPER", DISPLAYLIST = ",Insert,Update,Delete", TRUNCATE = 1, VALUELIST = ",Insert,Update,Delete") [ Required, SqlColumnNumber = 2, SqlFieldName = OperateType ];

Index OperType On OperateType;

/// 表名
Property TableName As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = TableName ];

Index TableName On TableName;

/// 表ID
Property DataID As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = DataID ];

/// 更新前数据
Property BeforeData As %String(COLLATION = "UPPER", MAXLEN = 2000, TRUNCATE = 1) [ SqlColumnNumber = 5, SqlFieldName = BeforeData ];

/// 更新后数据
Property AfterData As %String(COLLATION = "UPPER", MAXLEN = 2000, TRUNCATE = 1) [ Required, SqlColumnNumber = 6, SqlFieldName = AfterData ];

/// 更新日期
Property UpdateDate As %Date [ SqlColumnNumber = 7, SqlFieldName = UpdateDate ];

Index UpdateDate On UpdateDate;

/// 更新时间
Property UpdateTime As %Time [ SqlColumnNumber = 8, SqlFieldName = UpdateTime ];

/// 更新人
Property UpdateUserDr As User.HBUser [ SqlColumnNumber = 9, SqlFieldName = UpdateUser_Dr ];

/// IP
Property IP As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 10, SqlFieldName = IP ];

/// 物理地址
Property Mac As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 11, SqlFieldName = Mac ];

/// 备注 更新备注
Property Remark As %String(COLLATION = "UPPER", MAXLEN = 500, TRUNCATE = 1) [ SqlColumnNumber = 12, SqlFieldName = Remark ];

Storage Default
{
<Data name="BSDataModifyRecordDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>OperateType</Value>
</Value>
<Value name="3">
<Value>TableName</Value>
</Value>
<Value name="4">
<Value>DataID</Value>
</Value>
<Value name="5">
<Value>BeforeData</Value>
</Value>
<Value name="6">
<Value>AfterData</Value>
</Value>
<Value name="7">
<Value>UpdateDate</Value>
</Value>
<Value name="8">
<Value>UpdateTime</Value>
</Value>
<Value name="9">
<Value>UpdateUserDr</Value>
</Value>
<Value name="10">
<Value>IP</Value>
</Value>
<Value name="11">
<Value>Mac</Value>
</Value>
<Value name="12">
<Value>Remark</Value>
</Value>
</Data>
<DataLocation>^BSDataModifyRecordD</DataLocation>
<DefaultData>BSDataModifyRecordDefaultData</DefaultData>
<IdLocation>^BSDataModifyRecordD</IdLocation>
<IndexLocation>^BSDataModifyRecordI</IndexLocation>
<StreamLocation>^BSDataModifyRecordS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
