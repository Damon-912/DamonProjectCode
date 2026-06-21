Import SQLUSER

/// HIS数据映射服务
/// 将HIS接口返回的数据映射到本地表
Class src.DRG.HISData.DataMapper Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 映射并保存HIS住院患者数据
/// pResultArray: HIS接口返回的result数组（%DynamicArray）
/// 返回：%DynamicObject，包含errorCode、errorMessage、successCount、failedCount
ClassMethod MapAndSave(pResultArray As %Library.DynamicArray) As %Library.DynamicObject
{
	new (tLen,tItem,tAdmID,tSC,tResultObj,tMapRtn)
	set resultObj={"errorCode":"0","errorMessage":"","successCount":0,"failedCount":0}
	try
	{
		set tLen=pResultArray.%Size()
		for i=0:1:tLen-1 {
			set tItem=pResultArray.%Get(i)
			set tAdmID=$piece($get(tItem.admID),"",1)
			if tAdmID="" {
				set resultObj.failedCount=resultObj.failedCount+1
				continue
			}
			set tSC=..SavePatAdm(tItem)
			if $$$ISERR(tSC) {
				set resultObj.failedCount=resultObj.failedCount+1
				continue
			}
			if $IsObject($get(tItem.drgParams)) {
				set tSC=..SaveDRGParams(tAdmID,tItem.drgParams.result)
				if $$$ISERR(tSC) {}
			}
			if $IsObject($get(tItem.drgParams.result.oprnInfo)) {
				set tSC=..SaveOprnInfo(tAdmID,tItem.drgParams.result.oprnInfo)
				if $$$ISERR(tSC) {}
			}
			if $IsObject($get(tItem.drgParams.result.diseInfo)) {
				set tSC=..SaveDiseInfo(tAdmID,tItem.drgParams.result.diseInfo)
				if $$$ISERR(tSC) {}
			}
			set resultObj.successCount=resultObj.successCount+1
		}
	}
	catch tException {
		set resultObj.errorCode="-1"
		set resultObj.errorMessage=$System.Status.GetErrorText(tException.AsStatus(),"cn")
	}
	quit resultObj
}

/// 保存患者就诊主表
/// pItem: HIS接口返回的单个result对象
/// 返回：%Status
ClassMethod SavePatAdm(pItem As %Library.DynamicObject) As %Status
{
	new (tAdmID,tObj,tSC,tSaveSC)
	//set $zt="Error"
	//set tSC=$$$OK()
	try
	{
		set tAdmID=$piece($get(pItem.admID),"",1)
		if tAdmID="" quit
		set tObj=##class(User.BSHISPatAdm).%OpenId(tAdmID)
		if '$IsObject(tObj) {
			set tObj=##class(User.BSHISPatAdm).%New()
			set tObj.AdmID=tAdmID
		}
		set tObj.PatID=$piece($get(pItem.patID),"",1)
		set tObj.PatName=$get(pItem.patName,"")
		set tObj.PatSexCode=$get(pItem.patSexCode,"")
		set tObj.PatSexDesc=$get(pItem.patSexDesc,"")
		set tObj.PatNo=$get(pItem.patNo,"")
		set tObj.PatMedicalNo=$get(pItem.patMedicalNo,"")
		set tObj.AdmDocDesc=$get(pItem.admDocDesc,"")
		set tObj.AdmNurDesc=$get(pItem.admNurDesc,"")
		if $get(pItem.admDateTime)'="" {
			set tObj.AdmDateTime=$zdth($get(pItem.admDateTime),3)
		}
		set tObj.AdmInDays=$get(pItem.admInDays,0)
		set tObj.AdmDiag=$get(pItem.admDiag,"")
		set tObj.InLocDesc=$get(pItem.inLocDesc,"")
		set tObj.InWardDesc=$get(pItem.inWardDesc,"")
		set tObj.UpdateDate=$zd($h,5)
		set tObj.UpdateTime=$zt($p($h,",",2))
		set tSaveSC=tObj.%Save()
		if $$$ISERR(tSaveSC) {
			set tSC=tSaveSC
			quit
		}
	}
	catch tException {
		set tSC=tException.AsStatus()
	}
	quit tSC
}

