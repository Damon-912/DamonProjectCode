/// 角色菜单表
Class User.CBGroupMenu Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_GroupMenu ]
{

Parameter %JSONREFERENCE = "ID";

/// 顺序号 
Property SeqNo As %Integer [ SqlColumnNumber = 2, SqlFieldName = SeqNo ];

/// 角色id 指向角色表
Property GroupDr As CBGroup [ Required, SqlColumnNumber = 3, SqlFieldName = Group_Dr ];

Index Group On GroupDr;

/// 菜单类型 1.头菜单组2.侧菜单组,3.Tab菜单组
Property Type As %String(COLLATION = "UPPER", MAXLEN = 2, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Type ];

Index Type On Type;

/// 菜单id 指向菜单明细表
Property MenuDetailDr As CBMenuDetail [ Required, SqlColumnNumber = 5, SqlFieldName = MenuDetail_Dr ];

Index Menu On MenuDetailDr;

/// 上一级菜单
Property PreGroupMenuDr As CBGroupMenu [ SqlColumnNumber = 6, SqlFieldName = PreGroupMenu_Dr ];

Index PreMenu On PreGroupMenuDr;

/// 安全等级 1,2,3
Property SafeClassificat As User.CBDataAuthorityType [ SqlColumnNumber = 7, SqlFieldName = SafeClassificat ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 8, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 9, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBGroupMenuDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SeqNo</Value>
</Value>
<Value name="3">
<Value>GroupDr</Value>
</Value>
<Value name="4">
<Value>Type</Value>
</Value>
<Value name="5">
<Value>MenuDetailDr</Value>
</Value>
<Value name="6">
<Value>PreGroupMenuDr</Value>
</Value>
<Value name="7">
<Value>SafeClassificat</Value>
</Value>
<Value name="8">
<Value>CreateDate</Value>
</Value>
<Value name="9">
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>^CBGroupMenuD</DataLocation>
<DefaultData>CBGroupMenuDefaultData</DefaultData>
<ExtentSize>24</ExtentSize>
<IdLocation>^CBGroupMenuD</IdLocation>
<IndexLocation>^CBGroupMenuI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>4.75</AverageFieldSize>
<OutlierSelectivity>.833333:158</OutlierSelectivity>
<Selectivity>8.3333%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="GroupDr">
<AverageFieldSize>3.25</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="MenuDetailDr">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>5.8824%</Selectivity>
</Property>
<Property name="PreGroupMenuDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>16.6667%</Selectivity>
</Property>
<Property name="SafeClassificat">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>14.2857%</Selectivity>
</Property>
<Property name="SeqNo">
<AverageFieldSize>2.92</AverageFieldSize>
<Selectivity>16.6667%</Selectivity>
</Property>
<Property name="Type">
<AverageFieldSize>3</AverageFieldSize>
<OutlierSelectivity>.958333:2</OutlierSelectivity>
<Selectivity>4.1667%</Selectivity>
</Property>
<SQLMap name="Group">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Menu">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="PreMenu">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Type">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^CBGroupMenuS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
