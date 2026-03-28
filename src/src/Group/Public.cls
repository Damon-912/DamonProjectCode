Class src.Group.Public Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// w ##class(src.Group.MenuDetail).FindDataPosition("User.CBGroup")
ClassMethod FindDataPosition(ClassName As %String) As %Library.DynamicObject
{
	s storage=^oddCOM(ClassName,59)
	s defaultData=^oddCOM(ClassName,"s",storage,22)
	s prop={}
	s index=1
	for{
		s index=$o(^oddCOM(ClassName,"s",storage,"D",defaultData,"V",index)) 
		Quit:index=""
		s Property=^oddCOM(ClassName,"s",storage,"D",defaultData,"V",index,21)
		s dataType=^oddCOM(ClassName,"a",Property,5)
		if dataType["User."{
			//s $PROPERTY(prop,Property_"Desc")=##class(src.Group.Public).GetDescIndex(ClassName)	
		
			s fieldIndex=##class(src.Group.Public).GetDescIndex(ClassName)
			if fieldIndex'="" {
				s itemJson={}
				s itemJson.index=index
				s itemJson.descClassName=dataType
				s itemJson.descField="Descripts"
				s itemJson.fieldIndex=fieldIndex
				s $PROPERTY(prop,Property)=itemJson	
			}
			
		}else{
			s $PROPERTY(prop,Property)=index	
		}
		
		
	}
	Quit prop
}

/// w ##class(src.Group.MenuDetail).Find("User.CBMenuDetail",params)
ClassMethod Find(className As %String, paginationStr As %String, paramsStr As %String)
{
	Set $ZT="ERROR"
	s params=paramsStr //##class(%Library.DynamicObject).%FromJSON(paramsStr)
	//s FieldJson=##class(src.Group.Public).FindDataPosition(className)
	w className,!
	do ##class(src.Group.Public).FindDataPositionNew(className,.postdata)
	s pagination=paginationStr //##class(%Library.DynamicObject).%FromJSON(paginationStr)
	
	s pageSize=pagination.pageSize
	s currentPage=pagination.currentPage
	s sortColumn=pagination.sortColumn
	s sortOrder=pagination.sortOrder
	//if sortColumn="" s sortColumn="Code"
	//s sortOrder="desc"
	s resultArr=[]
	s TotalCount=0
	k dataJsonArr
	s id=0
	for{
		s id=$o(@("^"_$p(className,".",2)_"D("_id_")"))
		Quit:id=""
		set iter = params.%GetIterator()
		s dataJson={}
		s flag=0
		s count=0
		while iter.%GetNext(.key , .value ) {
			s val=$lg(@("^"_$p(className,".",2)_"D("_id_")"),postdata(key))
			s count=count+1
			continue:(value'="")&&(val'[value) 
			s flag=flag+1
		}
		continue:flag'=count
		//s itemJson=##class(src.Group.Public).FindOne(className,id,.FieldJson)
		
		s itemJson=##class(src.Group.Public).FindOneNew(className,id,.postdata)
		
		if sortColumn'=""{
			s ColumnVal=$PROPERTY(itemJson,sortColumn)
			if ColumnVal=""{	
				s dataJsonArr("ZZZZZ",id)=itemJson
			}else{
				if sortColumn="Code"{
					s dataJsonArr("Z"_ColumnVal,id)=itemJson
				}else{
					s dataJsonArr(ColumnVal,id)=itemJson	
				}	
			}	
		}else{
			s dataJsonArr(1,id)=itemJson	
		}
		
		//do resultArr.%Push(itemJson)
		s TotalCount=TotalCount+1
	}
	b ;1212
	s globalSort=1
	s index=0
	if sortOrder["desc"{
		s index=""
		s globalSort=-1	
	}
	if currentPage="" s currentPage=1
	s count=0
	for{
		s index=$o(dataJsonArr(index),globalSort)	 
		Quit:index=""
		s id=0
		for{
			s id=$o(dataJsonArr(index,id))
			Quit:id=""
			s itemJson=dataJsonArr(index,id)
			s count=count+1
			continue:(+pageSize>0)&&((count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize)))
			do resultArr.%Push(itemJson)
			//w count,!
		}
	}
	
	s resultJson={}
	s resultJson.TotalCount=TotalCount
	s resultJson.Data=resultArr
	s retJson={}
	s retJson.errorCode=0
	s retJson.errorMessage=0
	s retJson.result=resultJson
	Quit retJson
ERROR
	s retJson={}
	s retJson.errorCode=-100
	s retJson.errorMessage=$ze
	Quit retJson
}

