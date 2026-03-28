Import SQLUser

///      Author: TC<br>
///   CreatDate: 2024-05-07<br>
/// Description: 基础字典相关
Class src.BasicData.BasicDictionary Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     TC
/// CreatDate:   2024-05-07
/// Description: 根据类别获取类别下字典数据详情
/// Table:     	 CB_BasicDictionary,CB_BasicDictionarySub 
/// Input:       类别Code
/// Output:      
/// Return:      
/// Others: 
/// Debug：		w ##class(src.BasicData.BasicDictionary).GetDictionaryByType({"type":"ButtonSize"}).%ToJSON()
ClassMethod GetDictionaryByType(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
	new (jsonObj)
	set dataArr=[]
	try
	{
		set type=jsonObj.type
		set language=jsonObj.language
		set ID=$O(^CBBasicDictionaryI("Code",$ZCVT(type,"U"),""))
		if ID=""{
			set resultObj.errorCode="01040111"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040111")	
			quit
		}
		set status=$lg(^CBBasicDictionaryD(ID),6)		
		set DictionaryItem=[]
		set Null=9999
		set subID=""
		for{
			set subID=$O(^CBBasicDictionaryD(ID,"S",subID))
			quit:subID=""
			set data=$g(^CBBasicDictionaryD(ID,"S",subID))
			continue:data=""
			set status=$lg(data,4)
			;continue:status="N"
			set seqNo=$lg(data,9)
			if (seqNo="")||($D(sortData("Basic",seqNo))) set seqNo=Null,Null=Null+1
			set sortData("Basic",seqNo)=ID_"||"_subID
		}
		set defID=""
		set seqNo=""
		for{
			set seqNo=$O(sortData("Basic",seqNo))
			quit:seqNo=""
			set ID=sortData("Basic",seqNo)
			set data=$g(^CBBasicDictionaryD(+ID,"S",$P(ID,"||",2)))
			set itemObj={}
			set descripts=$lg(data,3)
			set enDescripts=$lg(data,11)
			set:(language="EN")&&(enDescripts'="") descripts=enDescripts
			set itemObj.id=ID
			set itemObj.code=$lg(data,2)
			set itemObj.descripts=descripts
			set itemObj.enDescripts=enDescripts
			set itemObj.value=$lg(data,10)
			set itemObj.default=$lg(data,8)
			set itemObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(itemObj.Descripts)
			do dataArr.%Push(itemObj)
		}	
	}catch(e){ 
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="根据类别获取类别下字典数据详情出错:w ##class("_$ClassName()_").GetDictionaryByType("_jsonObj.%ToJSON()_")"	    
	}
	quit dataArr
}

/// Creator:     TC
/// CreatDate:   2024-05-07
/// Description: 取基础字典明细ID
/// Table:     	 CB_BasicDictionary,CB_BasicDictionarySub 
/// Input:        
/// Output:      
/// Return:      
/// Others: 
/// Debug：		w ##class(src.BasicData.BasicDictionary).GetDictionaryID("Fundus","One")
ClassMethod GetDictionaryID(type, subCode)
{
	new (type, subCode)
	quit:(type="")||(subCode="") ""
	set ID=$O(^CBBasicDictionaryI("Code",$ZCVT(type,"U"),""))
	quit:ID="" ""
	set subID=$O(^CBBasicDictionarySubI("Code",$ZCVT(subCode,"U"),ID,""))
	quit ID_"||"_subID
}

/// Creator:     TC
/// CreatDate:   2024-05-07
/// Description: 取基础字典明细描述
/// Table:     	 CB_BasicDictionary,CB_BasicDictionarySub 
/// Input:        
/// Output:      
/// Return:      
/// Others: 
/// Debug：		w ##class(src.BasicData.BasicDictionary).GetDictionaryDesc("Fundus","One")
ClassMethod GetDictionaryDesc(type, subCode)
{
	new (type, subCode)
	set desc=""
	&sql(select Descripts into :desc from SQLUSER.CB_BasicDictionarySub where BD_ParRef->Code=:type and Code=:subCode and Status='Y')
	if SQLCODE'=0 set desc=""
	Quit desc
}

}
