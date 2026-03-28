Class src.CBTable.CBTableData Extends (%RegisteredObject, %XML.Adaptor) [ ProcedureBlock ]
{

Parameter NewParameter1 = 2323;

/// w ##class(src.CBTable.CBTableData).Add("")
ClassMethod Add(jsonStr As %String)
{
	set $zt="error"
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s resultJson={}
	s ID=jsonObj.ID
	s Code=jsonObj.Code
	s Descripts=jsonObj.Descripts
	s Notes=jsonObj.Notes
	s StartDate=jsonObj.StartDate
	s StopDate=jsonObj.StopDate
	s Notes=jsonObj.Notes		
	s SafeClassificat=jsonObj.SafeClassificat
	s ColNum=jsonObj.ColNum
	s CreateUserDr=jsonObj.CreateUserDr
	set ProductModuleDr=jsonObj.ProductModuleDr
	set HospitalFlag=jsonObj.HospitalFlag
	set FrequeUse=jsonObj.FrequeUse
	set ShortDesc=jsonObj.ShortDesc
	b ;121211
	s ParentName=##class(src.CBTable.CBTableFieldExt).GetParentName(Code)
	b ;3333
	s TableDataRef=""
	if ParentName'=""{
		s TableDataRef=$o(^CBTableDataI("Code",$ZCVT(ParentName,"U"),0))	
	}
	if ID=""{
		s tableId=$o(^CBTableDataI("Code",$ZCVT(Code,"U"),0))	
		if tableId'=""{
			s resultJson={}
			s resultJson.errorCode="-1"
			s resultJson.errorMessage="表名已存在"
			Quit resultJson		
		}
	}
	if StartDate'=""{
		s StartDate=$zdh(StartDate,3)	
	}else{
		s StartDate=+$h	
	}
	if StopDate'=""{
		s StopDate=$zdh(StopDate,3)	
	}
	if '$d(^oddCOM(Code)){
		s resultJson.errorCode="-1"
		s resultJson.errorMessage="表名不存在"
		Quit resultJson	
	}
	set GlobalName=##class(src.CBTable.CBTableFieldExt).GetGlobal(Code)
	TS
	if ID=""{
		s obj=##class(User.CBTableData).%New()
		s obj.Code=Code
		s obj.Descripts=Descripts
		s obj.Notes=Notes
		s obj.StartDate=StartDate
		s obj.StopDate=StopDate
		s obj.SafeClassificat=SafeClassificat
		s obj.ColNum=ColNum
		set obj.GlobalName=GlobalName
		set obj.HospitalFlag=""
		set obj.FrequeUse=FrequeUse
		set obj.ShortDesc=ShortDesc
		
		s classStr=$p(Code,".",2)
		if $e(classStr,1,2)="BS"{
			set obj.EditFlag="N"
		}else{
			set obj.EditFlag="Y"	
		}
		
		//
		if TableDataRef'=""{
			do obj.TableDataRefSetObjectId(TableDataRef)	
		}
		if ProductModuleDr'=""{
			do obj.ProductModuleDrSetObjectId(ProductModuleDr)		
		}
		do obj.CreateUserDrSetObjectId(CreateUserDr)
		
		s sc=obj.%Save()
		s RetJson={}
		s RetJson.errorCode=0
		if $$$ISERR(sc){
			tro
			s resultJson.errorCode="-1"
			s resultJson.errorMessage=$System.Status.GetErrorText(sc)
			
			Quit resultJson
		}
	}else{
		s obj=##class(User.CBTableData).%OpenId(ID)
		//s obj.Code=Code
		s obj.Descripts=Descripts
		s obj.Notes=Notes
		s obj.StartDate=StartDate
		s obj.StopDate=StopDate
		s obj.SafeClassificat=SafeClassificat
		s obj.ColNum=ColNum
		set obj.GlobalName=GlobalName
		if TableDataRef'=""{
			do obj.TableDataRefSetObjectId(TableDataRef)	
		}
		if ProductModuleDr'=""{
			do obj.ProductModuleDrSetObjectId(ProductModuleDr)		
		}else{
			set obj.ProductModuleDr=""	
		}
		set obj.HospitalFlag=""
		set obj.FrequeUse=FrequeUse
		set obj.ShortDesc=ShortDesc
		s sc=obj.%Save()
		s RetJson={}
		s RetJson.errorCode=0
		if $$$ISERR(sc){
			tro
			s resultJson.errorCode="-1"
			s resultJson.errorMessage=$System.Status.GetErrorText(sc)
			Quit resultJson
		}else{
			TC
			s resultJson.errorCode="0"
			s resultJson.errorMessage=""
			
			Quit resultJson	
		}	
	}
	s id=obj.%Id()
	
	s storage=^oddCOM(Code,59)
	s defaultData=^oddCOM(Code,"s",storage,22)
	s prop={}
	set HospitalFlag=""
	s index=1
	for{
		s index=$o(^oddCOM(Code,"s",storage,"D",defaultData,"V",index)) 
		Quit:index=""
		s Property=^oddCOM(Code,"s",storage,"D",defaultData,"V",index,21)
		s dataType=^oddDEF(Code,"a",Property,5)
		s fieldObj=##class(User.CBTableFieldExt).%New()
		do fieldObj.CBTFEParRefSetObjectId(id)
		s fieldObj.Code=Property
		s fieldObj.Descripts=##class(src.CBTable.CBTableData).GetDescriptsByCode(Property)
		s fieldObj.DataValue=index
		s fieldObj.FindFlag="N"
		if ($ZCVT(Property,"U")="CODE")||($ZCVT(Property,"U")="DESCRIPTS"){
			s fieldObj.FindFlag="Y"	
		}
		s fieldObj.EditFlag="Y"
		s fieldObj.ColumnFlag="Y"
		s fieldObj.ColumnWidth=""
		s fieldObj.CompType="" 
		s fieldObj.DirectTable=""
		
		
		set Required=$g(^oddDEF(Code,"a",Property,37))
		s ChangeEditFlag=##class(src.CBTable.CBTableData).GetChangeFlagByCode(Property)
		if ChangeEditFlag'=1{
			s Required=0
			s fieldObj.EditFlag="N"		
		}
		//必填项
		s fieldObj.RequiredFlag=Required   
		s fieldObj.ChangeEditFlag=ChangeEditFlag
		
		s displayList=$g(^oddCOM(Code,"a",Property,"P","DISPLAYLIST"))
		s valueList=$g(^oddCOM(Code,"a",Property,"P","VALUELIST"))
		if dataType'["%"{
			if dataType'["User." set dataType="User."_dataType
			s fieldObj.CompType="DR"
			s fieldObj.DirectTable=dataType
			if dataType="User.CBHospital"{
				set HospitalFlag=1	
			}
			s str=##class(src.CBTable.CBTableData).GetShowField(dataType)
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
			tro
			s RetJson.errorCode="-1"
			s RetJson.errorMessage=$System.Status.GetErrorText(sc)
			Quit
		}
		
	}
	if RetJson.errorCode'=0{
		tro
		Quit RetJson	
	}
	set obj.HospitalFlag=HospitalFlag
	do obj.%Save()
	tc
	do ##class(src.CBTable.CBTableFieldExt).CreateTableDataLink(Code,CreateUserDr)
	
	s RetJson={}
	s RetJson.errorCode=0
	s RetJson.errorMessage=""
	Quit RetJson
error
	s RetJson={}
	s RetJson.errorCode=-1
	s RetJson.errorMessage=$ze
	Quit RetJson
}

/// w ##class(src.CBTable.CBTableData).GetDescriptsByCode("LocDr")
ClassMethod GetDescriptsByCode(Code As %String)
{
	s Desc=""
	if Code="Code"{
		s Desc="代码"
	}elseif Code="Descripts"{
		s Desc="描述"
	}elseif Code["Hospital"{
		s Desc="医院"
	}elseif Code="StartDate"{
		s Desc="开始日期"
	}elseif Code="StopDate"{
		s Desc="失效日期"
	}elseif Code="CreateDate"{
		s Desc="创建日期"
	}elseif Code="CreateTime"{
		s Desc="创建时间"
	}elseif Code="CreateUserDr"{
		s Desc="创建人员"
	}elseif Code="UpdateDate"{
		s Desc="更新日期"
	}elseif Code="UpdateTime"{
		s Desc="更新日期"
	}elseif Code="UpdateUserDr"{
		s Desc="更新人员"
	}elseif Code="SeqNo"{
		s Desc="序号"
	}elseif Code="ENDesc"{
		s Desc="英文描述"
	}
	if Desc=""{
		s id=0
		for{
			s id=$o(^CBTableFieldExtI("Code",id))
			Quit:id=""
			s sub=0
			for{
				s sub=$o(^CBTableFieldExtI("Code",id,$ZCVT(Code,"U"),sub))
				Quit:sub=""
				s desc=$lg(^CBTableDataD(id,"O",sub),3)
				if desc'="" {
					s Desc=desc
					Quit
				}
			}
			if Desc'="" Quit 
		}	
	}
	if Desc="" s Desc=Code
	Quit Desc
}

/// w ##class(src.CBTable.CBTableData).GetChangeFlagByCode(1)
ClassMethod GetChangeFlagByCode(Code As %String)
{
	s Flag=1
	if Code="CreateDate"{
		s Flag=0
	}elseif Code="CreateTime"{
		s Flag=0
	}elseif Code="CreateUserDr"{
		s Flag=0
	}elseif Code="UpdateDate"{
		s Flag=0
	}elseif Code="UpdateTime"{
		s Flag=0
	}elseif Code="UpdateUserDr"{
		s Flag=0
	}
	Quit Flag
}