/// w ##class(src.Group.MenuDetail).FindOne("User.CBGroup",6)
ClassMethod FindOne(ClassName As %String, rowid As %String, ByRef FieldJson As %Library.DynamicObject) As %Library.DynamicObject
{
	//s FieldJson=##class(src.Group.Public).FindDataPosition(ClassName)
	//quit {}
	set iter = FieldJson.%GetIterator()
	s dataJson={}
	s dataJson.ID=rowid
	s itemData=@("^"_$p(ClassName,".",2)_"D("_rowid_")")
	while iter.%GetNext(.key , .value ) {
		s PropName=key
		
		s dataType=^oddCOM(ClassName,"a",PropName,5)
		if dataType["User."{
			
			s PropIndex=value.index
			s dataValue=$lg(itemData,PropIndex)
			s $PROPERTY(dataJson,PropName)=dataValue
			
			if dataValue'=""{
				s descPropName=value.descField
				s descPropIndex=value.fieldIndex
				s descClassName=value.descClassName
				s descItemData=@("^"_$p(descClassName,".",2)_"D("_dataValue_")")
				s $PROPERTY(dataJson,PropName_"Desc")=$lg(itemData,descPropIndex)
			}else{
				s $PROPERTY(dataJson,PropName_"Desc")=""	
			}
			
		}else{
			s PropIndex=value
			s dataValue=$lg(itemData,PropIndex)
			if dataType["Date"{
				if dataValue'=""{
					s $PROPERTY(dataJson,PropName)=$zd(dataValue,3)	
				}else{
					s $PROPERTY(dataJson,PropName)=""
				}
			
			}elseif dataType["Time"{
				if dataValue'=""{
					s $PROPERTY(dataJson,PropName)=$zt(dataValue)	
				}else{
					s $PROPERTY(dataJson,PropName)=""
				}	
			}else{
				s $PROPERTY(dataJson,PropName)=dataValue	
			}	
		}
	}
	Quit dataJson
}

/// w ##class(src.Group.MenuDetail).FindOne("User.CBGroup",6)
ClassMethod FindOneNew(ClassName As %String, rowid As %String, ByRef postData As %Library.DynamicObject) As %Library.DynamicObject
{
	//s FieldJson=##class(src.Group.Public).FindDataPosition(ClassName)
	//quit {}
	//set iter = FieldJson.%GetIterator()
	s dataJson={}
	
	s itemData=@("^"_$p(ClassName,".",2)_"D("_rowid_")")
	s PropName=""
	s dataJson.ID=rowid
	for {
		s PropName=$o(postData(PropName))
		Quit:PropName=""
		s PropIndex=postData(PropName)
		s dataType=^oddCOM(ClassName,"a",PropName,5)
		s dataValue=$lg(itemData,PropIndex)
		s $PROPERTY(dataJson,PropName)=dataValue
		if dataType["User."{
			
			s PropIndex=postData(PropName)
			s dataValue=$lg(itemData,PropIndex)
			s $PROPERTY(dataJson,PropName)=dataValue
			
			if dataValue'=""{
				s descPropName=postData(PropName,"descField")
				s descPropIndex=postData(PropName,"fieldIndex")
				s descClassName=postData(PropName,"descClassName")
				s descItemData=$g(@("^"_$p(descClassName,".",2)_"D("_dataValue_")"))
				s $PROPERTY(dataJson,PropName_"Desc")=$lg(descItemData,descPropIndex)	
			}else{
				s $PROPERTY(dataJson,PropName_"Desc")=""	
			}
			
		}else{
			s PropIndex=postData(PropName)
			s dataValue=$lg(itemData,PropIndex)
			if dataType["Date"{
				if dataValue'=""{
					s $PROPERTY(dataJson,PropName)=$zd(dataValue,3)	
				}else{
					s $PROPERTY(dataJson,PropName)=""
				}
			
			}elseif dataType["Time"{
				if dataValue'=""{
					s $PROPERTY(dataJson,PropName)=$zt(dataValue)	
				}else{
					s $PROPERTY(dataJson,PropName)=""
				}	
			}else{
				s $PROPERTY(dataJson,PropName)=dataValue	
			}	
		}
	}
	Quit dataJson
}

ClassMethod GetDescById(className As %String, rowid As %String)
{
	s storage=^oddCOM(className,59)
	s defaultData=^oddCOM(className,"s",storage,22)
	s prop={}
	s index=1
	s desc=""
	for{
		s index=$o(^oddCOM(className,"s",storage,"D",defaultData,"V",index)) 
		Quit:index=""
		s Property=^oddCOM(className,"s",storage,"D",defaultData,"V",index,21)
		continue:Property'="Descripts"
		s desc=$lg($g(@("^"_$p(className,".",2)_"D("_rowid_")")),index)
		Quit 
	}
	///w $o(a_"(0)")
	Quit desc
}

ClassMethod GetDescIndex(className As %String)
{
	n (className)
	s storage=^oddCOM(className,59)
	s defaultData=^oddCOM(className,"s",storage,22)
	s prop={}
	s index=1
	s fieldIndex=""
	s desc=""
	for{
		s index=$o(^oddCOM(className,"s",storage,"D",defaultData,"V",index)) 
		Quit:index=""
		s Property=^oddCOM(className,"s",storage,"D",defaultData,"V",index,21)
		continue:Property'="Descripts"
		s fieldIndex=index
		Quit 
	}
	///w $o(a_"(0)")
	Quit fieldIndex
}