/// 保存DRG分组参数表
ClassMethod SaveDRGParams(pAdmID As %String, pResultObj As %Library.DynamicObject) As %Status
{
	new (tAdmObj,tObj,tSC,tSaveSC)
	//set $zt="Error"
	//set tSC=$$$OK
	try
	{
		if pAdmID="" quit
		if '$IsObject(pResultObj) quit
		set tAdmObj=##class(User.BSHISPatAdm).%OpenId(pAdmID)
		if '$IsObject(tAdmObj) {
			set tSC=$$$ERROR($$$GeneralError,"就诊ID不存在："_pAdmID)
			quit
		}
		set tObj=##class(User.BSHISDRGParams).%OpenId(pAdmID)
		if '$IsObject(tObj) {
			set tObj=##class(User.BSHISDRGParams).%New()
			set tObj.AdmDr=tAdmObj
		}
		set tObj.PsnNo=$get(pResultObj.psnNo,"")
		set tObj.InsuranceAreaCode=$get(pResultObj.insuranceAreaCode,"")
		set tObj.MdtrtareaAreaCode=$get(pResultObj.mdtrtareaAreaCode,"")
		set tObj.InsuType=$get(pResultObj.insuType,"")
		set tObj.DiagnosisCode=$get(pResultObj.diagnosisCode,"")
		set tObj.DiagnosisName=$get(pResultObj.diagnosisName,"")
		set tObj.GroupStage=$get(pResultObj.groupStage,0)
		set tObj.DiaTypeCode=$get(pResultObj.diaTypeCode,"")
		set tObj.UnionOprnFlag=$get(pResultObj.unionOprnFlag,0)
		set tObj.MainDiagnosisCode=$get(pResultObj.mainDiagnosisCode,"")
		set tObj.MainOperationCode=$get(pResultObj.mainOperationCode,"")
		set tObj.Sex=$get(pResultObj.sex,"")
		set tObj.Age=$get(pResultObj.age,0)
		set tObj.AgeGroupDays=$get(pResultObj.ageGroupDays,"")
		set tObj.NewbornFlag=$get(pResultObj.newbornFlag,"")
		set tObj.RespiratorTime=$get(pResultObj.respiratorTime,"")
		set tObj.EcmoFlag=$get(pResultObj.ecmoFlag,"")
		set tObj.TransplantFlag=$get(pResultObj.transplantFlag,"")
		set tObj.MarrowTransplantFlag=$get(pResultObj.marrowTransplantFlag,"")
		set tObj.HivFlag=$get(pResultObj.hivFlag,"")
		set tObj.TraumaLevel=$get(pResultObj.traumaLevel,"")
		set tObj.Department=$get(pResultObj.department,"")
		set tObj.DepartmentDesc=$get(pResultObj.departmentDesc,"")
		set tObj.DischargeType=$get(pResultObj.dischargeType,"")
		set tObj.HospitalDays=$get(pResultObj.hospitalDays,0)
		set tObj.TotalCost=$get(pResultObj.totalCost,0)
		set tObj.MedicalRecordID=$get(pResultObj.medicalRecordID,"")
		set tObj.HisAdmId=$get(pResultObj.hisAdmId,"")
		set tObj.PatientName=$get(pResultObj.patientName,"")
		set tObj.DeptCode=$get(pResultObj.deptCode,"")
		set tObj.DeptName=$get(pResultObj.deptName,"")
		set tObj.DoctorCode=$get(pResultObj.doctorCode,"")
		set tObj.DoctorName=$get(pResultObj.doctorName,"")
		set tObj.TotalFee=$get(pResultObj.totalFee,0)
		set tObj.MedicalRecordDr=$get(pResultObj.medicalRecordDr,"")
		set tObj.FixmedinsCode=$get(pResultObj.fixmedinsCode,"")
		set tObj.FixmedinsName=$get(pResultObj.fixmedinsName,"")
		set tObj.DrgParamsStatusCode=$select($get(pResultObj.errorCode)="0":"0",1:"1")
		set tSaveSC=tObj.%Save()
		if $$$ISERR(tSaveSC) {
			set tSC=tSaveSC
			quit
		}
	}
	catch tException {
		set tSC=tException.AsStatus()
	}
	quit tSC
}