/// w ##class(src.CBTable.CBTableData).InsertField(1)
ClassMethod InsertField(id As %String)
{
	s Code="User.CBMenuDetail"
	s storage=^oddCOM(Code,59)
	s defaultData=^oddCOM(Code,"s",storage,22)
	s prop={}
	s index=1
	for{
		s index=$o(^oddCOM(Code,"s",storage,"D",defaultData,"V",index)) 
		Quit:index=""
		s Property=^oddCOM(Code,"s",storage,"D",defaultData,"V",index,21)
		s dataType=^oddCOM(Code,"a",Property,5)
		s fieldObj=##class(User.CBTableFieldExt).%New()
		do fieldObj.CBTFEParRefSetObjectId(id)
		//s fieldObj.CBTFEParRef=id
		s fieldObj.Code=Property
		s fieldObj.Descripts=Property
		s fieldObj.DataValue=index
		s fieldObj.FindFlag="Y"
		s fieldObj.EditFlag="Y"
		s fieldObj.ColumnFlag="Y"
		s fieldObj.ColumnWidth=""
		s fieldObj.CompType="" 
		s fieldObj.DirectTable=""
		
		if dataType["User."{
			s fieldObj.CompType="DR"
			s fieldObj.DirectTable=dataType
			
		}elseif dataType["String"{
			s fieldObj.CompType="Text"	
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
		b ;432323
	}
	s RetJson={}
	s RetJson.errorCode=0
	s RetJson.errorMessage=""
	Quit RetJson
}

/// w ##class(src.CBTable.CBTableData).GetFindField({"ClassName":"User.HBLoc","groupId":"","hospitalId":""}.%ToJSON()).%ToJSON()
ClassMethod GetFindField(jsonStr As %String, session As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s session=##class(%Library.DynamicObject).%FromJSON(session)
	s className=jsonObj.ClassName
	set groupId=jsonObj.groupId
	set hospitalId=jsonObj.hospitalId
	set hospID=session.hospID
	s resultJson={}
	s id=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if id=""{
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	s fieldArr=[]
	s TotalCount=0
	s DataAvialFlag=0
	s sub=0
	for{
		s sub=$o(^CBTableDataD(id,"O",sub))	
		Quit:sub=""
		s Code=$lg(^CBTableDataD(id,"O",sub),2)
		if Code="StartDate"{
			s DataAvialFlag=1	
		}
		s FindFlag=$lg(^CBTableDataD(id,"O",sub),6)
		continue:FindFlag'="Y"
		s fieldJson={}
		s fieldJson.Code=$lg(^CBTableDataD(id,"O",sub),2)
		s fieldJson.Desc=$lg(^CBTableDataD(id,"O",sub),3)
		s RelationFieldDr= $lg(^CBTableDataD(id,"O",sub),18)
		s RelationTableField=$lg(^CBTableDataD(id,"O",sub),19)
		set remoteSearch=$lg(^CBTableDataD(id,"O",sub),26)
		s ShowField=""
		if RelationFieldDr'=""{
			s ShowField=$lg(^CBTableDataD(+RelationFieldDr,"O",$p(RelationFieldDr,"||",2)),2)
		}
		s CompType=$lg(^CBTableDataD(id,"O",sub),10)
		s fieldJson.Type=CompType
		set fieldJson.remoteSearch=remoteSearch
		s fieldData=[]
		if CompType="DR"{
			s DirectTable=$lg(^CBTableDataD(id,"O",sub),11)
			b ;4545
			if (DirectTable="User.CBHospital")&&(hospID'=""){
				set hospStr=##class(src.CBTable.CBTableData).GetHosptialAuth(groupId,hospID,className)
				if hospStr="" set hospStr=hospID
				if hospStr'=""{
					for i=1:1:$l(hospStr,"^"){
						set hospId=$p(hospStr,"^",i)
						continue:hospId=""
						s hospObj=$CLASSMETHOD("User.CBHospital","%OpenId",hospId)
						
						s Desc=$PROPERTY(hospObj,"Descripts")
						if Desc=""{
							s Desc=$PROPERTY(hospObj,"Code")	
						}
			
						s StartDate=$PROPERTY(hospObj,"StartDate")
						s StopDate=$PROPERTY(hospObj,"StopDate")
						
						continue:(StartDate'="")&&(StartDate>(+$h))
						continue:(StopDate'="")&&(StopDate<(+$h))
						continue:Desc=""
						set itemData={}
						s Alias=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(Desc)
						s itemData.ID=hospId
						s itemData.Desc=Desc
						s itemData.Alias=Alias
						if (ShowField'="")&&(ValueField'=""){
							for i=1:1:$l(ShowField,"^"){
								if $ISOBJECT($PROPERTY(hospObj,$p(ValueField,"^",i))){
									s $PROPERTY(itemData,$p(ShowField,"^",i))=$PROPERTY(hospObj,$p(ValueField,"^",i)).%Id()	
								}else{
									s $PROPERTY(itemData,$p(ShowField,"^",i))=""	
								}	
							}
						}
						do fieldData.%Push(itemData)
					}
					
				}else{
						
				}
			}else{
				s dataJson=##class(src.CBTable.CBTableFieldExt).GetJsonByClassName(DirectTable,1,ShowField,RelationTableField,hospID)
				s fieldData=dataJson		
			}
			/*s DirectDataValue=$lg(^CBTableDataD(id,"O",sub),13)	
			s globalName=^oddCOM(DirectTable,"s","Default",24) 
			s dataId=0
			s dataJson={}
			s dataJson.ID="0"
			s dataJson.Desc="空"
			do fieldData.%Push(dataJson)
			for{
				s dataId=$o(@(globalName_"("_dataId_")"))
				Quit:dataId=""	
				s itemData=@(globalName_"("_dataId_")")
				s ShowValue=$lg(itemData,DirectDataValue)
				s dataJson={}
				s dataJson.ID=dataId
				s dataJson.Desc=ShowValue
				do fieldData.%Push(dataJson)
			}*/	
		}
		s fieldJson.Data=fieldData
		do fieldArr.%Push(fieldJson)
		s TotalCount=TotalCount+1
	}
	if (TotalCount>0)&&(DataAvialFlag=1){
		s fieldJson={}
		s fieldJson.Code="DataAvail"
		s fieldJson.Desc="DataAvail"
		s fieldJson.Type=""
		do fieldArr.%Push(fieldJson)
		s TotalCount=TotalCount+1
	}
	s fieldObj={}
	s fieldObj.TotalCount=TotalCount
	s fieldObj.Data=fieldArr
	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	s resultJson.result=fieldObj
	Quit resultJson
}

ClassMethod GetColumnField(jsonStr As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s className=jsonObj.ClassName
	s resultJson={}
	s id=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if id=""{
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	s FieldSort=$lg(^CBTableDataD(id),9)
	s fieldJsonArr=[]
	s TotalCount=0
	s sub=0
	s tableWidth=0
	for{
		s sub=$o(^CBTableDataD(id,"O",sub))	
		Quit:sub=""
		s ColumnFlag=$lg(^CBTableDataD(id,"O",sub),8)
		continue:ColumnFlag'="Y"
		s fieldJson={}
		s CompType=$lg(^CBTableDataD(id,"O",sub),10)
		s ColumnWidth=$lg(^CBTableDataD(id,"O",sub),9)
		if ColumnWidth="" s ColumnWidth=100
		s tableWidth=tableWidth+ColumnWidth
		if ColumnWidth'=""{
			s ColumnWidth=ColumnWidth_"px"	
		}
		if CompType="DR"{
			s dataIndex=$lg(^CBTableDataD(id,"O",sub),2)
			s title=$lg(^CBTableDataD(id,"O",sub),3) 
			s dataIndex=dataIndex_"Desc"
			s fieldJson.dataIndex=dataIndex
			s fieldJson.title=title
			s fieldJson.width=ColumnWidth 
			s fieldJson.align="center" 
				
		}else{
			s fieldJson.dataIndex=$lg(^CBTableDataD(id,"O",sub),2)
			s fieldJson.title=$lg(^CBTableDataD(id,"O",sub),3)	
			s fieldJson.width=ColumnWidth 
			s fieldJson.align="center" 
		}
		
		s fieldArr(sub)=fieldJson
		//do fieldArr.%Push(fieldJson)
	}
	
	if FieldSort'=""{
		s len=$l(FieldSort,"^")
		for i=1:1:len{
			continue:'$d(fieldArr($p($p(FieldSort,"^",i),"||",2)))
			s itemData=fieldArr($p($p(FieldSort,"^",i),"||",2))
			do fieldJsonArr.%Push(itemData)	
		}	
	}else{
		s sub=0
		for{
			s sub=$o(fieldArr(sub))
			Quit:sub=""
			s itemData=fieldArr(sub)
			do fieldJsonArr.%Push(itemData)		
		}	
	}
	s result={}
	s result.Data=fieldJsonArr
	s result.tableWidth=tableWidth
	
	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	s resultJson.result=result
	Quit resultJson
}

ClassMethod GetEditField(jsonStr As %String)
{
	set $zt="ERROR"
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s className=jsonObj.ClassName
	set groupId=jsonObj.groupId
	set hospitalId=jsonObj.hospitalId
	s resultJson={}
	s id=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if id=""{
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	s FieldSort=$lg(^CBTableDataD(id),9)
	s fieldJsonArr=[]
	s TotalCount=0
	s sub=0
	s ColNum=$lg(^CBTableDataD(id),11)
	k fieldArr
	for{
		s sub=$o(^CBTableDataD(id,"O",sub))	
		Quit:sub=""
		s EditFlag=$lg(^CBTableDataD(id,"O",sub),7)
		s ReadOnlyFlag=$lg(^CBTableDataD(id,"O",sub),17)
		continue:(EditFlag'="Y")&&(ReadOnlyFlag'="Y")
		s DirectTable=$lg(^CBTableDataD(id,"O",sub),11)
		s fieldJson={}
		s fieldJson.Code=$lg(^CBTableDataD(id,"O",sub),2)
		s fieldJson.Desc=$lg(^CBTableDataD(id,"O",sub),3) 
		s fieldJson.Type=$lg(^CBTableDataD(id,"O",sub),10) 
		s fieldJson.DirectTable=DirectTable
		set fieldJson.remoteSearch=$lg(^CBTableDataD(id,"O",sub),26) 
		s PrevLevelId=$lg(^CBTableDataD(id,"O",sub),18)
		s nextLevelFieldStr=""
		s nextSub=0
		for{
			s nextSub=$o(^CBTableDataD(id,"O",nextSub))
			Quit:nextSub=""
			s RelationFieldDrStr=$lg(^CBTableDataD(id,"O",nextSub),18)
			continue:RelationFieldDrStr=""
			continue:("^"_RelationFieldDrStr_"^")'[("^"_id_"||"_sub_"^")
			//if (fieldJson.Code="CityDr")&&(RelationFieldDrStr'="") b ;121222
			s nextLevelField=$lg(^CBTableDataD(id,"O",nextSub),2)
			if nextLevelFieldStr="" s nextLevelFieldStr=nextLevelField	
			else  s nextLevelFieldStr=nextLevelFieldStr_"^"_nextLevelField	
		}
		//if fieldJson.Code="CityDr" b ;1212
		s fieldJson.NextLevelField=nextLevelFieldStr	
		
		if PrevLevelId'=""{
			set PrevLevelField=""
			for i=1:1:$l(PrevLevelId,"^"){
				continue:$p(PrevLevelId,"^",i)=""
				if PrevLevelField="" set PrevLevelField=$lg(^CBTableDataD(+$p(PrevLevelId,"^",i),"O",$p($p(PrevLevelId,"^",i),"||",2)),2)	
				else  set PrevLevelField=PrevLevelField_"^"_$lg(^CBTableDataD(+$p(PrevLevelId,"^",i),"O",$p($p(PrevLevelId,"^",i),"||",2)),2)	 
			}
			s fieldJson.PrevLevelField=PrevLevelField
		}else{
			s fieldJson.PrevLevelField=""	
		}
		if (ReadOnlyFlag="Y"){
			s fieldJson.Type="Input"	
		}
		set Required=$g(^oddDEF(className,"a",fieldJson.Code,37))
		//s Required=PropObj.Required   //$lg(^CBTableDataD(id,"O",sub),16) 
		if ReadOnlyFlag="Y"{
			s Required="0"	
		}
		if (DirectTable="User.CBHospital")&&(hospitalId'=""){
			set publicFlag=##class(src.CBTable.CBTableData).GetPublicHospAuth(groupId,hospitalId,"User.CBHospital")
			b
			if publicFlag'=1{
				set Required=1	
			}
		}
		s rules=[]
		
		if Required=1{
			s rulesItem={}
			s rulesItem.required="true"
			s rulesItem.message=fieldJson.Desc_"不能为空"
			do rules.%Push(rulesItem)
		}
		s fieldJson.rules=rules
		s fieldArr(id_"||"_sub)=fieldJson
		//do fieldArr.%Push(fieldJson)
	}
	if FieldSort'=""{
		s len=$l(FieldSort,"^")
		for i=1:1:len{
			if $g(fieldArr($p(FieldSort,"^",i)))="" continue
			s itemData=fieldArr($p(FieldSort,"^",i))
			do fieldJsonArr.%Push(itemData)	
		}	
	}else{
		s id=0
		for{
			s id=$o(fieldArr(id))
			quit:id=""
			s itemData=fieldArr(id)
			do fieldJsonArr.%Push(itemData)	
		}	
	}
	if groupId=""{
		set operateAuth="Add"_"^"_"Update"_"^"_"Delete"	
	}else{
		set operateAuth=""	
	}
	  //##class(src.CBTable.CBTableData).GetOperateDataAuth(groupId,className,hospitalId)
	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	s result={}
	s result.Data=fieldJsonArr
	s result.ColNum=ColNum
	set result.operateAuth=operateAuth
	s resultJson.result=result
	Quit resultJson
ERROR
	set resultJson={}
	set resultJson.errorCode=-1
	set resultJson.errorMessage=$ZE
	
	Quit resultJson
}

ClassMethod GetTableData(paginationStr As %String, paramsStr As %String, session As %String)
{
	//set $ZT="ERROR"
	s pagination=##class(%Library.DynamicObject).%FromJSON(paginationStr)
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(paramsStr)
	set sessionObj=##class(%Library.DynamicObject).%FromJSON(session)
	
	s pageSize=pagination.pageSize
	s currentPage=pagination.currentPage
	s sortColumn=pagination.sortColumn
	s sortOrder=pagination.sortOrder
	
	set hospID=sessionObj.hospID
	s className=jsonObj.ClassName
	s FindFieldVal=jsonObj.FindFieldVal
	set groupId=jsonObj.groupId
	set hospitalId=jsonObj.hospitalId
	s ParentClassName=##class(src.CBTable.CBTableFieldExt).GetParentName(className)
	if ParentClassName'=""{
		s resultJson={}
		s resultJson.errorCode=0
		s resultJson.errorMessage=""
		s resultJson.result=[]
		Quit resultJson	
	}
	
	s retJson={}
	s resultJson={}
	s tableDataId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if tableDataId=""{
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	
	set authHospitalStr=..GetHosptialAuth(groupId,hospitalId,className)
	if authHospitalStr=""{
		set authHospitalStr=hospID	
	}
	b ;aaa
	k FindFieldValArr
	if $ISOBJECT(FindFieldVal){
		s iter=FindFieldVal.%GetIterator()
		while iter.%GetNext(.key,.value){
			s FindFieldValArr(key)=value
		}
	}
	s globalName=^oddCOM(className,"s","Default",24) 
	k valArr
	s itemDataArr=[]
	s TotalCount=0
	s sub=0
	set hospField=""
	set locField=""
	for{
		s sub=$o(^CBTableDataD(tableDataId,"O",sub))	
		Quit:sub=""
		s Code=$lg(^CBTableDataD(tableDataId,"O",sub),2)
		s ColumnFlag=$lg(^CBTableDataD(tableDataId,"O",sub),8)
		s DataValue=$lg(^CBTableDataD(tableDataId,"O",sub),5)
		s CompType=$lg(^CBTableDataD(tableDataId,"O",sub),10)
		s DirectTable=$lg(^CBTableDataD(tableDataId,"O",sub),11)
		s DirectDataValue=$lg(^CBTableDataD(tableDataId,"O",sub),13)
		s ShowField=$lg(^CBTableDataD(tableDataId,"O",sub),12)
		if ColumnFlag="Y"{
			s valArr(Code)=DataValue
			s valArr(Code,"Type")=CompType
			s valArr(Code,"DirectTable")=DirectTable
			s valArr(Code,"DirectDataValue")=DirectDataValue
			s valArr(Code,"ShowField")=ShowField
		}
		s valFindArr(Code)=DataValue
		s valFindArr(Code,"Type")=CompType
		s valFindArr(Code,"DirectTable")=DirectTable
		s valFindArr(Code,"DirectDataValue")=DirectDataValue
		s valFindArr(Code,"ShowField")=ShowField
	
		if DirectTable="User.CBHospital"{
			set hospField=DataValue
		}
		if DirectTable="User.HBLoc"{
			set locField=DataValue	
		}
		
		
	}
	s TotalCount=0
	k dataArr
	s id=0
	for{
		s id=$o(@(globalName_"("_id_")"))
		Quit:id=""	
		if $g(@(globalName_"("_id_")"))="" continue
		s Code=""
		s itemData=@(globalName_"("_id_")")
		
		if className="User.CBHospital"{
			continue:("^"_authHospitalStr_"^")'[("^"_id_"^")	
		}else{
			if (hospField'="")&&(hospID'=""){
				set hospDr=$lg(itemData,hospField)
				//continue:("^"_authHospitalStr_"^")'[("^"_hospDr_"^")
				continue:(hospDr'="")&&(hospDr'=hospID)
			}else{
				if hospField=""{
					//set hospStr=##class(src.CBTable.CBTableFieldExt).GetSelectDataNew(className,id)	
					//if $p(hospStr,"^",1)=1{
					//	continue:("^"_authHospitalStr_"^")'[("^"_$p(hospStr,"^",2)_"^")	
					//}
					if locField'=""{
						set locID=$lg(itemData,locField)	
						if locID'=""{
							set locObj=##class(User.HBLoc).%OpenId(locID)
							set tableHospID=locObj.HospDr.%Id()
							continue:(tableHospID'="")&&(tableHospID'=hospID)
						}
					}
				}	
			}	
		}
		//设置查询条件
		s fieldName=""
		s findFlag=0
		s findCount=0
		s findCountAll=0
		for{
			s fieldName=$o(FindFieldValArr(fieldName))
			Quit:fieldName=""
			s fieldValue=FindFieldValArr(fieldName)
			continue:('$d(valFindArr(fieldName,"Type")))&&(fieldName'="DataAvail")
			s findCountAll=findCountAll+1
			if (fieldName="DataAvail")&&($d(valFindArr("StartDate"))){
				///根据开始日期和结束日期来判断可用不可用
				s fieldValue=FindFieldValArr(fieldName) 
				s StartDate="" 
				if $d(valFindArr("StartDate")){
					s StartDate=$lg(itemData,valFindArr("StartDate"))	
				}
				s StopDate="" 
				if $d(valFindArr("StopDate")){
					s StopDate=$lg(itemData,valFindArr("StopDate"))	
				}
				if fieldValue=1{
					continue:(StartDate'="")&&(StartDate>(+$h))	
					continue:(StopDate'="")&&(StopDate<(+$h))	
				}elseif fieldValue=0{
					continue:(((StartDate'="")&&(StartDate<=(+$h)))||(StartDate=""))&&(((StopDate'="")&&(StopDate>=(+$h)))||(StopDate=""))	
				}
			}else{
				if fieldName'="DataAvail"{
					s CompType=valFindArr(fieldName,"Type")	
					s val=$lg(itemData,valFindArr(fieldName))
					if CompType="Text"{
						continue:(fieldValue'="")&&($ZCVT(val,"U")'[$ZCVT(fieldValue,"U"))
					}else{
						continue:(fieldValue'="")&&(val'=fieldValue)	
					}	
				}
			}
			s findCount=findCount+1
		}
		continue:findCount'=findCountAll
		
		s dataArr(id)=""
		s TotalCount=TotalCount+1
		//do itemDataArr.%Push(dataJson)
	}
	if currentPage="" s currentPage=1
	s count=0
	s id=0
	for{
		s id=$o(dataArr(id))	
		Quit:id=""
		//s itemData=dataArr(id)
		s count=count+1
		continue:(+pageSize>0)&&((count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize)))
		s itemData=@(globalName_"("_id_")")
		s dataJson={}
		s dataJson.ID=id
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
					}else{
						s $PROPERTY(dataJson,Code_"Desc")=""	
					}		
					s $PROPERTY(dataJson,Code)=val	
				}else{
					s $PROPERTY(dataJson,Code_"Desc")=val
					s $PROPERTY(dataJson,Code)=val	
				}
			}else{
				s $PROPERTY(dataJson,Code)=$lg(itemData,valArr(Code))
			}
		}
		do itemDataArr.%Push(dataJson)
	}
	s resultJson.TotalCount=TotalCount
	s resultJson.Data=itemDataArr
	s retJson.errorCode=0
	s retJson.errorMessage=""
	s retJson.result=resultJson
	Quit retJson
