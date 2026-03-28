Class src.Config.ModuleConfig Extends (%RegisteredObject, %XML.Adaptor) [ ProcedureBlock ]
{

/// w ##class(src.Config.ModuleConfig).GetConfig({"hospID":"6","moduleCode":"101","mulFlag":"Y"})
ClassMethod GetConfig(paraObj)
{
	set $zt="error"
	set configList=[]
	set moduleCode=paraObj.moduleCode
	set hospID=paraObj.hospID
	//多选标志
	set mulFlag=paraObj.mulFlag   
	if moduleCode=""{
		set resultObj={}
		set resultObj.errorCode="01040104"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040104")
		Quit resultObj	
	}
	set moduleID=$o(^CBProductModuleI("Code",$zcvt(moduleCode,"U"),0))
	if moduleID=""{
		set resultObj={}
		set resultObj.errorCode="01040104"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040104")
		Quit resultObj		
	}
	//set selectData={}
	kill selectArr
	set ID=0
	for{
		set ID=$o(^HBModuleConfigTypeI("HospModule",hospID,moduleID,ID))
		Quit:ID=""
		set configTypeData=$g(^HBModuleConfigTypeD(ID))
		set configCode=$lg(configTypeData,3)
		set configName=$lg(configTypeData,4)
		set fieldTypeID=$lg(configTypeData,6)
		continue:fieldTypeID=""
		set fieldTypeCode=$lg(^CBConfigFieldTypeD(fieldTypeID),2)
		set multipleType=$lg(configTypeData,8)
		if multipleType="" set multipleType="N"
		continue:(mulFlag'=multipleType)
		set configVal=""
		//配置的值
		set configValID=$o(^HBModuleConfigI("ModuleConfig",ID,0))
		if configValID'=""{
			set configVal=$lg(^HBModuleConfigD(configValID),3)	
		}
		set itemObj={}
		set itemObj.configCode=configCode
		set itemObj.configName=configName
		set itemObj.configVal=configVal_""
		set itemObj.type=fieldTypeCode
		if fieldTypeCode="Select"{
			set className=$lg(configTypeData,7)
			if className'=""{
				if '$d(selectArr(SelectUser)){
					set fieldDataList=##class(src.Config.TableClassName).GetJsonByClassName(className,1,"Descripts","",hospID)
					set selectArr(className)=fieldDataList	
				}
				set itemObj.configData=selectArr(className)
				
			}	
		}
		do configList.%Push(itemObj)
	}
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage=""
	set resultObj.result=configList
	Quit resultObj
error
	set resultObj={}
	set resultObj.errorCode="-1"
	set resultObj.errorMessage=$ze
	Quit resultObj
}

ClassMethod SaveConfig(paraStr As %String)
{
	set $zt="error"
	set paraObj=##class(%Library.DynamicObject).%FromJSON(paraStr)
	set userID=paraObj.userID
	set hospID=paraObj.hospID
	set configList=paraObj.configList
	
	TStart
	set errorCode="0"
	set errorMessage=""
	for i=0:1:configList.%Size()-1{
		
		set itemConfig=configList.%Get(i)
		set configVal=itemConfig.configVal
		set configCode=itemConfig.configCode
		set retObj=..SaveItemConfig(itemConfig.%ToJSON(),hospID,userID)
		if retObj.errorCode'=0{
			set errorCode=retObj.errorCode	
			set errorMessage=retObj.errorMessage
			Quit 
		}
	}
	if errorCode'=0{
		TRollback 1
		set resultObj={}
		set resultObj.errorCode=errorCode	
		set resultObj.errorMessage=errorMessage
		Quit resultObj	
	}
	TCommit
	set resultObj={}
	set resultObj.errorCode="0"	
	set resultObj.errorMessage=""
	Quit resultObj	
error
	set resultObj={}
	set resultObj.errorCode=-1
	set resultObj.errorMessage=$ze
	Quit resultObj
}

