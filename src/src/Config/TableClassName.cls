Class src.Config.TableClassName Extends (%RegisteredObject, %XML.Adaptor) [ ProcedureBlock ]
{

/// w ##class(src.Config.TableClassName).GetJsonByClassName("User.CBConfigFieldType",1,"Descripts","")
/// w ##class(src.Config.TableClassName).GetJsonByClassName("User.CBNationalDataAttributes","","","","62")
ClassMethod GetJsonByClassName(ClassName As %String, NullFlag As %String, ShowField As %String, ValueField As %String, hospID As %String = "")
{
	s ClassPara=ClassName
	s parentFlag=0
	s nodeStr=""
	s globalName=""
	set hospField=""
	set locField=""
	for{
		set myobj=##class(%Dictionary.CompiledClass).%OpenId(ClassPara)
		set myCount = myobj.Properties.Count()
		set parentname="",parentproprty="",Global=""
		s parentFlag=0
		for i=1:1:myCount {
			set mypropobj=myobj.Properties.GetAt(i)
			set propName=mypropobj.Name
			set dataType=mypropobj.Type
			b ;propName
			if dataType="User.CBHospital"{
				set hospField=propName
			}
#;			if dataType="User.HBLoc"{
#;				set locField=propName	
#;			}
			continue:mypropobj.Cardinality'="parent"
			s parentFlag=1
			set parentproprty=propName
			set parentname=dataType
			s node=^oddCOM(ClassPara,"s","Default",21)
			if node["{%%PARENT}"{
				s node=$p(node,"{%%PARENT}",2)
				s node=$p(node,"(",2,$l(node,"("))
				s node=$p(node,")",1,$l(node,")")-1)
				if nodeStr="" s nodeStr=node
				else  s nodeStr=node_"^"_nodeStr
				s ClassPara=dataType
					
			}else{
				s parentFlag=0
				s globalName=^oddCOM(ClassPara,"s","Default",21)	
			}
			
			
		}	
		if parentFlag=0{
			s globalName=^oddCOM(ClassPara,"s","Default",21)	
		}
		Quit:parentFlag=0
	}
	s id=0
	s resultJson={}
	s dataArr=[]
	if NullFlag=1{
		s itemData={}
		s itemData.ID="0"
		s itemData.Desc="全部"
		s itemData.Alias=""	
		//do dataArr.%Push(itemData)
	}
	s count=0
	s globalName=globalName_"("
	for{
		s id=$o(@(globalName_id_")"))
		
		Quit:id=""	
		continue:$g(@(globalName_id_")"))=""
		if (nodeStr'="")&&($l(nodeStr,"^")>0){
			s ret=..GetData(globalName_id_",",1,nodeStr,id,ClassName,.dataArr,ShowField ,ValueField,hospField,locField)
			
		}else{
			s item=@(globalName_id_")")
			s itemData={}
			s itemData.ID=id
			s Desc="",Alias=""
			s dataObj=$CLASSMETHOD(ClassName,"%OpenId",id)
			s Desc=""
			s Desc=$PROPERTY(dataObj,"Descripts")
			if Desc=""{
				s Desc=$PROPERTY(dataObj,"Code")	
			}
			B ;44443
			if hospField'=""{
				set dataHospID=""
				set dataHospObj=$PROPERTY(dataObj,hospField)
				if dataHospObj'=""{
					set dataHospID=dataHospObj.%Id()	
				}
				continue:(hospID'=dataHospID)
			}else{
				if locField'=""{
					set dataHospObj=$PROPERTY($PROPERTY(dataObj,locField),"HospDr")
					set dataHospID=""
					if dataHospObj'=""{
						set dataHospID=dataHospObj.%Id()
					}
					continue:(hospID'=dataHospID)	
				}
			}
			
			
			s StartDate=""  //$PROPERTY(dataObj,"StartDate")
			s StopDate=""  //$PROPERTY(dataObj,"StopDate")
			set StartDateBbj=##class(%Dictionary.CompiledProperty).%OpenId(ClassName_"||StartDate")
			if (StartDateBbj'=""){
				s StartDate=$PROPERTY(dataObj,"StartDate")	
			}
			set StopDateBbj=##class(%Dictionary.CompiledProperty).%OpenId(ClassName_"||StopDate")
			if (StopDateBbj'=""){
				s StopDate=$PROPERTY(dataObj,"StopDate")	
			}
			continue:(StartDate'="")&&(StartDate>(+$h))
			continue:(StopDate'="")&&(StopDate<(+$h))
			continue:Desc=""
			s count=count+1
			//Quit:count>100
			s Alias=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(Desc)
			s itemData.Desc=Desc
			s itemData.Alias=Alias
			if (ShowField'="")&&(ValueField'=""){
				for i=1:1:$l(ShowField,"^"){
					if $ISOBJECT($PROPERTY(dataObj,$p(ValueField,"^",i))){
					s $PROPERTY(itemData,$p(ShowField,"^",i))=$PROPERTY(dataObj,$p(ValueField,"^",i)).%Id()	
					}else{
						s $PROPERTY(itemData,$p(ShowField,"^",i))=""	
					}	
				}
			}
			do dataArr.%Push(itemData)
			do dataObj.%Close()
		}
	}
	Quit dataArr
}

/// w ##class(src.Config.TableClassName).Getdata("^SSU",1,"""SSUSR""^{SSUSR_RowId}")
ClassMethod GetData(str As %String, index As %String, nodeStr As %String, Rowid As %String, ClassName As %String, ByRef DataArr, ShowField As %String, ValueField As %String, hospField As %String, locField As %String, hospID As %String) [ ProcedureBlock = 0 ]
{
	n (str,index,nodeStr,Rowid,ClassName,DataArr,ShowField , ValueField,hospField,locField,hospID)
	//s dataJson=[]
	s id=0
	for{
		s id=$o(@(str_$p(nodeStr,"^",index)_","_id_")"))
		Quit:id=""	
		if index=$l(nodeStr,"^"){
			s item=@(str_$p(nodeStr,"^",index)_","_id_")")
			s itemData={}
			s itemData.ID=Rowid_"||"_id
			
			s dataObj=$CLASSMETHOD(ClassName,"%OpenId",Rowid_"||"_id)
			s Desc=""
			s Desc=$PROPERTY(dataObj,"Descripts")
			if Desc=""{
				s Desc=$PROPERTY(dataObj,"Code")	
			}
			continue:Desc=""
			if hospField'=""{
				set dataHospID=	$PROPERTY(dataObj,hospField)
				continue:(dataHospID'="")&&(dataHospID'=hospID)
			}else{
				if locField'=""{
					set dataLocID=$PROPERTY(dataObj,locField)	
					if dataLocID'=""{
						set dataLocObj=##class(User.HBLoc).%OpenId(dataLocID)
						if dataLocObj'=""{
							set dataHospID=dataLocObj.HospDr.%Id()
							continue:(dataHospID'="")&&(dataHospID'=hospID)	
						}	
					}
				}	
			}
			s Alias=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(Desc)
			s itemData.Desc=Desc
			s itemData.Alias=Alias
			if (ShowField'="")&&(ValueField'=""){
				for i=1:1:$l(ShowField,"^"){
					if $ISOBJECT($PROPERTY(dataObj,$p(ValueField,"^",i))){
					s $PROPERTY(itemData,$p(ShowField,"^",i))=$PROPERTY(dataObj,$p(ValueField,"^",i)).%Id()	
					}else{
						s $PROPERTY(itemData,$p(ShowField,"^",i))=""	
					}	
				}
			}
			do DataArr.%Push(itemData)
			do dataObj.%Close()
		}else{
			s ret=..GetData(str_$p(nodeStr,"^",index)_","_id_",",index+1,nodeStr,Rowid_"||"_id,ClassName,DataArr,ShowField  ,ValueField,hospField,locField)
			//d dataJson.%Push(retJson)
		}
	}
	Quit 0
}

}
