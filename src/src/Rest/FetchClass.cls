/// gjg
Class src.Rest.FetchClass Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// w ##class(src.Rest.FetchClass).GetClass(1000)
ClassMethod GetClass(code)
{
	new (code)
	set code=$ZCVT(code,"U")
	if ((code="")||('$d(^CBMapInterfaceI("Code",code)))){
		quit ##class(src.util.ResultSet).FailInfoByCode("04000001")
	}
	set mapInterfaceID=$o(^CBMapInterfaceI("Code",code,0))
	set mapInterfaceInfo=^CBMapInterfaceD(mapInterfaceID)
	set startDate=$lg(mapInterfaceInfo,6)
	set stopDate=$lg(mapInterfaceInfo,7)
	set curDate=+$h
	if ((startDate'="")&(startDate>curDate)){
		quit ##class(src.util.ResultSet).FailInfoByCode("04000004")
	}
	if ((stopDate'="")&(curDate>stopDate)){
		quit ##class(src.util.ResultSet).FailInfoByCode("04000005")
	}
	set obj={}
	set obj.code=$lg(mapInterfaceInfo,2)
	set obj.descripts=$lg(mapInterfaceInfo,3)
	set obj.className=$lg(mapInterfaceInfo,4)
	set obj.methodName=$lg(mapInterfaceInfo,5)
	set obj.serviceType=$lg(mapInterfaceInfo,8)
	set obj.serviceIP=$lg(mapInterfaceInfo,10)
	set obj.sessionFlag=$lg(mapInterfaceInfo,11)
	set obj.tokenFlag=$lg(mapInterfaceInfo,12)
	set obj.tokenOverTime=$lg(mapInterfaceInfo,13)
	quit ##class(src.util.ResultSet).Success(obj)
}

}
