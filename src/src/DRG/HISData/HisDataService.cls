Import SQLUSER

/// HIS数据获取服务
/// 调用HIS接口获取住院患者就诊数据
Class src.DRG.HISData.HisDataService Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 获取HIS住院患者就诊数据
/// 调用HIS接口 code=05900014
ClassMethod GetInpatientData(jsonObj) As %Library.DynamicObject
{
	//new (jsonObj, session, hospCode, hospID, firstItem, fixmedinsCode, fixmedinsName)
	set resultObj={"errorCode":"-1","errorMessage":"","result":[]}
	try
	{			
        set session=jsonObj.session.%Get(0)
        set hospCode=session.hospCode
        set hospID=session.hospID
        
        ///获取HIS数据
        set postObj={"params":(jsonObj.params),"code":"05900014","session":(jsonObj.session)}		
		set rtn=##class(src.External.Service).HisService(postObj,hospCode)
		if rtn="" 
		{
			set resultObj.errorCode="-1"
			set resultObj.errorMessage="HIS接口调用失败! 入参报文如下："_postObj.%ToJSON()
			quit
		}
		
		set resultObj={}.%FromJSON(rtn)	
		
		//保存数据到本地表（传入医院信息）
		if resultObj.errorCode="0" 
		{
			set saveRtn=..SaveInpatientData(resultObj.result)
			
			///合并保存结果到返回对象
			if saveRtn.errorCode'="0" 
			{
				set resultObj.errorCode=saveRtn.errorCode
				set resultObj.errorMessage=saveRtn.errorMessage
			}
		}
		
	}
	catch tException 
	{
		set resultObj.errorCode="-1"
		set resultObj.errorMessage=$System.Status.GetErrorText(tException.AsStatus(),"cn")
	}
	
	quit resultObj
}