ERROR
	set resultJson={}
	set resultJson=""
	s resultJson.errorCode=-1
	s resultJson.errorMessage=$ZE
	
	Quit resultJson
}

ClassMethod SaveData(jsonStr As %String)
{
	///s a={"Code":"01","Descripts":"Admin","ENDesc":"","LinkAddress":"","SeqNo":"","MainMenuDr":"","Type":"1","UpdateUserDr":"1"}
	///s b=##class(src.Group.CBMainMenu).Add(a.%ToJSON())
	set $zt="error"
	b ; begin
	s jsonObj= ##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s className=jsonObj.ClassName
	s userID=jsonObj.userID
	s itemJson=jsonObj.Item
	s rowid=itemJson.ID
	s resultJson={}
	s resultJson.errorCode=0
	s id=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if id=""{
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	s retObj=##class(src.CBTable.CBTableData).CheckData(jsonStr)
	b //do ##class(src.CBTable.CBTableData).EditJsonData(.jsonObj)
	if retObj.errorCode'=0{
		Quit retObj
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
		//b //continue:EditFlag'="Y"
		s fieldJson={}
		s Code=$lg(^CBTableDataD(id,"O",sub),2)
		s Desc=$lg(^CBTableDataD(id,"O",sub),3) 
		s Type=$lg(^CBTableDataD(id,"O",sub),10) 
		set Required=$g(^oddDEF(className,"a",Code,37))
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
						s $PROPERTY(itemData,Code)=userID	
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
	s json={}
	s json.className=className
	s json.updateUserID=userID
	s data=[]
	do data.%Push(itemData)
	s json.data=data
	b ; 6666666666666
	if rowid=""{
		b ;SSSSSSSSSSSSS
		s ret=##class(src.util.operatetable).Insert(.json)
		b ;;ret123
	}else{
		b ; UUUUUU
		s ret=##class(src.util.operatetable).Update(.json)	
	}
	b ; 77777777777777
	s retCode=ret.errorCode
	b ; 8888888888
	if retCode'=0{
		s errStr=ret.errorMessage
		s errStr=$p(errStr,"#",2)
		s errCode=$p(errStr,":",1)
		s errClassName=$p(errStr,":",3)
		s errClassName=$tr(errClassName," ","")
		s errField=$p(errStr,":",4)
		b ; 999999999999999999
		if errCode="5808"{
			s errFieldDesc=..GetFieldByIndex(className,errField)
			if errFieldDesc'=""{
				s resultJson.errorCode=$p(retCode,"^",1)
				s resultJson.errorMessage=errFieldDesc_"重复"
				set resultJson.errorField=errField
				Quit resultJson		
			}
			
		}
		s resultJson.errorCode=$p(retCode,"^",1)
		s resultJson.errorMessage=$p(retCode,"^",2)	
		Quit resultJson
	}	
	s resultJson.errorCode=0
	s resultJson.errorMessage="保存成功"
	Quit resultJson
error
	set resultObj={}
	set resultObj.errorCode="-1"
	set resultObj.errorMessage=$ZE
	b ;fffff
	Quit resultObj
}

ClassMethod DeleteData(jsonStr As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s id=jsonObj.id
	set className=jsonObj.className
	set userID=jsonObj.userID
	s tableId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if tableId=""{
		set resultJson={}
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	
	s json={}
	s json.className=className
	set json.updateUserID=userID
	s data=[]
	set obj={}
	set obj.ID=id
	do data.%Push(obj)
	s json.data=data
	s ret=##class(src.util.operatetable).Delete(.json)
	if $p(ret,"^",1)'=0{
		set resultJson={}
		s resultJson.errorCode=$p(ret,"^",1)
		s resultJson.errorMessage=$p(ret,"^",2)	
		Quit resultJson
	}
	set resultJson={}
	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	Quit resultJson
}

/// w ##class(src.CBTable.CBTableData).GetFieldByIndex("User.CBMenuDetail","Desc")
ClassMethod GetFieldByIndex(className As %String, indexName As %String)
{
	s id=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if id="" Quit ""
	s sub=0
	s str=""
	for{
		s sub=$o(^oddCOM(className,"i",indexName,"I",sub))
		Quit:sub=""
		s field=^oddCOM(className,"i",indexName,"I",sub,23)
		s fieldExtSub=$o(^CBTableFieldExtI("Code",id,$ZCVT(field,"U"),0))
		if fieldExtSub'=""{
			s FieldDesc=$lg(^CBTableDataD(id,"O",fieldExtSub),3) 
			if str="" s str=FieldDesc
			else  s str=str_","_FieldDesc
		}	
	}
	Quit str
}

ClassMethod GetItemData(jsonStr As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s className=jsonObj.ClassName
	s ID=jsonObj.ID
	
	s resultJson={}
	s id=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if id=""{
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	s globalName=^oddCOM(className,"s","Default",24) 
	k valArr
	s itemDataArr=[]
	s TotalCount=0
	s sub=0
	for{
		s sub=$o(^CBTableDataD(id,"O",sub))	
		Quit:sub=""
		s Code=$lg(^CBTableDataD(id,"O",sub),2)
		s EditFlag=$lg(^CBTableDataD(id,"O",sub),7)
		s ReadOnlyFlag=$lg(^CBTableDataD(id,"O",sub),17)
		continue:(EditFlag'="Y")&&(ReadOnlyFlag'="Y")
		s DataValue=$lg(^CBTableDataD(id,"O",sub),5)
		s CompType=$lg(^CBTableDataD(id,"O",sub),10)
		s DirectTable=$lg(^CBTableDataD(id,"O",sub),11)
		s DirectDataValue=$lg(^CBTableDataD(id,"O",sub),13)
		s valArr(Code)=DataValue
		s valArr(Code,"Type")=CompType
		s valArr(Code,"ReadOnlyFlag")=ReadOnlyFlag
		s valArr(Code,"DirectTable")=DirectTable
		s valArr(Code,"DirectDataValue")=DirectDataValue
		
	}
	s dataJson={}
	s dataJson.ID=id
	s itemData=@(globalName_"("_ID_")")
	s Code=""
	for{
		s Code=$o(valArr(Code))
		Quit:Code=""
		s dataJson.ID=ID
		s CompType=valArr(Code,"Type")
		s ReadOnlyFlag=valArr(Code,"ReadOnlyFlag")
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
		}elseif (CompType="DR")&&(ReadOnlyFlag="Y") {
				s val=$lg(itemData,valArr(Code))	
				s DirectTable=valArr(Code,"DirectTable")
				if (val'="")&&(DirectTable'=""){
					s DirectDataValue=valArr(Code,"DirectDataValue")
					if DirectDataValue'=""{
						s DirectData=$g(@("^"_$p(DirectTable,".",2)_"D("_val_")"))
						if DirectData'=""{
							s $PROPERTY(dataJson,Code)=$lg(DirectData,DirectDataValue)	
						}
					}else{
						s $PROPERTY(dataJson,Code)=$lg(itemData,valArr(Code))	
					}	
				}
				
		}elseif (CompType="DR"){
			s val=$lg(itemData,valArr(Code))	
			s DirectTable=valArr(Code,"DirectTable")
			if (val'="")&&(DirectTable'=""){
				s DirectDataValue=valArr(Code,"DirectDataValue")
				s $PROPERTY(dataJson,Code)=val
				if DirectDataValue'=""{
					s DirectData=$g(@("^"_$p(DirectTable,".",2)_"D("_val_")"))
					if DirectData'=""{
						s $PROPERTY(dataJson,Code_"Desc")=$lg(DirectData,DirectDataValue)	
					}
				}else{
					s $PROPERTY(dataJson,Code_"Desc")=$lg(itemData,valArr(Code))	
				}	
			}
			
			
				
		}else{
			
			s $PROPERTY(dataJson,Code)=$lg(itemData,valArr(Code))_""	
		}	
	}

	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	s resultJson.result=dataJson
	Quit resultJson
}

ClassMethod GetSelectData(jsonStr As %String, session As %String)
{
	set $zt="error"
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	set session=##class(%Library.DynamicObject).%FromJSON(session)
	s className=jsonObj.ClassName
	set groupId=jsonObj.groupId
	set hospitalId=jsonObj.hospitalId
	//s ID=jsonObj.ID
	set hospID=session.hospID
	
	s resultJson={}
	s TableId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if TableId=""{
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	s globalName=^oddCOM(className,"s","Default",24) 
	k valArr
	s itemDataArr=[]
	s TotalCount=0
	s sub=0
	for{
		s sub=$o(^CBTableDataD(TableId,"O",sub))	
		Quit:sub=""
		s EditFlag=$lg(^CBTableDataD(TableId,"O",sub),7)
		continue:EditFlag'="Y"
		s Code=$lg(^CBTableDataD(TableId,"O",sub),2)
		s CompType=$lg(^CBTableDataD(TableId,"O",sub),10)
		continue:(CompType'="DR")&&(CompType'="Select")
		s DataValue=$lg(^CBTableDataD(TableId,"O",sub),5)
		s DirectTable=$lg(^CBTableDataD(TableId,"O",sub),11)
		s ShowField=$lg(^CBTableDataD(TableId,"O",sub),12)
		s DirectDataValue=$lg(^CBTableDataD(TableId,"O",sub),13)
		continue:(CompType="DR")&&(DirectDataValue="")
		
		set Required=$g(^oddDEF(className,"a",Code,37))
		
		s RelationFieldDr= $lg(^CBTableDataD(TableId,"O",sub),18)
		s RelationTableField=$lg(^CBTableDataD(TableId,"O",sub),19)
		s ShowField=""
		if RelationFieldDr'=""{
			set ShowField=""
			for i=1:1:$l(RelationFieldDr,"^"){
				if ShowField="" s ShowField=$lg(^CBTableDataD(+$p(RelationFieldDr,"^",i),"O",$p($p(RelationFieldDr,"^",i),"||",2)),2)
				else  s ShowField=ShowField_"^"_$lg(^CBTableDataD(+$p(RelationFieldDr,"^",i),"O",$p($p(RelationFieldDr,"^",i),"||",2)),2)
			}
			//s ShowField=$lg(^CBTableDataD(+RelationFieldDr,"O",$p(RelationFieldDr,"||",2)),2)
		}
		s selectArr=[]
		if CompType="DR" {
			s NullFlag=1
			if Required=1{
				s NullFlag=0	
			}
			if (DirectTable="User.CBHospital")&&(hospID'=""){
				set hospStr=##class(src.CBTable.CBTableData).GetHosptialAuth(groupId,hospID,"User.CBHospital")
				if hospStr="" set hospStr=hospID
				if hospStr'=""{
					for i=1:1:$l(hospStr,"^"){
						set hospId=$p(hospStr,"^",i)
						continue:hospId=""
						s hospObj=$CLASSMETHOD("User.CBHospital","%OpenId",hospId)
						s Desc=$PROPERTY(hospObj,"Descripts")
						if Desc=""{
							s Desc=$PROPERTY(hospObj,"Code")	
						}
						//s StartDate=$PROPERTY(hospObj,"StartDate")
						//s StopDate=$PROPERTY(hospObj,"StopDate")
						continue:Desc=""
						set itemData={}
						s Alias=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(Desc)
						s itemData.ID=hospId
						s itemData.Desc=Desc
						s itemData.Alias=Alias
						if (ShowField'="")&&(ValueField'=""){
							for i=1:1:$l(ShowField,"^"){
								if $ISOBJECT($PROPERTY(hospObj,$p(ValueField,"^",i))){
									s $PROPERTY(itemData,$p(ShowField,"^",i))=$PROPERTY(hospObj,$p(ValueField,"^",i)).%Id()	
								}else{
									s $PROPERTY(itemData,$p(ShowField,"^",i))=""	
								}	
							}
						}
						do selectArr.%Push(itemData)
					}
					
				}else{
						
				}
			}else{
				if DirectTable="User.HBOrganDictionary" {
					set selectArr=[]
				}else {
					s dataJson=##class(src.CBTable.CBTableFieldExt).GetJsonByClassName(DirectTable,NullFlag,ShowField,RelationTableField,hospID)
					s selectArr=dataJson
				}	
			}
			
			/*s globalName=^oddCOM(DirectTable,"s","Default",24) 
			s id=0
			s dataJson={}
			s dataJson.ID="0"
			s dataJson.Desc="空"
			//do selectArr.%Push(dataJson)
			for{
				s id=$o(@(globalName_"("_id_")"))
				Quit:id=""	
				s itemData=@(globalName_"("_id_")")
				s ShowValue=$lg(itemData,DirectDataValue)
				s dataJson={}
				s dataJson.ID=id
				s dataJson.Desc=ShowValue
				do selectArr.%Push(dataJson)
			}*/
		}else{
			s displayList=$g(^oddCOM(className,"a",Code,"P","DISPLAYLIST"))
			s valueList=$g(^oddCOM(className,"a",Code,"P","VALUELIST"))	
			for i=1:1:$l(valueList,","){
				s dataJson={}
				s dataJson.ID=$p(valueList,",",i)
				s dataJson.Desc=$p(displayList,",",i)
				if dataJson.Desc="" {
					s dataJson.Desc="空"
					s dataJson.ID="0"
				}
				do selectArr.%Push(dataJson)	
			}
			
		}
		s $PROPERTY(resultJson,Code)=selectArr
	}
	s retJson={}
	s retJson.errorCode=0
	s retJson.errorMessage=""
	s retJson.result=resultJson
	Quit retJson
