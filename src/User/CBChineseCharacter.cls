Class User.CBChineseCharacter Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_ChineseCharacter ]
{

Parameter %JSONREFERENCE = "ID";

/// ASCII码
Property ASCIICode As %String(COLLATION = "Exact", MAXLEN = 10, TRUNCATE = 0) [ SqlColumnNumber = 2, SqlFieldName = ASCIICODE ];

Index ASCII On ASCIICode;

/// 汉字
Property Character As %String(COLLATION = "Exact", MAXLEN = 5, TRUNCATE = 0) [ SqlColumnNumber = 3, SqlFieldName = Character ];

Index Character On Character;

/// 拼音全拼
Property PinyinSpelling As %String(COLLATION = "Exact", MAXLEN = 10, TRUNCATE = 0) [ SqlColumnNumber = 4, SqlFieldName = PinyinSpelling ];

Index PinyinSpelling On PinyinSpelling;

/// 拼音首拼
Property PinyinFirstSpell As %String(COLLATION = "Exact", MAXLEN = 4, TRUNCATE = 0) [ SqlColumnNumber = 5, SqlFieldName = PinyinFirstSpell ];

Index PinyinFirstSpell On PinyinFirstSpell;

/// 四角码
Property FourCornersCode As %String(COLLATION = "Exact", MAXLEN = 10, TRUNCATE = 0) [ SqlColumnNumber = 6, SqlFieldName = FourCornersCode ];

/// 五笔码
Property WuBiCode As %String(COLLATION = "Exact", MAXLEN = 10, TRUNCATE = 0) [ SqlColumnNumber = 7, SqlFieldName = WuBiCode ];

Index WuBiCode On WuBiCode;

/// 郑码
Property ZhengCode As %String(COLLATION = "Exact", MAXLEN = 10, TRUNCATE = 0) [ SqlColumnNumber = 8, SqlFieldName = ZhengCode ];

/// 区位码
Property LocationCode As %String(COLLATION = "Exact", MAXLEN = 10, TRUNCATE = 0) [ SqlColumnNumber = 9, SqlFieldName = LocationCode ];

/// 笔画数
Property StrokesNumber As %String [ SqlColumnNumber = 10, SqlFieldName = StrokesNumber ];

Storage Default
{
<Data name="CBChineseCharacterDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ASCIICode</Value>
</Value>
<Value name="3">
<Value>Character</Value>
</Value>
<Value name="4">
<Value>PinyinSpelling</Value>
</Value>
<Value name="5">
<Value>PinyinFirstSpell</Value>
</Value>
<Value name="6">
<Value>FourCornersCode</Value>
</Value>
<Value name="7">
<Value>WuBiCode</Value>
</Value>
<Value name="8">
<Value>ZhengCode</Value>
</Value>
<Value name="9">
<Value>LocationCode</Value>
</Value>
<Value name="10">
<Value>StrokesNumber</Value>
</Value>
</Data>
<DataLocation>^CBChineseCharacterD</DataLocation>
<DefaultData>CBChineseCharacterDefaultData</DefaultData>
<ExtentSize>20985</ExtentSize>
<IdLocation>^CBChineseCharacterD</IdLocation>
<IndexLocation>^CBChineseCharacterI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>4.56</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="ASCIICode">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>0.0048%</Selectivity>
</Property>
<Property name="Character">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>0.0048%</Selectivity>
</Property>
<Property name="FourCornersCode">
<AverageFieldSize>1.2</AverageFieldSize>
<OutlierSelectivity>.698851:</OutlierSelectivity>
<Selectivity>0.0334%</Selectivity>
</Property>
<Property name="LocationCode">
<AverageFieldSize>1.2</AverageFieldSize>
<OutlierSelectivity>.698851:</OutlierSelectivity>
<Selectivity>0.0048%</Selectivity>
</Property>
<Property name="PinyinFirstSpell">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>4.3478%</Selectivity>
</Property>
<Property name="PinyinSpelling">
<AverageFieldSize>3.15</AverageFieldSize>
<Selectivity>0.3251%</Selectivity>
</Property>
<Property name="StrokesNumber">
<AverageFieldSize>1.79</AverageFieldSize>
<Selectivity>4.3478%</Selectivity>
</Property>
<Property name="WuBiCode">
<AverageFieldSize>3.93</AverageFieldSize>
<Selectivity>0.0059%</Selectivity>
</Property>
<Property name="ZhengCode">
<AverageFieldSize>3.84</AverageFieldSize>
<Selectivity>0.0065%</Selectivity>
</Property>
<SQLMap name="ASCII">
<BlockCount>-164</BlockCount>
</SQLMap>
<SQLMap name="Character">
<BlockCount>-172</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-576</BlockCount>
</SQLMap>
<SQLMap name="PinyinFirstSpell">
<BlockCount>-120</BlockCount>
</SQLMap>
<SQLMap name="PinyinSpelling">
<BlockCount>-116</BlockCount>
</SQLMap>
<SQLMap name="WuBiCode">
<BlockCount>-180</BlockCount>
</SQLMap>
<StreamLocation>^CBChineseCharacterS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