/// 保存HIS住院患者数据到本地表
ClassMethod SaveInpatientData(pData) As %Library.DynamicObject
{
	//new (pData, i, item, admID, admData, drgResult, diseArr, diseItem, oprnArr, oprnItem, j, k, dataObj, data, insObj, rtn, admObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{"successCount":0,"failedCount":0,"totalCount":0}}
	set resultObj.result.totalCount=pData.%Size()
	
	set (m,n)=0
	
	///同步开始时间
	set logStartTime=$zd(+$h,3)_" "_$zt($p($h,",",2))
	
	try 
	{
		for i=0:1:pData.%Size()-1 
		{
			set item=pData.%Get(i)
			set admID=item.admID  ///转为字符串			
			
			///========= 1. 保存就诊信息 BSHISPatAdm =========
			///先查询是否已存在，获取ID
			set existsID=""
			&sql(SELECT ID INTO :existsID FROM BS_HISPatAdm WHERE AdmID = :admID)
			
			set dataObj={}
			if existsID'="" 
			{
				set dataObj.ID=existsID
			}
			set dataObj.AdmID=admID
			set dataObj.PsnNo=item.drgParams.result.psnNo
			set dataObj.PatID=item.patID
			set dataObj.PatName=item.patName
			set dataObj.Age=item.drgParams.result.age
			set dataObj.PatSexCode=item.patSexCode
			set dataObj.PatSexDesc=item.patSexDesc	
			set dataObj.PatNo=item.patNo
			set dataObj.PatMedicalNo=item.patMedicalNo
			set dataObj.MdtrtArea=item.drgParams.result.mdtrtareaAreaCode
			set dataObj.AdmvsArea=item.drgParams.result.insuranceAreaCode
			set dataObj.InsuType=item.drgParams.result.insuType
			set dataObj.DiagnosisCode=item.drgParams.result.diagnosisCode
			set dataObj.DiagnosisName=item.drgParams.result.diagnosisName
			set dataObj.GroupStage=item.drgParams.result.groupStage
			set dataObj.DiaTypeCode=item.drgParams.result.diaTypeCode
			set dataObj.MainDiagnosisCode=item.drgParams.result.mainDiagnosisCode
			set dataObj.MainOperationCode=item.drgParams.result.mainOperationCode
			set dataObj.SumAmt=item.drgParams.result.totalFee
			set dataObj.AdmDocCode=item.drgParams.result.admDocCode
			set dataObj.AdmDocDesc=item.admDocDesc
			set dataObj.AdmNurCode=item.drgParams.result.admNurCode
			set dataObj.AdmNurDesc=item.admNurDesc
			set dataObj.AdmDateTime= item.admDateTime _":00"
			set dataObj.AdmInDays=item.admInDays
			set dataObj.AdmDiag=item.admDiag
			set dataObj.FixmedinsCode=item.drgParams.result.fixmedinsCode
			set dataObj.FixmedinsName=item.drgParams.result.fixmedinsName
			set dataObj.GroupParam=item.drgParams.result.%ToJSON()
			set dataObj.InLocDesc=item.inLocDesc
			set dataObj.InWardDesc=item.inWardDesc
			set dataObj.CreateDate=$zd(+$h,3)
			set dataObj.CreateTime=$zt($p($h,",",2))
			set dataObj.CreateUserDr="158"
			set dataObj.UpdateDate=$zd(+$h,3)
			set dataObj.UpdateTime=$zt($p($h,",",2))
			
			set data=[]
			do data.%Push(dataObj)
			
			set insObj={}
			set insObj.className="User.BSHISPatAdm"
			set insObj.updateUserID="158"
			set insObj.data=data
			
			///根据ID是否为空决定新增还是更新
			if existsID="" 
			{
				set rtn=##class(src.util.operatetable).Insert(.insObj)
			} 
			else 
			{
				set rtn=##class(src.util.operatetable).Update(.insObj)
			}
			
			if rtn.errorCode'=0 
			{
				///记录错误，继续下一条
				do ..LogSyncError(admID,"BS_HISPatAdm",rtn.errorMessage)
				set resultObj.result.failedCount=resultObj.result.failedCount+1
				continue
			}
			
			//更新成功，重新获取ID
			&sql(SELECT ID INTO :existsID FROM BS_HISPatAdm WHERE AdmID = :admID)
			
			///获取刚保存的BSHISPatAdm对象（用于外键关联）
			set admObj=##class(User.BSHISPatAdm).%OpenId(existsID)
			if admObj="" 
			{
				set resultObj.result.failedCount=resultObj.result.failedCount+1
				continue
			}
			
			//set resultObj.result.successCount=resultObj.result.successCount+1

			///========= 2. 保存DRG参数 BSHISDRGParams =========
			if $isobject(item.drgParams) && (item.drgParams.errorCode="0") 
			{
				if $isobject(item.drgParams.result) 
				{
					set drgResult=item.drgParams.result
					
					///先查询是否已存在（主键是AdmDr）
					set drgExistsID=""
					set admRefID=admObj.%Id()
					&sql(SELECT ID INTO :drgExistsID FROM BS_HISDRGParams WHERE Adm_Dr = :admRefID)
					
					set drgDataObj={}
					if drgExistsID'="" 
					{
						set drgDataObj.ID=drgExistsID
					}
					set drgDataObj.AdmDr=admObj.%Id()
					set drgDataObj.AdmID=admID
					set drgDataObj.PsnNo=drgResult.psnNo
					set drgDataObj.InsuranceAreaCode=drgResult.insuranceAreaCode
					set drgDataObj.MdtrtareaAreaCode=drgResult.mdtrtareaAreaCode
					set drgDataObj.InsuType=drgResult.insuType
					set drgDataObj.DiagnosisCode=drgResult.diagnosisCode
					set drgDataObj.DiagnosisName=drgResult.diagnosisName
					set drgDataObj.GroupStage=drgResult.groupStage
					set drgDataObj.DiaTypeCode=drgResult.diaTypeCode
					set drgDataObj.UnionOprnFlag=drgResult.unionOprnFlag
					set drgDataObj.MainDiagnosisCode=drgResult.mainDiagnosisCode
					set drgDataObj.MainOperationCode=drgResult.mainOperationCode
					set drgDataObj.Sex=drgResult.sex
					set drgDataObj.Age=drgResult.age
					set drgDataObj.AgeGroupDays=drgResult.ageGroupDays
					set drgDataObj.NewbornFlag=drgResult.newbornFlag
					set drgDataObj.RespiratorTime=drgResult.respiratorTime
					set drgDataObj.EcmoFlag=drgResult.ecmoFlag
					set drgDataObj.TransplantFlag=drgResult.transplantFlag
					set drgDataObj.MarrowTransplantFlag=drgResult.marrowTransplantFlag
					set drgDataObj.HivFlag=drgResult.hivFlag
					set drgDataObj.TraumaLevel=drgResult.traumaLevel
					set drgDataObj.Department=drgResult.department
					set drgDataObj.DepartmentDesc=drgResult.departmentDesc
					set drgDataObj.DischargeType=drgResult.dischargeType
					set drgDataObj.HospitalDays=drgResult.hospitalDays
					set drgDataObj.TotalCost=drgResult.totalCost
					set drgDataObj.MedicalRecordID=drgResult.medicalRecordID
					set drgDataObj.HisAdmId=drgResult.hisAdmId
					set drgDataObj.PatientName=drgResult.patientName
					set drgDataObj.DeptCode=drgResult.deptCode
					set drgDataObj.DeptName=drgResult.deptName
					set drgDataObj.DoctorCode=drgResult.doctorCode
					set drgDataObj.DoctorName=drgResult.doctorName
					set drgDataObj.TotalFee=drgResult.totalFee
					set drgDataObj.MedicalRecordDr=drgResult.medicalRecordDr
					set drgDataObj.FixmedinsCode=drgResult.fixmedinsCode
					set drgDataObj.FixmedinsName=drgResult.fixmedinsName
					set drgDataObj.DrgParamsStatus=item.drgParams.errorCode
					set drgDataObj.CreateDate=$zd(+$h,3)
					set drgDataObj.CreateTime=$zt($p($h,",",2))
					set drgDataObj.CreateUserDr="158"
					
					set drgData=[]
					do drgData.%Push(drgDataObj)
					
					set drgInsObj={}
					set drgInsObj.className="User.BSHISDRGParams"
					set drgInsObj.updateUserID="158"
					set drgInsObj.data=drgData
					
					///根据ID是否为空决定新增还是更新
					if drgExistsID="" 
					{
						set rtn=##class(src.util.operatetable).Insert(.drgInsObj)
					} 
					else 
					{
						set rtn=##class(src.util.operatetable).Update(.drgInsObj)
					}
					
					if rtn.errorCode'=0 
					{
						do ..LogSyncError(admID,"BS_HISDRGParams",rtn.errorMessage)
					}
					
					///========= 3. 保存诊断信息 BSHISDiseInfo =========
					set diseArr=drgResult.diseInfo
					if $isobject(diseArr) && (diseArr.%Size()>0) 
					{
						///先删除该就诊的所有诊断记录
						do ..DeleteDiseInfo(existsID)
						
						///插入新的诊断记录
						for j=0:1:diseArr.%Size()-1 
						{
							set diseItem=diseArr.%Get(j)
							
							set diseDataObj={}
							set diseDataObj.AdmDr=admObj.%Id()
							set diseDataObj.AdmID=admID
							set diseDataObj.DiagSn=diseItem.diagSn
							set diseDataObj.DiagType=item.drgParams.result.diaTypeCode
							set diseDataObj.MainFlag=diseItem.mainFlag
							set diseDataObj.DiagCode=diseItem.diagCode
							set diseDataObj.DiagName=diseItem.diagName
							set diseDataObj.CreateDate=$zd(+$h,3)
							set diseDataObj.CreateTime=$zt($p($h,",",2))
							set diseDataObj.CreateUserDr="158"
							set diseDataObj.UpdateDate=$zd(+$h,3)
							set diseDataObj.UpdateTime=$zt($p($h,",",2))
							
							set diseData=[]
							do diseData.%Push(diseDataObj)
							
							set diseInsObj={}
							set diseInsObj.className="User.BSHISDiseInfo"
							set diseInsObj.updateUserID="158"
							set diseInsObj.data=diseData
							
							set rtn=##class(src.util.operatetable).Insert(.diseInsObj)
							if rtn.errorCode'=0 
							{
								do ..LogSyncError(admID_"_"_diseItem.diagCode,"BS_HISDiseInfo",rtn.errorMessage)
							}
						}
					}
					
					///========= 4. 保存手术信息 BSHISOprnInfo =========
					set oprnArr=drgResult.oprnInfo
					if $isobject(oprnArr) && (oprnArr.%Size()>0) 
					{
						///先删除该就诊的所有手术记录
						do ..DeleteOprnInfo(existsID)
						
						///插入新的手术记录
						for k=0:1:oprnArr.%Size()-1 {
							set oprnItem=oprnArr.%Get(k)
							
							set oprnDataObj={}
							set oprnDataObj.AdmDr=admObj.%Id()
							set oprnDataObj.AdmID=admID
							set oprnDataObj.OprnSn=oprnItem.oprnSn
							set oprnDataObj.MainFlag=oprnItem.mainFlag
							set oprnDataObj.OprnCode=oprnItem.oprnCode
							set oprnDataObj.OprnName=oprnItem.oprnName
							set oprnDataObj.OprnDate=oprnItem.oprnDate
							set oprnDataObj.CreateDate=$zd(+$h,3)
							set oprnDataObj.CreateTime=$zt($p($h,",",2))
							set oprnDataObj.CreateUserDr="158"
							
							set oprnData=[]
							do oprnData.%Push(oprnDataObj)
							
							set oprnInsObj={}
							set oprnInsObj.className="User.BSHISOprnInfo"
							set oprnInsObj.updateUserID="158"
							set oprnInsObj.data=oprnData
							
							set rtn=##class(src.util.operatetable).Insert(.oprnInsObj)
							if rtn.errorCode'=0 
							{
								do ..LogSyncError(admID_"_"_oprnItem.oprnCode,"BS_HISOprnInfo",rtn.errorMessage)
							}
						}
					}
		 			
					//set resultObj.result.successCount=resultObj.result.successCount+1
				}
			}
			
			set resultObj.result.successCount=resultObj.result.successCount+1
		    
		}
		
		///写入同步日志 BS_HISSyncLog
		do ..WriteSyncLog(logStartTime,resultObj)
		
	} 
	catch e 
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="保存HIS住院患者数据出现问题:"_$classname()_".SaveInpatientData()"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
		
		///写入同步日志（异常）
		do ..WriteSyncLog(logStartTime,resultObj)
	}
	
	quit resultObj
}

