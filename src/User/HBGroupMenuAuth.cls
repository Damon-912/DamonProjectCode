/// 医院角色菜单表
Class User.HBGroupMenuAuth Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_GroupMenuAuth ]
{

Parameter %JSONREFERENCE = "ID";

///  指向角色菜单表 CB_GroupMenu
Property GroupMenuDr As User.CBGroupMenu [ Required, SqlColumnNumber = 2, SqlFieldName = GroupMenu_Dr ];

Index GroupMenu On GroupMenuDr;

/// 医院 指向CB_Hospital
Property HospDr As CBHospital [ Required, SqlColumnNumber = 3, SqlFieldName = Hosp_Dr ];

Index Hosp On HospDr;

Index HospMenu On (HospDr, GroupMenuDr) [ Unique ];

/// 创建人 指向 人员表 HB_User
Property CreatedByDr As HBUser [ Required, SqlColumnNumber = 4, SqlFieldName = CreatedBy_Dr ];

/// 创建日期 
Property CreatedDate As %Date [ Required, SqlColumnNumber = 5, SqlFieldName = CreatedDate ];

/// 创建时间 
Property CreatedTime As %Time [ Required, SqlColumnNumber = 6, SqlFieldName = CreatedTime ];

Storage Default
{
<Data name="HBGroupMenuAuthDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>GroupMenuDr</Value>
</Value>
<Value name="3">
<Value>HospDr</Value>
</Value>
<Value name="4">
<Value>CreatedByDr</Value>
</Value>
<Value name="5">
<Value>CreatedDate</Value>
</Value>
<Value name="6">
<Value>CreatedTime</Value>
</Value>
</Data>
<DataLocation>^HBGroupMenuAuthD</DataLocation>
<DefaultData>HBGroupMenuAuthDefaultData</DefaultData>
<ExtentSize>2</ExtentSize>
<IdLocation>^HBGroupMenuAuthD</IdLocation>
<IndexLocation>^HBGroupMenuAuthI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CreatedByDr">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreatedDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreatedTime">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="GroupMenuDr">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="HospDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<SQLMap name="GroupMenu">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Hosp">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="HospMenu">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^HBGroupMenuAuthS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