/// w ##class(src.Group.Public).FindDataPositionNew("User.CBGroup",.data)
ClassMethod FindDataPositionNew(ClassName As %String, ByRef DataPostArr) As %Library.DynamicObject
{
	s storage=^oddCOM(ClassName,59)
	s defaultData=^oddCOM(ClassName,"s",storage,22)
	s prop={}
	s index=1
	for{
		s index=$o(^oddCOM(ClassName,"s",storage,"D",defaultData,"V",index)) 
		Quit:index=""
		s Property=^oddCOM(ClassName,"s",storage,"D",defaultData,"V",index,21)
		s dataType=^oddCOM(ClassName,"a",Property,5)
		if dataType["User."{
			//s $PROPERTY(prop,Property_"Desc")=##class(src.Group.Public).GetDescIndex(ClassName)	
			s DataPostArr(Property)=index
			s fieldIndex=##class(src.Group.Public).GetDescIndex(ClassName)
			if fieldIndex'="" {
				s DataPostArr(Property,"descClassName")=dataType
				s DataPostArr(Property,"descField")="Descripts"
				s DataPostArr(Property,"fieldIndex")=fieldIndex
			}
			
		}else{
			s DataPostArr(Property)=index
		}
	}
	Quit 0
}

ClassMethod FindOneItem(className As %String, rowid As %String)
{
	do ##class(src.Group.Public).FindDataPositionNew(className,.postData)
	s ret=##class(src.Group.Public).FindOneNew(className,rowid,.postData)
	Quit ret
}

/// w ##class(src.Group.Public).GetGroupMenu({"GroupDr":1,"Type":"2","LocDr":345})
ClassMethod GetGroupMenu(jsonStr As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s resultJson={}
	
	s GroupDr=jsonObj.GroupDr
	s Type=jsonObj.Type
	s LocDr=jsonObj.LocDr
	s child=0
	//s GroupMenuId=""
	b ;1212
	s subJsonArr=[]
	k subArr
	k menuSortArr
	set menuSortStr=""
	for{
		s child=$o(^CBGroupD(GroupDr,"O",child))
		Quit:child=""	
		continue:$g(^CBGroupD(GroupDr,"O",child))=""
		s menuType=$lg(^CBGroupD(GroupDr,"O",child),3)
		continue:(menuType'=Type)&&(Type'="")
		set menuSortStr=$lg(^CBGroupD(GroupDr,"O",child),6)
		s sub=0
		for{
			s sub=$o(^CBGroupD(GroupDr,"O",child,"M",sub))
			Quit:sub=""
			s PreMenuGroupDr=$lg(^CBGroupD(GroupDr,"O",child,"M",sub),5)	
			continue:PreMenuGroupDr'=""
			//s MenuLocDr=$lg(^CBGroupD(GroupDr,"O",child,"M",sub),4)
			//continue:(MenuLocDr'=LocDr)&&(MenuLocDr'="")
					
			s MenuDetailDr=$lg(^CBGroupD(GroupDr,"O",child,"M",sub),3)
			continue:MenuDetailDr=""
			continue:$g(^CBMenuDetailD(MenuDetailDr))=""
			
			set locFlag=1
			set locSub=0
			for{
				set locSub=$o(^CBGroupD(GroupDr,"O",child,"M",sub,"L",locSub))
				Quit:locSub=""
				set menuLocData=$g(^CBGroupD(GroupDr,"O",child,"M",sub,"L",locSub))
				continue:menuLocData=""
				set locFlag=0
				set menuLocID=$lg(menuLocData,2)
				if menuLocID=LocDr{
					set locFlag=1
					Quit 	
				}
			}
			continue:locFlag'=1
			s Code=$lg(^CBMenuDetailD(MenuDetailDr),2)
			s MenuDetailDrDesc=$lg(^CBMenuDetailD(MenuDetailDr),3)
			s ENDesc=$lg(^CBMenuDetailD(MenuDetailDr),4)
			s LinkAddress=$lg(^CBMenuDetailD(MenuDetailDr),5)
			s LinkPath=$lg(^CBMenuDetailD(MenuDetailDr),6)
			s Image=$lg(^CBMenuDetailD(MenuDetailDr),9)
			s WinPosition=$lg(^CBMenuDetailD(MenuDetailDr),12)
			s BackMethod=$lg(^CBMenuDetailD(MenuDetailDr),13)
			s Paras=$lg(^CBMenuDetailD(MenuDetailDr),14)
			s CondExpress=$lg(^CBMenuDetailD(MenuDetailDr),15)
			s JSMethod=$lg(^CBMenuDetailD(MenuDetailDr),16)
			s Tooltip=$lg(^CBMenuDetailD(MenuDetailDr),17)
			
			
			s SeqNo=$lg(^CBGroupD(GroupDr,"O",child,"M",sub),2)
			if SeqNo="" s SeqNo=9999
			s subJson={}
			s subJson.ID=GroupDr_"||"_child_"||"_sub
			s subJson.title=MenuDetailDrDesc
			s subJson.ENDesc=ENDesc
			if LinkAddress["../"{
				s LinkAddress=$p(LinkAddress,"../",2)	
			}
			s LinkPath="/"_Code
			s subJson.path="/"_Code    //LinkPath
			s subJson.code=Code
			s subJson.component=LinkAddress
			s subJson.icon=Image
			s subJson.WinPosition=WinPosition
			s subJson.BackMethod=BackMethod
			
			s ParaJson={}
			if Paras'=""{
				for i=1:1:$l(Paras,","){
					s itemPara=$p(Paras,",",i)	
					continue:itemPara=""
					s $PROPERTY(ParaJson,$p(itemPara,"=",1))=$p(itemPara,"=",2)
				}		
			}
			s subJson.Paras=ParaJson
			s subJson.CondExpress=CondExpress
			s subJson.BackMethod=BackMethod
			s subJson.JSMethod=JSMethod
			s subJson.Tooltip=Tooltip
			
			s GroupMenuFlag=$lg(^CBMenuDetailD(MenuDetailDr),8)
			if GroupMenuFlag="Y"{
				s retJson=##class(src.Group.Public).GetGroupChildMenu(GroupDr_"||"_child_"||"_sub,LinkPath,LocDr )	
				s subJson.subs=retJson
			}
			s menuSortArr(sub)=subJson
			//do subJsonArr.%Push(subJson)
			
		}
		Quit
	}
	
	if menuSortStr'=""{
		for i=1:1:$l(menuSortStr,"^"){
			set subJson=$g(menuSortArr($p($p(menuSortStr,"^",i),"||",3)))
			continue:subJson=""
			do subJsonArr.%Push(subJson)	
			k menuSortArr($p($p(menuSortStr,"^",i),"||",3))
		}	
	}
	set id=0
	for{
		set id=$o(menuSortArr(id))
		Quit:id=""
		do subJsonArr.%Push(menuSortArr(id))		
	}
	
	
	s resultObj={}
	s resultObj.errorCode=0
	s resultObj.errorMessage=""
	s resultData=[]
	s resultData=subJsonArr
	s resultObj.result=resultData
	
	Quit resultObj
}

