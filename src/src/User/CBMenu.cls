/// 菜单字典表(系统级)
/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 存储系统菜单配置信息
/// 遵从CB表规范
Class User.CBMenu Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_Menu ]
{

/// 代码(菜单唯一编码,主键)
Property Code As %String(MAXLEN = 100) [ Required ];

/// 描述(菜单显示名称)
Property Descripts As %String(MAXLEN = 255) [ Required ];

/// 英文描述
Property ENDescripts As %String(MAXLEN = 255);

/// 开始日期
Property StartDate As %Date [ InitialExpression = {$zdateh($horolog, 5)} ];

/// 结束日期
Property StopDate As %Date;

/// 父菜单编码(顶级为空)
Property ParentCode As %String(MAXLEN = 100);

/// 菜单层级(1=一级,2=二级)
Property MenuLevel As %Integer [ InitialExpression = 1 ];

/// 排序号
Property SortNo As %Integer [ InitialExpression = 1 ];

/// 图标名称
Property Icon As %String(MAXLEN = 100);

/// 路由路径
Property RoutePath As %String(MAXLEN = 200);

/// 是否可见(Y/N)
Property IsVisible As %String(MAXLEN = 1) [ InitialExpression = "Y" ];

/// 是否启用(Y/N)
Property IsActive As %String(MAXLEN = 1) [ InitialExpression = "Y" ];

/// 创建日期
Property CreateDate As %Date [ InitialExpression = {$zdateh($horolog, 5)} ];

/// 创建用户(外键)
Property CreateUserDr As User.HBUser [ SqlColumnNumber = 14 ];

/// 删除标记(0=正常,1=已删除)
Property Deleted As %Integer [ InitialExpression = 0, Required ];

/// 删除时间
Property DeleteTime As %TimeStamp;

/// 主键索引
Index CodeIndex On Code [ PrimaryKey ];

/// 父菜单索引
Index ParentCodeIndex On ParentCode As Exact;

/// 菜单层级索引
Index MenuLevelIndex On MenuLevel As Exact;

/// 创建用户索引
Index CreateUserDrIndex On CreateUserDr As Exact;

/// 删除标记索引
Index DeletedIndex On Deleted As Exact;

/// 排序号索引
Index SortNoIndex On SortNo As Exact;

Storage Default
{
<Data name="CBMenuDefaultData">
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
<Value>ENDescripts</Value>
</Value>
<Value name="5">
<Value>StartDate</Value>
</Value>
<Value name="6">
<Value>StopDate</Value>
</Value>
<Value name="7">
<Value>ParentCode</Value>
</Value>
<Value name="8">
<Value>MenuLevel</Value>
</Value>
<Value name="9">
<Value>SortNo</Value>
</Value>
<Value name="10">
<Value>Icon</Value>
</Value>
<Value name="11">
<Value>RoutePath</Value>
</Value>
<Value name="12">
<Value>IsVisible</Value>
</Value>
<Value name="13">
<Value>IsActive</Value>
</Value>
<Value name="14">
<Value>CreateDate</Value>
</Value>
<Value name="15">
<Value>CreateUserDr</Value>
</Value>
<Value name="16">
<Value>Deleted</Value>
</Value>
<Value name="17">
<Value>DeleteTime</Value>
</Value>
</Data>
<DataLocation>^CBMenuD</DataLocation>
<DefaultData>CBMenuDefaultData</DefaultData>
<IdLocation>^CBMenuD</IdLocation>
<IndexLocation>^CBMenuI</IndexLocation>
<StreamLocation>^CBMenuS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
