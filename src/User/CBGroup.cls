/// 角色表
Class User.CBGroup Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_Group ]
{

Parameter %JSONREFERENCE = "ID";

Relationship ChildCBGroupAuthorize As CBGroupAuthorize [ Cardinality = children, Inverse = CBGAParRef ];

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 主界面 
Property MainInterface As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 4, SqlFieldName = MainInterface ];

/// 允许操作系统代码表 Y 允许添加删除系统代码表
Property OperCodeTable As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 5, SqlFieldName = OperCodeTable ];

/// 向所有用户发送消息 Y  允许向所有用户发送消息
Property SendMsgToAllUser As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 6, SqlFieldName = SendMsgToAllUser ];

/// 安全等级 1,2,3
Property SafeClassificat As User.CBDataAuthorityType [ Required, SqlColumnNumber = 7, SqlFieldName = SafeClassificat ];

/// 允许列编辑权限 Y 允许对列进行编辑
Property ColumnEdit As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 8, SqlFieldName = ColumnEdit ];

/// 允许布局权限 
Property LayoutEdit As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 9, SqlFieldName = LayoutEdit ];

/// 默认菜单类型 
Property DefaultMenuType As %String(DISPLAYLIST = ",Head,Side", TRUNCATE = 1, VALUELIST = ",1,2") [ SqlColumnNumber = 10, SqlFieldName = DefaultMenuType ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 11, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 12, SqlFieldName = CreateUser_Dr ];

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 13, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 14, SqlFieldName = StopDate ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 15, SqlFieldName = ENDesc ];

/// 超时时间 单位：分钟
Property OverTime As %Integer [ SqlColumnNumber = 16, SqlFieldName = OverTime ];

Storage Default
{
<Data name="CBGroupDefaultData">
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
<Value>MainInterface</Value>
</Value>
<Value name="5">
<Value>OperCodeTable</Value>
</Value>
<Value name="6">
<Value>SendMsgToAllUser</Value>
</Value>
<Value name="7">
<Value>SafeClassificat</Value>
</Value>
<Value name="8">
<Value>ColumnEdit</Value>
</Value>
<Value name="9">
<Value>LayoutEdit</Value>
</Value>
<Value name="10">
<Value>DefaultMenuType</Value>
</Value>
<Value name="11">
<Value>CreateDate</Value>
</Value>
<Value name="12">
<Value>CreateUserDr</Value>
</Value>
<Value name="13">
<Value>StartDate</Value>
</Value>
<Value name="14">
<Value>StopDate</Value>
</Value>
<Value name="15">
<Value>ENDesc</Value>
</Value>
<Value name="16">
<Value>OverTime</Value>
</Value>
</Data>
<DataLocation>^CBGroupD</DataLocation>
<DefaultData>CBGroupDefaultData</DefaultData>
<ExtentSize>1</ExtentSize>
<IdLocation>^CBGroupD</IdLocation>
<IndexLocation>^CBGroupI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>7</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="ColumnEdit">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="DefaultMenuType">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>8</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="ENDesc">
<AverageFieldSize>7</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="LayoutEdit">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="MainInterface">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="OperCodeTable">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="SafeClassificat">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="SendMsgToAllUser">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="Code">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Desc">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^CBGroupS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
