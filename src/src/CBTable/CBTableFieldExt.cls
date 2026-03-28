Import sqluser

Class src.CBTable.CBTableFieldExt Extends (%RegisteredObject, %XML.Adaptor) [ ProcedureBlock ]
{

ClassMethod GetDataByRefId(paginationStr As %String, paramsStr As %String)
{
	s pagination=##class(%Library.DynamicObject).%FromJSON(paginationStr)
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(paramsStr)
	
	s pageSize=pagination.pageSize
	s currentPage=pagination.currentPage
	s sortColumn=pagination.sortColumn
	s sortOrder=pagination.sortOrder
	s refId=jsonObj.RefId
	if refId=""{
		s resultJson={}
		s resultJson.errorCode="-1"
		s resultJson.errorMessage="主记录id为空"
		Quit resultJson	
	}
	s className=jsonObj.ClassName
	if className=""{
		s resultJson={}
		s resultJson.errorCode="-1"
		s resultJson.errorMessage="类名为空"
		Quit resultJson		
	}
	s tableDataId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if tableDataId=""{
		s resultJson={}
		s resultJson.errorCode="-1"
		s resultJson.errorMessage="类名不存在"
		Quit resultJson		
	}
	k valArr
	s sub=0
	for{
		s sub=$o(^CBTableDataD(tableDataId,"O",sub))	
		Quit:sub=""
		s Code=$lg(^CBTableDataD(tableDataId,"O",sub),2)
		s ColumnFlag=$lg(^CBTableDataD(tableDataId,"O",sub),8)
		continue:ColumnFlag'="Y"
		s DataValue=$lg(^CBTableDataD(tableDataId,"O",sub),5)
		s CompType=$lg(^CBTableDataD(tableDataId,"O",sub),10)
		s DirectTable=$lg(^CBTableDataD(tableDataId,"O",sub),11)
		s DirectDataValue=$lg(^CBTableDataD(tableDataId,"O",sub),13)
		s ShowField=$lg(^CBTableDataD(tableDataId,"O",sub),12)
		s valArr(Code)=DataValue
		s valArr(Code,"Type")=CompType
		s valArr(Code,"DirectTable")=DirectTable
		s valArr(Code,"DirectDataValue")=DirectDataValue
		s valArr(Code,"ShowField")=ShowField
		
	}
	s len=$l(refId,"||")
	s globalStr=""
	
	s globalNode=^oddCOM(className,"s","Default",21)
	if globalNode["{%%PARENT}"{
		s globalStr=$p(globalNode,"{%%PARENT}",2)
		s globalStr=$p(globalStr,"(",2,$l(globalStr,"("))
		s globalStr=$p(globalStr,")",1,$l(globalStr,")")-1)
		s LinkTableId=$lg(^CBTableDataD(tableDataId),12)
		s name=$lg(^CBTableDataD(LinkTableId),2)
		for i=len:1:1{
			s node=^oddCOM(name,"s","Default",21)
			if node["{%%PARENT}"{
				s node=$p(globalNode,"{%%PARENT}",2)
				s node=$p(node,"(",2,$l(node,"("))
				s node=$p(node,")",1,$l(node,")")-1)
				s globalStr=node_","_$p(refId,"||",i)_","_globalStr_","
			}else{
				s globalStr=node_"("_$p(refId,"||",i)_","_globalStr_","
			}
		}
			
	}else{
		s globalStr=globalNode_"("
	}
	s TotalCount=0
	s id=0
	k dataArr
	for{
		s id=$o(@(globalStr_id_")"))
		Quit:id=""	
		s dataJson={}
		s dataJson.ID=refId_"||"_id
		s itemData=@(globalStr_id_")")	
		s Code=""
		for{
			s Code=$o(valArr(Code))
			Quit:Code=""
			s CompType=valArr(Code,"Type")
			if CompType="Date"{
				s val=$lg(itemData,valArr(Code))
				if val'=""{
					s $PROPERTY(dataJson,Code)=$zd(val,3)	
				}else{
					s $PROPERTY(dataJson,Code)=""	
				}
			}elseif CompType="Time"{
				s val=$lg(itemData,valArr(Code))
				if val'=""{
					s $PROPERTY(dataJson,Code)=$zt(val)	
				}else{
					s $PROPERTY(dataJson,Code)=""	
				}
			}elseif CompType="DR"{
				s val=$lg(itemData,valArr(Code))
				s DirectTable=valArr(Code,"DirectTable")
				if (val'="")&&(DirectTable'=""){
					s DataObj=$CLASSMETHOD(DirectTable,"%OpenId",val)
					s ShowField=valArr(Code,"ShowField")
					if DataObj{
						s $PROPERTY(dataJson,Code_"Desc")=$PROPERTY(DataObj,ShowField)		
					}
				}else{
					s $PROPERTY(dataJson,Code)=$lg(itemData,valArr(Code))		
				}
			}else{
				s $PROPERTY(dataJson,Code)=$lg(itemData,valArr(Code))	
			}
		}
		s dataArr(id)=dataJson
		s TotalCount=TotalCount+1
		//do itemDataArr.%Push(dataJson)
	}
	if currentPage="" s currentPage=1
	s count=0
	s id=0
	s itemDataArr=[]
	for{
		s id=$o(dataArr(id))	
		Quit:id=""
		s itemData=dataArr(id)
		s count=count+1
		continue:(+pageSize>0)&&((count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize)))
		do itemDataArr.%Push(itemData)
	}
	
	s result={}
	s resultJson={}
	s result.TotalCount=TotalCount
	s result.Data=itemDataArr
	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	s resultJson.result=result
	Quit resultJson
}

ClassMethod Add(Code As %String)
{
}