/// 写入同步日志 BS_HISSyncLog
ClassMethod WriteSyncLog(pStartTime, pResultObj)
{
    try 
    {
        // 构造数据对象
        set dataObj = {}
        set dataObj.TaskName = "获取HIS住院患者数据"
        set dataObj.SyncType = "manual"
        set dataObj.StartTime = pStartTime
        set dataObj.EndTime =$zd(+$h,3)_" "_$zt($p($h,",",2))  // YYYY-MM-DD HH:MM:SS
        set total = pResultObj.result.totalCount
        set success = pResultObj.result.successCount
        set failed = pResultObj.result.failedCount
        set dataObj.TotalCount = total
        set dataObj.SuccessCount = success
        set dataObj.FailedCount = failed
        
		set dataObj.CreateDate=$zd(+$h,3)
		set dataObj.CreateTime=$zt($p($h,",",2))
		set dataObj.CreateUserDr="158"
		set dataObj.UpdateDate=$zd(+$h,3)
		set dataObj.UpdateTime=$zt($p($h,",",2))
        
        // 状态码计算
        if failed = 0
        {
            set statusCode = "success"
        } 
        elseif success = 0 
        {
            set statusCode = "failed"
        } 
        else 
        {
            set statusCode = "partial"
        }
        set dataObj.StatusCode = statusCode
        set dataObj.ErrorMessage = "同步完成：成功"_success_"条，失败"_failed_"条,"_pResultObj.result.errorMessage
        
        // 构造调用对象
        set insObj = {}
        set insObj.className = "User.BSHISSyncLog"
        set insObj.updateUserID = "158"
        set dataList = []
        do dataList.%Push(dataObj)
        set insObj.data = dataList
        
        // 调用 operatetable 插入
        set rtn = ##class(src.util.operatetable).Insert(.insObj)
        if rtn.errorCode '= 0 
        {
	        do ..LogSyncError(00000,"BS_HISSyncLog",rtn.errorMessage)
            // 记录失败日志（可忽略或写入系统日志）
            // 为保持兼容，不抛出异常
        }
        
    } catch (e) {
        // 日志写入失败不抛出异常，保持原有设计
    }
}

