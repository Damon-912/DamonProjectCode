/// 菜单关联组件表
Class User.CBMenuDetailComponent Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_MenuDetailComponent ]
{

Parameter %JSONREFERENCE = "ID";

Property MenuDetailDr As User.CBMenuDetail [ SqlColumnNumber = 2, SqlFieldName = MenuDetail_Dr ];

Index MenuDetail On MenuDetailDr;

Property ReactComponentDr As User.CBReactComponent [ SqlColumnNumber = 3, SqlFieldName = ReactComponent_Dr ];

Index ReactComponent On ReactComponentDr;

Index MenuComponent On (MenuDetailDr, ReactComponentDr);

/// 字段代码
Property FieldCode As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = FieldCode ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ SqlColumnNumber = 5, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ SqlColumnNumber = 6, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBMenuDetailComponentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>MenuDetailDr</Value>
</Value>
<Value name="3">
<Value>ReactComponentDr</Value>
</Value>
<Value name="4">
<Value>CreateDate</Value>
</Value>
<Value name="5">
<Value>CreateUserDr</Value>
</Value>
<Value name="6">
<Value>FieldCode</Value>
</Value>
</Data>
<DataLocation>^CBMenuDetailComponentD</DataLocation>
<DefaultData>CBMenuDetailComponentDefaultData</DefaultData>
<ExtentSize>2</ExtentSize>
<IdLocation>^CBMenuDetailComponentD</IdLocation>
<IndexLocation>^CBMenuDetailComponentI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="MenuDetailDr">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ReactComponentDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="MenuComponent">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="MenuDetail">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="ReactComponent">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^CBMenuDetailComponentS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