ClassMethod SaveDataLink(jsonStr As %String)
{
	///s a={"Code":"01","Descripts":"Admin","ENDesc":"","LinkAddress":"","SeqNo":"","MainMenuDr":"","Type":"1","UpdateUserDr":"1"}
	///s b=##class(src.Group.CBMainMenu).Add(a.%ToJSON())
	set $zt="error"
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s className=jsonObj.ClassName
	s userDr=jsonObj.UserDr
	s itemJson=jsonObj.Item
	s rowid=itemJson.ID
	b ;111
	s refId=itemJson.RefId
	s resultJson={}
	s resultJson.errorCode=0
	s id=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if id=""{
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	s fieldArr=[]
	s TotalCount=0
	s sub=0
	s flag=0
	s itemData={}
	for{
		s sub=$o(^CBTableDataD(id,"O",sub))	
		Quit:sub=""
		s EditFlag=$lg(^CBTableDataD(id,"O",sub),7)
		//continue:EditFlag'="Y"
		s fieldJson={}
		s Code=$lg(^CBTableDataD(id,"O",sub),2)
		s Desc=$lg(^CBTableDataD(id,"O",sub),3) 
		s Type=$lg(^CBTableDataD(id,"O",sub),10) 
		s Required=$g(^oddDEF(className,"a",Code,37))
		
		s fieldVal=$PROPERTY(itemJson,Code)
		s EditFlag=$lg(^CBTableDataD(id,"O",sub),7)
		if (Required=1)&&(EditFlag="Y"){
			if fieldVal=""{
				s resultJson.errorCode="-1"
				s resultJson.errorMessage=Desc_"不能为空"
				Quit 
			}
		}
		if EditFlag'="Y"{
			if (Code["Update")||((rowid="")&&(Code["Create")){
				if Type="Date"{
					s $PROPERTY(itemData,Code)=$zd(+$h,3)	
				}
				if Type="Time"{
					s $PROPERTY(itemData,Code)=$zt($p($h,",",2))	
				}
				if Type="DR"{
					s DirectTable=$lg(^CBTableDataD(id,"O",sub),11) 
					if DirectTable["HBUser"{
						s $PROPERTY(itemData,Code)=userDr	
					}
				}	
			}
		}else{
			if Type="Date"{
				if fieldVal'=""{
					s $PROPERTY(itemData,Code)=fieldVal	
				}else{
					s $PROPERTY(itemData,Code)=""	
				}
			}elseif Type="Time"{
				if fieldVal'=""{
					s $PROPERTY(itemData,Code)=fieldVal	
				}else{
					s $PROPERTY(itemData,Code)=""	
				}
					
			}else{
				s $PROPERTY(itemData,Code)=fieldVal	
			}
		}
	}
	if resultJson.errorCode'=0{
		Quit resultJson
	}
	s itemData.ID=rowid
	if refId'=""{
		s ParentField=##class(src.CBTable.CBTableFieldExt).GetParentField(className)
		b
		if ParentField'=""{
			s $PROPERTY(itemData,ParentField)=refId
		}		
	}
	s json={}
	s json.className=className
	set json.updateUserID=userDr
	s data=[]
	do data.%Push(itemData)
	s json.data=data
	if rowid=""{
		if refId=""{
			s ret=##class(src.util.operatetable).Insert(.json)		
		}else{
			b ;2323
			s ret=##class(src.util.operatetable).Insert(.json)	
		}
		
	}else{
		b ;bb
		s ret=##class(src.util.operatetable).Update(.json)	
	}
	b ;2323
	s retCode=ret.errorCode
	if $p(retCode,"^",1)'=0{
		s errStr=ret.errorMessage
		s errStr=$p(errStr,"#",2)
		s errCode=$p(errStr,":",1)
		s errClassName=$p(errStr,":",3)
		s errClassName=$tr(errClassName," ","")
		s errField=$p(errStr,":",4)
		b
		if errCode="5808"{
			s errFieldDesc=##class(src.CBTable.CBTableData).GetFieldByIndex(className,errField)
			if errFieldDesc'=""{
				s resultJson.errorCode=$p(retCode,"^",1)
				s resultJson.errorMessage=errFieldDesc_"重复"	
				Quit resultJson		
			}
			
		}
		s resultJson.errorCode=ret.errorCode
		s resultJson.errorMessage=ret.errorMessage	
		Quit resultJson
	}	
	s resultJson.errorCode=0
	s resultJson.errorMessage="保存成功"
	Quit resultJson
error
	set resultJson={}
	s resultJson.errorCode=-1
	s resultJson.errorMessage=$ze
	Quit resultJson
}

/// w ##class(src.CBTable.CBTableFieldExt).GetParentField("User.CBEquipFunction")
ClassMethod GetParentField(ClassName As %String)
{
	s myobj=##class(%Dictionary.CompiledClass).%OpenId(ClassName)
	s myCount = myobj.Properties.Count()
	s parentField=""
	s myParList=""
	f i=1:1:myCount {
		s mypropobj=myobj.Properties.GetAt(i)
		s PropertyName=mypropobj.Name
		s dataType=mypropobj.Type
		s Cardinality=mypropobj.Cardinality
		continue:Cardinality'="parent"
		s parentField=mypropobj.Name
		
	}
	Quit parentField
}

/// w ##class(src.CBTable.CBTableFieldExt).GetParentName("User.CBFreqTime")
ClassMethod GetParentName(ClassName As %String)
{
	s myobj=##class(%Dictionary.CompiledClass).%OpenId(ClassName)
	b ;1212
	s myCount = myobj.Properties.Count()
	s parentName=""
	s myParList=""
	f i=1:1:myCount {
		s mypropobj=myobj.Properties.GetAt(i)
		s PropertyName=mypropobj.Name
		s dataType=mypropobj.Type
		s Cardinality=mypropobj.Cardinality
		//w Cardinality,!
		continue:Cardinality'="parent"
		b ;122
		s parentName=dataType
		
	}
	Quit parentName
}