/// 记录同步错误日志
ClassMethod LogSyncError(pAdmID, pTableName, pErrorMessage)
{
	new (pAdmID, pTableName, pErrorMessage, errorInfo, errorLogID)
	try 
	{
		set errorInfo="AdmID="_pAdmID_"，表："_pTableName_"，错误信息："_pErrorMessage
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,pErrorMessage)
	} 
	catch (e) 
	{
		///记录错误日志失败，不中断主流程
	}
}

/// 删除诊断（示例，建议修改为接受主表ID）
ClassMethod DeleteDiseInfo(pAdmRefID As %Integer) As %Status
{
    &sql(DELETE FROM BS_HISDiseInfo WHERE Adm_Dr = :pAdmRefID)
    return SQLCODE
}

/// 删除手术
ClassMethod DeleteOprnInfo(pAdmRefID As %Integer) As %Status
{
    &sql(DELETE FROM BS_HISOprnInfo WHERE Adm_Dr = :pAdmRefID)
    return SQLCODE
}

/// 获取HIS住院患者费用数据
ClassMethod GetInpatientFeeData(jsonObj)
{
}

/// 查询已同步患者列表（接口02010075）
/// 参考DRGCataLog.GetDRGCataLogList方法风格改写
ClassMethod QuerySyncedPatients(jsonObj) As %Library.DynamicObject
{
    new (jsonObj)
    set resultObj={"errorCode":"0","errorMessage":"","result":{}}
    set pageSize="",currentPage=1,count=0,dataArr=[]
    
    try
    {
        // 1. 解析分页参数
        if (jsonObj.%IsDefined("pagination")'=0) 
        {
            set pagationObj=jsonObj.pagination.%Get(0)
            set pageSize=pagationObj.pageSize
            set currentPage=pagationObj.currentPage
        }
        
        // 2. 解析查询参数
        set params=jsonObj.params.%Get(0)
        set patientName=params.patientName
        set medicalRecordNo=params.medicalRecordNo
        set admDateStart=params.admDateStart
        set admDateEnd=params.admDateEnd
        
        // 3. 构建动态SQL（参考GetDRGCataLogList风格）
        set sql=" SELECT ID,AdmID,PatMedicalNo,PatName,PatSexCode,PatSexDesc,"
               _" InLocDesc,AdmDocDesc,AdmDateTime,AdmInDays,AdmDiag"
               _" FROM BS_HISPatAdm WHERE 1=1"
        
        // 添加查询条件
        if patientName'=""
        {
            set sql=sql_" AND PatName LIKE '%"_patientName_"%'" 
        }
        if medicalRecordNo'=""
        {
            set sql=sql_" AND PatMedicalNo LIKE '%"_medicalRecordNo_"%'" 
        }
        if admDateStart'=""
        {
            // 将admDateStart转为当天00:00:00
            set sql=sql_" AND AdmDateTime >= '"_admDateStart_" 00:00:00'" 
        }
        if admDateEnd'=""
        {
            // 将admDateEnd转为当天23:59:59
            set sql=sql_" AND AdmDateTime <= '"_admDateEnd_" 23:59:59'" 
        }
        
        set sql=sql_" ORDER BY AdmDateTime DESC"
        
        // 4. 执行SQL查询
        set sqlObj=##class(%SQL.Statement).%New(1)
        set sc=sqlObj.%Prepare(sql)
        set result=sqlObj.%Execute()
        
        // 5. 遍历结果集，进行内存分页
        while result.%Next(sc)	
        {
            set id=result.ID
            set admID=result.AdmID
            set patMedicalNo=result.PatMedicalNo
            set patName=result.PatName
            set patSexCode=result.PatSexCode
            set patSexDesc=result.PatSexDesc
            set inLocDesc=result.InLocDesc
            set admDocDesc=result.AdmDocDesc
            set admDateTime=result.AdmDateTime
            set admInDays=result.AdmInDays
            set admDiag=result.AdmDiag
            
            // 构建数据对象
            set dataObj={}
            set dataObj.admissionNo=admID
            set dataObj.medicalRecordNo=patMedicalNo
            set dataObj.patientName=patName
            set dataObj.sexCode=patSexCode
            set dataObj.sexDesc=patSexDesc
            set dataObj.department=inLocDesc
            set dataObj.doctor=admDocDesc
            set dataObj.admissionDate=admDateTime
            set dataObj.admInDays=admInDays
            set dataObj.mainDiagnosis=admDiag
            
            // 获取主诊断（从BS_HISDiseInfo表中查询）
            set dataObj.mainDiagnosisCode=""
            set dataObj.mainDiagnosisName=""
            set diseSql="SELECT DiseCode,DiseName FROM BS_HISDiseInfo WHERE AdmDr=? AND MainFlag='Y' AND Deleted=0 ORDER BY DiagSn"
            set diseStmt=##class(%SQL.Statement).%New(1)
            do diseStmt.%Prepare(diseSql)
            set diseRs=diseStmt.%Execute(id)
            if diseRs.%Next()
            {
                set dataObj.mainDiagnosisCode=diseRs.%Get("DiseCode")
                set dataObj.mainDiagnosisName=diseRs.%Get("DiseName")
            }
            do diseRs.%Close()
            
            // 获取主手术（从BS_HISOprnInfo表中查询）
            set dataObj.mainProcedureCode=""
            set dataObj.mainProcedureName=""
            set oprnSql="SELECT OprnCode,OprnName FROM BS_HISOprnInfo WHERE AdmDr=? AND MainFlag='Y' AND Deleted=0 ORDER BY OprnSn"
            set oprnStmt=##class(%SQL.Statement).%New(1)
            do oprnStmt.%Prepare(oprnSql)
            set oprnRs=oprnStmt.%Execute(id)
            if oprnRs.%Next()
            {
                set dataObj.mainProcedureCode=oprnRs.%Get("OprnCode")
                set dataObj.mainProcedureName=oprnRs.%Get("OprnName")
            }
            do oprnRs.%Close()
            
            // 获取总费用（从BS_HISDRGParams表中查询）
            set dataObj.totalCost=0
            set costSql="SELECT TotalCost FROM BS_HISDRGParams WHERE AdmDr=? AND Deleted=0"
            set costStmt=##class(%SQL.Statement).%New(1)
            do costStmt.%Prepare(costSql)
            set costRs=costStmt.%Execute(id)
            if costRs.%Next()
            {
                set dataObj.totalCost=costRs.%Get("TotalCost")
            }
            do costRs.%Close()
            
            set count=count+1
            // 内存分页：跳过不符合分页条件的数据
            if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
            do dataArr.%Push(dataObj)
        }
        
        // 6. 设置返回结果
        set resultObj.result.rows=dataArr
        set resultObj.result.total=count
                
    }catch(e){
        set status=e.AsStatus()
        set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
        set errorInfo="查询已同步患者出现问题:w ##class("_$ClassName()_").QuerySyncedPatients("_jsonObj.%ToJSON()_")"
        set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
        set resultObj={}
        set resultObj.errorCode="04000007"
        set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
    }
    quit resultObj
}

/// 查询患者详情（接口02010076）
ClassMethod QueryPatientDetail(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (jsonObj)
    set resultObj = {"errorCode":"-1","errorMessage":"","result":{"admInfo":{},"diseList":[],"oprnList":[]}}
    
    try {
        // 1. 参数解析
        set params = jsonObj.params.%Get(0)
        set admID = $get(params.admID, "")
        if admID = "" {
            set resultObj.errorCode = "04000001"
            set resultObj.errorMessage = "就诊ID不能为空"
            quit
        }
        
        // 2. 查询就诊信息（改用 SQL 避免对象锁，且只取所需字段）
        set admSql = "SELECT AdmID, PatID, PatMedicalNo, PatName, PatSexCode, PatSexDesc, " _
                    "PatNo, AdmDocDesc, AdmNurDesc, AdmDateTime, AdmInDays, AdmDiag, " _
                    "InLocDesc, InWardDesc, CreateDate, CreateTime " _
                    "FROM BS_HISPatAdm " _
                    "WHERE ID = ? AND Deleted = 0"
        set admStmt = ##class(%SQL.Statement).%New(1)
        do admStmt.%Prepare(admSql)
        set admRs = admStmt.%Execute(admID)
        
        if 'admRs.%Next() {
            set resultObj.errorCode = "04000002"
            set resultObj.errorMessage = "未找到就诊记录："_admID
            do admRs.%Close()
            quit
        }
        
        // 构造就诊信息 JSON，日期格式化为字符串
        set admInfo = {}
        set admInfo.admissionNo = admRs.%Get("AdmID")
        set admInfo.patID = admRs.%Get("PatID")
        set admInfo.medicalRecordNo = admRs.%Get("PatMedicalNo")
        set admInfo.patientName = admRs.%Get("PatName")
        set admInfo.sexCode = admRs.%Get("PatSexCode")
        set admInfo.sexDesc = admRs.%Get("PatSexDesc")
        set admInfo.patNo = admRs.%Get("PatNo")
        set admInfo.admDocDesc = admRs.%Get("AdmDocDesc")
        set admInfo.admNurDesc = admRs.%Get("AdmNurDesc")
        
        // 日期时间转换
        set admDateTime = admRs.%Get("AdmDateTime")
        if admDateTime '= "" {
            set admInfo.admDateTime = $zd(admDateTime, 3)  // YYYY-MM-DD
        } else {
            set admInfo.admDateTime = ""
        }
        set admInfo.admInDays = admRs.%Get("AdmInDays")
        set admInfo.admDiag = admRs.%Get("AdmDiag")
        set admInfo.inLocDesc = admRs.%Get("InLocDesc")
        set admInfo.inWardDesc = admRs.%Get("InWardDesc")
        
        set createDate = admRs.%Get("CreateDate")
        set createTime = admRs.%Get("CreateTime")
        if createDate '= "" {
            set admInfo.createDate = $zd(createDate, 3)
        } else {
            set admInfo.createDate = ""
        }
        if createTime '= "" {
            set admInfo.createTime = $zt(createTime, 2)  // HH:MM:SS
        } else {
            set admInfo.createTime = ""
        }
        
        do admRs.%Close()
        set resultObj.result.admInfo = admInfo
        
        // 3. 查询诊断列表（明确字段，参数化）
        set diseList = []
        set diseSql = "SELECT DiagSn, DiseCode, DiseName, MainFlag, DiseType " _
                     "FROM BS_HISDiseInfo WHERE AdmDr = ? AND Deleted = 0 ORDER BY DiagSn"
        set diseStmt = ##class(%SQL.Statement).%New(1)
        do diseStmt.%Prepare(diseSql)
        set diseRs = diseStmt.%Execute(admID)
        
        while diseRs.%Next() {
            set diseItem = {}
            set diseItem.diseSn = diseRs.%Get("DiagSn")
            set diseItem.diseCode = diseRs.%Get("DiseCode")
            set diseItem.diseName = diseRs.%Get("DiseName")
            set diseItem.mainFlag = diseRs.%Get("MainFlag")
            set diseItem.diseType = diseRs.%Get("DiseType")
            do diseList.%Push(diseItem)
        }
        do diseRs.%Close()
        set resultObj.result.diseList = diseList
        
        // 4. 查询手术列表
        set oprnList = []
        set oprnSql = "SELECT OprnSn, OprnCode, OprnName, MainFlag, OprnDate " _
                     "FROM BS_HISOprnInfo WHERE AdmDr = ? AND Deleted = 0 ORDER BY OprnSn"
        set oprnStmt = ##class(%SQL.Statement).%New(1)
        do oprnStmt.%Prepare(oprnSql)
        set oprnRs = oprnStmt.%Execute(admID)
        
        while oprnRs.%Next() {
            set oprnItem = {}
            set oprnItem.oprnSn = oprnRs.%Get("OprnSn")
            set oprnItem.oprnCode = oprnRs.%Get("OprnCode")
            set oprnItem.oprnName = oprnRs.%Get("OprnName")
            set oprnItem.mainFlag = oprnRs.%Get("MainFlag")
            set oprnDate = oprnRs.%Get("OprnDate")
            if oprnDate '= "" {
                set oprnItem.oprnDate = $zd(oprnDate, 3)
            } else {
                set oprnItem.oprnDate = ""
            }
            do oprnList.%Push(oprnItem)
        }
        do oprnRs.%Close()
        set resultObj.result.oprnList = oprnList
        
        set resultObj.errorCode = "0"
    }
    catch e {
        set resultObj.errorCode = "-1"
        set resultObj.errorMessage = "查询患者详情失败：" _ $System.Status.GetErrorText(e.AsStatus())
        // 可加入日志记录：do ##class(Util.Log).Error("QueryPatientDetail", e.DisplayString())
    }
    quit resultObj
}