error
	s retJson={}
	s retJson.errorCode="-1"
	s retJson.errorMessage=$ze
	Quit retJson
}

ClassMethod GetTableFieldData(jsonStr As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s className=jsonObj.ClassName
	
	s resultJson={}
	s id=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if id=""{
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	if '$d(^oddCOM(className)){
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	s FieldSort=$lg(^CBTableDataD(id),9)
	s globalName=^oddCOM(className,"s","Default",24) 
	k valArr
	s itemDataArr=[]
	s TotalCount=0
	s sub=0
	k fieldArr
	for{
		s sub=$o(^CBTableDataD(id,"O",sub))	
		Quit:sub=""
		s Code=$lg(^CBTableDataD(id,"O",sub),2)
		s Descripts=$lg(^CBTableDataD(id,"O",sub),3)
		s Notes=$lg(^CBTableDataD(id,"O",sub),4)
		s FindFlag=$lg(^CBTableDataD(id,"O",sub),6)
		s EditFlag=$lg(^CBTableDataD(id,"O",sub),7)
		//continue:EditFlag'="Y"
		s ColumnFlag=$lg(^CBTableDataD(id,"O",sub),8)
		s DirectTable=$lg(^CBTableDataD(id,"O",sub),11)
		s ShowField=$lg(^CBTableDataD(id,"O",sub),12)
		s DataValue=$lg(^CBTableDataD(id,"O",sub),5)
		s CompType=$lg(^CBTableDataD(id,"O",sub),10)
		s ChangeEditFlag=$lg(^CBTableDataD(id,"O",sub),15)
		s ColumnWidth=$lg(^CBTableDataD(id,"O",sub),9)
		s ReadOnlyFlag=$lg(^CBTableDataD(id,"O",sub),17)
		s itemData={}
		s itemData.ID=id_"||"_sub
		s itemData.Code=Code
		s itemData.Descripts=Descripts
		s itemData.Notes=Notes
		s itemData.FindFlag=FindFlag
		s itemData.EditFlag=EditFlag
		s itemData.ColumnFlag=ColumnFlag
		s itemData.DirectTable=DirectTable
		s itemData.ShowField=ShowField
		s itemData.DataValue=DataValue
		s itemData.CompType=CompType
		s itemData.ChangeEditFlag=ChangeEditFlag
		s itemData.ColumnWidth=ColumnWidth
		s itemData.ReadOnlyFlag=ReadOnlyFlag
		if ChangeEditFlag=0{
			s itemData.EditFlag="N"	
		}
		s fieldArr(sub)=itemData
		//do itemDataArr.%Push(itemData)
	}
	s key=0
	if FieldSort'=""{
		s len=$l(FieldSort,"^")
		for i=1:1:len{
			continue:'$d(fieldArr($p($p(FieldSort,"^",i),"||",2)))
			s itemData=fieldArr($p($p(FieldSort,"^",i),"||",2))
			s itemData.key=key
			s key=key+1
			do itemDataArr.%Push(itemData)
			k fieldArr($p($p(FieldSort,"^",i),"||",2))	
		}	
	}
		
	s id=0
	for{
		s id=$o(fieldArr(id))
		quit:id=""
		s itemData=fieldArr(id)
		s itemData.key=key
		s key=key+1
		do itemDataArr.%Push(itemData)	
	}
	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	s resultJson.result=itemDataArr
	Quit resultJson
}

ClassMethod SaveFieldSort(jsonStr As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s className=jsonObj.ClassName
	s fieldSort=jsonObj.FieldSort
	s editData=jsonObj.EditData
	s id=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	s resultJson={}
	s resultJson.errorCode=0
	if id=""{
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	s obj=##class(User.CBTableData).%OpenId(id)
	s obj.FieldSort=fieldSort
	s sc=obj.%Save()
	if $$$ISERR(sc){
		s resultJson.errorCode="-1"
		s resultJson.errorMessage=$System.Status.GetErrorText(sc)
		Quit resultJson
	}
	
	s size=editData.%Size()
	for i=0:1:(size-1){
		s itemData=editData.%Get(i)
		s id=itemData.ID
		s FindFlag=itemData.FindFlag
		s EditFlag=itemData.EditFlag
		s ColumnFlag=itemData.ColumnFlag
		s Descripts=itemData.Descripts
		s ColumnWidth=itemData.ColumnWidth
		s ReadOnlyFlag=itemData.ReadOnlyFlag
		s FieldObj=##class(User.CBTableFieldExt).%OpenId(id)
		s FieldObj.Descripts=Descripts
		s FieldObj.FindFlag=FindFlag
		s FieldObj.EditFlag=EditFlag
		s FieldObj.ColumnFlag=ColumnFlag
		s FieldObj.ColumnWidth=ColumnWidth
		s FieldObj.ReadOnlyFlag=ReadOnlyFlag
		s sc=FieldObj.%Save()
		if $$$ISERR(sc){
			s resultJson.errorCode="-1"
			s resultJson.errorMessage=$System.Status.GetErrorText(sc)
			Quit 
		}
		do FieldObj.%Close()
	}
	if resultJson.errorCode'=0{
		Quit resultJson
	}
	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	Quit resultJson
}

ClassMethod GetClassData(paginationStr As %String, paramsStr As %String)
{
	s pagination=##class(%Library.DynamicObject).%FromJSON(paginationStr)
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(paramsStr)
	s descripts=jsonObj.Descripts
	s code=jsonObj.Code
	s userId=jsonObj.User
	s hospitalId=jsonObj.Hospital
	s groupId=jsonObj.Group
	
	s pageSize=pagination.pageSize
	s currentPage=pagination.currentPage
	s sortColumn=pagination.sortColumn
	s sortOrder=pagination.sortOrder
	
	s id=0
	s retJson={}
	s dataJson=[]
	s resultJson={}
	k dataArr
	s TotalCount=0
	for {
		s id=$o(^CBTableDataD(id))
		Quit:id=""
		s Code=$lg(^CBTableDataD(id),2)
		continue:(Code="User.HBAdmReason") ;费别表重要,不提供维护
		s Descripts=$lg(^CBTableDataD(id),3)
		continue:(code'="")&&($ZCVT(Code,"U")'[$ZCVT(code,"U"))
		continue:(descripts'="")&&($ZCVT(Descripts,"U")'[$ZCVT(descripts,"U"))
		if groupId'=""{
			//if $o(^CBGroupLinkTableI("TableGroup",groupId,id,0))="" continue	
		}
		s dataArr(id)=""
		s TotalCount=TotalCount+1
	}
	if currentPage="" s currentPage=1
	s count=0
	s id=0
	for{
		s id=$o(dataArr(id))	
		Quit:id=""
		//s itemData=dataArr(id)
		s count=count+1
		continue:(+pageSize>0)&&((count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize)))
		s Code=$lg(^CBTableDataD(id),2)
		s Descripts=$lg(^CBTableDataD(id),3)
		s itemData={}
		s itemData.ID=id
		s itemData.Code=Code
		s itemData.Descripts=Descripts
		s ParentName=##class(src.CBTable.CBTableFieldExt).GetParentName(Code)
		s itemData.ParentName=ParentName
		//do dataJson.%Push(itemData)
		do dataJson.%Push(itemData)
		
	}
	
	s resultJson.TotalCount=TotalCount
	s resultJson.Data=dataJson
	s retJson.errorCode=0
	s retJson.errorMessage=""
	s retJson.result=resultJson
	Quit retJson
}

/// w ##class(src.CBTable.CBTableData).GetShowField("User.CBOrderSubCat")
ClassMethod GetShowField(ClassName As %String)
{
	s storage=^oddCOM(ClassName,59)
	s defaultData=^oddCOM(ClassName,"s",storage,22)
	s descIndex=""
	s codeIndex=""
	s index=1
	
	for{
		s index=$o(^oddCOM(ClassName,"s",storage,"D",defaultData,"V",index)) 
		Quit:index=""
		s Property=^oddDEF(ClassName,"s",storage,"D",defaultData,"V",index,21)
		s dataType=$g(^oddDEF(ClassName,"a",Property,5))
		if Property="Code" s codeIndex=index
		if Property="Descripts" s descIndex=index
	}
	if descIndex'=""{
		set descStr="Descripts"_"^"_descIndex
	}else{
		set descStr="^"	
	}
	if codeIndex'=""{
		set codeStr="Code"_"^"_codeIndex
	}else{
		set codeStr="^"	
	}
	Quit descStr_","_codeStr
}

ClassMethod GetTableItem(jsonStr As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s ID=jsonObj.ID
	s jsonObj={}
	s tableObj=##class(User.CBTableData).%OpenId(ID)
	s jsonObj.ID=ID
	s jsonObj.Code=tableObj.Code
	s jsonObj.Descripts=tableObj.Descripts
	s jsonObj.Notes=tableObj.Notes
	s jsonObj.SafeClassificat=tableObj.SafeClassificat
	s jsonObj.ColNum=tableObj.ColNum
	s jsonObj.FrequeUse=tableObj.FrequeUse
	s jsonObj.ShortDesc=tableObj.ShortDesc
	set jsonObj.ProductModuleDr=""
	if tableObj.ProductModuleDr'=""{
		set jsonObj.ProductModuleDr=tableObj.ProductModuleDr.%Id()	
	}
	s retJson={}
	s retJson.errorCode=0
	s retJson.errorMessage=""
	s retJson.result=jsonObj
	Quit retJson
}