ClassMethod GetItemData(jsonStr As %String)
{
	set $zt="error"
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s ID=jsonObj.ID
	s className=jsonObj.ClassName
	if className=""{
		s resultJson={}
		s resultJson.errorCode="-1"
		s resultJson.errorMessage="类名为空"
		Quit resultJson		
	}
	s tableDataId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if tableDataId=""{
		s resultJson={}
		s resultJson.errorCode="-1"
		s resultJson.errorMessage="类名不存在"
		Quit resultJson		
	}
	k valArr
	s sub=0
	for{
		s sub=$o(^CBTableDataD(tableDataId,"O",sub))	
		Quit:sub=""
		s Code=$lg(^CBTableDataD(tableDataId,"O",sub),2)
		s EditFlag=$lg(^CBTableDataD(tableDataId,"O",sub),7)
		s ReadOnlyFlag=$lg(^CBTableDataD(tableDataId,"O",sub),17)
		continue:(EditFlag'="Y")&&(ReadOnlyFlag'="Y")
		s DataValue=$lg(^CBTableDataD(tableDataId,"O",sub),5)
		s CompType=$lg(^CBTableDataD(tableDataId,"O",sub),10)
		s DirectTable=$lg(^CBTableDataD(tableDataId,"O",sub),11)
		s DirectDataValue=$lg(^CBTableDataD(tableDataId,"O",sub),13)
		s ShowField=$lg(^CBTableDataD(tableDataId,"O",sub),12)
		s valArr(Code)=DataValue
		s valArr(Code,"Type")=CompType
		s valArr(Code,"DirectTable")=DirectTable
		s valArr(Code,"DirectDataValue")=DirectDataValue
		s valArr(Code,"ReadOnlyFlag")=ReadOnlyFlag
		s valArr(Code,"ShowField")=ShowField
	}
	b ;43433
	s dataJson={}
	s dataJson.ID=ID
	s itemObj=$CLASSMETHOD(className,"%OpenId",ID)
	b ;1212
	s Code=""
	for{
		s Code=$o(valArr(Code))
		Quit:Code=""
		s CompType=valArr(Code,"Type")
		s ReadOnlyFlag=valArr(Code,"ReadOnlyFlag")
		if CompType="Date"{
			s val=$PROPERTY(itemObj,Code)
			if val'=""{
				s $PROPERTY(dataJson,Code)=$zd(val,3)	
			}else{
				s $PROPERTY(dataJson,Code)=""	
			}
		}elseif CompType="Time"{
			s val=$PROPERTY(itemObj,Code)
			if val'=""{
				s $PROPERTY(dataJson,Code)=$zt(val)	
			}else{
				s $PROPERTY(dataJson,Code)=""	
			}
		}elseif (CompType="DR"){
			s val=""
			if $PROPERTY(itemObj,Code){
				s val=$PROPERTY(itemObj,Code).%Id()	
			}
			s DirectTable=valArr(Code,"DirectTable")
			if (val'="")&&(DirectTable'=""){
			
				s DataObj=$CLASSMETHOD(DirectTable,"%OpenId",val)
				s ShowField=valArr(Code,"ShowField")
				if (ReadOnlyFlag="Y"){
					if DataObj{
					s $PROPERTY(dataJson,Code)=$PROPERTY(DataObj,ShowField)		
					}else{
						s $PROPERTY(dataJson,Code)=""	
					}		
				}else{
					s $PROPERTY(dataJson,Code)=val
				}
			}else{
				s $PROPERTY(dataJson,Code)=$PROPERTY(itemObj,Code)	
			}	
		}else{
			s $PROPERTY(dataJson,Code)=$PROPERTY(itemObj,Code)
		}
	}
	s resultJson={}
	s resultJson.errorCode="0"
	s resultJson.errorMessage=""
	s resultJson.result=dataJson
	Quit resultJson
error
	set resultObj={}
	set resultObj.errorCode="-1"
	set resultObj.errorMessage=$ze
	Quit resultObj
}

ClassMethod DeleteItemData(jsonStr As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s ID=jsonObj.ID
	s className=jsonObj.ClassName
	set userID=jsonObj.userID
	if ID=""{
		s resultJson={}
		s resultJson.errorCode="-1"
		s resultJson.errorMessage="要删除的数据为空"
		Quit resultJson	
	}
	
	s itemData={}
	s itemData.ID=ID
	s json={}
	s json.className=className
	set json.updateUserID=userID
	s data=[]
	do data.%Push(itemData)
	s json.data=data
	
	s ret=##class(src.util.operatetable).Delete(.json)
	s retCode=ret.errorCode
	if $p(retCode,"^",1)'=0{
		s resultJson={}
		s resultJson.errorCode=ret.errorCode
		s resultJson.errorMessage=ret.errorMessage
		b ;4444
		Quit resultJson
	}
	s resultJson={}
	s resultJson.errorCode="0"
	s resultJson.errorMessage=""
	Quit resultJson
}

/// w ##class(src.CBTable.CBTableFieldExt).GetJsonByClassName("User.CBRoom",1,"Descripts","")
/// w ##class(src.CBTable.CBTableFieldExt).GetJsonByClassName("User.CBNationalDataAttributes","","","","62")
ClassMethod GetJsonByClassName(ClassName As %String, NullFlag As %String, ShowField As %String, ValueField As %String, hospID As %String = "")
{
	s ClassPara=ClassName
	s parentFlag=0
	s nodeStr=""
	s globalName=""
	set hospField=""
	set locField=""
	;set:(ClassName="User.CBNationalDataAttributes") ^Temp("nzs","GetJsonByClassName")=$lb(ClassName,NullFlag,ShowField,ValueField,hospID)
	for{
		set myobj=##class(%Dictionary.CompiledClass).%OpenId(ClassPara)
		set myCount = myobj.Properties.Count()
		set parentname="",parentproprty="",Global=""
		s parentFlag=0
		for i=1:1:myCount {
			set mypropobj=myobj.Properties.GetAt(i)
			set propName=mypropobj.Name
			set dataType=mypropobj.Type
			//b ;propName
			if dataType="User.CBHospital"{
				set:hospField="" hospField=propName
			}
			if dataType="User.HBLoc"{
				set locField=propName	
			}
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
			if (ClassName="User.CBExtSubCat")
			{
				set Desc=dataObj.SubCatDr.Descripts_"("_Desc_")"
			}
			if hospField'=""{
				set dataHospID=""
				set dataHospObj=$PROPERTY(dataObj,hospField)
				if dataHospObj'=""{
					set dataHospID=dataHospObj.%Id()	
				}
				;continue:(hospID'=dataHospID)
				//国标数据显示公共及当前医院配置数据
				continue:(ClassName="User.CBNationalDataAttributes")&&(dataHospID'="")&&(hospID'=dataHospID)
				continue:(ClassName'="User.CBNationalDataAttributes")&&(hospID'=dataHospID)
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
			s Alias=""	;##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(Desc)
			if ClassName="User.CBMedItem"{
				continue:dataObj.SubCatDr.OrderTypeDr.Code="G"
				set Desc=$PROPERTY(dataObj,"Code")_Desc
			}
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
	///添加多点执业 ---zxz 2022.7.13
	if ((ClassName="User.HBUser")&&(hospID'="")){
		set sql="SELECT  User_Dr->Descripts as userDesc, User_Dr,StartDate,StopDate FROM HB_UserLinkHospital WHERE Hospital_Dr="_hospID
		set st=##class(%SQL.Statement).%New(1)
		set sc=st.%Prepare(sql)
		set rs=st.%Execute()
		while rs.%Next(){
			set startDate=rs.%Get("StartDate")
			set stopDate=rs.%Get("StopDate")
			if startDate'=""{
				set startDate=$zdh(startDate,3)
				continue:startDate>$h
			}
			if stopDate'=""{
				set stopDate=$zdh(stopDate,3)
				continue:stopDate<$h
			}
			set itemData={}
			set id=rs.%Get("User_Dr")
			set desc=rs.%Get("userDesc")
			set alias=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(desc)
			set itemData.ID=id
			set itemData.Desc=desc
			set itemData.Alias=alias
			do dataArr.%Push(itemData)
		}
	}

	Quit dataArr
}

/// w ##class(src.util.operatetable).Getdata("^SSU",1,"""SSUSR""^{SSUSR_RowId}")
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

/// w ##class(src.CBTable.CBTableFieldExt).CreateTableDataLink("User.HBUserLogonLoc",1)
ClassMethod CreateTableDataLink(className As %String, userDr As %String)
{
	s id=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if id=""{
		Quit 0
	}
	k directTableArr
	ts
	s sub=0
	s errCode=""
	for{
		s sub=$o(^CBTableDataD(id,"O",sub))	
		Quit:sub=""
		s field=$lg(^CBTableDataD(id,"O",sub),2)
		s compType=$lg(^CBTableDataD(id,"O",sub),10)
		s editFlag=$lg(^CBTableDataD(id,"O",sub),7)
		continue:(compType'="DR")||(editFlag'="Y")
		s directTable=$lg(^CBTableDataD(id,"O",sub),11)
		continue:directTable=""
		s directTableArr(directTable)=id_"||"_sub
		
		s storage=^oddCOM(directTable,59)
		s defaultData=^oddCOM(directTable,"s",storage,22)
		s prop={}
		s index=1
		s relationFieldDr="",relationTableField=""
		s showField=""
		s relationFieldDrStr=""
		s relationTableFieldStr=""
		for{
			s index=$o(^oddCOM(directTable,"s",storage,"D",defaultData,"V",index)) 
			Quit:index=""
			
			s Property=^oddCOM(directTable,"s",storage,"D",defaultData,"V",index,21)
			continue:'$D(^oddDEF(directTable,"a",Property,5))
			s dataType=^oddDEF(directTable,"a",Property,5)
			
			continue:dataType'["User."
			continue:directTable=dataType
			if $d(directTableArr(dataType)){
				s relationFieldDr=directTableArr(dataType)
				if relationFieldDrStr="" s relationFieldDrStr=relationFieldDr
				else  s relationFieldDrStr=relationFieldDrStr_"^"_relationFieldDr 
				
				if relationTableFieldStr="" s relationTableFieldStr=Property
				else  s relationTableFieldStr=relationTableFieldStr_"^"_Property
			}
		}
		if relationFieldDr="" continue
		s itemData={}
		s itemData.ID=id_"||"_sub
		s itemData.RelationFieldDrStr=relationFieldDrStr
		s itemData.RelationTableField=relationTableFieldStr
		s json={}
		s json.className="User.CBTableFieldExt"
		s json.updateUserID=userDr
		s data=[]
		do data.%Push(itemData)
		s json.data=data
		s ret=##class(src.util.operatetable).Update(.json)
		s ret=$p(ret,"!",1)	
		if $p(ret,"^",1)'=0{
			tro
			s errCode=$p(ret,"^",2)	
			Quit 
		}
	}
	if errCode'=""{
		Quit errCode	
	} 
	tc
	Quit 0
}

