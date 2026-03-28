Class src.DRG.MIService Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator: CM
/// Description: 获取医保平台的病人参保信息
/// code: 
/// Debug：w ##class(src.INSU.Interface).DynamicQueryPatCurrentInsuInfo({"params":[{"patID":"833757","hospID":"45"}]}).%ToJSON()
ClassMethod QueryPatCurrentInsuInfo(postObj) As %Library.DynamicAbstractObject
{
	new (postObj)
	set paramsobj=postObj.params.%Get(0)
	set patID=paramsobj.patID
	set admID=paramsobj.admID
	set hospID=paramsobj.hospID
	set errorCode=0
	set errorMessage=""
	try{
		if patID'=""
		{
			set patobj=##class(User.BSPatient).%OpenId(patID)
			set IDCardNo=patobj.IDCardNo
			set:IDCardNo="" IDCardNo=patobj.CredNo
			if IDCardNo'=""
			{
				set sqlStr="SELECT TOP 1 * FROM BS_MIPatCurrentInsuInfo where PsnCertNO='"_IDCardNo_"' and Hospital_Dr->HisHospital_Dr='"_hospID_"' ORDER BY ID desc" 
			}
			else{
				 set errorCode="-100001"
				set errorMessage="身份证信息为空"
				quit 
			}
		}
		set:admID'="" sqlStr="SELECT TOP 1 * FROM BS_MIPatCurrentInsuInfo WHERE AdmID='"_admID_"' ORDER BY ID desc"
		set postObj={
				"code":"09010082",
				"params":[{
					"sqlStr":(sqlStr)
				}]}
		set ret=##class(src.Interface.XYSHisService).XYSHisService(postObj,"HIS","Cloudinsunew")
	    set ybreturnobj=##class(%Library.DynamicObject).%FromJSON(ret)
	    b ;?
	    set errorCode=ybreturnobj.errorCode
		set errorMessage=ybreturnobj.errorMessage
	    if errorCode'=0
	    {
			quit  
	    }
	    set result=ybreturnobj.result
	    if result=""
	    {
			quit  
	    }
	    if result.rows.%Size()=0
	    {
		    set result=""
			quit  
	    }
	    set result=result.rows.%Get(0)
	    set psnType=result.psnType
	}catch (e) {
		Set status=e.AsStatus()
	    set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
    set resultObj={}
	set resultObj.errorCode=errorCode
    set resultObj.errorMessage=errorMessage
    set resultObj.result=$g(result)
	quit resultObj
}

}