ClassMethod GetBasicClassData(jsonStr As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s dataJson=[]
	s id=""
	for{
		s id=$o(^oddCOM(id))
		Quit:(id="")
		continue:((id'["User.")&&(id'["src."))
		continue:$o(^CBTableDataI("Code",$ZCVT(id,"U"),0))'=""
		continue:$g(^oddCOM(id,23))'="persistent"
		s classStr=$p(id,".",2)
		
		s itemData={}
		s itemData.ID=id
		s itemData.Desc=id
		do dataJson.%Push(itemData)
	}
	s retJson={}
	s retJson.errorCode=0
	s retJson.errorMessage=""
	s retJson.result=dataJson
	Quit retJson
}

ClassMethod GetLinkTableData(jsonStr As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s className=jsonObj.ClassName
	
	s tableId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	b ;121
	if tableId=""{
		s retJson={}
		s retJson.errorCode=-1
		s retJson.errorMessage="表名不存在"	
		Quit retJson
	}
	s dataJson=[]
	s id=0
	for{
		s id=$o(^CBTableDataI("TableRef",tableId,id))
		Quit:id=""
		
		s Code=$lg(^CBTableDataD(id),2)
		s Desc=$lg(^CBTableDataD(id),3)
		s itemData={}
		s itemData.Code=Code
		s itemData.Desc=Desc
		s itemData.ID=id
		do dataJson.%Push(itemData)	
	}
	s retJson={}
	s retJson.errorCode=0
	s retJson.errorMessage=""
	s retJson.result=dataJson
	Quit retJson
}

ClassMethod GetDataByClassName(ClassName As %String)
{
	set myobj=##class(%Dictionary.CompiledClass).%OpenId(ClassName)
	set myCount = myobj.Properties.Count()
	set parentname="",parentproprty="",Global=""
	for i=1:1:myCount {
		continue:parentname'=""
		set mypropobj=myobj.Properties.GetAt(i)
		set propName=mypropobj.Name
		set dataType=mypropobj.Type
		if (mypropobj.Cardinality="parent"){
			set parentproprty=propName
			set parentname=dataType
			set myobj1=##class(%Dictionary.CompiledStorage).%OpenId((parentname_"||Default"))
			set Global=myobj1.DataLocation
		}
	}
	
	Quit retJson
}

ClassMethod GetAllCBTable(jsonStr As %String = "") As %Library.DynamicAbstractObject
{
	set id=0
	set retJson={}
	set dataJson=##class(%Library.DynamicArray).%New()
	for  set id=$o(^CBTableDataD(id)) quit:id=""  do
	.set jsonObj=##class(%Library.DynamicObject).%New()
	.set code=$lg(^CBTableDataD(id),2)
	.set descripts=$lg(^CBTableDataD(id),3)
	.;do jsonObj.%Set("code",code)
	.;do jsonObj.%Set("descripts",descripts)
	.set jsonObj.code=code
	.set jsonObj.descripts=descripts
	.set jsonObj.id=id
	.do dataJson.%Push(jsonObj)
	
	set retJson={}
	set retJson.errorCode=0
	set retJson.errorMessage=""
	set retJson.result=dataJson

	quit retJson
}

ClassMethod test1235()
{
	set updObj={},data=[]
	set updObj.code="ceshi002"
	set dataobj={}
	set dataobj.className="User.HBTarSubType"
	do data.%Push(dataobj)
	set updObj.params=data
	b ;1
	set rtn=..GetTableDataFromCls(.updObj)
	b
	q rtn
}

ClassMethod GetTableDataFromCls(jsonObj As %Library.DynamicAbstractObject) As %Library.DynamicAbstractObject
{
	;set jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	set params=jsonObj.params
	set iter=params.%GetIterator()
	while iter.%GetNext(.key , .value ) {
	      ;write "key = "_key_" , value = "_value,!
	      set:value.%Get("className")'="" className=value.%Get("className")
	   }
	/*for i=1:1:params.%Size() {
		set obj=params.%Get(i)
		set className=obj.%Get("className")
	}*/
	set retJson={}
	set retJson.errorCode=0
	set retJson.errorMessage=""
	if ('##class(%Dictionary.CompiledClass).%ExistsId(className)){
		set retJson.errorCode=-1
		set retJson.errorMessage="表名不存在"
	}else{
		set obj=##class(%Dictionary.CompiledClass).%OpenId(className)
		;set objStorage=##class(%Dictionary.CompiledStorage).%OpenId(className_"||Default")
		set objTable=obj.SqlTableName
		
	    set sql = "select * from "_objTable
	    set result=##class(%ResultSet).%New("%DynamicQuery:SQL")
	    do result.RuntimeModeSet(1)
	    set sc=result.Prepare(sql)
	    if $$$ISERR(sc) {
		    set retJson.errorCode=-1
			set retJson.errorMessage="sql错误"
		}
		
		set sc=result.Execute()
		if $$$ISERR(sc) {
			set retJson.errorCode=-1
			set retJson.errorMessage="表数据查询出错"
		}
		
		set colCount=result.GetColumnCount()
		set dataJson=[]
	    while(result.%Next(sc)){
		    set row=##class(%Library.DynamicObject).%New()
		    for i=1:1:colCount {
			    set colName=result.GetColumnHeader(i)
			    set val=result.Get(colName)
			    do row.%Set(colName,val)
			}
			do dataJson.%Push(row)
		}
		set retJson.result=dataJson	
	}
	quit retJson
}

ClassMethod GetCBDataCompOrd(jsonObj As %Library.DynamicAbstractObject) As %Library.DynamicAbstractObject
{
	set retJson={}
	set retJson.errorCode=0
	set retJson.errorMessage=""
	set result=[]
	set id=0 for  set id=$o(^CBDataCompOrgD(id)) quit:id=""  do
	.set objOrg={}
	.set code= $lg(^CBDataCompOrgD(id),2)
	.set desc= $lg(^CBDataCompOrgD(id),3)
	.set note= $lg(^CBDataCompOrgD(id),4)
	.set endesc= $lg(^CBDataCompOrgD(id),5)
	.set startDate= $lg(^CBDataCompOrgD(id),6)
	.set stopDate= $lg(^CBDataCompOrgD(id),7)
	.set createDate= $lg(^CBDataCompOrgD(id),8)
	.set createUserDr= $lg(^CBDataCompOrgD(id),9)
	.set objOrg.ID=id
	.set objOrg.Code=code
	.set objOrg.Descripts=desc
	.set objOrg.Note=note
	.set objOrg.ENDesc=endesc
	.set objOrg.StartDate=startDate
	.set:startDate'="" objOrg.StartDate=$zd(startDate,3)
	.set objOrg.StopDate=stopDate
	.set:stopDate'="" objOrg.StopDate=$zd(stopDate,3)
	.set objOrg.CreateDate=createDate
	.set:createDate'="" objOrg.CreateDate=$zd(createDate,3)
	.set objOrg.CreateUserDr=createUserDr
	.do result.%Push(objOrg)
	set retJson.result=result
	quit retJson
}

ClassMethod GetDataComparion(jsonObj As %Library.DynamicAbstractObject) As %Library.DynamicAbstractObject
{
	set retJson={}
	set retJson.errorCode=0
	set retJson.errorMessage=""
	
	set params=jsonObj.params
	set iter=params.%GetIterator()
	while iter.%GetNext(.key , .value ) {
	    ;write "key = "_key_" , value = "_value,!
		set tableDataId=value.%Get("tableDataId")
		set orgDataId=value.%Get("orgDataId")
		set dataId=value.%Get("dataId")
	}
	b
	if ((tableDataId="")||(dataId="")){
		set retJson.errorCode=-1
		set retJson.errorMessage="tableDataId或DataId为空"
		return retJson
	}
	if (orgDataId'=""){
		set sql = "select * from "_"CB_DataComparison"_" where CompOrg_Dr="_orgDataId_" and TableData_Dr="_tableDataId_" and DataID="_dataId
	}else{
		set sql = "select * from "_"CB_DataComparison"_" where TableData_Dr="_tableDataId_" and DataID="_dataId
	}
	
	set result=##class(%ResultSet).%New("%DynamicQuery:SQL")
	do result.RuntimeModeSet(1)
	set sc=result.Prepare(sql)
	set sc=result.Execute()
	
	set colCount=result.GetColumnCount()
	set dataJson=[]
	while(result.%Next(sc)){
		set row=##class(%Library.DynamicObject).%New()
		for i=1:1:colCount {
			set colName=result.GetColumnHeader(i)
			set val=result.Get(colName)
			set property=$replace(colName,"_","")
			do row.%Set(property,val)
		}
		do dataJson.%Push(row)
	}
	set retJson.result=dataJson	
	return retJson
}

ClassMethod SaveComparisonOrg(jsonObj As %Library.DynamicAbstractObject) As %Library.DynamicAbstractObject
{
	set retJson={}
	set retJson.errorCode=0
	set retJson.errorMessage="成功"
	
	set params=jsonObj.params
	set session=jsonObj.session.%Get(0)
	set userId=session.%Get("userID")
	set iter=params.%GetIterator()
	set insObj={},updObj={}, insData=[], updData=[]
	do insObj.%Set("className","User.CBDataComparison")
	do insObj.%Set("updateUserID",userId)
	set updObj={}.%FromJSON(insObj.%ToJSON())

	while iter.%GetNext(.key , .value ) {
	    ;write "key = "_key_" , value = "_value,!
	    set id=value.%Get("ID")
		set tableDataId=value.%Get("TableDataDr")
		set orgDataId=value.%Get("CompOrgDr")
		set dataId=value.%Get("DataID")
		set extCode=value.%Get("ExtCode")
		set extDesc=value.%Get("ExtDesc")
		set note=value.%Get("Note")
		set startDate=value.%Get("StartDate")
		set stopDate=value.%Get("StopDate")
		do:id'="" value.%Remove("CreateUserDr")
		do:id'="" value.%Remove("CreateDate")
		do:id="" value.%Set("CreateUserDr",userId)
		do:id="" value.%Set("CreateDate",$zd(+$h,3))
		set:startDate["-" startDate=startDate
		set:stopDate["-" stopDate=stopDate
		do value.%Set("StartDate",startDate)
		do value.%Set("StopDate",stopDate)
		if (id=""){
			do insData.%Push(value)
		}else{
			do updData.%Push(value)
		}
		
	}
	set insObj.data=insData, updObj.data=updData
	b
	if ((tableDataId="")||(orgDataId="")||(dataId="")){
		set retJson.errorCode=-1
		set retJson.errorMessage="数据不完整"_tableDataId_","_orgDataId_","_dataId
		return retJson
	}
	if ((insData.%Size()>0)&&(tableDataId'="")&&(orgDataId'="")&&(dataId'="")){
		b	;id=""
		set sc=##class(src.util.operatetable).Insert(insObj)
		set flag=$p(sc,"^",1)
		if (flag'=0){
			set retJson.errorCode=-1
			set retJson.errorMessage="添加失败"_sc
			return retJson
		}
	}

	if ((updData.%Size()>0)&&(tableDataId'="")&&(orgDataId'="")&&(dataId'="")){
		b	;id'=""
		set sc=##class(src.util.operatetable).Update(updObj)
		set flag=$p(sc,"^",1)
		if (flag'=0){
			set retJson.errorCode=-1
			set retJson.errorMessage="修改失败"_sc
			return retJson
		}
	}
	
	set retJson.errorMessage="成功"
	set sql = "select * from "_"CB_DataComparison"_" where TableData_Dr ="_tableDataId_" and DataID="_dataId
	set result=##class(%ResultSet).%New("%DynamicQuery:SQL")
	do result.RuntimeModeSet(1)
	set sc=result.Prepare(sql)
	set sc=result.Execute()
	
	set colCount=result.GetColumnCount()
	set dataJson=[]
	while(result.%Next(sc)){
		set row=##class(%Library.DynamicObject).%New()
		for i=1:1:colCount {
			set colName=result.GetColumnHeader(i)
			set val=result.Get(colName)
			set property=$replace(colName,"_","")
			do row.%Set(property,val)
		}
		do dataJson.%Push(row)
	}
	set retJson.result=dataJson
	quit retJson
}

/// 保存数据之前对数据进行检测
/// 返回数据格式  json 对像 
ClassMethod CheckData(jsonStr)
{
	s jsonObj= ##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s className=jsonObj.ClassName
	s userDr=jsonObj.UserDr
	s itemJson=jsonObj.Item
	s rowid=itemJson.ID
	
	if className="src.Rest.SYSMapInterface"{
		set existFlag=##class(%Library.ClassDefinition).%ExistsId(itemJson.ClassName)	
		if existFlag=0{
			s resultJson={}
			s resultJson.errorCode=-1
			s resultJson.errorMessage="类不存在"
			Quit resultJson	
		}
		s existFlag=##class(%Dictionary.MethodDefinition).%ExistsId(itemJson.ClassName_"||"_itemJson.MethodName)
		if existFlag=0{
			s resultJson={}
			s resultJson.errorCode=-1
			s resultJson.errorMessage="方法不存在"
			Quit resultJson	
		}
	}
	
	s resultJson={}
	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	
	Quit resultJson
}

/// 保存数据之前对数据进行检测
/// 返回数据格式  json 对像 
ClassMethod EditJsonData(ByRef jsonData As %Library.DynamicObject)
{
	if jsonData.ClassName="src.Rest.SYSMapInterface"{
		
		if (jsonData.ID="")&&(jsonData.Code=""){
			set productCatDr=jsonData.ProductCatDr
			set productModuleDr=jsonData.ProductModuleDr
			if (productCatDr'="")&&(productModuleDr'=""){
				set productModuleCode=$lg(^CBProductModuleD(productModuleDr),2)
				set productCatCode=$lg(^CBProductCatD(productCatDr),3)
				set id=$o(^SYSMapInterfaceI("Product",productCatDr,productModuleDr,""),-1)
				if id'=""{
					set code=$lg(^SYSMapInterfaceD(id),2)
					set seqno=+$e(code,5,8)+1
					set jsonData.Code=$e(code,1,4)_$e("0000",1,4-$l(seqno))_seqno
				}
				b ;111
				if jsonData.Code=""{
					set productCode=productCatCode_productModuleCode
					set code=productCode
					set seqno=0	
					set newCode=""
					b ;111
					for{
						set code=$o(^SYSMapInterfaceI("Code",code))
						continue:$l(code)'=8
						Quit:$e(code,1,4)'=productCode
						if seqno<(+$e(code,5,8)) set seqno=+$e(code,5,8) 
						//set newCode=code
					}
					if seqno'=""{
						set seqno=seqno+1
						set jsonData.Code=productCode_$e("0000",1,4-$l(seqno))_seqno	
					}
				}
			}	
		}	
	}else{
			
	}
	
	
	
	Quit 0
}

ClassMethod GetAuthCBData(jsonStr As %String)
{
	set $zt="error"
	set jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	set hospID=jsonObj.hospID
	set groupID=jsonObj.groupID
	
	if hospID=""{
		set resultJson={}
		set resultJson.errorCode=-1
		set resultJson.errorMessage="医院不能为空"
		Quit resultJson	
	}
	if groupID=""{
		set resultJson={}
		set resultJson.errorCode=-1
		set resultJson.errorMessage="角色不能为空"
		Quit resultJson	
	}
	
	set tableDataArr=[]
	set id=0
	for{
		s id=$o(^CBGroupLinkTableI("TableGroup",groupID,id))
		Quit:id=""
		set tableData=$g(^CBTableDataD(id))
		continue:tableData=""
		set desc=$lg(tableData,3)
		s alias=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(desc)	
		s className=$lg(tableData,2)
		set moduleDr=$lg(tableData,13)
		set catDr=""
		if moduleDr'=""{
			set catDr=$lg($g(^CBProductModuleD(moduleDr)),4)	
		}
		s itemData={}
		s itemData.ID=id
		s itemData.key=id
		s itemData.Desc=desc
		s itemData.Alias=alias
		s itemData.ClassName=className
		set itemData.moduleDr=moduleDr
		set itemData.catDr=catDr
		
		do tableDataArr.%Push(itemData)
	}
	set ProductCatData=##class(src.Interface.BasicData).GetProductCat()
	set ProductModuleData=##class(src.Interface.BasicData).GetProductModule()
	set resultJson={}
	set resultJson.errorCode=0
	set resultJson.errorMessage=""
	set resultJson.TableData=tableDataArr
	set resultJson.ProductCatData=ProductCatData
	set resultJson.ProductModuleData=ProductModuleData
	Quit resultJson
error
	set resultObj={}
	set resultObj.errorCode="-1"
	set resultObj.errorMessage=$ze
	Quit resultObj
}

/// w ##class(src.CBTable.CBTableData).Test()
ClassMethod CheckDataAuth(loginHospId As %String, dataHospId As %String, groupId As %String, className As %String)
{
	s classId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if classId=""{
		Quit 0
	}
}

ClassMethod GetFormData()
{
	set json={}
	set classData=##class(src.CBTable.CBTableData).GetBasicClassData(json.%ToJSON())
	set classData=classData.result
	if classData="" set classData=[]
	set proModuleData=##class(src.Interface.BasicData).GetProductModule()
	set resultJson={}
	set resultJson.errorCode=0
	set resultJson.errorMessage=""
	set resultJson.classData=classData
	set resultJson.proModuleData=proModuleData
	Quit resultJson
}

ClassMethod GetLowerHosptial(hospitalId As %String)
{
	set lowerHospitalStr=""
	if (hospitalId="") Quit ""
	for{
		set hospId=$o(^CBHospitalI("Hosp",hospitalId,hospId))	
		Quit:hospId=""
		set itemData=$g(^CBHospitalD(hospId))
		continue:itemData=""
		set startDate=$lg(^CBHospitalD(hospId),24)
		set stopDate=$lg(^CBHospitalD(hospId),25)
		continue:(startDate'="")&&(startDate>(+$h))
		continue:(stopDate'="")&&(stopDate<(+$h))
		if lowerHospitalStr="" set lowerHospitalStr=hospId
		else  set lowerHospitalStr=lowerHospitalStr_"^"_hospId
	}
	Quit lowerHospitalStr
}

ClassMethod GetHosptialAuth(groupId As %String, hospitalId As %String, className As %String)
{
	set authHospitalStr=""
	set lowerHospitalStr=""
	if (groupId="")||(hospitalId="") Quit ""
	s tableDataId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if tableDataId="" Quit ""
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
		if lowerHospitalStr="" set lowerHospitalStr=hospId
		else  set lowerHospitalStr=lowerHospitalStr_"^"_hospId
	}
	set allHospitalStr=""
	for{
		set hospId=$o(^CBHospitalD(hospId))	
		Quit:hospId=""
		set itemData=$g(^CBHospitalD(hospId))
		continue:itemData=""
		if allHospitalStr="" set allHospitalStr=hospId
		else  set allHospitalStr=allHospitalStr_"^"_hospId
	}
	set authHospitalStr=""
	set classLinkId=$o(^CBGroupLinkTableI("TableGroup",groupId,tableDataId,0))
	if classLinkId=""{
		Quit ""		
	}else{	
		set authSub=0
		for{
			set authSub=$o(^CBGroupLinkTableD(classLinkId,"A",authSub))
			Quit:authSub=""
			set authId=$lg(^CBGroupLinkTableD(classLinkId,"A",authSub),2)
			continue:authId=""
			set authCode=$lg(^CBHospGroupAuthTypeD(authId),2)
			set str=0
			if authCode="Hosp"{
				set str=hospitalId	
			}
			if authCode="Public"{
				set str=""	
			}
			if authCode="All"{
				set str=allHospitalStr	
			}
			if authCode="LowHosp"{
				set str=lowerHospitalStr	
			}
			if str'=0{
				if authHospitalStr="" set authHospitalStr=str
				else  set authHospitalStr=authHospitalStr_"^"_str
			} 
		}
	}	
	set hospStr=""
	if authHospitalStr'=""{
		for i=1:1:$l(authHospitalStr,"^"){
			set hospId=$p(authHospitalStr,"^",i)
			if ("^"_hospStr_"^")'[("^"_hospId_"^"){
				if hospStr="" set hospStr=hospId
				else  set hospStr=hospStr_"^"_hospId
			}
		}	
	}
	Quit hospStr
}