/// w ##class(src.CBTable.CBTableFieldExt).UpdateTableField("User.HBTarSubType",1)
ClassMethod UpdateTableField(jsonStr As %String)
{
	set $zt="error"
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	set className=jsonObj.className
	///需要更新的字段  DataValue   CompType  DirectTable  ShowField  DirectDataValue  ChangeEditFlag  RequiredFlag  ReadOnlyFlag
	s id=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	
	if id=""{
		Quit 0
	}
	k directTableArr
	ts
	k deleteField
	
	s resultJson={}
	s resultJson.errorCode=0
	
	s storage=^oddCOM(className,59)
	s defaultData=^oddCOM(className,"s",storage,22)
	s prop={}
	s index=1
	set HospitalFlag=""
	for{
		s index=$o(^oddCOM(className,"s",storage,"D",defaultData,"V",index)) 
		Quit:index=""
		s Property=^oddCOM(className,"s",storage,"D",defaultData,"V",index,21)
		if '$d(^oddCOM(className,"a",Property)) continue
		s dataType=^oddDEF(className,"a",Property,5)
		//s fieldObj=##class(User.CBTableFieldExt).%New()
		//do fieldObj.CBTFEParRefSetObjectId(id)
		s sub=$o(^CBTableFieldExtI("Code",id,$ZCVT(Property,"u"),0))
		
		if sub=""{
			set fieldObj = ##class(User.CBTableFieldExt).%New()
			do fieldObj.CBTFEParRefSetObjectId(id)
		}else{
			set fieldObj = ##class(User.CBTableFieldExt).%OpenId(id_"||"_sub)
		}
		if dataType["CBHospital"{
			set HospitalFlag=1
		}
		if sub=""{
			///需要增加的字段 	
			s fieldObj.CBTFEParRef=id
			s fieldObj.Code=Property
			s fieldObj.Descripts=##class(src.CBTable.CBTableData).GetDescriptsByCode(Property)
			s fieldObj.DataValue=index
			s fieldObj.FindFlag="N"
			if ($ZCVT(Property,"U")="CODE")||($ZCVT(Property,"U")="DESCRIPTS"){
				s fieldObj.FindFlag="Y"	
			}
			s fieldObj.EditFlag="Y"
			s fieldObj.ColumnFlag="Y"
			s fieldObj.ColumnWidth="80"
		}else{
			
		}
		s PropObj=##class(%Dictionary.CompiledProperty).%OpenId(className_"||"_Property)
		s Required=PropObj.Required
		s ChangeEditFlag=##class(src.CBTable.CBTableData).GetChangeFlagByCode(Property)
		if ChangeEditFlag'=1{
			s Required=0
			s fieldObj.EditFlag="N"		
		}
		s fieldObj.RequiredFlag=Required
		s fieldObj.ChangeEditFlag=ChangeEditFlag
		s fieldObj.DataValue=index
		s displayList=$g(^oddCOM(className,"a",Property,"P","DISPLAYLIST"))
		s valueList=$g(^oddCOM(className,"a",Property,"P","VALUELIST"))
		s fieldObj.ShowField=""
		s fieldObj.DirectDataValue=""
		s fieldObj.DirectTable=""
		set fieldObj.Collection=$g(^oddDEF(className,"a",Property,27))
		set fieldObj.IndexCode=""
		if dataType'["%"{
			if dataType'["User." set dataType="User."_dataType
			s fieldObj.CompType="DR"
			s fieldObj.DirectTable=dataType
			s str=##class(src.CBTable.CBTableData).GetShowField(dataType)
			set fieldObj.IndexCode=##class(src.CBTable.CBTableFieldExt).GetCodeIndex(dataType)
			if $p(str,",",1)'="^"{
				s descStr=$p(str,",",1)
				s fieldObj.ShowField=$p(descStr,"^",1)
				s fieldObj.DirectDataValue=$p(descStr,"^",2)
			}
			if $p(str,",",2)'="^"{
				s codeStr=$p(str,",",2)	
				s fieldObj.CodeField=$p(codeStr,"^",1)
				s fieldObj.CodeFieldValue=$p(codeStr,"^",2)
			}
			if fieldObj.ShowField'=""{
				set fieldObj.GlobalName=##class(src.CBTable.CBTableFieldExt).GetGlobal(dataType)	
			}
		}elseif dataType["String"{
			s fieldObj.CompType="Text"
			if valueList'=""{
				if valueList["Y,N"{
					s fieldObj.CompType="Radio"	
				}else{
					s fieldObj.CompType="Select"	
				}	
			}	
		}elseif dataType["Date"{
			s fieldObj.CompType="Date"	
		}elseif dataType["Time"{
			s fieldObj.CompType="Time"	
		}elseif dataType["Integer"{
			s fieldObj.CompType="Integer"	
		}else{
			s fieldObj.CompType="Text"		
		}
		
		s sc=fieldObj.%Save()
		if $$$ISERR(sc){
			tro 1
			s RetJson.errorCode="-1"
			s RetJson.errorMessage=$System.Status.GetErrorText(sc)
			Quit
		}
	}
	if resultJson.errorCode'=0{
		tro 1
		Quit resultJson	
	}
	s sub=0
	for{
		s sub=$o(^CBTableDataD(id,"O",sub))
		Quit:sub=""
		s code=$lg(^CBTableDataD(id,"O",sub),2)	
		if '$d(^oddCOM(className,"a",code)){
			s deleteField(id_"||"_sub)=""
		}
	}
	s fieldId=""
	for{
		s fieldId=$o(deleteField(fieldId))
		Quit:fieldId=""
		s dataObj=##class(User.CBTableFieldExt).%OpenId(fieldId)
		s sc=dataObj.%DeleteId(fieldId)
		if $$$ISERR(sc){
			tro 1
			s RetJson.errorCode="-1"
			s RetJson.errorMessage=$System.Status.GetErrorText(sc)
			Quit
		}
	}
	if resultJson.errorCode'=0{
		tro 1
		Quit resultJson	
	}
	set tableObj=##class(User.CBTableData).%OpenId(id)
	set tableObj.HospitalFlag=HospitalFlag
	s sc=tableObj.%Save()
	TCommit
	do ##class(src.CBTable.CBTableFieldExt).CreateTableDataLink(className,1)
	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	Quit resultJson
