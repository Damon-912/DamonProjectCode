/// 表定义模板
/// 请根据实际业务需求修改以下内容：
/// 1. 类名：User.{前缀}{业务描述}
/// 2. SqlTableName：与类名相同
/// 3. 必填字段：CB表必须包含所有必填字段
/// 4. 业务字段：根据业务需求添加
Class User.CBSample Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_Sample ]
{

// ======== CB表必填字段（仅CB前缀表需要） ========

/// 表类型
/// SQL表名
/// 代码（主键）
Property Code As %String(MAXLEN = 100) [ Required ];

/// 描述
Property Descripts As %String(MAXLEN = 255) [ Required ];

/// 英文描述
Property ENDescripts As %String(MAXLEN = 255);

/// 开始日期
Property StartDate As %Date [ InitialExpression = {$zdateh($horolog, 5)} ];

/// 结束日期
Property StopDate As %Date;

/// 创建日期
Property CreateDate As %Date [ InitialExpression = {$zdateh($horolog, 5)} ];

/// 创建用户
Property CreateUserDr As User.HBUser [ SqlColumnNumber = 9 ];

// ======== 系统字段 ========

/// 删除标记
/// 0: 正常
/// 1: 已删除
Property Deleted As %Integer [ InitialExpression = 0, Required ];

/// 删除时间
Property DeleteTime As %TimeStamp;

// ======== 业务字段 ========

/// 示例业务字段
Property SampleField As %String(MAXLEN = 255);

/// 示例外键字段
Property SampleDr As User.CBSample;

// ======== 索引定义 ========

/// 主键索引
Index CodeIndex On Code [ PrimaryKey ] ;

/// 创建用户索引
Index CreateUserDrIndex On CreateUserDr As Exact;

/// 删除标记索引
Index DeletedIndex On Deleted As Exact;

/// 示例业务索引
Index SampleFieldIndex On SampleField As Exact;

/// 示例外键索引
Index SampleDrIndex On SampleDr As Exact;

/// 示例组合索引
Index CodeSampleIndex On (Code As Exact, SampleDr As Exact);

Storage Default
{
<Data name="CBSampleDefaultData">
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
<Value>CreateDate</Value>
</Value>
<Value name="8">
<Value>CreateUserDr</Value>
</Value>
<Value name="9">
<Value>Deleted</Value>
</Value>
<Value name="10">
<Value>DeleteTime</Value>
</Value>
<Value name="11">
<Value>SampleField</Value>
</Value>
<Value name="12">
<Value>SampleDr</Value>
</Value>
</Data>
<DataLocation>^CBSampleD</DataLocation>
<DefaultData>CBSampleDefaultData</DefaultData>
<IdLocation>^CBSampleD</IdLocation>
<IndexLocation>^CBSampleI</IndexLocation>
<StreamLocation>^CBSampleS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