/// w ##class(src.Group.CBGroupMenuSub).GetChildMenu("2||6||2")
ClassMethod GetGroupChildMenu(MenuGroupId As %String, LinkPathStr As %String, locID As %String)
{
	n (MenuGroupId,LinkPathStr,locID)
	s GroupId=+MenuGroupId
	s GroupChild=$p(MenuGroupId,"||",2)
	s childarr=[]
	k childItemArr
	s sub=0
	k menuSortArr
	for{
		s sub=$o(^CBGroupMenuSubI("PreMenu",MenuGroupId,GroupId,GroupChild,sub))
		Quit:sub=""
		
		s MenuId=$lg(^CBGroupD(GroupId,"O",GroupChild,"M",sub),3)
		continue:$g(^CBMenuDetailD(MenuId))=""
		s GroupMenuFlag=$lg(^CBMenuDetailD(MenuId),8)
		
		s MenuDetailDr=$lg(^CBGroupD(GroupId,"O",GroupChild,"M",sub),3)
		continue:MenuDetailDr=""
		set locFlag=1
		set locSub=0
		for{
			set locSub=$o(^CBGroupD(GroupId,"O",GroupChild,"M",sub,"L",locSub))
			Quit:locSub=""
			set menuLocData=$g(^CBGroupD(GroupId,"O",GroupChild,"M",sub,"L",locSub))
			continue:menuLocData=""
			set locFlag=0
			set menuLocID=$lg(menuLocData,2)
			if menuLocID=locID{
				set locFlag=1
				Quit 	
			}
		}
		continue:locFlag'=1
		s Code=$lg(^CBMenuDetailD(MenuDetailDr),2)	
		s MenuDetailDrDesc=$lg(^CBMenuDetailD(MenuDetailDr),3)
		s ENDesc=$lg(^CBMenuDetailD(MenuDetailDr),4)
		s LinkAddress=$lg(^CBMenuDetailD(MenuDetailDr),5)
		s LinkPath=$lg(^CBMenuDetailD(MenuDetailDr),6)
		s Image=$lg(^CBMenuDetailD(MenuDetailDr),9)
		s WinPosition=$lg(^CBMenuDetailD(MenuDetailDr),12)
		s BackMethod=$lg(^CBMenuDetailD(MenuDetailDr),13)
		s Paras=$lg(^CBMenuDetailD(MenuDetailDr),14)
		s CondExpress=$lg(^CBMenuDetailD(MenuDetailDr),15)
		s JSMethod=$lg(^CBMenuDetailD(MenuDetailDr),16)
		s Tooltip=$lg(^CBMenuDetailD(MenuDetailDr),17)
			
			
		s SeqNo=$lg(^CBGroupD(GroupId,"O",GroupChild,"M",sub),2)
		if SeqNo="" s SeqNo=9999
		s subJson={}
		s subJson.ID=GroupId_"||"_GroupChild_"||"_sub
		s subJson.title=MenuDetailDrDesc
		s subJson.ENDesc=ENDesc
		if LinkAddress["../"{
			s LinkAddress=$p(LinkAddress,"../",2)	
		}
		s LinkPath="/"_Code
		if LinkPath'["/" s LinkPath="/"_LinkPath
		if LinkPathStr'=""{
			s subJson.path=LinkPathStr_LinkPath	
		}else{
			s subJson.path=LinkPath
		}
		s subJson.component=LinkAddress
		s subJson.icon=Image
		s subJson.WinPosition=WinPosition
		s subJson.BackMethod=BackMethod
		s ParaJson={}
		if Paras'=""{
			for i=1:1:$l(Paras,","){
				s itemPara=$p(Paras,",",i)	
				continue:itemPara=""
				s $PROPERTY(ParaJson,$p(itemPara,"=",1))=$p(itemPara,"=",2)
			}		
		}
		s subJson.Paras=ParaJson
		s subJson.CondExpress=CondExpress
		s subJson.BackMethod=BackMethod
		s subJson.JSMethod=JSMethod
		s subJson.Tooltip=Tooltip
		
		
		if GroupMenuFlag="Y"{
			s MenuDetailDr=$lg(^CBGroupD(GroupId,"O",GroupChild,"M",sub),3)
			s MenuDetailDrDesc=""
			if MenuDetailDr'=""{
				s MenuDetailDrDesc=$lg(^CBMenuDetailD(MenuDetailDr),3)
			}
			s jsonret=##class(src.Group.Public).GetGroupChildMenu(GroupId_"||"_GroupChild_"||"_sub,LinkPathStr_LinkPath)	
			s subJson.subs=jsonret
			//do childarr.%Push(subJson)
		}else{
			//do childarr.%Push(subJson)
		}
		s menuSortArr(sub)=subJson
	}
	set menuSortStr=$lg(^CBGroupD(+MenuGroupId,"O",$p(MenuGroupId,"||",2),"M",$p(MenuGroupId,"||",3)),9)
	if menuSortStr'=""{
		for i=1:1:$l(menuSortStr,"^"){
			set subJson=$g(menuSortArr($p($p(menuSortStr,"^",i),"||",3)))
			continue:subJson=""
			do childarr.%Push(subJson)	
			k menuSortArr($p($p(menuSortStr,"^",i),"||",3))
		}	
	}
	set id=0
	for{
		set id=$o(menuSortArr(id))
		Quit:id=""
		do childarr.%Push(menuSortArr(id))		
	}
	
	
	Quit childarr
}