error
	set resultJson={}
	s resultJson.errorCode="-1"
	s resultJson.errorMessage=$ze
	Quit resultJson
}

ClassMethod GetOperateAuth(jsonStr As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s className=jsonObj.ClassName
	s groupId=jsonObj.Group
	set hospital=jsonObj.hospital
	set dataId=jsonObj.dataId
	
	s tableDataId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if tableDataId=""{
		s resultJson={}
		s resultJson.errorCode="-1"
		s resultJson.errorMessage="类名不存在"
		Quit resultJson		
	}
	s id=$o(^CBGroupLinkTableI("TableGroup",groupId,tableDataId,0))	
	if id=""{
		s resultJson={}
		s resultJson.errorCode="-1"
		s resultJson.errorMessage="没有权限维护该表数据"
		Quit resultJson		
	}
	set dataHospId=""

	set hosptialFlag=""
	s sub=0
	for{
		s sub=$o(^CBTableDataD(tableDataId,"O",sub))	
		Quit:sub=""
		s Code=$lg(^CBTableDataD(tableDataId,"O",sub),2)
		s DirectTable=$lg(^CBTableDataD(tableDataId,"O",sub),11)
		continue:DirectTable'="User.CBHospital"
		set dataObj=$CLASSMETHOD(className,"%OpenId",dataId)
		set dataHospId=$PROPERTY(dataObj,Code)
		set hosptialFlag=1
	}	
	
	set flag=""
	set authSub=0
	set classLinkId=$o(^CBGroupLinkTableI("TableGroup",groupId,tableDataId,0))
	if classLinkId="" Quit ""
	set authStr=""
	for{
		set authSub=$o(^CBGroupLinkTableD(classLinkId,"A",authSub))
		Quit:authSub=""
		set authHospId=$lg(^CBGroupLinkTableD(classLinkId,"A",authSub),2)
		continue:authHospId=""
		set authHospCode=$lg(^CBHospGroupAuthTypeD(authHospId),2)
		set authOPerId=$lg(^CBGroupLinkTableD(classLinkId,"A",authSub),3)
		continue:authOPerId=""
		set authOPerCode=$lg(^CBHospGroupAuthTypeD(authOPerId))
		b ;122
		set hospStr=..GetHospByAuthCode(authHospCode)
		continue:(("^"_hospStr_"^")'[("^"_dataHospId_"^"))&&(hosptialFlag=1)
		set str=""
		if authCode="Add"{
			if str'["Add" set str="Add"
		}
		if authCode="Update"{
			set str="Update"
		}
		if authCode="Delete"{
			set str="Delete"
		}
		if authStr'[str{
			if authStr="" set authStr=str
		else  set authStr=authStr_"^"_str	
		}
		
	}
	set resultJson={}
	set resultJson.errorCode="0"
	set resultJson.errorMessage=""
	set resultJson.authType=authStr
	Quit resultJson
}