/// 保存手术信息表
ClassMethod SaveOprnInfo(pAdmID As %String, pOprnInfoArray As %Library.DynamicArray) As %Status
{
	new (tAdmObj,tObj,tOprnItem,tOprnSn,tSaveSC,tSC,i)
	//set $zt="Error"
	//set tSC=$$$OK()
	try
	{
		if pAdmID="" quit
		if '$IsObject(pOprnInfoArray) quit
		set tAdmObj=##class(User.BSHISPatAdm).%OpenId(pAdmID)
		if '$IsObject(tAdmObj) {
			set tSC=$$$ERROR($$$GeneralError,"就诊ID不存在："_pAdmID)
			quit
		}
		set tLen=pOprnInfoArray.%Size()
		for i=0:1:tLen-1 {
			set tOprnItem=pOprnInfoArray.%Get(i)
			set tOprnSn=$get(tOprnItem.oprnSn,0)
			set tObj=##class(User.BSHISOprnInfo).%OpenId(pAdmID,tOprnSn)
			if '$IsObject(tObj) {
				set tObj=##class(User.BSHISOprnInfo).%New()
				set tObj.AdmDr=tAdmObj
				set tObj.OprnSn=tOprnSn
			}
			set tObj.MainFlag=$get(tOprnItem.mainFlag,"")
			set tObj.OprnCode=$get(tOprnItem.oprnCode,"")
			set tObj.OprnName=$get(tOprnItem.oprnName,"")
			set tObj.OprnDate=$get(tOprnItem.oprnDate,"")
			set tSaveSC=tObj.%Save()
			if $$$ISERR(tSaveSC) {
				set tSC=tSaveSC
				quit
			}
		}
	}
	catch tException {
		set tSC=tException.AsStatus()
	}
	quit tSC
}

/// 保存诊断信息表
ClassMethod SaveDiseInfo(pAdmID As %String, pDiseInfoArray As %Library.DynamicArray) As %Status
{
	new (tAdmObj,tObj,tDiseItem,tDiagSn,tSaveSC,tSC,i)
	//set $zt="Error"
	//set tSC=$$$OK
	try
	{
		if pAdmID="" quit
		if '$IsObject(pDiseInfoArray) quit
		set tAdmObj=##class(User.BSHISPatAdm).%OpenId(pAdmID)
		if '$IsObject(tAdmObj) {
			set tSC=$$$ERROR($$$GeneralError,"就诊ID不存在："_pAdmID)
			quit
		}
		set tLen=pDiseInfoArray.%Size()
		for i=0:1:tLen-1 {
			set tDiseItem=pDiseInfoArray.%Get(i)
			set tDiagSn=$get(tDiseItem.diagSn,0)
			if tDiagSn=0 continue
			set tObj=##class(User.BSHISDiseInfo).%OpenId(pAdmID,tDiagSn)
			if '$IsObject(tObj) {
				set tObj=##class(User.BSHISDiseInfo).%New()
				set tObj.AdmDr=tAdmObj
				set tObj.DiagSn=tDiagSn
			}
			set tObj.MainFlag=$get(tDiseItem.mainFlag,0)
			set tObj.DiagCode=$get(tDiseItem.diagCode,"")
			set tObj.DiagName=$get(tDiseItem.diagName,"")
			set tObj.UpdateDate=$zd($h,5)
			set tObj.UpdateTime=$zt($p($h,",",2))
			set tSaveSC=tObj.%Save()
			if $$$ISERR(tSaveSC) {
				set tSC=tSaveSC
				quit
			}
		}
	}
	catch tException {
		set tSC=tException.AsStatus()
	}
	quit tSC
}

}
