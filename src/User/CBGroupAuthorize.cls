Class User.CBGroupAuthorize Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_GroupAuthorize ]
{

Parameter %JSONREFERENCE = "ID";

///  指向角色表
Relationship CBGAParRef As CBGroup [ Cardinality = parent, Inverse = ChildCBGroupAuthorize, Required, SqlFieldName = CBGA_ParRef ];

/// 权限
Property HosAuthTypeDr As CBHospGroupAuthType [ Required, SqlColumnNumber = 3, SqlFieldName = HosAuthType_Dr ];

/// 权限
Property OPAuthTypeDr As CBOperateAuthType [ Required, SqlColumnNumber = 4, SqlFieldName = OPAuthType_Dr ];

Index HosOPAuth On (CBGAParRef, HosAuthTypeDr, OPAuthTypeDr) [ Unique ];

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 5, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 6, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 7, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 8, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBGroupAuthorizeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>HosAuthTypeDr</Value>
</Value>
<Value name="3">
<Value>OPAuthTypeDr</Value>
</Value>
<Value name="4">
<Value>StartDate</Value>
</Value>
<Value name="5">
<Value>StopDate</Value>
</Value>
<Value name="6">
<Value>CreateDate</Value>
</Value>
<Value name="7">
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>{%%PARENT}("A")</DataLocation>
<DefaultData>CBGroupAuthorizeDefaultData</DefaultData>
<ExtentSize>79</ExtentSize>
<IdLocation>^CBGroupC("A")</IdLocation>
<IndexLocation>^CBGroupAuthorizeI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>6.61</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CBGAParRef">
<AverageFieldSize>2.57</AverageFieldSize>
<Selectivity>4.3478%</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>3.8462%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>1.11</AverageFieldSize>
<OutlierSelectivity>.936709:1</OutlierSelectivity>
<Selectivity>3.1646%</Selectivity>
</Property>
<Property name="HosAuthTypeDr">
<AverageFieldSize>1</AverageFieldSize>
<OutlierSelectivity>.772152:1</OutlierSelectivity>
<Selectivity>7.5949%</Selectivity>
</Property>
<Property name="OPAuthTypeDr">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="StartDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>3.2258%</Selectivity>
</Property>
<Property name="StopDate">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="childsub">
<AverageFieldSize>2.04</AverageFieldSize>
<Selectivity>1.2658%</Selectivity>
</Property>
<SQLMap name="HosOPAuth">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-64</BlockCount>
</SQLMap>
<StreamLocation>^CBGroupAuthorizeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