/// w ##class(src.Group.Public).GetGroupRouter(^XYSRESTMAP(20190128,1776,142606,"INPUT"))
ClassMethod GetGroupRouter(jsonStr As %String)
{
	s jsonObj=##class(%Library.DynamicObject).%FromJSON(jsonStr)
	s resultJson={}
	
	s GroupDr=jsonObj.GroupDr
	s Type=jsonObj.Type
	s LocDr=jsonObj.LocDr
	s child=0
	s routerArr=[]
	//s GroupMenuId=""
	s subJsonArr=[]
	for{
		s child=$o(^CBGroupD(GroupDr,"O",child))
		Quit:child=""
		continue:$g(^CBGroupD(GroupDr,"O",child))=""	
		s menuType=$lg(^CBGroupD(GroupDr,"O",child),3)
		continue:(menuType'=Type)&&(Type'="")
		
		s sub=0
		for{
			s sub=$o(^CBGroupD(GroupDr,"O",child,"M",sub))
			Quit:sub=""
			s PreMenuGroupDr=$lg(^CBGroupD(GroupDr,"O",child,"M",sub),5)	
			continue:PreMenuGroupDr'=""
			s MenuLocDr=$lg(^CBGroupD(GroupDr,"O",child,"M",sub),4)
			continue:(MenuLocDr'=LocDr)&&(MenuLocDr'="")
			s MenuDetailDr=$lg(^CBGroupD(GroupDr,"O",child,"M",sub),3)
			continue:MenuDetailDr=""
			continue:$g(^CBMenuDetailD(MenuDetailDr))=""
			set locFlag=1
			set locSub=0
			for{
				set locSub=$o(^CBGroupD(GroupDr,"O",child,"M",sub,"L",locSub))
				Quit:locSub=""
				set menuLocData=$g(^CBGroupD(GroupDr,"O",child,"M",sub,"L",locSub))
				continue:menuLocData=""
				set locFlag=0
				set menuLocID=$lg(menuLocData,2)
				if menuLocID=LocDr{
					set locFlag=1
					Quit 	
				}
			}
			s Code=$lg(^CBMenuDetailD(MenuDetailDr),2)
			s MenuDetailDrDesc=$lg(^CBMenuDetailD(MenuDetailDr),3)
			s ENDesc=$lg(^CBMenuDetailD(MenuDetailDr),4)
			s LinkAddress=$lg(^CBMenuDetailD(MenuDetailDr),5)
			s LinkPath=$lg(^CBMenuDetailD(MenuDetailDr),6)
			s Image=$lg(^CBMenuDetailD(MenuDetailDr),9)
			s WinPosition=$lg(^CBMenuDetailD(MenuDetailDr),12)
			s BackMethod=$lg(^CBMenuDetailD(MenuDetailDr),13)
			s Paras=$lg(^CBMenuDetailD(MenuDetailDr),14)
			s CondExpress=$lg(^CBMenuDetailD(MenuDetailDr),15)
			s JSMethod=$lg(^CBMenuDetailD(MenuDetailDr),16)
			s Tooltip=$lg(^CBMenuDetailD(MenuDetailDr),17)
			
			
			s SeqNo=$lg(^CBGroupD(GroupDr,"O",child,"M",sub),2)
			s subJson={}
			s subJson.ID=GroupDr_"||"_child_"||"_sub
			s subJson.code=Code
			s subJson.title=MenuDetailDrDesc
			s subJson.ENDesc=ENDesc
			s component=""
			if LinkAddress["../"{
				s LinkAddress=$p(LinkAddress,"../",2)	
			}
			if Image["../"{
				s Image=$p(Image,"../",2)	
			}
			s LinkPath="/"_Code
			s subJson.path=LinkPath
			s subJson.component=LinkAddress
			s subJson.image=Image
			s BreadCrumb=[]
			do BreadCrumb.%Push(MenuDetailDrDesc)
			s subJson.breadcrumbName=BreadCrumb
			s GroupMenuFlag=$lg(^CBMenuDetailD(MenuDetailDr),8)
			if GroupMenuFlag="Y"{
				s retJson=##class(src.Group.Public).GetGroupChildRouter(GroupDr_"||"_child_"||"_sub,BreadCrumb.%ToJSON(),.routerArr,LinkPath,LocDr)	
				//s subJson.children=retJson
			}else{
				do routerArr.%Push(subJson)	
			}
		}
		
	}
	s resultObj={}
	s resultObj.errorCode=0
	s resultObj.errorMessage=""
	s resultData=[]
	s resultData=subJsonArr
	s resultObj.result=routerArr
	
	Quit resultObj
}

/// w ##class(src.Group.CBGroupMenuSub).GetChildMenu("2||6||2")
ClassMethod GetGroupChildRouter(MenuGroupId As %String, BreadCrumbStr As %String, ByRef routerArr As %Library.DynamicArray, LinkPathStr As %String, locID As %String)
{
	n (MenuGroupId,BreadCrumbStr,routerArr,LinkPathStr,locID)
	//s BreadCrumb=##class(%Library.DynamicObject).%FromJSON(BreadCrumbStr)
	s GroupId=+MenuGroupId
	s GroupChild=$p(MenuGroupId,"||",2)
	s sub=0
	//s routerArr=[]
	for{
		s sub=$o(^CBGroupMenuSubI("PreMenu",MenuGroupId,GroupId,GroupChild,sub))
		Quit:sub=""
		
		s MenuId=$lg(^CBGroupD(GroupId,"O",GroupChild,"M",sub),3)
		continue:$g(^CBMenuDetailD(MenuId))=""
		s GroupMenuFlag=$lg(^CBMenuDetailD(MenuId),8)
		s MenuDetailDr=$lg(^CBGroupD(GroupId,"O",GroupChild,"M",sub),3)
		continue:MenuDetailDr=""
		set locFlag=1
		set locSub=0
		for{
			set locSub=$o(^CBGroupD(GroupId,"O",GroupChild,"M",sub,"L",locSub))
			Quit:locSub=""
			set menuLocData=$g(^CBGroupD(GroupId,"O",GroupChild,"M",sub,"L",locSub))
			continue:menuLocData=""
			set locFlag=0
			set menuLocID=$lg(menuLocData,2)
			if menuLocID=locID{
				set locFlag=1
				Quit 	
			}
		}
		s Code=$lg(^CBMenuDetailD(MenuDetailDr),2)	
		s MenuDetailDrDesc=$lg(^CBMenuDetailD(MenuDetailDr),3)
		s ENDesc=$lg(^CBMenuDetailD(MenuDetailDr),4)
		s LinkAddress=$lg(^CBMenuDetailD(MenuDetailDr),5)
		s LinkPath=$lg(^CBMenuDetailD(MenuDetailDr),6)
		s Image=$lg(^CBMenuDetailD(MenuDetailDr),9)
		s WinPosition=$lg(^CBMenuDetailD(MenuDetailDr),12)
		s BackMethod=$lg(^CBMenuDetailD(MenuDetailDr),13)
		s Paras=$lg(^CBMenuDetailD(MenuDetailDr),14)
		s CondExpress=$lg(^CBMenuDetailD(MenuDetailDr),15)
		s JSMethod=$lg(^CBMenuDetailD(MenuDetailDr),16)
		s Tooltip=$lg(^CBMenuDetailD(MenuDetailDr),17)
			
			
		s SeqNo=$lg(^CBGroupD(GroupId,"O",GroupChild,"M",sub),2)
		s subJson={}
		s subJson.ID=GroupId_"||"_GroupChild_"||"_sub
		s subJson.title=MenuDetailDrDesc
		s subJson.ENDesc=ENDesc
		if LinkAddress["../"{
			s LinkAddress=$p(LinkAddress,"../",2)	
		}
		s LinkPath="/"_Code
		if LinkPath'["/" s LinkPath="/"_LinkPath
		if LinkPathStr'=""{
			s subJson.path=LinkPathStr_LinkPath	
		}else{
			s subJson.path=LinkPath	
		}

		s subJson.component=LinkAddress
		s BreadCrumb=##class(%Library.DynamicObject).%FromJSON(BreadCrumbStr)
		do BreadCrumb.%Push(MenuDetailDrDesc)
		s subJson.breadcrumbName=BreadCrumb
		if GroupMenuFlag="Y"{
			s MenuDetailDr=$lg(^CBGroupD(GroupId,"O",GroupChild,"M",sub),3)
			s MenuDetailDrDesc=""
			if MenuDetailDr'=""{
				s MenuDetailDrDesc=$lg(^CBMenuDetailD(MenuDetailDr),3)
			}
			s jsonret=##class(src.Group.Public).GetGroupChildRouter(GroupId_"||"_GroupChild_"||"_sub,BreadCrumb.%ToJSON(),.routerArr,LinkPathStr_LinkPath)	
			
			//s subJson.children=jsonret
			//do childarr.%Push(routerArr)
		}else{
			do routerArr.%Push(subJson)
		}	
	}
	Quit routerArr
}

/// w ##class(src.Group.Public).GetRouterData()
ClassMethod GetRouterData()
{
	s RouterData=[]
	s route={}
	s route.path="/header"
	s route.breadcrumbName=["首页", "欢迎进入"]
	s route.component="pages/Header/index.jsx"
	do RouterData.%Push(route)
	
	s route={}
	s route.path="/mine/add"
	s route.breadcrumbName=["菜单管理", "菜单维护"]
	s route.component="pages/Mine/index.jsx"
	do RouterData.%Push(route)
	
	s route={}
	s route.path="/mine/list"
	s route.breadcrumbName=["菜单管理", "菜单授权"]
	s route.component="pages/System/menuAuthorization.jsx"
	do RouterData.%Push(route)
	
	s route={}
	s route.path="/basic/system/user"
	s route.breadcrumbName=["基础数据", "系统资源", "用户"]
	s route.component="pages/System/user.jsx"
	do RouterData.%Push(route)
	
	s route={}
	s route.path="/basic/system/user_maintenance"
	s route.breadcrumbName=["基础数据", "系统资源", "用户管理"]
	s route.component="pages/System/userMaintenance.jsx"
	do RouterData.%Push(route)
	
	s route={}
	s route.path="/basic/system/role_maintenance"
	s route.breadcrumbName=["基础数据", "系统资源", "角色管理"]
	s route.component="pages/System/roleMaintenance.jsx"
	do RouterData.%Push(route)
	
	s route={}
	s route.path="/basic/main"
	s route.breadcrumbName=["基础数据", "主菜单维护"]
	s route.component="pages/System/mainMenuMaintenance.jsx"
	do RouterData.%Push(route)
	
	s route={}
	s route.path="/basic/detail"
	s route.breadcrumbName=["基础数据", "菜单明细维护"]
	s route.component="pages/System/menuDetailMaintenance.jsx"
	do RouterData.%Push(route)
	
	s route={}
	s route.path="/basic/authorization"
	s route.breadcrumbName=["基础数据", "菜单授权"]
	s route.component="pages/System/menuAuthorization.jsx"
	do RouterData.%Push(route)
	
	s route={}
	s route.path="/basic/cbdata"
	s route.breadcrumbName=["基础数据", "数据维护"]
	s route.component="pages/System/cbdata.jsx"
	//do RouterData.%Push(route)
	
	
	Quit RouterData
}

/// w ##class(src.Group.Public).GetMenuData()
ClassMethod GetMenuData()
{
	s menuDataArr=[]
	s menuItem={}
	s menuItem.title="首页"
	s menuItem.icon="home"
	s menuItem.path="/header"
	do menuDataArr.%Push(menuItem)
	
	s menuItem={}
	s menuItem.title="菜单管理"
	s menuItem.icon="schedule"
	s menuItem.path="/mine"
	
	s menuSubs=[]
	s menuSubItem={}
	s menuSubItem.path="/mine/add"
	s menuSubItem.title="菜单维护"
	s menuSubItem.icon="coffee"
	do menuSubs.%Push(menuSubItem)
	s menuSubItem={}
	s menuSubItem.path="/mine/list"
	s menuSubItem.title="菜单授权"
	s menuSubItem.icon="zoom-in"
	do menuSubs.%Push(menuSubItem)
	s menuItem.subs=menuSubs
	
	do menuDataArr.%Push(menuItem)
	
	
	s menuItem={}
	s menuItem.title="基础数据"
	s menuItem.icon="sliders"
	s menuItem.path="/basic"
	
	s menuSubs=[]
	
	s menuSubItem={}
	
	s menuSubItem.path="/basic/system"
	s menuSubItem.title="系统资源"
	s menuSubItem.icon="deployment-unit"
	s systemSub=[]
	s systemSubItem={}
	s systemSubItem.path="/basic/system/user"
	s systemSubItem.title="用户"
	s systemSubItem.icon="user-delete"
	
	do systemSub.%Push(systemSubItem)

	s systemSubItem={}
	s systemSubItem.path="/basic/system/user_maintenance"
	s systemSubItem.title="用户维护"
	s systemSubItem.icon="usergroup-add"
	do systemSub.%Push(systemSubItem)
	
	s systemSubItem={}
	s systemSubItem.path="/basic/system/role_maintenance"
	s systemSubItem.title="角色维护"
	s systemSubItem.icon="usergroup-delete"
	do systemSub.%Push(systemSubItem)
	
	s menuSubItem.subs=systemSub
	
	do menuSubs.%Push(menuSubItem)
	
	
	
	s menuSubItem={}
	s menuSubItem.path="/basic/main"
	s menuSubItem.title="主菜单维护"
	s menuSubItem.icon="build"
	do menuSubs.%Push(menuSubItem)
	s menuSubItem={}
	s menuSubItem.path="/basic/detail"
	s menuSubItem.title="菜单明细维护"
	s menuSubItem.icon="branches"
	do menuSubs.%Push(menuSubItem)
	s menuSubItem={}
	s menuSubItem.path="/basic/authorization"
	s menuSubItem.title="菜单授权"
	s menuSubItem.icon="branches"
	do menuSubs.%Push(menuSubItem)
	
	
	s menuItem.subs=menuSubs
	
	do menuDataArr.%Push(menuItem)
	
	Quit menuDataArr
}

/// w ##class(src.Group.Public).test1("")
ClassMethod test1(Arg1 As %String)
{
	set json={}
	set json.GroupDr=2
	
	s json.Type=2
	s json.LocDr=1
	set ret=##class(src.Group.Public).GetGroupRouter(json.%ToJSON())
	quit ret.%ToJSON()
}

/// tt  根据角色菜单授权子表ID获取对应菜单路由path
ClassMethod GetMenuSubPath(menuSubID, linkPath As %Library.String = "")
{
	new (menuSubID, linkPath)
	quit:menuSubID="" linkPath
	quit:$l(menuSubID,"||")'=3 linkPath
	set groupID=+menuSubID
	set groupMenuID=$p(menuSubID,"||",2)
	set groupMenuSubID=$p(menuSubID,"||",3)
	set menuSubData=$g(^CBGroupD(groupID,"O",groupMenuID,"M",groupMenuSubID))
	;处理角色默认主界面指针不存在数据问题 [2019-11-12 NZS]
	if ($d(^CBGroupD(groupID,"O",groupMenuID,"M",groupMenuSubID))'=0){
		set menuDetailID=$lg(menuSubData,3)
		set preGroupMenuSubID=$lg(menuSubData,5)
		set code=$case($d(^CBMenuDetailD(menuDetailID))'=0,"1":$lg($g(^CBMenuDetailD(menuDetailID)),2),:"")
		set linkPath="/"_code_linkPath
		if preGroupMenuSubID'="" {
			set linkPath=..GetMenuSubPath(preGroupMenuSubID,linkPath)
		}
	}
	quit linkPath
}

/// tc  根据角色描述获取角色id
/// w ##class(src.Group.Public).GetDroupIDByDesc()
ClassMethod GetDroupIDByDesc(jsonObj)
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set errorCode="0",errorMessage=""
	try{
		set desc=jsonObj.params.%Get(0).desc
		quit:desc=""
		set id=$o(^CBGroupI("Desc",desc,0))
		set resultObj.result.groupID=id
	}catch(e){
	}
	quit resultObj
}

}
