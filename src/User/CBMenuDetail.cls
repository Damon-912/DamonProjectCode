Class User.CBMenuDetail Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_MenuDetail ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ SqlColumnNumber = 4, SqlFieldName = ENDesc ];

/// 链接地址 csp名称
Property LinkAddress As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 5, SqlFieldName = LinkAddress ];

/// 菜单路径
Property LinkPath As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 6, SqlFieldName = LinkPath ];

/// 顺序号 
Property SeqNo As %Integer [ SqlColumnNumber = 7, SqlFieldName = SeqNo ];

Index SeqNo On SeqNo;

/// 菜单组标志
Property MenuGroup As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 8, SqlFieldName = MenuGroup ];

/// 图片地址 图片名称
Property Image As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 9, SqlFieldName = Image ];

/// Tab菜单组 
Property MainMenuDr As CBMainMenu [ SqlColumnNumber = 10, SqlFieldName = MainMenu_Dr ];

/// 快捷键 
Property ShortcutKey As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ SqlColumnNumber = 11, SqlFieldName = ShortcutKey ];

/// 弹窗位置 Top:0px;left:0px;width:100px;height:100px,如果为空则不弹窗
Property WinPosition As %String(COLLATION = "UPPER", MAXLEN = 60, TRUNCATE = 1) [ SqlColumnNumber = 12, SqlFieldName = WinPosition ];

/// 执行后台方法 
Property BackMethod As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 13, SqlFieldName = BackMethod ];

/// 参数 
Property Paras As %String(COLLATION = "UPPER", MAXLEN = 5000, TRUNCATE = 1) [ SqlColumnNumber = 14, SqlFieldName = Paras ];

/// 条件表达式 
Property CondExpress As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 15, SqlFieldName = CondExpress ];

/// JS方法 
Property JSMethod As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 16, SqlFieldName = JSMethod ];

/// 提示信息 
Property Tooltip As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 17, SqlFieldName = Tooltip ];

/// 产品分类
Property ProductCatDr As User.CBProductCat [ Required, SqlColumnNumber = 18, SqlFieldName = ProductCat_Dr ];

Index ProductCat On ProductCatDr;

/// 产品模块
Property ProductModuleDr As User.CBProductModule [ Required, SqlColumnNumber = 19, SqlFieldName = ProductModule_Dr ];

Index ProductModule On ProductModuleDr;

/// 更新日期 系统自动产生
Property UpdateDate As %Date [ Required, SqlColumnNumber = 20, SqlFieldName = UpdateDate ];

/// 更新时间 
Property UpdateTime As %Time [ Required, SqlColumnNumber = 21, SqlFieldName = UpdateTime ];

/// 更新人 指向HB_User表
Property UpdateUserDr As HBUser [ Required, SqlColumnNumber = 22, SqlFieldName = UpdateUser_Dr ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property EndDate As %Date [ SqlColumnNumber = 23, SqlFieldName = EndDate ];

Storage Default
{
<Data name="CBMenuDetailDefaultData">
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
<Value>ENDesc</Value>
</Value>
<Value name="5">
<Value>LinkAddress</Value>
</Value>
<Value name="6">
<Value>LinkPath</Value>
</Value>
<Value name="7">
<Value>SeqNo</Value>
</Value>
<Value name="8">
<Value>MenuGroup</Value>
</Value>
<Value name="9">
<Value>Image</Value>
</Value>
<Value name="10">
<Value>MainMenuDr</Value>
</Value>
<Value name="11">
<Value>ShortcutKey</Value>
</Value>
<Value name="12">
<Value>WinPosition</Value>
</Value>
<Value name="13">
<Value>BackMethod</Value>
</Value>
<Value name="14">
<Value>Paras</Value>
</Value>
<Value name="15">
<Value>CondExpress</Value>
</Value>
<Value name="16">
<Value>JSMethod</Value>
</Value>
<Value name="17">
<Value>Tooltip</Value>
</Value>
<Value name="18">
<Value>ProductCatDr</Value>
</Value>
<Value name="19">
<Value>ProductModuleDr</Value>
</Value>
<Value name="20">
<Value>UpdateDate</Value>
</Value>
<Value name="21">
<Value>UpdateTime</Value>
</Value>
<Value name="22">
<Value>UpdateUserDr</Value>
</Value>
<Value name="23">
<Value>EndDate</Value>
</Value>
</Data>
<DataLocation>^CBMenuDetailD</DataLocation>
<DefaultData>CBMenuDetailDefaultData</DefaultData>
<ExtentSize>12</ExtentSize>
<IdLocation>^CBMenuDetailD</IdLocation>
<IndexLocation>^CBMenuDetailI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="BackMethod">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>8.67</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CondExpress">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>10.67</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="ENDesc">
<AverageFieldSize>13.08</AverageFieldSize>
<OutlierSelectivity>.416667:</OutlierSelectivity>
<Selectivity>8.3333%</Selectivity>
</Property>
<Property name="EndDate">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Image">
<AverageFieldSize>3.08</AverageFieldSize>
<OutlierSelectivity>.916667:</OutlierSelectivity>
<Selectivity>8.3333%</Selectivity>
</Property>
<Property name="JSMethod">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="LinkAddress">
<AverageFieldSize>31.75</AverageFieldSize>
<Selectivity>10.0000%</Selectivity>
</Property>
<Property name="LinkPath">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="MainMenuDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="MenuGroup">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="Paras">
<AverageFieldSize>14.83</AverageFieldSize>
<OutlierSelectivity>.833333:</OutlierSelectivity>
<Selectivity>8.3333%</Selectivity>
</Property>
<Property name="ProductCatDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="ProductModuleDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="SeqNo">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ShortcutKey">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Tooltip">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="UpdateDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>12.5000%</Selectivity>
</Property>
<Property name="UpdateTime">
<AverageFieldSize>6.75</AverageFieldSize>
<Selectivity>8.3333%</Selectivity>
</Property>
<Property name="UpdateUserDr">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="WinPosition">
<AverageFieldSize>2</AverageFieldSize>
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
<SQLMap name="SeqNo">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^CBMenuDetailS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