/// w ##class(src.CBTable.CBTableData).GetPublicHospAuth()
ClassMethod GetPublicHospAuth(groupId As %String, hospitalId As %String, className As %String)
{
	if (groupId="")||(hospitalId="") Quit ""
	s tableDataId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if tableDataId="" Quit ""
	set flag=""
	set authSub=0
	set classLinkId=$o(^CBGroupLinkTableI("TableGroup",groupId,tableDataId,0))
	if classLinkId="" Quit ""
	for{
		set authSub=$o(^CBGroupLinkTableD(classLinkId,"A",authSub))
		Quit:authSub=""
		set authId=$lg(^CBGroupLinkTableD(classLinkId,"A",authSub),2)
		continue:authId=""
		set authCode=$lg(^CBHospGroupAuthTypeD(authId),2)
		set str=0
		if (authCode="Public"){
			set flag=1
		}
	}
	Quit flag
}

ClassMethod GetOperateDataAuth(groupId As %String, className As %String, hospitalId As %String, dataId As %String)
{
	
	
	if (className="") Quit ""
	if groupId=""{
		Quit "Add"_"^"_"Update"_"^"_"Delete"	
	}
	if hospitalId=""{
		Quit "Add"_"^"_"Update"_"^"_"Delete"	
	}
	
	set dataHospId=""
	s tableDataId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if tableDataId'=""{
		s sub=0
		for{
			s sub=$o(^CBTableDataD(tableDataId,"O",sub))	
			Quit:sub=""
			s Code=$lg(^CBTableDataD(tableDataId,"O",sub),2)
			s DirectTable=$lg(^CBTableDataD(tableDataId,"O",sub),11)
			continue:DirectTable'="User.CBHospital"
			set dataObj=$CLASSMETHOD(className,"%OpenId",dataId)
			set dataHospId=$PROPERTY(dataObj,Code)
		}	
	}
	
	s tableDataId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if tableDataId="" Quit ""
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
		
		set hospStr=..GetHospByAuthCode(authHospCode)
		continue:("^"_hospStr_"^")'[("^"_dataHospId_"^")
		set str=""
		if authCode="Add"{
			
			set str="Add"
		}
		if authCode="Update"{
			set str="Update"
		}
		if authCode="Delete"{
			set str="Delete"
		}
		if authStr="" set authStr=str
		else  set authStr=authStr_"^"_str
	}
	Quit authStr
}

/// w ##class(src.CBTable.CBTableData).Test()
ClassMethod Test()
{
	set jsonObj={"params":[{"ClassName":"User.HBMedItemLis","FindFieldVal":{"DataAvail":""},"groupId":"","hospitalId":""}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"","sortOrder":""}],"code":"4003","session":[{"userID":"1","locID":"101","groupID":"3","hospID":"62","sessionID":"ZmJwGBFmMr","hospCode":"H19","language":"CN","hostName":"","ipv4":"182.254.131.121","ipv6":"","mac":""}]}
	set postParams=jsonObj.params.%Get(0)
	set postPagination=jsonObj.pagination.%Get(0)
	set session=jsonObj.session.%Get(0)
	set ret=##class(src.CBTable.CBTableData).GetTableData(postPagination.%ToJSON(),postParams.%ToJSON(),session.%ToJSON())
	Quit ret.%ToJSON()
	
	
	
	set json={}
	set json.ClassName="User.CBTitle"
	s ret=##class(src.CBTable.CBTableData).GetSelectData(json.%ToJSON())
	Quit ret.%ToJSON()
	
	set json={}
	set ret=..GetBasicClassData(json.%ToJSON())
	Quit ret.%ToJSON()
	
	set page={}
	
	
	
	set admin=1
	set obj={"Code":"01","Descripts":"Admin","ENDesc":"","LinkAddress":"","SeqNo":"","MainMenuDr":"","Type":"1","UpdateUserDr":"1"}
	set obj={}
	set obj.Code="01"
	set obj.Descripts="Admin"
	set json={}
	set json.ClassName="User.CBMenuDetail"
	set json.UserDr=1
	set json.item=obj
	
	
	set json={}
	set json.ClassName="src.Rest.SYSMapInterface"
	set json.ID=""
	set json.Code=""
	set json.ProductCatDr=1
	set json.ProductModuleDr=2
	s ret=##class(src.CBTable.CBTableData).EditJsonData(.json)
	b ;12121
	Quit ret.%ToJSON()
	
	
	
	
	
	
	w $now(),!
	s json={}
	set data=[]
	set id=0
	for i=1:1:100000 {
		
		set item=^CBSexD(1)
		set code=$lg(item,3)
		set desc=$lg(item,4)
		set ENDesc=$lg(item,5)
		set StartDate=$lg(item,6)
		if StartDate'="" set StartDate=$zd(StartDate,3)
		set StopDate=$lg(item,7)
		if StopDate'="" set StopDate=$zd(StopDate,3)
		set CreateDate=$lg(item,8)
		if CreateDate'="" set CreateDate=$zd(CreateDate,3)
		set CreateUserDr=$lg(item,9)
		
		set item={}
		set item.ID=id
		set item.code=code
		set item.desc=desc
		set item.ENDesc=ENDesc
		set item.StartDate=StartDate
		set item.StopDate=StopDate
		set item.CreateDate=CreateDate
		set item.CreateUserDr=CreateUserDr
		do data.%Push(item)
	}
	set json.data=data
	w $now(),!
	Quit json
	
	
	
	w $now(),!
	s json={}
	set data=[]
	for i=1:1:100000{
		set obj=##class(User.CBSex).%OpenId(1)
		set item={}
		s sc=obj.ToDynamicObj(.item)
		do data.%Push(item)
	}
	
	set json.data=data
	w $now(),!
	Quit json
	
	
	set updObj={},data=[]
	set updObj.className="User.CBTradingChannel"
	set updObj.updateUserID=1
	set dataobj={}
	//set dataobj.ID=""
	set dataobj.Code="122221"
	set dataobj.Descripts="122221"
	set dataobj.CreateDate="2019-03-22"
	set dataobj.StartDate="2019-03-22"
	set dataobj.CreateUserDr=1
	

	do data.%Push(dataobj)
	set updObj.data=data
	b ;11212
	//s ret=##class(src.CBTable.CBTableData).InsertNew(updObj)
	s ret=##class(src.util.operatetable).InsertNew(updObj)
	
	Quit 0
	
	s json={}
	set json.ClassName="User.CBTradingChannel"
	set json.UserDr=1
	set Item={}
	set Item.Code="01"
	set Item.Descripts="01"
	set Item.ENDesc="测试122"
	set Item.StartDate="2019-03-22"
	set Item.StopDate=""
	
	set json.Item=Item
	 
	//set ret=##class(src.CBTable.CBTableData).GetOperateDataAuth(2,"User.HBTimeRange")
	//q ret
	s ret=##class(src.CBTable.CBTableData).SaveData(json.%ToJSON())
	Quit ret.%ToJSON()
	
	
	
	
	
	
	s json={}
	set json.ClassName="src.Rest.SYSMapInterface"
	set json.groupId=""
	set json.hospitalId=""
	set page={}
	//set ret=##class(src.CBTable.CBTableData).GetOperateDataAuth(2,"User.HBTimeRange")
	//q ret
	s ret=##class(src.CBTable.CBTableData).GetSelectData(json.%ToJSON())
	Quit ret.%ToJSON()
}

/// w ##class(src.CBTable.CBTableData).ImportData()
ClassMethod ImportData()
{
	s table=""
	for{
		set table=$o(^tabledataimport(table))
		Quit:table=""
		s tableId=$o(^CBTableDataI("Code",$ZCVT(table,"U"),0))
		continue:tableId=""
		s catId=^tabledataimport(table)
		&sql(update SQLUSER.CB_TableData set ProductModule_Dr=:catId where ID=:tableId)
		w SQLCODE	
	}
	Quit 0
}

/// w ##class(src.CBTable.CBTableData).Test4()
ClassMethod Test4()
{
	w $now(),!
	for i=1:1:100000{
		k PLIST
		set PLIST(2)=""
		set PLIST(3)="001"
		set PLIST(4)="001"
		set PLIST(5)=""
		set PLIST(6)=+$h
		set PLIST(7)=""
		set PLIST(8)=+$h
		set PLIST(9)=1
		//s ret=##class(User.CBSex1).%SQLInsert(.PLSIT)
		set sqldata3d=1
		//s ret=##class(User.CBSex1).%SQLInsert(.PLIST,$c(0,0,0,0,0,0,0),,,'$g(sqldata3d))
		//w ret,!
		//&sql(insert into SQLUSER.CB_Sex1 values:PLIST())
		//w %ROWID
	}
	w $now(),!
	quit ""
}

/// w ##class(src.CBTable.CBTableData).Test5()
ClassMethod Test5()
{
	
	w $now(),!
	set item={}
		set item.Code="002"
		set item.Desc="002"
		set item.ENDesc=""
		set item.StartDate=+$h
		set item.StopDate=""
		set item.CreateDate=+$h
		set item.CreateUserDr=1
		set json={}
		set json.className="User.CBSex1"
		s data=[]
		do data.%Push(item)
		s json.data=data
	for i=1:1:100000{
		
		s ret=##class(src.util.operatetable).Insert(.json)
	}
	w $now(),!
	Quit ""
}