ClassMethod SaveItemConfig(itemConfig As %String, hospID As %String, userID As %String)
{
	set configObj=##class(%Library.DynamicObject).%FromJSON(itemConfig)
	set configVal=configObj.configVal
	set configCode=configObj.configCode
	set configTypeID=$o(^HBModuleConfigTypeI("HospCode",hospID,$zcvt(configCode,"u"),0))
	b ;11122
	if configTypeID=""{
		set resultObj={}
		set resultObj.errorCode="0"	
		set resultObj.errorMessage=""
		Quit resultObj
	}
	set configID=$o(^HBModuleConfigI("ModuleConfig",configTypeID,0))
	b ;1111
	if configID'=""{
		set oldConfigVal=$lg(^HBModuleConfigD(configID),4)	
		if oldConfigVal=configVal{
			set resultObj={}
			set resultObj.errorCode="0"	
			set resultObj.errorMessage=""
			Quit resultObj	
		}
	}
	TStart
	set dataObj={}
	set dataObj.className="User.HBModuleConfig"
	set dataObj.updateUserID=userID
	set item={}
	set item.ID=configID
	set item.ModuleConfigDr=configTypeID
	set item.ConfigValues=configVal
	set item.UpdateDate=$zd(+$h,3)
	set item.UpdateTime=$zt($p($h,",",2))
	set item.UpdateUserDr=userID
	set data=[]
	do data.%Push(item)
	set dataObj.data=data
	if configID=""{
		s ret=##class(src.util.operatetable).Insert(.dataObj)
	}else{
		s ret=##class(src.util.operatetable).Update(.dataObj)		
	}
	b ;000
	set retStr=$p(ret,"!",1)
	set ID=+$p(ret,"!",2)
	set errorCode=$p(retStr,"^",1)
	set errorMessage=$p(retStr,"^",2)
	if errorCode'="0"{
		TRollback 1
		set resultObj={}
		set resultObj.errorCode=errorCode	
		set resultObj.errorMessage=errorMessage
		Quit resultObj	
	}
	TCommit
	set resultObj={}
	set resultObj.errorCode="0"	
	set resultObj.errorMessage=""
	Quit resultObj
}

/// w ##class(src.Config.ModuleConfig).Test()
ClassMethod Test()
{
	set data={"hospID":"1","userID":"53","configList":[{"configCode":"AppCycle","configVal":"7"},{"configCode":"BreakAppTimes","configVal":"4"},{"configCode":"BreakAppCycle","configVal":"100"},{"configCode":"BreakAppDays","configVal":"300"},{"configCode":"RegFeeSubCat","configVal":"62"},{"configCode":"ConsultingFeeSubCat","configVal":"61"},{"configCode":"RegFeeSettlement","configVal":"Y"},{"configCode":"CancelRegReleaseSeqNo","configVal":"Y"},{"configCode":"CancelRegReleaseSeqNoAdd","configVal":"Y"},{"configCode":"ResCreateCycle","configVal":"7"},{"configCode":"INSUSettlement","configVal":"Y"},{"configCode":"AppRecurrenceReleaseSeqNo","configVal":"Y"},{"configCode":"ShowStockZeroOrder","configVal":"Y"},{"configCode":"ShowNoRecLocOrder","configVal":"Y"},{"configCode":"AutoStopExec","configVal":"Y"}]}
	set ret=..SaveConfig(data.%ToJSON())
	Quit ret.%ToJSON()
}

/// w ##class(src.Config.ModuleConfig).GetConfigByCode("HisIP",6)
ClassMethod GetConfigByCode(configCode As %String, hospID As %String)
{
	set val=""
	if hospID'=""
	{
		set configTypeID=$o(^HBModuleConfigTypeI("HospCode",hospID,$zcvt(configCode,"u"),0))
		if configTypeID'=""
		{
			set configID=$o(^HBModuleConfigI("ModuleConfig",configTypeID,0))
			if configID'=""
			{
				set val=$lg(^HBModuleConfigD(configID),3)	
			}
		}
	}
	if val=""
	{
		;//取公共的数据
		set configTypeID=$o(^HBModuleConfigTypeI("HospCode",-100000000000000,$zcvt(configCode,"u"),0))
		if configTypeID'=""
		{
			set configID=$o(^HBModuleConfigI("ModuleConfig",configTypeID,0))
			if configID'=""
			{
				set val=$lg(^HBModuleConfigD(configID),3)	
			}
		}
	}
	
	Quit val
}

ClassMethod GetOperationConfigInfo(paraStr As %String)
{
	set configList=..GetConfig(paraStr).result
	for i=0:1:configList.%Size()-1{
		set displayInfo=""
		set configCode=configList.%Get(i).configCode
		set configVal=configList.%Get(i).configVal
		if (configCode="MedItem")&&(configVal'=""){
			set displayInfo=##class(User.CBMedItem).%OpenId(configVal).Descripts
		}
		set configList.%Get(i).displayInfo=displayInfo
	}
	set resultObj={"errorCode":"0","errorMessage":"","result":(configList)}
	quit resultObj
}

}