ClassMethod GetHospByAuthCode(hospitalId As %String, authCode As %String) [ Private ]
{
	set authHospitalStr=""
	if authCode="LowHosp"{
		set str=""
		set hospId=0
		for{
			set hospId=$o(^CBHospitalI("Hosp",hospitalId,hospId))	
			Quit:hospId=""
			set itemData=$g(^CBHospitalD(hospId))
			continue:itemData=""
			set startDate=$lg(^CBHospitalD(hospId),24)
			set stopDate=$lg(^CBHospitalD(hospId),25)
			continue:(startDate'="")&&(startDate>(+$h))
			continue:(stopDate'="")&&(stopDate<(+$h))
			if str="" set str=hospId
			else  set str=str_"^"_hospId
		}
		Quit str
	}elseif authCode="Hosp"{
		Quit hospitalId	
	}elseif authCode="Public"{
		Quit ""	
	}elseif authCode="ALL"{
		set allHospitalStr=""
		for{
			set hospId=$o(^CBHospitalD(hospId))	
			Quit:hospId=""
			set itemData=$g(^CBHospitalD(hospId))
			continue:itemData=""
			set startDate=$lg(^CBHospitalD(hospId),24)
			set stopDate=$lg(^CBHospitalD(hospId),25)
			continue:(startDate'="")&&(startDate>(+$h))
			continue:(stopDate'="")&&(stopDate<(+$h))
			if allHospitalStr="" set allHospitalStr=hospId
			else  set allHospitalStr=allHospitalStr_"^"_hospId
		}
		Quit allHospitalStr
	}
	Quit ""
}

/// w ##class(src.CBTable.CBTableFieldExt).Test()
ClassMethod Test(Arg1 As %String)
{
	s json={}
	s json.className="User.BSOrderDetail"
	s ret=##class(src.CBTable.CBTableFieldExt).UpdateTableField(json.%ToJSON())
	q ret.%ToJSON()
	
	
	
	
	s json={}
	s json.className="User.HBTarSubType"
	s ret=##class(src.CBTable.CBTableFieldExt).UpdateTableField(json.%ToJSON())
	q ret.%ToJSON()
	
	
	s json={}
	s json.Group="220"
	s json.ClassName="User.CBSex"
	s json.hospital="1"
	s json.dataId=""
	
	s page={}
	//s json={"ClassName": "User.HBOrderCatRecLoc", "ID": "1||4"}
	s ret=##class(src.CBTable.CBTableFieldExt).GetOperateAuth(json.%ToJSON())
	q ret.%ToJSON()
}

/// w ##class(src.CBTable.CBTableFieldExt).Test23()
ClassMethod Test23()
{
	s ClassPara="User.CBSex"
	s parentFlag=0
	s nodeStr=""
	s globalName=""
	for{
		set myobj=##class(%Dictionary.CompiledClass).%OpenId(ClassPara)
		set myCount = myobj.Properties.Count()
		set parentname="",parentproprty="",Global=""
		s parentFlag=0
		for i=1:1:myCount {
			set mypropobj=myobj.Properties.GetAt(i)
			set propName=mypropobj.Name
			set dataType=mypropobj.Type
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
	b ;2323
	quit ""
}

/// w ##class(src.CBTable.CBTableFieldExt).GetGlobal("User.BSWorkModel")
ClassMethod GetGlobal(className As %String)
{
	set ClassPara=className
	k nodeArr
	set count=0
	for{
		set myobj=##class(%Dictionary.CompiledClass).%OpenId(ClassPara)
		set myCount = myobj.Properties.Count()
		set parentname="",parentproprty="",Global=""
		s parentFlag=0
		for i=1:1:myCount {
			set mypropobj=myobj.Properties.GetAt(i)
			set propName=mypropobj.Name
			set dataType=mypropobj.Type
			continue:mypropobj.Cardinality'="parent"
			s parentFlag=1
			set parentproprty=propName
			set parentname=dataType
			s node=^oddCOM(ClassPara,"s","Default",21)
			if node["{%%PARENT}"{
				s node=$p(node,"{%%PARENT}",2)
				s node=$p(node,"(",2,$l(node,"("))
				s node=$p(node,")",1,$l(node,")")-1)
				set count=count+1
				set nodeArr(count)=node
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
	set num=1
	set str=""
	set str=globalName_"(+{id}"
	set id=""
	set num=1
	for{
		set id=$o(nodeArr(id),-1)
		Quit:id=""
		set num=num+1
		set str=str_","_nodeArr(id)_","_"$p({id},""||"","_num_")"
	}
	set str=str_")"
	Quit str
}

/// w ##class(src.CBTable.CBTableFieldExt).CreateGetDataMethod("User.CBMedItem")
ClassMethod CreateGetDataMethod(className As %String)
{
	s tableId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	s sub=0
	set globalName=$lg(^CBTableDataD(tableId),14)
	set shortDesc=$lg(^CBTableDataD(tableId),17)
	s globalName=$Replace(globalName,"{id}",shortDesc_"ID")
	
	set str=""
	set str=str_"ClassMethod Get"_$p(className,".",2)_"Obj("_shortDesc_"ID As %String) As %Library.DynamicObject"_$c(13,10)
	set str=str_"{"_$c(13,10)
	set str=str_"    "_"set obj={}"_$c(13,10)
	set str=str_"    "_"try{"_$c(13,10)
	set str=str_"    "_"    "_"set obj."_shortDesc_"ID="_shortDesc_"ID"_$c(13,10)
	set str=str_"    "_"    "_"s data=$g("_globalName_")"_$c(13,10)
	
	
	for{
		s sub=$o(^CBTableDataD(tableId,"O",sub))	
		Quit:sub=""
		s Code=$lg(^CBTableDataD(tableId,"O",sub),2)
		s ColumnFlag=$lg(^CBTableDataD(tableId,"O",sub),8)
		s DataValue=$lg(^CBTableDataD(tableId,"O",sub),5)
		s CompType=$lg(^CBTableDataD(tableId,"O",sub),10)
		s DirectTable=$lg(^CBTableDataD(tableId,"O",sub),11)
		s DirectDataValue=$lg(^CBTableDataD(tableId,"O",sub),13)
		s ShowField=$lg(^CBTableDataD(tableId,"O",sub),12)
		set CodeFieldValue=$lg(^CBTableDataD(tableId,"O",sub),24)
		s valArr(Code)=DataValue
		s valArr(Code,"Type")=CompType
		s valArr(Code,"DirectTable")=DirectTable
		s valArr(Code,"DirectDataValue")=DirectDataValue
		s valArr(Code,"ShowField")=ShowField
		set ExtGlobalName=$lg(^CBTableDataD(tableId,"O",sub),20)
		//set Code=$ZCVT($e(Code,1,1),"L")_$e(Code,2,$l(Code))
		
		
		//w "s "_Code_"=$lg(data,"_DataValue_")",!
		if (CompType="DR"){
			if (ExtGlobalName'=""){
				set fieldName=$e(Code,1,$l(Code)-2)
				//w "if "_Code_"'="""""_" 
				//w "set obj."_Code_"Desc="_"$lg("_$Replace(ExtGlobalName,"{id}",Code)_","_DirectDataValue_")",!
				set fieldName=shortDesc_fieldName
				
				set str=str_"    "_"    "_"set "_fieldName_"ID=$lg(data,"_DataValue_")"_$c(13,10)
				set str=str_"    "_"    "_"set obj."_fieldName_"ID=$lg(data,"_DataValue_")"_$c(13,10)
				
				if (ShowField'="")||(CodeFieldValue'=""){
					set str=str_"    "_"    "_"if "_fieldName_"ID"_"'=""""{"_$c(13,10)	
					if CodeFieldValue'=""{
						set str=str_"    "_"    "_"    "_"set obj."_fieldName_"Code="_"$lg("_$Replace(ExtGlobalName,"{id}",fieldName_"ID")_","_CodeFieldValue_")"_$c(13,10)	
					}
					if ShowField'=""{
						set str=str_"    "_"    "_"    "_"set obj."_fieldName_"Desc="_"$lg("_$Replace(ExtGlobalName,"{id}",fieldName_"ID")_","_DirectDataValue_")"_$c(13,10)	
					}
					set str=str_"    "_"    "_"}else{"_$c(13,10)
					if CodeFieldValue'=""{
						set str=str_"    "_"    "_"    "_"set obj."_fieldName_"Code="""""_$c(13,10)	
						
					}
					if ShowField'=""{
						set str=str_"    "_"    "_"    "_"set obj."_fieldName_"Desc="""""_$c(13,10)	
							
					}
					set str=str_"    "_"    "_"}"_$c(13,10)
				}
			}
		}else{
			if CompType="Date"{
				set str=str_"    "_"    "_"set "_shortDesc_Code_"=$lg(data,"_DataValue_")"_$c(13,10)
				set str=str_"    "_"    "_"set obj."_shortDesc_Code_"=$zd("_shortDesc_Code_",3)"_$c(13,10)
			}elseif CompType="Time"{
				set str=str_"    "_"    "_"set "_shortDesc_Code_"=$lg(data,"_DataValue_")"_$c(13,10)
				set str=str_"    "_"    "_"set obj."_shortDesc_Code_"=$zt("_shortDesc_Code_")"_$c(13,10)	
			}else{
				set str=str_"    "_"    "_"set obj."_shortDesc_Code_"=$lg(data,"_DataValue_")"_$c(13,10)	
			}
				
		}
	}
	set str=str_"    "_"}catch(e){"_$c(13,10)
	set str=str_"    "_"}"_$c(13,10)
	set str=str_"    "_"Quit obj"_$c(13,10)
	set str=str_"}"
	set resultJson={}
	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	s resultJson.result=str
	Quit resultJson
}

/// d ##class(src.CBTable.CBTableFieldExt).CreateSelectMethod("User.CBSocialStatus")
ClassMethod CreateSelectMethodOld(className As %String)
{
	s tableId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	s sub=0
	set globalName=$lg(^CBTableDataD(tableId),14)
	
	s globalName=$Replace(globalName,"{id}","id")
	
	w "ClassMethod Select"_$p(className,".",2)_"() As %Library.DynamicObject"_$c(13,10)
	w "{"_$c(13,10)
	w "    "_"set dataArr=[]"_$c(13,10)
	w "    "_"try{"_$c(13,10)
	w "    "_"    "_"set id=0"_$c(13,10)
	w "    "_"    "_"for{"_$c(13,10)
	w "    "_"    "_"    "_"set id=$o("_globalName_")"_$c(13,10)
	w "    "_"    "_"    "_"Quit:id="""""_$c(13,10)
	w "    "_"    "_"    "_"set itemData=$g("_globalName_")"_$c(13,10)
	w "    "_"    "_"    "_"continue:itemData="""""_$c(13,10)
	w "    "_"    "_"    "_"set item={}"_$c(13,10)
	w "    "_"    "_"    "_"set item.id=id"_$c(13,10)
	
	set sub=0
	for{
		set sub=$o(^CBTableDataD(tableId,"O",sub))
		Quit:sub=""
		set fieldData=$g(^CBTableDataD(tableId,"O",sub))
		continue:fieldData=""
		set fieldCode=$lg(fieldData,2)
		set fieldIndex=$lg(fieldData,5)
		set fieldType=$lg(fieldData,10)
		set directTable=$lg(fieldData,11)
		continue:directTable="User.HBUser"
		if fieldCode="Code"{
			w "    "_"    "_"    "_"set item.code=$lg(itemData,"_fieldIndex_")"_$c(13,10)	
		}elseif fieldCode="Descripts"{
			w "    "_"    "_"    "_"set item.descripts=$lg(itemData,"_fieldIndex_")"_$c(13,10)	
		}elseif fieldCode="ENDesc"{
			w "    "_"    "_"    "_"set item.enDescripts=$lg(itemData,"_fieldIndex_")"_$c(13,10)		
		}elseif fieldType="DR"{
			set fieldCode=$ZCVT($e(fieldCode,1,1),"L")_$e(fieldCode,2,$l(fieldCode))
			w "    "_"    "_"    "_"set item."_fieldCode_"=$lg(itemData,"_fieldIndex_")"_$c(13,10)
		}
	}
	w "    "_"    "_"    "_"set item.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(item.descripts)"_$c(13,10)
	w "    "_"    "_"    "_"do dataArr.%Push(item)"_$c(13,10)
	w "    "_"    "_"}"_$c(13,10)
	w "    "_"}catch(e){"_$c(13,10)
	w "    "_"}"_$c(13,10)
	w "    "_"Quit dataArr"_$c(13,10)
	w "}"
	
	Quit
}

/// w ##class(src.CBTable.CBTableFieldExt).CreateSelectMethod("User.CBSocialStatus")
ClassMethod CreateSelectMethod(className As %String)
{
	s tableId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	s sub=0
	set globalName=$lg(^CBTableDataD(tableId),14)
	
	s globalName=$Replace(globalName,"{id}","id")
	set str=""
	set str=str_"ClassMethod Select"_$p(className,".",2)_"() As %Library.DynamicObject"_$c(13,10)
	set str=str_"{"_$c(13,10)
	set str=str_"    "_"set dataArr=[]"_$c(13,10)
	set str=str_"    "_"try{"_$c(13,10)
	set str=str_"    "_"    "_"set id=0"_$c(13,10)
	set str=str_"    "_"    "_"for{"_$c(13,10)
	set str=str_"    "_"    "_"    "_"set id=$o("_globalName_")"_$c(13,10)
	set str=str_"    "_"    "_"    "_"Quit:id="""""_$c(13,10)
	set str=str_"    "_"    "_"    "_"set itemData=$g("_globalName_")"_$c(13,10)
	set str=str_"    "_"    "_"    "_"continue:itemData="""""_$c(13,10)
	set str=str_"    "_"    "_"    "_"set item={}"_$c(13,10)
	set str=str_"    "_"    "_"    "_"set item.id=id"_$c(13,10)
	
	set sub=0
	for{
		set sub=$o(^CBTableDataD(tableId,"O",sub))
		Quit:sub=""
		set fieldData=$g(^CBTableDataD(tableId,"O",sub))
		continue:fieldData=""
		set fieldCode=$lg(fieldData,2)
		set fieldIndex=$lg(fieldData,5)
		set fieldType=$lg(fieldData,10)
		set directTable=$lg(fieldData,11)
		continue:directTable="User.HBUser"
		if fieldCode="Code"{
			set str=str_"    "_"    "_"    "_"set item.code=$lg(itemData,"_fieldIndex_")"_$c(13,10)	
		}elseif fieldCode="Descripts"{
			set str=str_"    "_"    "_"    "_"set item.descripts=$lg(itemData,"_fieldIndex_")"_$c(13,10)	
		}elseif fieldCode="ENDesc"{
			set str=str_"    "_"    "_"    "_"set item.enDescripts=$lg(itemData,"_fieldIndex_")"_$c(13,10)		
		}elseif fieldType="DR"{
			set fieldCode=$ZCVT($e(fieldCode,1,1),"L")_$e(fieldCode,2,$l(fieldCode))
			set str=str_"    "_"    "_"    "_"set item."_fieldCode_"=$lg(itemData,"_fieldIndex_")"_$c(13,10)
		}
	}
	set str=str_"    "_"    "_"    "_"set item.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(item.descripts)"_$c(13,10)
	set str=str_"    "_"    "_"    "_"do dataArr.%Push(item)"_$c(13,10)
	set str=str_"    "_"    "_"}"_$c(13,10)
	set str=str_"    "_"}catch(e){"_$c(13,10)
	set str=str_"    "_"}"_$c(13,10)
	set str=str_"    "_"Quit dataArr"_$c(13,10)
	set str=str_"}"
	set resultJson={}
	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	s resultJson.result=str
	Quit resultJson
}

/// w ##class(src.CBTable.CBTableFieldExt).GetCodeIndex("User.BSOrderDetail")
ClassMethod GetCodeIndex(className As %String)
{
	
	set indexGlobalName=$g(^oddDEF(className,"s","Default",25))
	if indexGlobalName="" Quit ""
	set indexCodeStr=""
	set tableIndex=0
	for{
		set tableIndex=$o(^oddDEF(className,"i",tableIndex))
		Quit:tableIndex=""
		if tableIndex="Code"{
			set indexCodeStr=^oddDEF(className,"i",tableIndex,28)
			Quit 
		}	
	}
	if indexCodeStr="" Quit ""
	set tableIndex=indexGlobalName_"("_"""Code"","_indexCodeStr_",0)"
	Quit tableIndex
}

ClassMethod Test20()
{
}

ClassMethod GetIDByCode(fieldID As %String, CodeStr As %String)
{
	set fieldData=$g(^CBTableDataD(+fieldID,"O",$p(fieldID,"||",2)))
	set indexCodeStr=$lg(fieldData,22)
}

/// w ##class(src.CBTable.CBTableFieldExt).GetFieldObj("User.BSPatient")
ClassMethod GetFieldObj(className)
{
	set sql="select Code,Descripts from SQLUSER.CB_TableFieldExt where CBTFE_ParRef->Code=?"
	set sqlObj=##class(%SQL.Statement).%New()
	set sc=sqlObj.%Prepare(sql)
	set rs=sqlObj.%Execute(className)
	set fieldObj={}
	while rs.%Next(){
		set fieldCode=rs.%Get("Code")	
		set fieldDesc=rs.%Get("Descripts")
		set $Property(fieldObj,fieldCode)=fieldDesc
	}
	Quit fieldObj
}

/// 
/// w ##class(src.CBTable.CBTableFieldExt).GetJsonByClassNameNew("User.HBLoc","","","",25)
ClassMethod GetJsonByClassNameNew(ClassName As %String, NullFlag As %String, ShowField As %String, ValueField As %String, hospID As %String)
{
	try{
		//组织查询sql语句
		//1.判断该表里是否有指向医院的字段，指向科室的字段，拼成按医院查询的数据
		set sqlStr="select name as name,SqlFieldName as sqlFieldName,parent->SqlQualifiedNameQ as sqlQualifiedNameQ,Type as dataType from %Dictionary.CompiledProperty where parent=? "
		set sqlObj=##class(%SQL.Statement).%New()
		set sc=sqlObj.%Prepare(sqlStr)
		set list=sqlObj.%Execute(ClassName)
		set hospField=""
		set locField=""
		kill tableProperyArr
		while list.%Next(){
			set name=list.%Get("name")
			set sqlFieldName=list.%Get("sqlFieldName")
			set dataType=list.%Get("dataType")
			if dataType="User.CBHospital"{
				set hospField=sqlFieldName	
			}
			if dataType="User.HBLoc"{
				set locField=sqlFieldName	
			} 
			set sqlTableName=list.%Get("sqlQualifiedNameQ")
			set tableProperyArr(name)=sqlFieldName
		}
		//组织查询字段
		set sqlShowStr="ID as ID"
		if $g(tableProperyArr("Descripts"))'=""{
			set sqlShowStr=sqlShowStr_",Descripts as Descripts"
		}
		if ShowField'=""{
			for i=1:1:$l(ShowField,"^"){
				continue:$g(tableProperyArr($p(ValueField,"^",i)))=""	
				set sqlShowStr=sqlShowStr_","_$g(tableProperyArr($p(ValueField,"^",i)))_" as "_$p(ShowField,"^",i)
			}	
		}
		
		set findSqlStr="select "_sqlShowStr_" from "_sqlTableName_" where 1=1 "
		
		if hospField'=""{
			set findSqlStr=findSqlStr_" and "_hospField_"="_hospID
		}else{
			if locField'=""{
				set findSqlStr=findSqlStr_" and "_locField_"->Hosp_Dr="_hospID
			}	
		}
		if $d(tableProperyArr("StartDate")){
			set findSqlStr=findSqlStr_" and (StartDate is null or StartDate<="_curDate_") and (StopDate is null or StopDate>="_curDate_")"
		}
		set sc=sqlObj.%Prepare(findSqlStr)
		set dataObj=[]
		set list=sqlObj.%Execute()
		while list.%Next(){
			set itemObj={}
			set ID=list.%Get("ID")
			set Desc=list.%Get("Descripts")
			set itemObj.ID=ID
			set itemObj.Desc=Desc
			if ShowField'=""{
				for i=1:1:$l(ShowField,"^"){
					set $Property(itemObj,$p(ShowField,"^",i))=list.%Get($p(ShowField,"^",i))
				}	
			}
			s Alias=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(Desc)
			s itemObj.Alias=Alias
			do dataObj.%Push(itemObj)
		}
	}catch(e){
		
		set status=e.AsStatus()
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    B ;343
		set dataObj=[]
	}
	Quit dataObj
}

/// w ##class(src.CBTable.CBTableFieldExt).test123()
ClassMethod test123()
{
	set sqlStr="select * from SQLUSER.CB_Sex"
	set sqlObj=##class(%SQL.Statement).%New()
	set sc=sqlObj.%Prepare(sqlStr)
	set list=sqlObj.%Execute()
	set hospField=""
	set locField=""
	b ;34
	while list.%Next(){
		set name=list.%Get("name")
	}
}

}
