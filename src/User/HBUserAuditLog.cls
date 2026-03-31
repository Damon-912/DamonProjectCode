/// 申请记录
Class User.HBUserAuditLog Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_UserAuditLog ]
{

Parameter %JSONREFERENCE = "ID";

/// 登录工号 非空  
Property Code As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ SqlColumnNumber = 2, SqlFieldName = Code ];

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

/// 医院 加索引Code和医院组合索引
Property HospitalDr As CBHospital [ SqlColumnNumber = 15, SqlFieldName = Hospital_Dr ];

Index HospUser On (HospitalDr, Code) [ Unique ];

/// 审核人 指向用户表 HB_User 索引
Property AuditUserDr As HBUser [ SqlColumnNumber = 16, SqlFieldName = AuditUser_Dr ];

/// 审核角色 指向用户表 CB_Group 
Property AuditGroupDr As CBGroup [ SqlColumnNumber = 17, SqlFieldName = AuditGroup_Dr ];

/// 审核状态
Property AuditStatus As %String(DISPLAYLIST = ",Yes,No,Ready", TRUNCATE = 1, VALUELIST = ",Y,N,R") [ Required, SqlColumnNumber = 18, SqlFieldName = AuditStatus ];

/// 审核备注
Property AuditRemarks As %String [ SqlColumnNumber = 19, SqlFieldName = AuditRemarks ];

/// 审核日期 系统自动产生 索引
Property ApplyDate As %Date [ Required, SqlColumnNumber = 20, SqlFieldName = ApplyDate ];

/// 审核时间 系统自动产生 
Property ApplyTime As %Time [ Required, SqlColumnNumber = 21, SqlFieldName = ApplyTime ];

/// 创建人 指向 人员表 HB_User
Property CreatedByDr As HBUser [ SqlColumnNumber = 22, SqlFieldName = CreatedBy_Dr ];

/// 创建日期 
Property CreatedDate As %Date [ Required, SqlColumnNumber = 23, SqlFieldName = CreatedDate ];

/// 创建时间 
Property CreatedTime As %Time [ Required, SqlColumnNumber = 24, SqlFieldName = CreatedTime ];

Storage Default
{
<Data name="HBUserAuditLogDefaultData">
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
<Value>HospitalDr</Value>
</Value>
<Value name="16">
<Value>AuditUserDr</Value>
</Value>
<Value name="17">
<Value>AuditGroupDr</Value>
</Value>
<Value name="18">
<Value>AuditStatus</Value>
</Value>
<Value name="19">
<Value>AuditRemarks</Value>
</Value>
<Value name="20">
<Value>ApplyDate</Value>
</Value>
<Value name="21">
<Value>ApplyTime</Value>
</Value>
<Value name="22">
<Value>CreatedByDr</Value>
</Value>
<Value name="23">
<Value>CreatedDate</Value>
</Value>
<Value name="24">
<Value>CreatedTime</Value>
</Value>
</Data>
<DataLocation>^HBUserAuditLogD</DataLocation>
<DefaultData>HBUserAuditLogDefaultData</DefaultData>
<IdLocation>^HBUserAuditLogD</IdLocation>
<IndexLocation>^HBUserAuditLogI</IndexLocation>
<StreamLocation>^HBUserAuditLogS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