/// 查询同步日志列表（接口02010077）
/// 参考DRGCataLog.GetDRGCataLogList方法风格改写
ClassMethod QuerySyncLogs(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (jsonObj)
    set resultObj={"errorCode":"0","errorMessage":"","result":{}}
    set pageSize="",currentPage=1,count=0,dataArr=[]
    
    try
    {
        // 1. 解析分页参数
        if (jsonObj.%IsDefined("pagination")'=0) 
        {
            set pagationObj=jsonObj.pagination.%Get(0)
            set pageSize=pagationObj.pageSize
            set currentPage=pagationObj.currentPage
        }
        
        // 2. 解析查询参数
        set params=jsonObj.params.%Get(0)
        set syncType=params.syncType
        set statusCode=params.statusCode
        set startDate=params.startDate
        set endDate=params.endDate
        
        // 3. 构建动态SQL（参考GetDRGCataLogList风格）
        set sql=" SELECT ID,TaskName,SyncType,StartTime,EndTime,StatusCode,"
               _" TotalCount,SuccessCount,FailedCount,ErrorMessage"
               _" FROM BS_HISSyncLog WHERE 1=1"
        
        // 添加查询条件
        if syncType'=""
        {
            set sql=sql_" AND SyncType = '"_syncType_"'" 
        }
        if statusCode'=""
        {
            set sql=sql_" AND StatusCode = '"_statusCode_"'" 
        }
        if startDate'=""
        {
            // 将startDate转为当天00:00:00
            set sql=sql_" AND StartTime >= '"_startDate_" 00:00:00'" 
        }
        if endDate'=""
        {
            // 将endDate转为当天23:59:59
            set sql=sql_" AND StartTime <= '"_endDate_" 23:59:59'" 
        }
        
        set sql=sql_" ORDER BY StartTime DESC"
        
        // 4. 执行SQL查询
        set sqlObj=##class(%SQL.Statement).%New(1)
        set sc=sqlObj.%Prepare(sql)
        set result=sqlObj.%Execute()
        
        // 5. 遍历结果集，进行内存分页
        while result.%Next(sc)	
        {
            set id=result.ID
            set taskName=result.TaskName
            set syncType=result.SyncType
            set startTime=result.StartTime
            set endTime=result.EndTime
            set statusCode=result.StatusCode
            set totalCount=result.TotalCount
            set successCount=result.SuccessCount
            set failedCount=result.FailedCount
            set errorMessage=result.ErrorMessage
            
            // 构建数据对象
            set dataObj={}
            set dataObj.id=id
            set dataObj.taskName=taskName
            set dataObj.syncType=syncType
            set dataObj.startTime=startTime
            set dataObj.endTime=endTime
            set dataObj.statusCode=statusCode
            set dataObj.totalCount=totalCount
            set dataObj.successCount=successCount
            set dataObj.failedCount=failedCount
            set dataObj.errorMessage=errorMessage
            
            set count=count+1
            // 内存分页：跳过不符合分页条件的数据
            if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
            do dataArr.%Push(dataObj)
        }
        
        // 6. 设置返回结果
        set resultObj.result.rows=dataArr
        set resultObj.result.total=count
                
    }catch(e){
        set status=e.AsStatus()
        set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
        set errorInfo="查询同步日志出现问题:w ##class("_$ClassName()_").QuerySyncLogs("_jsonObj.%ToJSON()_")"
        set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
        set resultObj={}
        set resultObj.errorCode="04000007"
        set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
    }
    quit resultObj
}

}
