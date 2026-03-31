/// 用户
Class User.HBUser Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_User ]
{

Parameter %JSONREFERENCE = "ID";

/// 登录工号 非空  
Property Code As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 姓名 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts;

/// 登陆密码 非空,加密,加密方式
Property Password As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Password ];

/// 性别 指向CB_Sex
Property SexDr As CBSex [ Required, SqlColumnNumber = 5, SqlFieldName = Sex_Dr ];

/// 用户激活 Y/N
Property Active As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 6, SqlFieldName = Active ];

/// 手机号 
Property Mobile As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ SqlColumnNumber = 7, SqlFieldName = Mobile ];

Index Mobile On Mobile [ Unique ];

/// 证件类型 指向 证件类型表 HB_User
Property CredTypeDr As CBCredType [ SqlColumnNumber = 8, SqlFieldName = CredType_Dr ];

/// 证件号
Property CredNo As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ SqlColumnNumber = 9, SqlFieldName = CredNo ];

Index CredType On (CredTypeDr, CredNo);

/// 照片
Property Image As %String(COLLATION = "UPPER", MAXLEN = 300, TRUNCATE = 1) [ SqlColumnNumber = 10, SqlFieldName = Image ];

/// 简介
Property Introduce As %String(COLLATION = "UPPER", MAXLEN = 2000, TRUNCATE = 1) [ SqlColumnNumber = 11, SqlFieldName = Introduce ];

/// 昵称
Property Nickname As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 12, SqlFieldName = Nickname ];

/// 电子邮箱
Property Email As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ SqlColumnNumber = 13, SqlFieldName = Email ];

/// 工作手机
Property WorkMobile As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ SqlColumnNumber = 14, SqlFieldName = WorkMobile ];

/// 生效日期 
Property StartDate As %Date [ Required, SqlColumnNumber = 15, SqlFieldName = StartDate ];

/// 截止日期 
Property StopDate As %Date [ SqlColumnNumber = 16, SqlFieldName = StopDate ];

/// 出生日期 
Property BirthDate As %Date [ Required, SqlColumnNumber = 17, SqlFieldName = BirthDate ];

/// 创建人 指向 人员表 HB_User
Property CreatedByDr As HBUser [ SqlColumnNumber = 18, SqlFieldName = CreatedBy_Dr ];

/// 创建日期 
Property CreatedDate As %Date [ Required, SqlColumnNumber = 19, SqlFieldName = CreatedDate ];

/// 创建时间 
Property CreatedTime As %Time [ Required, SqlColumnNumber = 20, SqlFieldName = CreatedTime ];

Storage Default
{
<Data name="HBUserDefaultData">
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
<Value>Password</Value>
</Value>
<Value name="5">
<Value>SexDr</Value>
</Value>
<Value name="6">
<Value>Active</Value>
</Value>
<Value name="7">
<Value>Mobile</Value>
</Value>
<Value name="8">
<Value>CredTypeDr</Value>
</Value>
<Value name="9">
<Value>CredNo</Value>
</Value>
<Value name="10">
<Value>Image</Value>
</Value>
<Value name="11">
<Value>Introduce</Value>
</Value>
<Value name="12">
<Value>Nickname</Value>
</Value>
<Value name="13">
<Value>Email</Value>
</Value>
<Value name="14">
<Value>WorkMobile</Value>
</Value>
<Value name="15">
<Value>StartDate</Value>
</Value>
<Value name="16">
<Value>StopDate</Value>
</Value>
<Value name="17">
<Value>BirthDate</Value>
</Value>
<Value name="18">
<Value>CreatedByDr</Value>
</Value>
<Value name="19">
<Value>CreatedDate</Value>
</Value>
<Value name="20">
<Value>CreatedTime</Value>
</Value>
</Data>
<DataLocation>^HBUserD</DataLocation>
<DefaultData>HBUserDefaultData</DefaultData>
<ExtentSize>3</ExtentSize>
<IdLocation>^HBUserD</IdLocation>
<IndexLocation>^HBUserI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Active">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>5.33</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CreatedByDr">
<AverageFieldSize>7</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="CreatedDate">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreatedTime">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CredNo">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CredTypeDr">
<AverageFieldSize>13</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>8</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="Email">
<AverageFieldSize>2.33</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="Image">
<AverageFieldSize>14.67</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="Introduce">
<AverageFieldSize>2.33</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="Mobile">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Nickname">
<AverageFieldSize>3.67</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="Password">
<AverageFieldSize>26</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="SexDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="WorkMobile">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<SQLMap name="Code">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="CredType">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Desc">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Mobile">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^HBUserS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
