Class User.BSSession Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_Session ]
{

Parameter %JSONREFERENCE = "ID";

/// session串
Property SessionStr As %String(COLLATION = "UPPER", MAXLEN = 20) [ SqlColumnNumber = 2, SqlFieldName = SessionStr ];

Index SessionStr On SessionStr;

/// 设备ID 设备类型+名称如  WEB:XX, IPHONE:XX, PAD:XXX
Property DeviceID As %String(COLLATION = "UPPER", MAXLEN = 50) [ SqlColumnNumber = 3, SqlFieldName = DeviceID ];

Index DeviceID On DeviceID;

/// IP
Property IP As %String(COLLATION = "UPPER", MAXLEN = 40) [ SqlColumnNumber = 4, SqlFieldName = IP ];

Index IP On IP;

/// Mac地址
Property Mac As %String(COLLATION = "UPPER", MAXLEN = 50) [ SqlColumnNumber = 5, SqlFieldName = Mac ];

Index Mac On Mac;

/// 登录角色  
Property GroupDr As CBGroup [ SqlColumnNumber = 6, SqlFieldName = Group_Dr ];

Index Group On GroupDr;

/// 登录医院  
Property HospitalDr As CBHospital [ SqlColumnNumber = 7, SqlFieldName = Hospital_Dr ];

Index Hosp On HospitalDr;

/// 登录日期
Property LoginDate As %Date [ SqlColumnNumber = 8, SqlFieldName = LoginDate ];

/// 登录时间
Property LoginTime As %Time [ SqlColumnNumber = 9, SqlFieldName = LoginTime ];

/// 登录人员ID 
Property LoginUserDr As HBUser [ SqlColumnNumber = 10, SqlFieldName = LoginUser_Dr ];

Index LoginUser On LoginUserDr;

/// 超时时间 分钟
Property TimeOut As %Integer [ SqlColumnNumber = 11, SqlFieldName = TimeOut ];

/// 创建日期 
Property CreatedDate As %Date [ Required, SqlColumnNumber = 12, SqlFieldName = CreatedDate ];

/// 创建时间 
Property CreatedTime As %Time [ Required, SqlColumnNumber = 13, SqlFieldName = CreatedTime ];

/// 创建人 指向 
Property CreateUserDr As HBUser [ SqlColumnNumber = 14, SqlFieldName = CreateUser_Dr ];

/// 更新日期 
Property UpdateDate As %Date [ SqlColumnNumber = 15, SqlFieldName = UpdateDate ];

/// 更新时间 
Property UpdateTime As %Time [ SqlColumnNumber = 16, SqlFieldName = UpdateTime ];

/// 更新人员 
Property UpdateUserDr As HBUser [ SqlColumnNumber = 17, SqlFieldName = UpdateUser_Dr ];

/// 是否生效 Y 生效，N 失效 
Property IsActive As %String(COLLATION = "UPPER", DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 18, SqlFieldName = IsActive ];

Storage Default
{
<Data name="BSSessionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SessionStr</Value>
</Value>
<Value name="3">
<Value>DeviceID</Value>
</Value>
<Value name="4">
<Value>IP</Value>
</Value>
<Value name="5">
<Value>Mac</Value>
</Value>
<Value name="6">
<Value>GroupDr</Value>
</Value>
<Value name="7">
<Value>HospitalDr</Value>
</Value>
<Value name="8">
<Value>LoginDate</Value>
</Value>
<Value name="9">
<Value>LoginTime</Value>
</Value>
<Value name="10">
<Value>LoginUserDr</Value>
</Value>
<Value name="11">
<Value>TimeOut</Value>
</Value>
<Value name="12">
<Value>CreatedDate</Value>
</Value>
<Value name="13">
<Value>CreatedTime</Value>
</Value>
<Value name="14">
<Value>CreateUserDr</Value>
</Value>
<Value name="15">
<Value>UpdateDate</Value>
</Value>
<Value name="16">
<Value>UpdateTime</Value>
</Value>
<Value name="17">
<Value>UpdateUserDr</Value>
</Value>
<Value name="18">
<Value>IsActive</Value>
</Value>
</Data>
<DataLocation>^BSSessionD</DataLocation>
<DefaultData>BSSessionDefaultData</DefaultData>
<IdLocation>^BSSessionD</IdLocation>
<IndexLocation>^BSSessionI</IndexLocation>
<StreamLocation>^BSSessionS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
