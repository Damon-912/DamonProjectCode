Import SQLUSER

Class src.DRG.BasicData.CoreAlgorithm Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 通用方法根据起始和截至时间判断有效/失效
ClassMethod IsRecordActive(startDate As %Date, stopDate As %Date) As %Boolean
{
    Set currentDate = +$Horolog
    
    // 处理空值：startDate为空视为最小日期，stopDate为空视为最大日期
    Set effectiveStart = $Select(startDate="":0, 1:startDate)  // 0 = 1840-12-31
    Set effectiveEnd = $Select(stopDate="":99999, 1:stopDate)  // 99999 = 未来日期
        
    Quit (effectiveStart <= currentDate) && (effectiveEnd >= currentDate)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存DRG核心算法配置
/// Table:     	 HB_DRGCoreAlgorithmData
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug:
ClassMethod UpdateDRGCoreAlgorithm(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="保存成功"
	set resultObj.result={}
	try{
		set params=postObj.params.%Get(0)
		//set session=postObj.session.%Get(0)
		//set hospID=session.hospID
		//set userID=session.userID
		
		set dictID=params.id
		set drg=params.drg			
		set drgDesc=params.drgDesc
		set points=params.points //基准点数	
		set dgdov=params.dgdov   //病组差异系数
		set pipValue=params.pipValue
		set payStandard=params.payStandard   //支付标准
        set insuType=params.insuType //险种类型
        set mdtrtArea=params.mdtrtArea //就医地区划代码        
        set medinsLv=params.medinsLv //医疗机构等级
		set fixmedinsCode=params.fixmedinsCode //医疗机构代码
		set fixmedinsName=params.fixmedinsName //医疗机构名称

		set provinceID=params.provinceDr //省
		set cityID=params.cityID         //市
		set startDate=params.startDate
		set stopDate=params.stopDate
		
		set identification=params.identification
		set remark=params.remark
		set year=params.year //分组方案年份
		
		if (startDate'="")&&(stopDate'="")
		{
			set startDate=$zdh(startDate,3)
			set stopDate=$zdh(stopDate,3)
			
			if (startDate>stopDate)
			{
			    set resultObj.errorCode="01040014"
			    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040014")   
			    quit	
			}
		}						

        set criteria=$TRANSLATE(points_dgdov_payStandard_insuType_mdtrtArea_medinsLv_fixmedinsCode," ","")
        set criteria=$REPLACE(criteria,"NULL","")

		if (criteria="")
		{
			set resultObj.errorCode="-1"
			set resultObj.errorMessage="基准点数\病组差异系数\支付标准\险种类型\就医地区划代码\医疗机构等级\医疗机构代码,参数不能为空！"
			quit
		}
		
		if (fixmedinsCode="")
		{
			set resultObj.errorCode="01040016"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040016")
			quit
		}		
																				
		if (provinceID="")
		{
			set resultObj.errorCode="01000007"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000007")
			quit
		}
		
		if (cityID="")
		{
			set resultObj.errorCode="01000008"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000008")
			quit
		}
		
		set data=[]
		set dataObj={}
		set dataObj.ID=dictID
		set dataObj.DRG=drg
		set dataObj.DRGDESC=drgDesc	
		set dataObj.Points=points
		set dataObj.DGDOV=dgdov
		set dataObj.PipValue=pipValue
		set dataObj.PayStandard=payStandard
		set dataObj.InsuType=insuType
		set dataObj.MdtrtArea=mdtrtArea
		set dataObj.MedinsLv=medinsLv																					
		set dataObj.ProvinceDr=provinceID
		set dataObj.CityDr=cityID		
		set dataObj.StartDate=startDate
		set dataObj.StopDate=stopDate		
		set dataObj.CreateUserDr= "158" //userID
		set dataObj.CreateDate=$zd($h,3)
		set dataObj.CreateTime=$zt($p($h,",",2),1)
		set dataObj.FixmedinsCode=fixmedinsCode
		set dataObj.FixmedinsName=fixmedinsName
		set dataObj.Identification=identification
		set dataObj.Remark=remark
		set dataObj.Year=year		
				
		set insObj={}
		set insObj.className="User.HBDRGCoreAlgorithmData"
		set insObj.updateUserID= "0" //userID	
		set rtn=""
		do data.%Push(dataObj)
		set insObj.data=data
		if dictID=""{
			set rtn=##class(src.util.operatetable).Insert(.insObj)
		}else{
			set rtn=##class(src.util.operatetable).Update(.insObj)
		}
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
	    if errorCode'=0{
		    set resultObj.errorCode=errorCode
	    	set resultObj.errorMessage=errorMessage
	   	}
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="保存核心算法配置数据出现问题:w ##class("_$ClassName()_").UpdateDRGCoreAlgorithm("_postObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
 	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询DRG核心算法配置
/// Table:     	 HB_DRGCoreAlgorithmData
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug: 
ClassMethod GetDRGCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try
	{
		if (jsonObj.%IsDefined("pagination")'=0) 
		{
			set pagationObj=jsonObj.pagination.%Get(0)
			set pageSize=pagationObj.pageSize
			set currentPage=pagationObj.currentPage
		}
		
		set params=jsonObj.params.%Get(0)
		set DRG=params.drg		
		set fixmedinsName=params.fixmedinsName
		set fixmedinsCode=params.fixmedinsCode
		set cityID=params.cityID
		set provinceID=params.provinceID
		set insuType=params.insuType
		
		set status=params.status
		set year=params.year  //分组方案年份

		set sql =" SELECT ID,DRG,DRGDESC,Points,PipValue,DGDOV,PayStandard,InsuType,MdtrtArea,MedinsLv,"
		        _" Province_Dr as ProvinceID,Province_Dr->Descripts as ProvinceDesc,"
		        _" City_Dr as CityID,City_Dr->Descripts as CityDesc,StartDate,StopDate," 
			    _" FixmedinsCode,FixmedinsName,Identification,Remark,CreateDate,CreateTime,Year "
			    _" FROM HB_DRGCoreAlgorithmData where 1=1"
		
		if DRG'=""
		{
			set sql=sql_" and DRG like '%"_DRG_"%'" 
		}					   
		if fixmedinsName'=""
		{
			set sql=sql_" and FixmedinsName like '%"_fixmedinsName_"%'" 
		}		
		if fixmedinsCode'=""
		{
			set sql=sql_" and FixmedinsCode = "_fixmedinsCode 
		}		
		if cityID'=""
		{
			set sql=sql_" and City_Dr = "_cityID 
		}
		if provinceID'=""
		{
			set sql=sql_" and Province_Dr = "_provinceID 
		}	
		if insuType'=""
		{
			set sql=sql_" and insuType = "_insuType 
		}
		if year'=""
		{
			set sql=sql_" and Year = '"_year_"'" 
		}										

		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)	
		{
			set startDate=result.%Get("startDate")
			set stopDate=result.%Get("StopDate")
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.drg=result.%Get("DRG")
            set dataObj.drgDesc=result.%Get("DRGDESC")
            
		    set dataObj.points=result.%Get("Points")
		    set dataObj.pipValue=result.%Get("PipValue")		
		    set dataObj.dgdov=result.%Get("DGDOV")
		    set dataObj.payStandard=result.%Get("PayStandard")	
		    
		    set dataObj.insuType=result.%Get("InsuType")
		    set dataObj.mdtrtArea=result.%Get("MdtrtArea")
		    set dataObj.medinsLv=result.%Get("MedinsLv")
		    		
			set dataObj.provinceID=result.%Get("ProvinceID")
			set dataObj.provinceDesc=result.%Get("ProvinceDesc")
			set dataObj.cityID=result.%Get("CityID")
			set dataObj.cityDesc=result.%Get("CityDesc")
			set dataObj.startDate=startDate
			set dataObj.stopDate=stopDate			
		    set dataObj.fixmedinsCode=result.%Get("FixmedinsCode")
		    set dataObj.fixmedinsName=result.%Get("FixmedinsName")
		    set dataObj.identification=result.%Get("Identification")
		    set dataObj.remark=result.%Get("Remark")
		    set dataObj.year=result.%Get("Year")				

			if startDate'=""{
				set startDate=$zdh(startDate,3)
			}
			if stopDate'=""{
				set stopDate=$zdh(stopDate,3)
			}			
			
			set iStatus=..IsRecordActive(startDate,stopDate)
							
			if (iStatus){
		    	set statusDesc="有效"
		     	set statusFlag="Y"				
			}
			else{
		    	set statusDesc="无效"
		     	set statusFlag="N"				
			}
															
			if status="Y"{
				continue:statusFlag="N"
			}
			elseif status="N"{
			    continue:statusFlag="Y"	
			}			
			
			set dataObj.statusDesc=statusDesc
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询核心算法配置数据出现问题:w ##class("_$ClassName()_").GetDRGCoreAlgorithm("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除DRG核心算法配置
/// Table:     	 HB_DRGCoreAlgorithmData
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug:
ClassMethod DeleteDRGCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
    new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set userID=session.userID
		if params.id="" 
		{
			set resultObj.errorCode="05100128"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")  ///请选择一条数据
			quit
		}
		set delObj={},data=[]
		set delObj.className="User.HBDRGCoreAlgorithmData"
		set delObj.updateUserID=userID
		set dataObj={}
		set dataObj.ID=params.id
		do data.%Push(dataObj)
		set delObj.data=data
		;b ;0
		set rtn=##class(src.util.operatetable).Delete(.delObj) ;调用公共类方法记录修改日记
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage		
		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="删除核心算法配置数据出现问题:w ##class("_$ClassName()_").DeleteDRGCoreAlgorithm("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     System
/// CreatDate:   2026-04-17
/// Description: 下载DRG核心算法配置导入模板
/// Output:      CSV格式模板内容（Base64编码）
/// Return:      接口响应对象
/// Debug:       w ##class(src.DRG.BasicData.CoreAlgorithm).DownloadDRGCoreAlgorithmTemplate({}).%ToJSON()
ClassMethod DownloadDRGCoreAlgorithmTemplate(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (jsonObj)
    set resultObj={"errorCode":"0","errorMessage":"","result":{}}
    
    try {
        // 生成CSV内容
        set csvContent = "DRGCode,DRGDesc,Points,PipValue,DGDOV,PayStandard"_$c(13,10)
        set csvContent = csvContent_"AA01,NULL,120.50,1.2,0.95,15000.00"_$c(13,10)
        set csvContent = csvContent_"BB02,NULL,85.30,1.0,1.05,9800.00"_$c(13,10)
        
        // Base64编码
        set base64Data = ##class(%SYSTEM.Encryption).Base64Encode(csvContent)
        
        set resultObj.result.fileName = "DRG核心算法配置导入模板.csv"
        set resultObj.result.fileData = base64Data
        set resultObj.result.contentType = "text/csv"
        
    } catch e {
        set status = e.AsStatus()
        set resultObj.errorCode = "04000007"
        set resultObj.errorMessage = "下载模板失败: "_$system.Status.GetErrorText(status)
    }
    
    quit resultObj
}

/// Creator:     System
/// CreatDate:   2026-04-17
/// Description: DRG核心算法配置导入预览（校验数据并返回预览结果）
/// Table:       HB_DRGCoreAlgorithmData (User.HBDRGCoreAlgorithmData)
/// Input:       provinceID, cityID, medicalInstitution, fileData(Base64)
/// Output:      预览结果（含重复数据标记）
/// Return:      接口响应对象
/// Debug:       w ##class(src.DRG.BasicData.CoreAlgorithm).PreviewImportDRGCoreAlgorithm({}).%ToJSON()
ClassMethod PreviewImportDRGCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
    new (jsonObj)
    set resultObj={"errorCode":"0","errorMessage":"","result":{"totalCount":0,"validCount":0,"invalidCount":0,"duplicateCount":0,"previewList":[]}}
    
    set totalCount=0,validCount=0,invalidCount=0,duplicateCount=0
    set previewList=[]
    
    try 
    {
        set params=jsonObj.params.%Get(0)
        set provinceID=params.provinceID
        set cityID=params.cityID
        set fileData=params.fileData
        set mdtrtArea=params.mdtrtArea
        set fixmedinsCode=params.fixmedinsCode
        set fixmedinsName=params.fixmedinsName
        set year=params.year  //分组方案年份（导入必选）
        set medinsLv=params.medinsLv
        
        // 参数校验
        if provinceID="" {
            set resultObj.errorCode="01000007"
            set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000007")
            quit
        }
        if cityID="" {
            set resultObj.errorCode="01000008"
            set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000008")
            quit
        }
        if fileData="" {
            set resultObj.errorCode="02010001"
            set resultObj.errorMessage="导入文件不能为空"
            quit
        }
        
        // Base64解码 - 尝试多种方法
        set csvContent = ""
        
        // 方法1: 使用$zcvt函数
        try {
            set csvContent = $zcvt(fileData, "I", "BASE64")
        } catch e1 {
            // 不输出调试信息
        }
        
        // 如果方法1失败，尝试方法2: 使用%SYSTEM.Encryption.Base64Decode
        if csvContent="" {
            try {
                set binaryData = ##class(%SYSTEM.Encryption).Base64Decode(fileData)
                set csvContent = $zcvt(binaryData, "I", "UTF8")
                if csvContent["?" {
                    set csvContent = $zcvt(binaryData, "I", "GB18030")
                }
                if csvContent["?" {
                    set csvContent = binaryData
                }
            } catch e2 {
                // 不输出调试信息
            }
        }
        
        if csvContent="" 
        {
            set resultObj.errorCode="02010003"
            set resultObj.errorMessage="文件解码失败，请提供有效的CSV文件"
            quit
        }
        
        // 解析CSV内容
        set lineNum=0
        set ptr=1
        set csvContent=$replace(csvContent,$c(13,10),$c(10))
        set csvContent=$replace(csvContent,$c(13),$c(10))
        
        for 
        {
            set line=$piece(csvContent,$c(10),ptr)
            quit:line=""
            set ptr=ptr+1
            set lineNum=lineNum+1
            continue:lineNum=1
            continue:line=""
            
            set totalCount=totalCount+1
            set rowNum=lineNum-1
            
            // 解析CSV列
            set errorMsg=""
            try { set drgCode=$piece(line,",",1) } catch { set drgCode="",errorMsg="字段解析错误" }
            try { set drgDesc=$piece(line,",",2) } catch { set drgDesc="" }
            try { set points=$piece(line,",",3) } catch { set points="" }
            try { set pipValue=$piece(line,",",4) } catch { set pipValue="" }
            try { set dgdov=$piece(line,",",5) } catch { set dgdov="" }
            try { set payStandard=$piece(line,",",6) } catch { set payStandard="" }
            
            set previewObj={}
            set previewObj.rowNum=rowNum
            set previewObj.drgCode=drgCode
            set previewObj.drgDesc=drgDesc
            set previewObj.points=points
            set previewObj.pipValue=pipValue
            set previewObj.dgdov=dgdov
            set previewObj.payStandard=payStandard
            set previewObj.errorMsg=errorMsg
            
            // 数据校验
            if (errorMsg '="")
            {
                set invalidCount=invalidCount+1
                set previewObj.status="invalid"
                set previewObj.statusDesc="解析错误"
            } 		
            elseif drgCode="" 
            {
                set previewObj.status="invalid"
                set previewObj.statusDesc="错误"
                set previewObj.errorMsg="DRG代码不能为空"
                set invalidCount=invalidCount+1
                do previewList.%Push(previewObj)
                continue
            }
            elseif drgDesc=""
            {
                set previewObj.status="invalid"
                set previewObj.statusDesc="错误"
                set previewObj.errorMsg="DRG描述不能为空"
                set invalidCount=invalidCount+1
                do previewList.%Push(previewObj)
                continue
            }
            elseif (points="")
            {
                set previewObj.status="invalid"
                set previewObj.statusDesc="错误"
                set previewObj.errorMsg="基准点数不能为空"
                set invalidCount=invalidCount+1
                do previewList.%Push(previewObj)
                continue
            }
            elseif (pipValue="")
            {
                set previewObj.status="invalid"
                set previewObj.statusDesc="错误"
                set previewObj.errorMsg="预估点值不能为空"
                set invalidCount=invalidCount+1
                do previewList.%Push(previewObj)
                continue
            }
            elseif (dgdov="")
            {
                set previewObj.status="invalid"
                set previewObj.statusDesc="错误"
                set previewObj.errorMsg="病组差异系数不能为空"
                set invalidCount=invalidCount+1
                do previewList.%Push(previewObj)
                continue
            }
            elseif (payStandard="")
            {
                set previewObj.status="invalid"
                set previewObj.statusDesc="错误"
                set previewObj.errorMsg="支付标准不能为空"
                set invalidCount=invalidCount+1
                do previewList.%Push(previewObj)
                continue
            }
            
            // 检查是否已存在（根据表主键索引：DRG+省+市+机构代码+年份）
            set existingID=""
            &sql(SELECT ID INTO :existingID FROM SQLUser.HB_DRGCoreAlgorithmData 
                 WHERE DRG=:drgCode AND Province_Dr=:provinceID AND City_Dr=:cityID AND FixmedinsCode=:fixmedinsCode AND Year=:year)
            
            if existingID'="" 
            {
                set previewObj.status="duplicate"
                set previewObj.statusDesc="重复"
                set previewObj.errorMsg="该DRG配置已存在，导入将执行更新操作"
                set duplicateCount=duplicateCount+1
            } 
            else 
            {
                set previewObj.status="valid"
                set previewObj.statusDesc="正常"
                set validCount=validCount+1
            }
            
            do previewList.%Push(previewObj)
                
        }
        
        set resultObj.result.totalCount=totalCount
        set resultObj.result.validCount=validCount
        set resultObj.result.invalidCount=invalidCount
        set resultObj.result.duplicateCount=duplicateCount
        set resultObj.result.previewList=previewList
        
    } 
    catch(e) 
    {
        set status=e.AsStatus()
        set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
        set resultObj.errorCode="04000007"
        set resultObj.errorMessage="预览失败："_errorMessage
    }
    
    quit resultObj
}

/// Creator:     System
/// CreatDate:   2026-04-17
/// Description: 确认导入DRG核心算法配置
/// Table:       HB_DRGCoreAlgorithmData (User.HBDRGCoreAlgorithmData)
/// Input:       provinceID, cityID, medicalInstitution, fileData(Base64)
/// Output:      详细导入结果报告
/// Return:      接口响应对象
/// Debug:       w ##class(src.DRG.BasicData.CoreAlgorithm).ConfirmImportDRGCoreAlgorithm({}).%ToJSON()
ClassMethod ConfirmImportDRGCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
    new (jsonObj)
    set resultObj={"errorCode":"0","errorMessage":"","result":{"totalCount":0,"successCount":0,"failCount":0,"duplicateCount":0,"newCount":0,"failList":[]}}
    
    set (totalCount,successCount,failCount,duplicateCount,newCount)=0
    set failList=[]
    
    try 
    {
        set params=jsonObj.params.%Get(0)
        set session=jsonObj.session.%Get(0)
        set userID=session.userID
        
        if (userID="")
        {
	        set userID="158"    
	    }                              
        
        // 检查必需参数
        if '$isobject(params) {
            set resultObj.errorCode="02010001"
            set resultObj.errorMessage="参数错误：缺少params参数"
            quit
        }
        
        set fileData=params.fileData
        set provinceID=params.provinceID
        set cityID=params.cityID
        set mdtrtArea=params.mdtrtArea
        set fixmedinsCode=params.fixmedinsCode
        set fixmedinsName=params.fixmedinsName
        set medinsLv=params.medinsLv
        set year=params.year  //分组方案年份（导入必选）
        
        if (provinceID="")||(cityID="")
        {
            set resultObj.errorCode="-1"
            set resultObj.errorMessage="接口入参省、市代码不能为空！"
            quit	
        }
                
        // Base64解码
        set csvContent = ""
        try {
            set csvContent = $zcvt(fileData, "I", "BASE64")
        } catch e1 {
        }
        
        if csvContent="" {
            try {
                set binaryData = ##class(%SYSTEM.Encryption).Base64Decode(fileData)
                set csvContent = $zcvt(binaryData, "I", "UTF8")
                if csvContent["?" {
                    set csvContent = $zcvt(binaryData, "I", "GB18030")
                }
                if csvContent["?" {
                    set csvContent = binaryData
                }
            } catch e2 {
            }
        }
        
        if csvContent="" {
            set resultObj.errorCode="02010003"
            set resultObj.errorMessage="文件解码失败，请提供有效的CSV文件"
            quit
        }
        
        // 解析CSV并执行导入
        set lineNum=0
        set ptr=1
        set csvContent=$replace(csvContent,$c(13,10),$c(10))
        set csvContent=$replace(csvContent,$c(13),$c(10))
        
        for 
        {
            set line=$piece(csvContent,$c(10),ptr)
            quit:line=""
            set ptr=ptr+1
            set lineNum=lineNum+1
            continue:lineNum=1
            continue:line=""
            
            set totalCount=totalCount+1
            set rowNum=lineNum-1
            
            // 解析CSV列
            try { set drgCode=$piece(line,",",1) } catch { set drgCode="" }
            try { set drgDesc=$piece(line,",",2) } catch { set drgDesc="" }
            try { set points=$piece(line,",",3) } catch { set points="" }
            try { set pipValue=$piece(line,",",4) } catch { set pipValue="" }
            try { set dgdov=$piece(line,",",5) } catch { set dgdov="" }
            try { set payStandard=$piece(line,",",6) } catch { set payStandard="" }
            
            // 跳过校验失败的行
            if (drgCode="")||(drgDesc="")||(points="")||(pipValue="")||(dgdov="")||(payStandard="")
            {
                set failCount=failCount+1
                set failObj={}
                set failObj.rowNum=rowNum
                set failObj.drgCode=drgCode
                set failObj.errorMsg="必填字段为空"
                do failList.%Push(failObj)
                continue
            }
            
            // 检查是否已存在（根据表主键索引：DRG+省+市+机构代码+年份）
            set existingID=""
            &sql(SELECT ID INTO :existingID FROM HB_DRGCoreAlgorithmData 
                 WHERE DRG=:drgCode AND Province_Dr=:provinceID AND City_Dr=:cityID AND FixmedinsCode=:fixmedinsCode AND Year=:year)
            
            // 构建数据对象
            set dataObj={}
            set dataObj.DRG=drgCode
            set dataObj.DRGDESC=drgDesc
            set dataObj.Points=points
            set dataObj.PipValue=pipValue
            set dataObj.DGDOV=dgdov
            set dataObj.PayStandard=payStandard
            set dataObj.ProvinceDr=provinceID
            set dataObj.CityDr=cityID
            set dataObj.MdtrtArea=mdtrtArea
            set dataObj.FixmedinsCode=fixmedinsCode
            set dataObj.FixmedinsName=fixmedinsName
            set dataObj.MedinsLv=medinsLv
            set dataObj.Year=year
            set dataObj.StartDate=$zd($h,3)
            set dataObj.StopDate=""
            set dataObj.CreateDate=$zd($h,3)
            set dataObj.CreateTime=$zt($p($h,",",2),1)
            set dataObj.CreateUserDr=userID
            
            set insObj={},data=[]
            set insObj.className="User.HBDRGCoreAlgorithmData"
            do data.%Push(dataObj)
            set insObj.data=data
            
            set operationType=""
            if existingID'="" 
            {
                set dataObj.ID=existingID
                set rtn=##class(src.util.operatetable).Update(.insObj)
                set operationType="更新"
                set duplicateCount=duplicateCount+1
            } 
            else 
            {
                set rtn=##class(src.util.operatetable).Insert(.insObj)
                set operationType="新增"
                set newCount=newCount+1
            }
            
            if rtn.errorCode'=0 
            {
                set failCount=failCount+1
                set failObj={}
                set failObj.rowNum=rowNum
                set failObj.drgCode=drgCode
                set failObj.errorMsg=rtn.errorMessage
                do failList.%Push(failObj)
            } 
            else 
            {
                set successCount=successCount+1
            }
        
        }
        
        set resultObj.result.totalCount=totalCount
        set resultObj.result.successCount=successCount
        set resultObj.result.failCount=failCount
        set resultObj.result.duplicateCount=duplicateCount
        set resultObj.result.newCount=newCount
        set resultObj.result.failList=failList
        
        
        if failCount>0 
        {
            set resultObj.errorCode="02010002"
            set resultObj.errorMessage="导入完成，部分数据导入失败，请查看失败列表"
        }                   
        
    } 
    catch(e) 
    {
        set status=e.AsStatus()
        set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
        set errorInfo="导入DRG核心算法配置出现问题:w ##class("_$ClassName()_").ConfirmImportDRGCoreAlgorithm("_jsonObj.%ToJSON()_")"
        set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
        set resultObj.errorCode="04000007"
        set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
    }
    
    quit resultObj
}

/// Creator:     System
/// CreatDate:   2026-04-21
/// Description: 查询DIP核心算法配置
/// Table:       HB_DIPCoreAlgorithmData (User.HBDIPCoreAlgorithmData)
/// Input:       principalDiagnosis, majorProcedure, provinceID, cityID, medinsLv, pagination
/// Output:      rows数组和total总数
/// Return:      接口响应对象
/// Debug:       w ##class(src.DRG.BasicData.CoreAlgorithm).QueryDIPCoreAlgorithm({}).%ToJSON()
ClassMethod QueryDIPCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{"rows":[],"total":0}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try
	{
		if (jsonObj.%IsDefined("pagination")'=0) 
		{
			set pagationObj=jsonObj.pagination.%Get(0)
			set pageSize=pagationObj.pageSize
			set currentPage=pagationObj.currentPage
		}
		
		set params=jsonObj.params.%Get(0)
		set principalDiagnosis=params.principalDiagnosis
		set principalDiagnosisName=params.principalDiagnosisName
		set majorProcedure=params.majorProcedure
		set majorProcedureName=params.majorProcedureName
		set provinceID=params.provinceID
		set cityID=params.cityID
		set medinsLv=params.medinsLv
		set year=params.year  //分组方案年份
		
		set sql =" SELECT ID,PrincipalDiagnosis,PrincipalDiagnosisName,"
		        _" MajorProcedure,MajorProcedureName,"
		        _" SecondaryProcedure,SecondaryProcedureName,"
		        _" Province_Dr as ProvinceID,Province_Dr->Descripts as ProvinceDesc,"
		        _" City_Dr as CityID,City_Dr->Descripts as CityDesc,"
		        _" MdtrtArea,MedinsLv,"
		        _" ScoreValue,AdjustCoefficient,"
		        _" PrimaryAdjustCoefficient,SecondaryAdjustCoefficient,ThirdAdjustCoefficient,"
		        _" CreateDate,CreateTime,Year "
		        _" FROM HB_DIPCoreAlgorithmData where 1=1"
		
		if principalDiagnosis'=""
		{
			set sql=sql_" and PrincipalDiagnosis like '%"_principalDiagnosis_"%'" 
		}
		if principalDiagnosisName'=""
		{
			set sql=sql_" and PrincipalDiagnosisName like '%"_principalDiagnosisName_"%'" 
		}
		if majorProcedure'=""
		{
			set sql=sql_" and MajorProcedure like '%"_majorProcedure_"%'" 
		}
		if majorProcedureName'=""
		{
			set sql=sql_" and MajorProcedureName like '%"_majorProcedureName_"%'" 
		}
		if provinceID'=""
		{
			set sql=sql_" and Province_Dr = "_provinceID 
		}
		if cityID'=""
		{
			set sql=sql_" and City_Dr = "_cityID 
		}
		if medinsLv'=""
		{
			set sql=sql_" and MedinsLv = '"_medinsLv_"'" 
		}
		if year'=""
		{
			set sql=sql_" and Year = '"_year_"'" 
		}
		
		set sql=sql_" ORDER BY ID DESC"
		
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)	
		{
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.principalDiagnosis=result.%Get("PrincipalDiagnosis")
			set dataObj.principalDiagnosisName=result.%Get("PrincipalDiagnosisName")
			set dataObj.majorProcedure=result.%Get("MajorProcedure")
			set dataObj.majorProcedureName=result.%Get("MajorProcedureName")
			set dataObj.secondaryProcedure=result.%Get("SecondaryProcedure")
			set dataObj.secondaryProcedureName=result.%Get("SecondaryProcedureName")
			set dataObj.provinceID=result.%Get("ProvinceID")
			set dataObj.provinceDesc=result.%Get("ProvinceDesc")
			set dataObj.cityID=result.%Get("CityID")
			set dataObj.cityDesc=result.%Get("CityDesc")
			set dataObj.mdtrtArea=result.%Get("MdtrtArea")
			set dataObj.medinsLv=result.%Get("MedinsLv")
			set dataObj.scoreValue=result.%Get("ScoreValue")
			set dataObj.adjustCoefficient=result.%Get("AdjustCoefficient")
			set dataObj.primaryAdjustCoefficient=result.%Get("PrimaryAdjustCoefficient")
			set dataObj.secondaryAdjustCoefficient=result.%Get("SecondaryAdjustCoefficient")
			set dataObj.thirdAdjustCoefficient=result.%Get("ThirdAdjustCoefficient")
			set dataObj.createDate=result.%Get("CreateDate")
			set dataObj.createTime=result.%Get("CreateTime")
			set dataObj.year=result.%Get("Year")
			
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询DIP核心算法配置数据出现问题:w ##class("_$ClassName()_").QueryDIPCoreAlgorithm("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     System
/// CreatDate:   2026-04-21
/// Description: 保存DIP核心算法配置（新增/更新）
/// Table:       HB_DIPCoreAlgorithmData (User.HBDIPCoreAlgorithmData)
/// Input:       DIP算法配置表单参数
/// Output:      操作结果
/// Return:      接口响应对象
/// Debug:       w ##class(src.DRG.BasicData.CoreAlgorithm).SaveDIPCoreAlgorithm({}).%ToJSON()
ClassMethod SaveDIPCoreAlgorithm(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="保存成功"
	set resultObj.result={}
	try{
		set params=postObj.params.%Get(0)
		
		set dictID=params.id
		set principalDiagnosis=params.principalDiagnosis
		set principalDiagnosisName=params.principalDiagnosisName
		set majorProcedure=params.majorProcedure
		set majorProcedureName=params.majorProcedureName
		set secondaryProcedure=params.secondaryProcedure
		set secondaryProcedureName=params.secondaryProcedureName
		set provinceID=params.provinceDr
		set cityID=params.cityDr
		set mdtrtArea=params.mdtrtArea
		set medinsLv=params.medinsLv
		set scoreValue=params.scoreValue
		set adjustCoefficient=params.adjustCoefficient
		set primaryAdjustCoefficient=params.primaryAdjustCoefficient
		set secondaryAdjustCoefficient=params.secondaryAdjustCoefficient
		set thirdAdjustCoefficient=params.thirdAdjustCoefficient
		set year=params.year  //分组方案年份
		
		// 必填校验
		if (principalDiagnosis="")
		{
			set resultObj.errorCode="-1"
			set resultObj.errorMessage="主要诊断代码不能为空！"
			quit
		}
		if (principalDiagnosisName="")
		{
			set resultObj.errorCode="-1"
			set resultObj.errorMessage="主要诊断名称不能为空！"
			quit
		}
		if (provinceID="")
		{
			set resultObj.errorCode="01000007"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000007")
			quit
		}
		if (cityID="")
		{
			set resultObj.errorCode="01000008"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000008")
			quit
		}
		if (medinsLv="")
		{
			set resultObj.errorCode="-1"
			set resultObj.errorMessage="医疗机构等级不能为空！"
			quit
		}
		if (scoreValue="")
		{
			set resultObj.errorCode="-1"
			set resultObj.errorMessage="基准分值不能为空！"
			quit
		}
		
		set data=[]
		set dataObj={}
		set dataObj.ID=dictID
		set dataObj.PrincipalDiagnosis=principalDiagnosis
		set dataObj.PrincipalDiagnosisName=principalDiagnosisName
		set dataObj.MajorProcedure=majorProcedure
		set dataObj.MajorProcedureName=majorProcedureName
		set dataObj.SecondaryProcedure=secondaryProcedure
		set dataObj.SecondaryProcedureName=secondaryProcedureName
		set dataObj.ProvinceDr=provinceID
		set dataObj.CityDr=cityID
		set dataObj.MdtrtArea=mdtrtArea
		set dataObj.MedinsLv=medinsLv
		set dataObj.ScoreValue=scoreValue
		set dataObj.AdjustCoefficient=adjustCoefficient
		set dataObj.PrimaryAdjustCoefficient=primaryAdjustCoefficient
		set dataObj.SecondaryAdjustCoefficient=secondaryAdjustCoefficient
		set dataObj.ThirdAdjustCoefficient=thirdAdjustCoefficient
		set dataObj.Year=year
		set dataObj.CreateDate=$zd($h,3)
		set dataObj.CreateTime=$zt($p($h,",",2),1)
		set dataObj.CreateUserDr="158" //userID
		
		set insObj={}
		set insObj.className="User.HBDIPCoreAlgorithmData"
		set insObj.updateUserID="0" //userID
		set rtn=""
		do data.%Push(dataObj)
		set insObj.data=data
		if dictID=""{
			set rtn=##class(src.util.operatetable).Insert(.insObj)
		}else{
			set rtn=##class(src.util.operatetable).Update(.insObj)
		}
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
	    if errorCode'=0{
		    set resultObj.errorCode=errorCode
	    	set resultObj.errorMessage=errorMessage
	   	}
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="保存DIP核心算法配置数据出现问题:w ##class("_$ClassName()_").SaveDIPCoreAlgorithm("_postObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
 	quit resultObj
}

/// Creator:     System
/// CreatDate:   2026-04-21
/// Description: 删除DIP核心算法配置
/// Table:       HB_DIPCoreAlgorithmData (User.HBDIPCoreAlgorithmData)
/// Input:       id: 记录ID
/// Output:      操作结果
/// Return:      接口响应对象
/// Debug:       w ##class(src.DRG.BasicData.CoreAlgorithm).DeleteDIPCoreAlgorithm({}).%ToJSON()
ClassMethod DeleteDIPCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
    new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set userID=session.userID
		if params.id="" 
		{
			set resultObj.errorCode="05100128"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")
			quit
		}
		set delObj={},data=[]
		set delObj.className="User.HBDIPCoreAlgorithmData"
		set delObj.updateUserID=userID
		set dataObj={}
		set dataObj.ID=params.id
		do data.%Push(dataObj)
		set delObj.data=data
		set rtn=##class(src.util.operatetable).Delete(.delObj)
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage
		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="删除DIP核心算法配置数据出现问题:w ##class("_$ClassName()_").DeleteDIPCoreAlgorithm("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     System
/// CreatDate:   2026-04-22
/// Description: 下载DIP核心算法配置导入模板
/// Output:      CSV格式模板内容（Base64编码）
/// Return:      接口响应对象
/// Debug:       w ##class(src.DRG.BasicData.CoreAlgorithm).DownloadDIPCoreAlgorithmTemplate({}).%ToJSON()
ClassMethod DownloadDIPCoreAlgorithmTemplate(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (jsonObj)
    set resultObj={"errorCode":"0","errorMessage":"","result":{}}
    
    try {
        // 生成CSV内容 - DIP核心算法模板
        // 列：主要诊断代码,主要诊断名称,主要手术代码,主要手术名称,相关手术代码,相关手术名称,基准分值,调节系数,一级调节系数,二级调节系数,三级调节系数
        set csvContent = "PrincipalDiagnosis,PrincipalDiagnosisName,MajorProcedure,MajorProcedureName,SecondaryProcedure,SecondaryProcedureName,ScoreValue,AdjustCoefficient,PrimaryAdjustCoefficient,SecondaryAdjustCoefficient,ThirdAdjustCoefficient"_$c(13,10)
        set csvContent = csvContent_"A01.01,NULL,31.1,NULL,,,,100.00,1.0,1.1,1.2,1.3"_$c(13,10)
        set csvContent = csvContent_"K25.0,NULL,43.7,NULL,45.6,NULL,150.50,1.1,1.2,1.3,1.5"_$c(13,10)
        
        // Base64编码
        set base64Data = ##class(%SYSTEM.Encryption).Base64Encode(csvContent)
        
        set resultObj.result.fileName = "DIP核心算法配置导入模板.csv"
        set resultObj.result.fileData = base64Data
        set resultObj.result.contentType = "text/csv"
        
    } catch e {
        set status = e.AsStatus()
        set resultObj.errorCode = "04000007"
        set resultObj.errorMessage = "下载模板失败: "_$system.Status.GetErrorText(status)
    }
    
    quit resultObj
}

/// Creator:     System
/// CreatDate:   2026-04-22
/// Description: DIP核心算法配置导入预览（校验数据并返回预览结果）
/// Table:       HB_DIPCoreAlgorithmData (User.HBDIPCoreAlgorithmData)
/// Input:       provinceID, cityID, medinsLv, mdtrtArea, fileData(Base64)
/// Output:      预览结果（含重复数据标记）
/// Return:      接口响应对象
/// Debug:       w ##class(src.DRG.BasicData.CoreAlgorithm).PreviewImportDIPCoreAlgorithm({}).%ToJSON()
ClassMethod PreviewImportDIPCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
    new (jsonObj)
    set resultObj={"errorCode":"0","errorMessage":"","result":{"totalCount":0,"validCount":0,"invalidCount":0,"duplicateCount":0,"previewList":[]}}
    
    set totalCount=0,validCount=0,invalidCount=0,duplicateCount=0
    set previewList=[]
    
    // 预览数量限制，避免JSON过大导致MAXSTRING错误
    set previewLimit=100
    set previewCount=0
    
    try 
    {
        set params=jsonObj.params.%Get(0)
        set provinceID=params.provinceID
        set cityID=params.cityID
        set medinsLv=params.medinsLv
        set mdtrtArea=params.mdtrtArea
        set fileData=params.fileData
        set year=params.year  //分组方案年份（导入必选）
        
        // 参数校验
        if provinceID="" {
            set resultObj.errorCode="01000007"
            set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000007")
            quit
        }
        if cityID="" {
            set resultObj.errorCode="01000008"
            set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000008")
            quit
        }
        if medinsLv="" {
            set resultObj.errorCode="-1"
            set resultObj.errorMessage="机构等级不能为空"
            quit
        }
        if fileData="" {
            set resultObj.errorCode="02010001"
            set resultObj.errorMessage="导入文件不能为空"
            quit
        }
        
        // Base64解码 - 与PreviewImportDRGCoreAlgorithm完全相同的逻辑
        set csvContent = ""
        
        // 方法1: 使用$zcvt函数直接解码Base64
        try {
            set csvContent = $zcvt(fileData, "I", "BASE64")
        } catch e1 {
            // 不输出调试信息
        }
        
        // 如果方法1失败或内容为空，尝试方法2
        if csvContent="" {
            try {
                set binaryData = ##class(%SYSTEM.Encryption).Base64Decode(fileData)
                set csvContent = $zcvt(binaryData, "I", "UTF8")
                if csvContent["?" {
                    set csvContent = $zcvt(binaryData, "I", "GB18030")
                }
                if csvContent["?" {
                    set csvContent = binaryData
                }
            } catch e2 {
                // 不输出调试信息
            }
        }
        
        if csvContent="" 
        {
            set resultObj.errorCode="02010003"
            set resultObj.errorMessage="文件解码失败，请提供有效的CSV文件"
            quit
        }
        
        // 解析CSV内容
        set lineNum=0
        set ptr=1
        set csvContent=$replace(csvContent,$c(13,10),$c(10))
        set csvContent=$replace(csvContent,$c(13),$c(10))
        
        for 
        {
            set line=$piece(csvContent,$c(10),ptr)
            quit:line=""
            set ptr=ptr+1
            set lineNum=lineNum+1
            continue:lineNum=1
            continue:line=""
            
            set totalCount=totalCount+1
            set rowNum=lineNum-1
            
            // 预览数量限制：超过限制后只统计，不加入预览列表
            if previewCount >= previewLimit
            {
                quit
            }
            
            // 解析CSV列（11列）
            set errorMsg=""
            try { set principalDiagnosis=$piece(line,",",1) } catch { set principalDiagnosis="",errorMsg="字段解析错误" }
            try { set principalDiagnosisName=$piece(line,",",2) } catch { set principalDiagnosisName="" }
            try { set majorProcedure=$piece(line,",",3) } catch { set majorProcedure="" }
            try { set majorProcedureName=$piece(line,",",4) } catch { set majorProcedureName="" }
            try { set secondaryProcedure=$piece(line,",",5) } catch { set secondaryProcedure="" }
            try { set secondaryProcedureName=$piece(line,",",6) } catch { set secondaryProcedureName="" }
            try { set scoreValue=$piece(line,",",7) } catch { set scoreValue="" }
            try { set adjustCoefficient=$piece(line,",",8) } catch { set adjustCoefficient="" }
            try { set primaryAdjustCoefficient=$piece(line,",",9) } catch { set primaryAdjustCoefficient="" }
            try { set secondaryAdjustCoefficient=$piece(line,",",10) } catch { set secondaryAdjustCoefficient="" }
            try { set thirdAdjustCoefficient=$piece(line,",",11) } catch { set thirdAdjustCoefficient="" }
            
            set previewObj={}
            set previewObj.rowNum=rowNum
            set previewObj.principalDiagnosis=principalDiagnosis
            set previewObj.principalDiagnosisName=principalDiagnosisName
            set previewObj.majorProcedure=majorProcedure
            set previewObj.majorProcedureName=majorProcedureName
            set previewObj.secondaryProcedure=secondaryProcedure
            set previewObj.secondaryProcedureName=secondaryProcedureName
            set previewObj.scoreValue=scoreValue
            set previewObj.adjustCoefficient=adjustCoefficient
            set previewObj.primaryAdjustCoefficient=primaryAdjustCoefficient
            set previewObj.secondaryAdjustCoefficient=secondaryAdjustCoefficient
            set previewObj.thirdAdjustCoefficient=thirdAdjustCoefficient
            set previewObj.errorMsg=errorMsg
            
            // 数据校验
            if (errorMsg '="")
            {
                set invalidCount=invalidCount+1
                set previewObj.status="invalid"
                set previewObj.statusDesc="解析错误"
                do previewList.%Push(previewObj)
                continue
            } 		
            elseif principalDiagnosis="" 
            {
                set previewObj.status="invalid"
                set previewObj.statusDesc="错误"
                set previewObj.errorMsg="主要诊断代码不能为空"
                set invalidCount=invalidCount+1
                do previewList.%Push(previewObj)
                continue
            }
            elseif principalDiagnosisName=""
            {
                set previewObj.status="invalid"
                set previewObj.statusDesc="错误"
                set previewObj.errorMsg="主要诊断名称不能为空"
                set invalidCount=invalidCount+1
                do previewList.%Push(previewObj)
                continue
            }
            elseif (scoreValue="")
            {
                set previewObj.status="invalid"
                set previewObj.statusDesc="错误"
                set previewObj.errorMsg="基准分值不能为空"
                set invalidCount=invalidCount+1
                do previewList.%Push(previewObj)
                continue
            }
            
            // 检查是否已存在（主要诊断代码+省+市+机构等级+年份）
            set existingID=""
            &sql(SELECT ID INTO :existingID FROM SQLUser.HB_DIPCoreAlgorithmData 
                 WHERE PrincipalDiagnosis=:principalDiagnosis AND Province_Dr=:provinceID AND City_Dr=:cityID AND MedinsLv=:medinsLv AND Year=:year)
            
            if existingID'="" 
            {
                set previewObj.status="duplicate"
                set previewObj.statusDesc="重复"
                set previewObj.errorMsg="该DIP配置已存在，导入将执行更新操作"
                set duplicateCount=duplicateCount+1
            } 
            else 
            {
                set previewObj.status="valid"
                set previewObj.statusDesc="正常"
                set validCount=validCount+1
            }
            
            do previewList.%Push(previewObj)
            set previewCount=previewCount+1
                
        }
        
        set resultObj.result.totalCount=totalCount
        set resultObj.result.validCount=validCount
        set resultObj.result.invalidCount=invalidCount
        set resultObj.result.duplicateCount=duplicateCount
        set resultObj.result.previewList=previewList
        
    } 
    catch(e) 
    {
        set status=e.AsStatus()
        set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
        set resultObj.errorCode="04000007"
        set resultObj.errorMessage="预览失败："_errorMessage
    }
    
    quit resultObj
}

/// Creator:     System
/// CreatDate:   2026-04-22
/// Description: 确认导入DIP核心算法配置
/// Table:       HB_DIPCoreAlgorithmData (User.HBDIPCoreAlgorithmData)
/// Input:       provinceID, cityID, medinsLv, mdtrtArea, fileData(Base64)
/// Output:      详细导入结果报告
/// Return:      接口响应对象
/// Debug:       w ##class(src.DRG.BasicData.CoreAlgorithm).ConfirmImportDIPCoreAlgorithm({}).%ToJSON()
ClassMethod ConfirmImportDIPCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
    new (jsonObj)
    set resultObj={"errorCode":"0","errorMessage":"","result":{"totalCount":0,"successCount":0,"failCount":0,"duplicateCount":0,"newCount":0,"failList":[]}}
    
    set (totalCount,successCount,failCount,duplicateCount,newCount)=0
    set failList=[]
    
    try {
        set params=jsonObj.params.%Get(0)
        
        if '$isobject(params) {
            set resultObj.errorCode="02010001"
            set resultObj.errorMessage="参数错误：缺少params参数"
            quit
        }
        
        set fileData=params.fileData
        set provinceID=params.provinceID
        set cityID=params.cityID
        set medinsLv=params.medinsLv
        set mdtrtArea=params.mdtrtArea
        set year=params.year  //分组方案年份（导入必选）
        
        if (provinceID="")||(cityID="")
        {
            set resultObj.errorCode="-1"
            set resultObj.errorMessage="接口入参省、市代码不能为空！"
            quit	
        }
        
        if (medinsLv="")
        {
            set resultObj.errorCode="-1"
            set resultObj.errorMessage="机构等级不能为空！"
            quit	
        }
        
        // 创建用户ID
        set createUserDr=""
        if $isobject(jsonObj.session) 
        {
            set session=jsonObj.session.%Get(0)
            set:session'="" createUserDr=session.userID
        }
        set:createUserDr="" createUserDr="158"
        
        // Base64解码 - 使用与PreviewImportDRGCoreAlgorithm完全相同的逻辑
        set csvContent = ""
        
        // 方法1: 使用$zcvt函数直接解码Base64
        try {
            set csvContent = $zcvt(fileData, "I", "BASE64")
        } catch e1 {
            // 不输出调试信息
        }
        
        // 如果方法1失败或内容为空，尝试方法2
        if csvContent="" {
            try {
                set binaryData = ##class(%SYSTEM.Encryption).Base64Decode(fileData)
                set csvContent = $zcvt(binaryData, "I", "UTF8")
                if csvContent["?" {
                    set csvContent = $zcvt(binaryData, "I", "GB18030")
                }
                if csvContent["?" {
                    set csvContent = binaryData
                }
            } catch e2 {
                // 不输出调试信息
            }
        }
        
        if csvContent="" {
            set resultObj.errorCode="02010003"
            set resultObj.errorMessage="文件解码失败，请提供有效的CSV文件"
            quit
        }
        
        // 解析CSV并执行导入
        set lineNum=0
        set ptr=1
        set csvContent=$replace(csvContent,$c(13,10),$c(10))
        set csvContent=$replace(csvContent,$c(13),$c(10))
        
        for 
        {
            set line=$piece(csvContent,$c(10),ptr)
            quit:line=""
            set ptr=ptr+1
            set lineNum=lineNum+1
            continue:lineNum=1
            continue:line=""
            
            set totalCount=totalCount+1
            set rowNum=lineNum-1
            
            // 解析CSV列（11列）
            try { set principalDiagnosis=$piece(line,",",1) } catch { set principalDiagnosis="" }
            try { set principalDiagnosisName=$piece(line,",",2) } catch { set principalDiagnosisName="" }
            try { set majorProcedure=$piece(line,",",3) } catch { set majorProcedure="" }
            try { set majorProcedureName=$piece(line,",",4) } catch { set majorProcedureName="" }
            try { set secondaryProcedure=$piece(line,",",5) } catch { set secondaryProcedure="" }
            try { set secondaryProcedureName=$piece(line,",",6) } catch { set secondaryProcedureName="" }
            try { set scoreValue=$piece(line,",",7) } catch { set scoreValue="" }
            try { set adjustCoefficient=$piece(line,",",8) } catch { set adjustCoefficient="" }
            try { set primaryAdjustCoefficient=$piece(line,",",9) } catch { set primaryAdjustCoefficient="" }
            try { set secondaryAdjustCoefficient=$piece(line,",",10) } catch { set secondaryAdjustCoefficient="" }
            try { set thirdAdjustCoefficient=$piece(line,",",11) } catch { set thirdAdjustCoefficient="" }
            
            // 跳过校验失败的行
            if (principalDiagnosis="")||(principalDiagnosisName="")||(scoreValue="")
            {
                set failCount=failCount+1
                set failObj={}
                set failObj.rowNum=rowNum
                set failObj.principalDiagnosis=principalDiagnosis
                set failObj.errorMsg="必填字段为空"
                do failList.%Push(failObj)
                continue
            }
            
            // 检查是否已存在（含年份）
            set existingID=""
            &sql(SELECT ID INTO :existingID FROM HB_DIPCoreAlgorithmData 
                 WHERE PrincipalDiagnosis=:principalDiagnosis AND Province_Dr=:provinceID AND City_Dr=:cityID AND MedinsLv=:medinsLv AND Year=:year)
            
            // 构建数据对象
            set dataObj={}
            set dataObj.PrincipalDiagnosis=principalDiagnosis
            set dataObj.PrincipalDiagnosisName=principalDiagnosisName
            set dataObj.MajorProcedure=majorProcedure
            set dataObj.MajorProcedureName=majorProcedureName
            set dataObj.SecondaryProcedure=secondaryProcedure
            set dataObj.SecondaryProcedureName=secondaryProcedureName
            set dataObj.ProvinceDr=provinceID
            set dataObj.CityDr=cityID
            set dataObj.MdtrtArea=mdtrtArea
            set dataObj.MedinsLv=medinsLv
            set dataObj.ScoreValue=scoreValue
            set dataObj.AdjustCoefficient=adjustCoefficient
            set dataObj.PrimaryAdjustCoefficient=primaryAdjustCoefficient
            set dataObj.Year=year
            set dataObj.SecondaryAdjustCoefficient=secondaryAdjustCoefficient
            set dataObj.ThirdAdjustCoefficient=thirdAdjustCoefficient
            set dataObj.CreateDate=$zd($h,3)
            set dataObj.CreateTime=$zt($p($h,",",2),1)
            set dataObj.CreateUserDr=createUserDr
            
            set insObj={},data=[]
            set insObj.className="User.HBDIPCoreAlgorithmData"
            do data.%Push(dataObj)
            set insObj.data=data
            
            set operationType=""
            if existingID'="" 
            {
                set dataObj.ID=existingID
                set rtn=##class(src.util.operatetable).Update(.insObj)
                set operationType="更新"
                set duplicateCount=duplicateCount+1
            } 
            else 
            {
                set rtn=##class(src.util.operatetable).Insert(.insObj)
                set operationType="新增"
                set newCount=newCount+1
            }
            
            if rtn.errorCode'=0 
            {
                set failCount=failCount+1
                set failObj={}
                set failObj.rowNum=rowNum
                set failObj.principalDiagnosis=principalDiagnosis
                set failObj.errorMsg=rtn.errorMessage
                do failList.%Push(failObj)
            } 
            else 
            {
                set successCount=successCount+1
            }
        }
        
        set resultObj.result.totalCount=totalCount
        set resultObj.result.successCount=successCount
        set resultObj.result.failCount=failCount
        set resultObj.result.duplicateCount=duplicateCount
        set resultObj.result.newCount=newCount
        set resultObj.result.failList=failList
        
        if failCount>0 
        {
            set resultObj.errorCode="02010002"
            set resultObj.errorMessage="导入完成，部分数据导入失败，请查看失败列表"
        }
        
    } catch(e) {
        set status=e.AsStatus()
        set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
        set errorInfo="导入DIP核心算法配置出现问题:w ##class("_$ClassName()_").ConfirmImportDIPCoreAlgorithm("_jsonObj.%ToJSON()_")"
        set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
        set resultObj.errorCode="04000007"
        set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
    }
    
    quit resultObj
}

}