/// w ##class(src.CBTable.CBTableData).Test23()
ClassMethod Test23(Arg1 As %String)
{
		w $now(),!
	for i=1:1:100000{
	k PLIST
	set PLIST(2)="001"
	set PLIST(3)="001"
	//set sql="insert into SQLUSER.CB_Sex1 (Code,Descripts,StartDate,CreateDate,CreateUserDr)" 
	//set sql=sql_"values('001','001'"_","_+$h_","_+$h_",1)"
	//b ;sql
	//set ret=$SYSTEM.SQL.Execute("insert into SQLUSER.CB_Sex1 (Code,Descripts) values('001',001) ",2)
	//b ;12
	}
	w $now(),!
	quit ""
}

ClassMethod GetHospByAuthCode(hospitalId As %String, authCode As %String)
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

/// w ##class(src.CBTable.CBTableData).GetFrequeUseClass()
ClassMethod GetFrequeUseClass()
{
	s dataJson=[]
	s id=""
	for{
		s id=$o(^CBTableDataD(id))
		Quit:id=""
		set FrequeUse=$lg(^CBTableDataD(id),16)
		set className=$lg(^CBTableDataD(id),2)
		set desc=$lg(^CBTableDataD(id),3)
		continue:FrequeUse'="Y"
		s itemData={}
		s itemData.className=className
		s itemData.desc=desc
		do dataJson.%Push(itemData)
	}
	s retJson={}
	s retJson.errorCode=0
	s retJson.errorMessage=""
	s retJson.result=dataJson
	Quit retJson
}

/// w ##class(src.CBTable.CBTableData).CheckTableEditFlag("src.Rest.SYSMapInterface")
ClassMethod CheckTableEditFlag(ClassName As %String)
{
	s classStr=$p(ClassName,".",2)
	if $e(classStr,1,2)="BS"{
		set errorCode="01040091"
		set errorMessage=##class(src.Interface.Message).GetErrorMessage(errorCode)
		Quit errorCode_"^"_errorMessage
	}
	s className=##class(src.CBTable.CBTableFieldExt).GetParentName(ClassName)
	if className'=""{
		set errorCode="01040092"
		set errorMessage=##class(src.Interface.Message).GetErrorMessage(errorCode)
		Quit errorCode_"^"_errorMessage	
	}
	Quit "0^"
}

/// w ##class(src.CBTable.CBTableData).UpdateTableDataId()
ClassMethod UpdateTableDataId()
{
	set tableID=0
	for{
		set tableID=$o(^CBTableDataD(tableID))	
		Quit:tableID=""
		set maxSub=$o(^CBTableDataD(tableID,"O",""),-1)
		set sub=$g(^CBTableFieldExtD(tableID,"O",0))
		if sub<maxSub{
			w maxSub_"--"_sub,!
			//set ^CBTableFieldExtD(tableID,"O",0)=maxSub
		}
		
	}
	Quit ""
}

/// w ##class(src.CBTable.CBTableData).GetExportTableData({"ClassName":"User.BSMemorandum"})
ClassMethod GetExportTableData(jsonObj As %String)
{
	s className=jsonObj.ClassName
	s resultJson={}
	k valArr
	s itemDataArr=[]
	s TotalCount=0
	s sub=0
	k fieldArr
	s id=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if id=""{
		if '$d(^oddCOM(className)){
			s resultJson.errorCode=-1
			s resultJson.errorMessage="表不存在"
			Quit resultJson
		}
		s fieldArr("0")={"ID":"ID","Descripts":"","Code":"ID","only":"Y","Length":"","required":"Y","DirectTable":"","CompType":"ID","notes":"系统唯一,主健","DISPLAYLIST":"","VALUELIST":"","indexDesc":""}  
		set Code=""
		for{
			set Code=$O(^oddDEF(className,"a",Code))
			quit:Code=""
			s Descripts=$P($G(^oddDEF(className,"a",Code,4))," ")
			set maxLen=$G(^oddCOM(className,"a",Code,"P","MAXLEN")) 
			set CompType=""  
			s DirectTable=$G(^oddDEF(className,"a",Code,5)) 
			if DirectTable["%" {
				set CompType=$Replace(DirectTable,"%","")
				set DirectTable=""
			}else{ 
				set CompType="DR"
			}   
			
			set required=$Case($G(^oddDEF(className,"a",Code,37)),"1":"Y",:"")
			set indexDesc=$P(..GetIndexColumn(className,Code),"^",1)
			set indexColumn=$P(..GetIndexColumn(className,Code),"^",2)
			
			set itemData={}
			set itemData.Length=maxLen
			set itemData.required=required
			set itemData.ID=Code
			set itemData.Code=Code
			set itemData.Descripts=Descripts 
			set itemData.DirectTable=DirectTable
			set itemData.CompType=CompType	
			set itemData.indexDesc=indexDesc
			set itemData.indexColumn=indexColumn
			set DISPLAYLIST=$G(^oddDEF(className,"a",Code,"P","DISPLAYLIST"))
			set itemData.DISPLAYLIST=$P(DISPLAYLIST,",",2,$L(DISPLAYLIST,","))
			set VALUELIST=$G(^oddDEF(className,"a",Code,"P","VALUELIST"))
			set itemData.VALUELIST=$P(VALUELIST,",",2,$L(VALUELIST,","))
			set itemData.notes="" ;$G(^oddDEF(className,"a",Code,4))
			set itemData.only=""
			s fieldArr(Code)=itemData  
		}
		
	}else{
		s FieldSort=$lg(^CBTableDataD(id),9)
		s globalName=$G(^oddCOM(className,"s","Default",24))
		if FieldSort'="" set FieldSort="0||0^"_FieldSort
		else  set FieldSort="0||0"
		s fieldArr("0")={"ID":"ID","Descripts":"","Code":"ID","only":"Y","Length":"","required":"Y","DirectTable":"","CompType":"ID","notes":"系统唯一,主健","DISPLAYLIST":"","VALUELIST":"","indexDesc":""}  
		for{
			s sub=$o(^CBTableDataD(id,"O",sub))	
			Quit:sub=""
			s Code=$lg(^CBTableDataD(id,"O",sub),2)
			set maxLen=$G(^oddCOM(className,"a",Code,"P","MAXLEN"))
			s Descripts=$lg(^CBTableDataD(id,"O",sub),3) 
			s DirectTable=$lg(^CBTableDataD(id,"O",sub),11)
			s CompType=$lg(^CBTableDataD(id,"O",sub),10)
			set CompType=$Case(CompType,"Text":"String","Radio":"String",:CompType)
			set required=$lg(^CBTableDataD(id,"O",sub),16)
			s itemData={}
			s itemData.ID=id_"||"_sub
			s itemData.Code=Code
			s itemData.Descripts=Descripts 
			s itemData.DirectTable=DirectTable
			s itemData.CompType=CompType
			set itemData.Length=maxLen
			set itemData.required=$Case(required,"1":"Y",:"")
			set indexDesc=$P(..GetIndexColumn(className,Code),"^",1)
			set indexColumn=$P(..GetIndexColumn(className,Code),"^",2)
			set itemData.indexDesc=indexDesc
			set itemData.indexColumn=indexColumn
			set DISPLAYLIST=$G(^oddDEF(className,"a",Code,"P","DISPLAYLIST"))
			set itemData.DISPLAYLIST=$P(DISPLAYLIST,",",2,$L(DISPLAYLIST,","))
			set VALUELIST=$G(^oddDEF(className,"a",Code,"P","VALUELIST"))
			set itemData.VALUELIST=$P(VALUELIST,",",2,$L(VALUELIST,","))
			set itemData.notes="" ;$G(^oddDEF(className,"a",Code,4))
			set itemData.only=""
			s fieldArr(sub)=itemData 
		}
	}
	b
	s key=0
	if $G(FieldSort)'=""{
		s len=$l(FieldSort,"^")
		for i=1:1:len{
			continue:'$d(fieldArr($p($p(FieldSort,"^",i),"||",2)))
			s itemData=fieldArr($p($p(FieldSort,"^",i),"||",2))
			s itemData.key=key
			s key=key+1
			do itemDataArr.%Push(itemData)
			k fieldArr($p($p(FieldSort,"^",i),"||",2))	
		}	
	} 
	b ;32
	s id=""
	for{
		s id=$o(fieldArr(id))
		quit:id=""
		s itemData=fieldArr(id)
		s itemData.key=key
		s key=key+1
		do itemDataArr.%Push(itemData)	
	}
	s resultJson.errorCode=0
	s resultJson.errorMessage=""
	s resultJson.result=itemDataArr
	Quit resultJson
}

ClassMethod GetIndexColumn(className, Code)
{
	set ret=""
	set indexCode=""
	for{
		set indexCode=$O(^oddDEF(className,"i",indexCode))
		quit:indexCode=""
		set indexColumn=$P($G(^oddDEF(className,"i",indexCode,"28")),",",1)
		if (Code=indexColumn) set ret=indexCode_"^"_$G(^oddDEF(className,"i",indexCode,"28"))
		
	}
	quit ret
}

ClassMethod GetALLTable()
{
 
	s dataJson=[]
	s id=""
	for{
		s id=$o(^oddCOM(id))
		Quit:(id="")
		continue:((id'["User.")&&(id'["src."))
		if $o(^CBTableDataI("Code",$ZCVT(id,"U"),0))'=""{
			set tableID=$o(^CBTableDataI("Code",$ZCVT(id,"U"),0))
			s Code=$lg(^CBTableDataD(tableID),2)
			s Descripts=$lg(^CBTableDataD(tableID),3) 
			s itemData={}
			s itemData.ID=id
			s itemData.Code=id
			s itemData.Desc=Descripts
			set itemData.Table=^oddCOM(id,58)
			do dataJson.%Push(itemData)
		}
		continue:$o(^CBTableDataI("Code",$ZCVT(id,"U"),0))'=""
		continue:$g(^oddCOM(id,23))'="persistent"
		s classStr=$p(id,".",2)
	
		s itemData={}
		s itemData.ID=id
		s itemData.Code=id
		s itemData.Desc=$G(^oddDEF(id,4))
		set itemData.Table=^oddCOM(id,58)
		do dataJson.%Push(itemData)
	}
	s retJson={}
	s retJson.errorCode=0
	s retJson.errorMessage=""
	s retJson.result=dataJson
	Quit retJson
}

/// w ##class(src.CBTable.CBTableData).GetExportTableData({"ClassName":"src.Rest.SYSMapInterface"})
ClassMethod GetTableDataNew(paginationStr As %String, paramsStr As %String, session As %String)
{
	try{
	s pagination=##class(%Library.DynamicObject).%FromJSON(paginationStr)
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(paramsStr)
	set sessionObj=##class(%Library.DynamicObject).%FromJSON(session)
	
	s pageSize=pagination.pageSize
	s currentPage=pagination.currentPage
	s sortColumn=pagination.sortColumn
	s sortOrder=pagination.sortOrder
	
	set hospID=sessionObj.hospID
	s className=jsonObj.ClassName
	s FindFieldVal=jsonObj.FindFieldVal
	set groupId=jsonObj.groupId
	set hospitalId=jsonObj.hospitalId
	s ParentClassName=##class(src.CBTable.CBTableFieldExt).GetParentName(className)
	if ParentClassName'=""{
		set resultObj={}
		s resultObj.errorCode=0
		s resultObj.errorMessage=""
		s resultObj.result=[]
		Quit	
	}
	s retJson={}
	s resultJson={}
	s tableDataId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if tableDataId=""{
		set resultObj={}
		s resultObj.errorCode=-1
		s resultObj.errorMessage="表不存在"
		Quit 
	}
	s sub=0
	set hospField=""
	for{
		s sub=$o(^CBTableDataD(tableDataId,"O",sub))	
		Quit:sub=""
		s Code=$lg(^CBTableDataD(tableDataId,"O",sub),2)
		s ColumnFlag=$lg(^CBTableDataD(tableDataId,"O",sub),8)
		s DataValue=$lg(^CBTableDataD(tableDataId,"O",sub),5)
		s CompType=$lg(^CBTableDataD(tableDataId,"O",sub),10)
		s DirectTable=$lg(^CBTableDataD(tableDataId,"O",sub),11)
		s DirectDataValue=$lg(^CBTableDataD(tableDataId,"O",sub),13)
		s ShowField=$lg(^CBTableDataD(tableDataId,"O",sub),12)
		b ;bb
		if ColumnFlag="Y"{
			s valArr(Code)=DataValue
			s valArr(Code,"Type")=CompType
			s valArr(Code,"DirectTable")=DirectTable
			s valArr(Code,"DirectDataValue")=DirectDataValue
			s valArr(Code,"ShowField")=ShowField
		}
		s valFindArr(Code)=DataValue
		s valFindArr(Code,"Type")=CompType
		s valFindArr(Code,"DirectTable")=DirectTable
		s valFindArr(Code,"DirectDataValue")=DirectDataValue
		s valFindArr(Code,"ShowField")=ShowField
	
		if DirectTable="User.CBHospital"{
			set hospField=DataValue
		}
	}
	b ;aaa
	//组织查询sql语句
	//1.判断该表里是否有指向医院的字段，指向科室的字段，拼成按医院查询的数据
	set sqlStr="select name as name,SqlFieldName as sqlFieldName,parent->SqlQualifiedNameQ as sqlQualifiedNameQ,Type as dataType from %Dictionary.CompiledProperty where parent=? "
	set sqlObj=##class(%SQL.Statement).%New()
	set sc=sqlObj.%Prepare(sqlStr)
	set list=sqlObj.%Execute(className)
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
	b ;2323
	if currentPage="" s currentPage=1
	if pageSize="" set pageSize=20
	
	//拼查询结果串
	set showSqlStr="ID as ID"
	set fieldCode=0
	for{
		s fieldCode=$o(valArr(fieldCode))
		Quit:fieldCode=""
		set compType=valArr(fieldCode,"Type")
		set showField=valArr(fieldCode,"ShowField")
		if compType="DR"{
			s DirectTable=valArr(fieldCode,"DirectTable")
			
			if (DirectTable'=""){
				set itemStr=tableProperyArr(fieldCode)_"->"_showField_" as "_fieldCode_"Desc"
			}else{
				set itemStr=tableProperyArr(fieldCode)_" as "_fieldCode_"Desc"	
			}
			
		}else{
			set itemStr=tableProperyArr(fieldCode)_" as "_fieldCode
		}
		
		set showSqlStr=showSqlStr_","_itemStr
	}
	
	//set findSqlStr="select top "_pageSize_" "_showSqlStr_" from "_sqlTableName_"where ID not in (" 
	//set findSqlStr=findSqlStr_"select top "_((currentPage-1)*pageSize)_" ID from  "_sqlTableName_" where 1=1"
	
	set findSqlStr="select top all count(id) as totalCount,"_showSqlStr_" from "_sqlTableName_" where 1=1" 
	if hospField'=""{
		set findSqlStr=findSqlStr_" and "_hospField_"="_hospID
	}else{
		if locField'=""{
			set findSqlStr=findSqlStr_" and "_locField_"->Hosp_Dr="_hospID
		}	
	}
	set curDate=+$h
	//拼查询条件
	if $ISOBJECT(FindFieldVal){
		s iter=FindFieldVal.%GetIterator()
		while iter.%GetNext(.key,.value){
			
			//拼是否有效sql
			set fieldValue=value
			set findFileName=$g(tableProperyArr(key))
			continue:findFileName=""
			if findFileName="DataAvail"{
				if $d(tableProperyArr("StartDate")){
					if fieldValue=1{
						//查询有效的数据
						set findSqlStr=findSqlStr_" and (StartDate is null or StartDate<="_curDate_") and (StopDate is null or StopDate>="_curDate_")"
					}elseif fieldValue=0{
						//查询无效的数据
						set findSqlStr=findSqlStr_" and ((StartDate is not null and StartDate>"_curDate_") or (StopDate is not null and StopDate<"_curDate_"))"
					}	
				}else{
						
				}
			}else{
				if fieldValue'=""{
					s CompType=valFindArr(fieldName,"Type")	
					if CompType="Text"{
						set findSqlStr=findSqlStr_" "_findFileName_" like '%"_fieldValue_"%'"	
					}else{
						set findSqlStr=findSqlStr_" "_findFileName_"='"_fieldValue_"'"		
					}
				}	
			}
				
		}
	}
	set findSqlStr=findSqlStr_" order by ID"
	
	set startNum=(currentPage-1)*pageSize
	set endNum=(currentPage)*pageSize
	
	set newSqlStr="select * from ("_findSqlStr_") where %vid between "_startNum_" and "_endNum
	
	
	///执行sql语句
	set sqlObj=##class(%SQL.Statement).%New(1)
	set sc=sqlObj.%Prepare(newSqlStr)
	set list=sqlObj.%Execute()
	b ;545
	set data=[]
	set count=0
	while list.%Next(){
		set totalCount=list.totalCount
		//s count=count+1
		//continue:(+pageSize>0)&&((count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize)))
		set itemData={}
		set fieldCode=0
		for{
			s fieldCode=$o(valArr(fieldCode))
			Quit:fieldCode=""
			s compType=valArr(fieldCode,"Type")
			if compType="DR"{
				set $Property(itemData,fieldCode_"Desc")=list.%Get(fieldCode_"Desc")
			}else{
				set $Property(itemData,fieldCode)=list.%Get(fieldCode)
			}
		}
		do data.%Push(itemData)	
	}
	b ;2322
		s resultJson.TotalCount=count
		s resultJson.Data=data
		set resultObj={}
		s resultObj.errorCode=0
		s resultObj.errorMessage=""
		s resultObj.result=resultJson
		Quit 
	
	}catch(e){
		set status=e.AsStatus()
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	   	set resultObj={}
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=errorMessage    //##class(src.Interface.Message).GetErrorMessage("01040044")		
	}
	Quit resultObj
}

ClassMethod GetSelectDataNew(jsonStr As %String, session As %String)
{
	set $zt="error"
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s className=jsonObj.ClassName
	set groupId=jsonObj.groupId
	set hospitalId=jsonObj.hospitalId
	set hospID=session.hospID
	
	set sqlStr="select CompType as compType,DirectTable as directTable,ShowField as showField,Required as required,RelationFieldDrStr as relationFieldDrStr,RelationTableField as relationTableField  "
	set sqlStr=sqlStr_" from SQLUSER.CB_TableFieldExt where CBTFE_ParRef->Code=? and EditFlag!='Y' and (CompType='DR' or CompType='Select')"
	set sqlObj=##class(%SQL.Statement).%New()
	set sc=sqlObj.%Prepare(sqlStr)
	set list=sqlObj.%Execute(className)
	while list.%Next(){
		set compType=list.%Get("compType")	
		set directTable=list.%Get("directTable")
		set showField=list.%Get("showField")
		set required=list.%Get("required")
		set relationFieldDrStr=list.%Get("relationFieldDrStr")
		set relationTableField=list.%Get("relationTableField")
		
		if CompType="DR"{
			
			set sql="select"
			
		}else{
				
		}
	}
	//s ID=jsonObj.ID
	
	s resultJson={}
	s TableId=$o(^CBTableDataI("Code",$ZCVT(className,"U"),0))
	if TableId=""{
		s resultJson.errorCode=-1
		s resultJson.errorMessage="表不存在"
		Quit resultJson
	}
	s globalName=^oddCOM(className,"s","Default",24) 
	k valArr
	s itemDataArr=[]
	s TotalCount=0
	s sub=0
	for{
		s sub=$o(^CBTableDataD(TableId,"O",sub))	
		Quit:sub=""
		s EditFlag=$lg(^CBTableDataD(TableId,"O",sub),7)
		continue:EditFlag'="Y"
		s Code=$lg(^CBTableDataD(TableId,"O",sub),2)
		s CompType=$lg(^CBTableDataD(TableId,"O",sub),10)
		continue:(CompType'="DR")&&(CompType'="Select")
		s DataValue=$lg(^CBTableDataD(TableId,"O",sub),5)
		s DirectTable=$lg(^CBTableDataD(TableId,"O",sub),11)
		s ShowField=$lg(^CBTableDataD(TableId,"O",sub),12)
		s DirectDataValue=$lg(^CBTableDataD(TableId,"O",sub),13)
		continue:(CompType="DR")&&(DirectDataValue="")
		
		set Required=$g(^oddDEF(className,"a",Code,37))
		
		s RelationFieldDr= $lg(^CBTableDataD(TableId,"O",sub),18)
		s RelationTableField=$lg(^CBTableDataD(TableId,"O",sub),19)
		s ShowField=""
		if RelationFieldDr'=""{
			set ShowField=""
			for i=1:1:$l(RelationFieldDr,"^"){
				if ShowField="" s ShowField=$lg(^CBTableDataD(+$p(RelationFieldDr,"^",i),"O",$p($p(RelationFieldDr,"^",i),"||",2)),2)
				else  s ShowField=ShowField_"^"_$lg(^CBTableDataD(+$p(RelationFieldDr,"^",i),"O",$p($p(RelationFieldDr,"^",i),"||",2)),2)
			}
			//s ShowField=$lg(^CBTableDataD(+RelationFieldDr,"O",$p(RelationFieldDr,"||",2)),2)
		}
		s selectArr=[]
		if CompType="DR" {
			s NullFlag=1
			if Required=1{
				s NullFlag=0	
			}
			if (DirectTable="User.CBHospital")&&(hospID'=""){
				set hospStr=##class(src.CBTable.CBTableData).GetHosptialAuth(groupId,hospID,className)
				if hospStr="" set hospStr=hospID
				if hospStr'=""{
					for i=1:1:$l(hospStr,"^"){
						set hospId=$p(hospStr,"^",i)
						continue:hospId=""
						
						s hospObj=$CLASSMETHOD("User.CBHospital","%OpenId",hospId)
						
						s Desc=$PROPERTY(hospObj,"Descripts")
						if Desc=""{
							s Desc=$PROPERTY(hospObj,"Code")	
						}
			
						s StartDate=$PROPERTY(hospObj,"StartDate")
						s StopDate=$PROPERTY(hospObj,"StopDate")
						
						continue:(StartDate'="")&&(StartDate>(+$h))
						continue:(StopDate'="")&&(StopDate<(+$h))
						continue:Desc=""
						set itemData={}
						s Alias=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(Desc)
						s itemData.ID=hospId
						s itemData.Desc=Desc
						s itemData.Alias=Alias
						if (ShowField'="")&&(ValueField'=""){
							for i=1:1:$l(ShowField,"^"){
								if $ISOBJECT($PROPERTY(hospObj,$p(ValueField,"^",i))){
									s $PROPERTY(itemData,$p(ShowField,"^",i))=$PROPERTY(hospObj,$p(ValueField,"^",i)).%Id()	
								}else{
									s $PROPERTY(itemData,$p(ShowField,"^",i))=""	
								}	
							}
						}
						do selectArr.%Push(itemData)
					}
					
				}else{
						
				}
			}else{
				
				s dataJson=##class(src.CBTable.CBTableFieldExt).GetJsonByClassName(DirectTable,NullFlag,ShowField,RelationTableField,hospID)
				s selectArr=dataJson	
			}
			
			/*s globalName=^oddCOM(DirectTable,"s","Default",24) 
			s id=0
			s dataJson={}
			s dataJson.ID="0"
			s dataJson.Desc="空"
			//do selectArr.%Push(dataJson)
			for{
				s id=$o(@(globalName_"("_id_")"))
				Quit:id=""	
				s itemData=@(globalName_"("_id_")")
				s ShowValue=$lg(itemData,DirectDataValue)
				s dataJson={}
				s dataJson.ID=id
				s dataJson.Desc=ShowValue
				do selectArr.%Push(dataJson)
			}*/
		}else{
			s displayList=$g(^oddCOM(className,"a",Code,"P","DISPLAYLIST"))
			s valueList=$g(^oddCOM(className,"a",Code,"P","VALUELIST"))	
			for i=1:1:$l(valueList,","){
				s dataJson={}
				s dataJson.ID=$p(valueList,",",i)
				s dataJson.Desc=$p(displayList,",",i)
				if dataJson.Desc="" {
					s dataJson.Desc="空"
					s dataJson.ID="0"
				}
				do selectArr.%Push(dataJson)	
			}
			
		}
		s $PROPERTY(resultJson,Code)=selectArr
	}
	s retJson={}
	s retJson.errorCode=0
	s retJson.errorMessage=""
	s retJson.result=resultJson
	Quit retJson
error
	s retJson={}
	s retJson.errorCode="-1"
	s retJson.errorMessage=$ze
	Quit retJson
}

/// w ##class(src.CBTable.CBTableData).Test12() 
ClassMethod Test12()
{
	set jsonObj={"params":[{"ClassName":"User.CBOrderAlias","FindFieldVal":{"DataAvail":""},"groupId":"","hospitalId":""}],"pagination":[{"pageSize":20,"currentPage":100,"sortColumn":"","sortOrder":""}],"code":"4003","session":[{"userID":"1","locID":"1","groupID":"3","hospID":"25","sessionID":"TLfa3Ianhb","hospCode":"H03","language":"CN","hostName":"","ipv4":"182.254.131.121","ipv6":"","mac":""}]}
	set postParams=jsonObj.params.%Get(0)
	set postPagination=jsonObj.pagination.%Get(0)
	set session=jsonObj.session.%Get(0)
	set ret=##class(src.CBTable.CBTableData).GetTableDataNew(postPagination.%ToJSON(),postParams.%ToJSON(),session.%ToJSON())
	b ;434
	Quit ret.%ToJSON()
	
	
	set jsonObj={"params":[{"ClassName":"User.HBMedItemLis","groupId":"","hospitalId":""}],"code":"4001","session":[{"userID":"1","locID":"1","groupID":"3","hospID":"25","sessionID":"c6jjZW0SRP","hospCode":"H03","language":"CN","hostName":"","ipv4":"182.254.131.121","ipv6":"","mac":""}]}
	set postParams=jsonObj.params.%Get(0)
	set session=jsonObj.session.%Get(0)
	set ret=##class(src.CBTable.CBTableData).GetFindField(postParams.%ToJSON(),session.%ToJSON())
	Quit ret.%ToJSON()
	
	set jsonObj={"params":[{"ClassName":"User.HBOperationRoom","groupId":"","hospitalId":""}],"code":"4007","session":[{"userID":"1","locID":"101","groupID":"3","hospID":"62","sessionID":"IG0wLjqmGT","hospCode":"H19","language":"CN","hostName":"","ipv4":"182.254.131.121","ipv6":"","mac":""}]}
	set postParams=jsonObj.params.%Get(0)
	set session=jsonObj.session.%Get(0)
	set ret= ##class(src.CBTable.CBTableData).GetSelectData(postParams.%ToJSON(),session.%ToJSON())
	Quit ret.%ToJSON()
}

/// w ##class(src.CBTable.CBTableData).Test13() 
ClassMethod Test13()
{
	//b ;aa
	//&sql(select count(id) from SQLUSER.BS_ChangedTableData)
	//b ;bb
	
	set sql="select * from SQLUSER.CB_Village"
	
	w $zd(+$h,3)_" "_$zt($p($h,",",2)),!
	//set sql="select * from SQLUSER.BS_ChangedTableData"
	set sqlObj=##class(%SQL.Statement).%New()
	set sc=sqlObj.%Prepare(sql)
	set list=sqlObj.%Execute()
	while list.%Next(){
		set id=list.%Get("ID")
		//w id,!
	}
	w $zd(+$h,3)_" "_$zt($p($h,",",2)),!
	b ;545
	Quit 0
}

}
