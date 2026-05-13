Import SQLUSER

Class src.DRG.GroupDevice Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 设置成功返回结果（封装重复逻辑）
ClassMethod SetSuccessResult(code As %String, message As %String) As %Library.DynamicObject
{
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage=message

	set result={}
	set result.code=code
	set result.desc=message
	set result.checkTime=$ZDATETIME($HOROLOG,3)
    set resultObj.result=result
    
    quit resultObj
}

/// 设置成功返回结果数组（封装重复逻辑）
ClassMethod SetJarraySuccessResult(jsonObj As %Library.DynamicObject, iCount As %String) As %Library.DynamicObject
{
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage=""
    set resultObj.result=jsonObj
    set resultObj.totalCount=iCount
	//set resultObj.result.checkTime=$ZDATETIME($HOROLOG,3)
    
    quit resultObj
}

/// 设置错误返回结果（封装重复逻辑）
ClassMethod SetErrorResult(errorCode As %String, errorMsg As %String) As %Library.DynamicObject
{
	set resultObj={}
	set resultObj.errorCode= errorCode
	set resultObj.errorMessage= errorMsg

	set result={}
	set result.code=""
	set result.desc=""
	set result.checkTime= $ZDATETIME($HOROLOG,3)
    set resultObj.result= result
    
    quit resultObj
}

/// 私有方法：记录检查日志（可扩展到日志表）
ClassMethod LogCheckInfo(logType As %String, logContent As %String)
{
    // 此处可扩展：写入日志表/文件
    // 示例：do ##class(src.Interface.Log).InsertLog("DRG分组", "PreMDC", logType, logContent)
    w $ZDATETIME($HOROLOG,3) _ " | " _ logType _ " | " _ logContent _ $C(13,10)
}

/// 根据参保地区和就医地区划代码判断结算类型
/// @param insuranceAreaCode 参保地区划代码（6位）
/// @param mdtrtareaAreaCode 就医地区划代码（6位）
/// @return 市本级|省直|异地
ClassMethod GetSettlementType(insuranceAreaCode As %String, mdtrtareaAreaCode As %String) As %String
{
    quit:(insuranceAreaCode = "")||(mdtrtareaAreaCode = "") "市本级"
    
    set insuranceAreaCode = $ZCVT(insuranceAreaCode, "U")
    set mdtrtareaAreaCode = $ZCVT(mdtrtareaAreaCode, "U")
    
    // 判断是否省直（第3-4位=99）
    set isDirect = ($EXTRACT(insuranceAreaCode, 3, 4) = "99")
    
    if (isDirect) {
        // 省直：同一省份返回"省直"，否则"异地"
        set insProv = $EXTRACT(insuranceAreaCode, 1, 2)
        set medProv = $EXTRACT(mdtrtareaAreaCode, 1, 2)
        quit $SELECT(insProv = medProv: "省直", 1: "异地")
    }
    
    // 市本级：前4位相同
    if ($EXTRACT(insuranceAreaCode, 1, 4) = $EXTRACT(mdtrtareaAreaCode, 1, 4)) {
        quit "市本级"
    }
    
    quit "异地"
}

ClassMethod GetComplicationDesc(num As %String) As %String
{
    set descripts = $select(
        num = "1": "伴有严重并发症与合并症",
        num = "3": "伴有一般并发症与合并症",
        num = "5": "不伴有并发症与合并症",
        num = "7": "死亡或转院",
        num = "0": "小于17岁组，儿童病例（<17岁）",
        num = "9": "合并症与并发症未作区分的情况",
        num = "QY": "歧义（QY）组，指与主要诊断无关的手术病例组，检查病例的主要诊断和主要手术/操作是否匹配，如果二者在临床逻辑上不匹配，或者不在同一个主要诊断大类（MDC）里，这个病例就会被判定为歧义，送入QY组",
        num = "0000": "指由于疾病诊断编码不规范等原因导致的不能正常入组的病例进入的组",
        1: "其他数字表示其他需单独分组的情况"
    )
    
    return descripts
}

/// 校验是否存在 不作为分组规则疾病诊断、手术操作表中
ClassMethod CheckNoRulesList(code As %String) As %String
{
    set iCount = 0
    &sql(SELECT COUNT(*) INTO :iCount 
         FROM HB_DRGBasicDataSub 
         WHERE HBDictionaries_Dr->InsuCode IN ('NoRuleOfDiagnosis', 'NoRuleOfOperation') 
         AND Code = :code)
    
    quit iCount
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 分组前校验规则：校验不作为分组规则的疾病诊断和手术操作列表、QY组 检查病例的主要诊断和主要手术/操作是否匹配
///              在分组流程的第一步（确定主要诊断大类MDC）和第二步（确定核心疾病诊断相关组ADRG）中，
///              如果病例的主要诊断或主要手术操作存在于这个列表中，系统就会判定该病例无法进入正常的MDC或ADRG。
///              被过滤掉的病例最终会进入“0000组”（空白病组，即无法入组的病例）
/// code: 
/// Input:{"params":[{"":""}]}
/// Debug：
ClassMethod CheckRules(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
	new (jsonObj)
	set params = ##class(%DynamicArray).%New()	
	try
	{
        // 1. 初始化返回对象（标准化结构）
        set resultObj = ..SetSuccessResult("0","")
        
        // 2. 参数合法性校验（核心前置检查）
        if (jsonObj = "") || (jsonObj.params = "") 
        {
            set resultObj = ..SetErrorResult("-1", "入参异常：缺少params参数或参数为空")
            quit 
        } 

        // 3. 提取入参并设置默认值（避免空值报错）
        set preMsg="CheckRules分组前校验不通过："
        set params = jsonObj.params.%Get(0)
        set mainDiagCode = params.mainDiagnosisCode  // 主诊断代码
        set mainOperationCode = params.mainOperationCode  // 主手术代码
        
        if (mainDiagCode ="")
        {
		    set resultObj = ..SetErrorResult("-1", "主诊断不能为空！")
		    quit    
	    }	    
        
        //1.剔除不作为分组规则的疾病诊断列表、不作为分组规则的手术操作列表	         	         		
	    set iCountA=..CheckNoRulesList(mainDiagCode)
	    set iCountB=..CheckNoRulesList(mainOperationCode)	   
	    
	    if (mainOperationCode '="")
    	{
	         if (iCountA>0)
	         {
		         set preMsg= preMsg_" 该主诊断["_mainDiagCode_"]存在CHS-DRG不作为分组规则的疾病诊断列表中,无法分组,请检查！"
             }
		 
	         if (iCountB>0)
	         {
		         set preMsg= preMsg_" 该主手术操作["_mainOperationCode_"]存在CHS-DRG不作为分组规则的手术操作列表中,无法分组,请检查！"			 
	         }
	         
	         if (iCountA>0)||(iCountB>0)
	         {
		         set resultObj = ..SetErrorResult("-1", preMsg)
		         quit    
		     } 	        
	    }
	    else	
	    {
	         if (iCountA>0)
	         {
		         set preMsg=OutMsg_" 该主诊断["_mainDiagCode_"]存在CHS-DRG不作为分组规则的疾病诊断列表中,无法分组！"
		         set resultObj = ..SetErrorResult("-1", preMsg)
		         quit   
             }	    	
	    }    	
	}
    catch(e) 
    {
        // 7. 异常处理（增强：包含错误码+详细信息）
        set status = e.AsStatus()
        set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
        set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
        set errorInfo = "CheckRules分组前校验规则异常：类=" _ $ClassName() _ "，入参=" _ jsonObj.%ToJSON() _ "，错误：" _ errorMsg
        
        // 记录错误日志到数据库
        set errorLogID = ##class(src.Interface.Message).InsErrRecord("04000007", errorInfo, errorMsg)
        set resultObj = ..SetErrorResult("-99", "CheckRules分组前校验规则异常（日志ID："_errorLogID_")："_errorMsg)
    }

    quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 判断歧义组-主要诊断与主要手术操作在临床逻辑上不相关,或分属不同的主要诊断大类（MDC）
///              必要判断条件：主诊断MDC、主要手术操作
/// code:		 
/// Input:{"params":[{"":""}]}
/// Debug：
ClassMethod CheckGroupQY(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
	new (jsonObj)
	set params = ##class(%DynamicArray).%New()	
	try
	{
        // 1. 初始化返回对象（标准化结构）
        set resultObj = ..SetSuccessResult("0","")
        
        // 2. 参数合法性校验（核心前置检查）
        if (jsonObj = "") || (jsonObj.params = "") 
        {
            set resultObj = ..SetErrorResult("-1", "入参异常：缺少params参数或参数为空")
            quit 
        } 
                   
        // 3. 提取入参并设置默认值（避免空值报错）
        set preMsg="CheckRules分组前校验不通过："
        set params = jsonObj.params.%Get(0)        
        set mainDiagCode = params.mainDiagnosisCode  // 主诊断代码
        set mainOperationCode = params.mainOperationCode  // 主手术代码
        set mainDiagMDC = params.mdc //主诊断MDC
        set mainOprnMDC = ""  //主手术MDC
                
        if (mainOperationCode '= "")
	    {
		    //set cc = $EXTRACT(mdc,4) Left(ADRG, 1)=:cc
		    set leftMDC = $EXTRACT(mainDiagMDC,4) 
		    set iCount=""
		    &sql(SELECT COUNT(*) into :iCount FROM CB_DRGCoreGroupsList WHERE MajorProcedure=:mainOperationCode 
		         AND SelectionCriteria='包含以下主要手术或操作' AND UnionFlag=0 AND LEFT(ADRG,1)=:leftMDC)
		         		 	    
		    if (SQLCODE =0) && (iCount =0)
		    {			    
			     set resultObj = ..SetErrorResult("-1", "进入QY组,主手术操作与主诊断对应MDC：【"_mainDiagMDC_"】不匹配！")	
			}
		}	    	                   	   	        	
	}
    catch(e) 
    {
        // 7. 异常处理（增强：包含错误码+详细信息）
        set status = e.AsStatus()
        set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
        set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
        set errorInfo = "CheckGroupQY校验歧义组异常：类=" _ $ClassName() _ "，入参=" _ jsonObj.%ToJSON() _ "，错误：" _ errorMsg
        
        // 记录错误日志到数据库
        set errorLogID = ##class(src.Interface.Message).InsErrRecord("04000007", errorInfo, errorMsg)
        set resultObj = ..SetErrorResult("-99", "CheckGroupQY校验歧义组异常（日志ID："_errorLogID_")："_errorMsg)
    }

    quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 第一步：MDC先期分组
/// code:		 
/// Input:{"params":[{"":""}]}
/// Debug：
ClassMethod GroupPreMDC(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
	new (jsonObj)
	set params = ##class(%DynamicArray).%New()	
    try
    {  
        // 1. 初始化返回对象（标准化结构）
        set resultObj = ..SetSuccessResult("0","")
        
        // 2. 参数合法性校验（核心前置检查）
        if (jsonObj = "") || (jsonObj.params = "") 
        {
            set resultObj = ..SetErrorResult("-1", "入参异常：缺少params参数或参数为空")
            quit 
        }              
        // 3. 提取入参并设置默认值（避免空值报错）
        set params = jsonObj.params.%Get(0)
        set mainDiagCode = params.mainDiagnosisCode  // 主诊断代码
        set sex = params.sex                        // 性别
        set age = params.age                          // 年龄（默认0）
        set ageGroupDays = params.ageGroupDays        // 新生儿出生天数（默认0）
        set newbornFlag = params.newbornFlag        // 新生儿标志（默认0）
        set respiratorTime = params.respiratorTime    // 有创呼吸机时长（默认0）
        set ecmoFlag = params.ecmoFlag              // ECMO标志（默认0）
        set transplantFlag = params.transplantFlag  // 器官移植标志（默认0）
        set marrowTransplantFlag = params.marrowTransplantFlag // 骨髓移植标志
        set hivFlag = params.hivFlag                // HIV标志（默认0）
        set traumaLevel = params.traumaLevel          // 多发创伤等级（默认0）

        // 4. 日志记录（新增：便于问题排查）
        set checkParams = "主诊断=" _ mainDiagCode _ ",年龄=" _ age _ ",新生儿天数=" _ ageGroupDays
        //do ..LogCheckInfo("PreMDC检查开始", checkParams)

        // 5. 先期分组核心逻辑（按优先级排序：高资源消耗优先）
        // 5.1 MDCA - 高资源消耗病例（器官移植/骨髓移植/ECMO/呼吸机≥96h）
        if (transplantFlag = "1") 
        {
            set resultObj = ..SetSuccessResult("MDCA", "主诊断大类入组MDCA：器官移植病例")
        } 
        elseif (marrowTransplantFlag = "1") 
        {
            set resultObj = ..SetSuccessResult("MDCA", "主诊断大类入组MDCA：骨髓移植病例")
        } 
        elseif (ecmoFlag = "1") 
        {
            set resultObj = ..SetSuccessResult("MDCA", "主诊断大类入组MDCA：ECMO治疗病例")
        } 
        elseif (respiratorTime >= 96) 
        {
            set resultObj = ..SetSuccessResult("MDCA", "主诊断大类入组MDCA：有创呼吸机使用时长≥96小时（实际："_respiratorTime_"小时）")
        }
        // 5.2 MDCP - 新生儿病例（出生天数1-28天 或 新生儿标志为1）
        elseif ((ageGroupDays > 0) && (ageGroupDays < 29) || (newbornFlag = "1")) 
        {
            set resultObj = ..SetSuccessResult("MDCP", "主诊断大类入组MDCP：新生儿疾病（出生天数："_ageGroupDays_"天）")
        }
        // 5.3 MDCY - HIV感染病例
        elseif (hivFlag = "1") 
        {
            set resultObj = ..SetSuccessResult("MDCY", "主诊断大类入组MDCY：HIV感染相关疾病")
        }
        // 5.4 MDCZ - 多发严重创伤（等级≥2）
        elseif (traumaLevel >= 2) 
        {
            set resultObj = ..SetSuccessResult("MDCZ", "主诊断大类入组MDCZ：多发严重创伤（创伤等级："_traumaLevel_"级）")
        }
        // 5.5 未命中先期分组（返回空编码，进入常规MDC分组）
        else 
        {
		    set (mdcCode,mdcDesc)=""
		    &sql(SELECT HBDictionaries_Dr->InsuCode,HBDictionaries_Dr->InsuDesc into :mdcCode,:mdcDesc 
		         FROM HB_DRGBasicDataSub WHERE HBDictionaries_Dr->Remark='主诊断编码对照表' 
		         AND Code= :mainDiagCode )
		    
		    if (mdcCode'="")
		    {
			    set resultObj = ..SetSuccessResult(mdcCode, mdcDesc) 
			}
			else
			{
			    set resultObj = ..SetErrorResult("-1", "通过主诊断 "_mainDiagCode_", 主诊断大类MDC分组失败！")	
			}	        	                    
        }

        // 6. 日志记录检查结果
        //do ..LogCheckInfo("PreMDC检查结束", "分组结果：" _ resultObj.result.Code _ "，说明：" _ resultObj.result.Message)        
    } 
    catch(e) 
    {
        // 7. 异常处理（增强：包含错误码+详细信息）
        set status = e.AsStatus()
        set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
        set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
        set errorInfo = "PreMDC分组异常：类=" _ $ClassName() _ "，入参=" _ jsonObj.%ToJSON() _ "，错误：" _ errorMsg
        
        // 记录错误日志到数据库
        set errorLogID = ##class(src.Interface.Message).InsErrRecord("04000007", errorInfo, errorMsg)
        set resultObj = ..SetErrorResult("-99", "MDC先期分组异常（日志ID："_errorLogID_")："_errorMsg)
    }

    quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 第二步：ADRG分组 
/// code:		 
/// Input:{"params":[{"":""}]}
/// Debug：
ClassMethod GroupADRG(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
     //ADRG分组顺序
     //ADRG联合分组规则有AC1、AH2、PS1、PS2、PS3、PS4、BB1、CB2、CB3、FB1、FF1、YC1、YR1、YR2、ZZ1     
	 //1.先期分组+联合分组规则--AC1、AH2、PS1、PS2、PS3、PS4、YC1、YR1、YR2、ZZ1
	 //2.先期分组+非联合分组规则--AA1、AA2、AB1、AD1、AE1、AF1、AG1、AG2、AG3、AH1、PB1、PC1、PD1、PJ1、PK1、PR1、PU1、PV1、ZB1、ZC1、ZD1、ZJ1
	 //3.非先期分组+联合分组规则--BB1、CB2、CB3、FB1、FF1...
	 //4.非先期分组+非联合分组规则+主要诊断--...
	 //5.非先期分组+非联合分组规则+主要手术或操作--...
	 
	//new (jsonObj)
	//set params = ##class(%DynamicArray).%New()    
    try
    {	    
        // 1. 初始化返回对象（标准化结构）
        set resultObj = ..SetSuccessResult("","")
        
        // 2. 参数合法性校验（核心前置检查）
        if (jsonObj = "") || (jsonObj.params = "") 
        {
            set resultObj = ..SetErrorResult("-1", "入参异常：缺少params参数或参数为空")
            quit 
        }                                       
        	    
        // 3. 提取入参并设置默认值（避免空值报错）
        set params = jsonObj.params.%Get(0)
        set mainDiagCode = params.mainDiagnosisCode  // 主诊断代码
        set diseinfo = params.diseInfo  // 疾病诊断代码-数组对象
        set mainOpCode = params.mainOperationCode  // 主手术操作代码
        set oprninfo = params.oprnInfo  // 手术操作代码-数组对象        
        set respiratorTime = params.respiratorTime    // 有创呼吸机时长（默认0）
        set sex = params.sex                         // 性别
        set age = params.age                         // 年龄（默认0）
        set mdc = params.mdc                          //MDC主诊断大类分组   
        
        // 如果为空字符串或非数组，设置为空数组
    	if (diseinfo = "") || ('$ISOBJECT(diseinfo)) set diseinfo = []
    	if (oprninfo = "") || ('$ISOBJECT(oprninfo)) set oprninfo = []       	   	      	        	                                          	    	     
	    
	    //先期分组标志
	    set preMDCFlag=0
	    if ($listfind($lb("MDCA","MDCP","MDCY","MDCZ"), mdc) = 1)
	    {
		    set preMDCFlag=1   
		}  
		
        set rows = [], row={}, totalCount=0
        set (adrgCode,adrgDesc,adrgCodeList,adrgDescList)= ""	 
        Set sqlStr = " SELECT Code,Descripts,Identification FROM HB_DRGBasicDataSub WHERE HBDictionaries_Dr->InsuCode='ADRG' "  
                   _ " AND Left(Code, 1)= '"_$EXTRACT(mdc,4)_"'"
	
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sqlStr)
		//set list=sqlObj.%Execute()	
		Set rs = sqlObj.%Execute()       
        while rs.%Next(sc)
        {
	        set iGetValue=0
	        	        	        	        
	        set adrgCode= rs.%Get("Code")      //ADRG编码
	        set adrgDesc= rs.%Get("Descripts") //ADRG名称	  
	        
	        if (adrgCode="")
	        {
				set resultObj = ..SetErrorResult("-1","主诊断大类_【"_mdc_"】未维护对应ADRG核心疾病诊断相关分组！")
				quit 
		    }      	                	        
	        	        
			//查询当前ADRG分组规则  主要诊断/主要手术或操作
			set (adrg,selectionCriteria,unionFlag)="" //入组规则、联合规则标志			      				         				        
			&sql(SELECT Top 1 ADRG,SelectionCriteria,UnionFlag into :adrg,:selectionCriteria,:unionFlag FROM CB_DRGCoreGroupsList WHERE ADRG=:adrgCode)	        	
	        if (SQLCODE=0)
	        {
		        if (adrg ="")
		        {
				    set resultObj = ..SetErrorResult("-11","ADRG核心疾病诊断相关分组表CB_DRGCoreGroupsList未维护:【"_adrgCode_"："_adrgDesc_"】分组规则！")
				    quit	   
			    }
		        
		        if (selectionCriteria ="")
		        {
				    set resultObj = ..SetErrorResult("-12","ADRG核心疾病诊断相关分组表CB_DRGCoreGroupsList未维护:【"_adrgCode_"："_adrgDesc_"】入组条件！")
				    quit			        
			    } 
		    }  		    		    
		    		         	        	        	               	          
	        //1.先处理--先期分组
	        if (preMDCFlag=1)
	        {
		        //2.处理先期分组--联合分组规则
		        //同时包含以下手术或操作
		        if (adrgCode="AC1") 
		        {			             
		            set (iCount,m)=0		        	
                    // 遍历operationArray数组
                    for j=0:1:oprninfo.%Size()-1 
                    {        
                        // 获取手术操作编码和名称             
                        set item = oprninfo.%Get(j)
                        set mainFlag = item.mainFlag
                        set oprnSn = item.oprnSn
                        set oprnCode = item.oprnCode
                        set oprnName = item.oprnName 
                        
                        //存在不作为分组规则手术及操作代码表中
                        if (..CheckNoRulesList(oprnCode)>0)
                        {
	                        continue
	                    }
                                                                                                  
                        &sql(SELECT COUNT(DISTINCT ADRG) into :iCount FROM CB_DRGCoreGroupsList WHERE UnionFlag =1  
                             AND ADRG=:adrgCode AND (MajorProcedure=:oprnCode OR SecondaryProcedure=:oprnCode OR ThirdlyProcedure=:oprnCode))
                        // 如果SQL执行成功且有结果
                        if (SQLCODE = 0) && (iCount > 0) 
                        {
                            set m = m + 1
                        }
                        
                        if (m>1)
                        {
	                        //set resultObj = ..SetSuccessResult(adrgCode,adrgDesc)
	                        set iGetValue=1				            
				            //continue	                    
	                    }                                                	                    	                                              
                    }			        	        			        			        			       	
			    }
			    //（其他诊断 或 手术或操作1）+ 手术或操作2
			    elseif (adrgCode="AH2") 
			    {              
			       set (m,n)=0			       
			       //手术或操作1 + 手术或操作2
			       for i=0:1:oprninfo.%Size()-1 
			       {
                        // 获取手术或操作编码和名称                    
                        set item = oprninfo.%Get(i)
                        set mainFlag = item.mainFlag
                        set oprnSn = item.oprnSn
                        set oprnCode = item.oprnCode
                        set oprnName = item.oprnName
                        
                        //存在不作为分组规则手术及操作代码表中
                        if (..CheckNoRulesList(oprnCode)>0)
                        {
	                        continue
	                    }
	                    
                        //主要手术或操作标识不为1,序号需要为2表示第二次要手术或操作
                        if (mainFlag '= "1")&&(oprnSn="2")
                        {
	                        set secOperationCode = oprnCode
	                    }
	                    //主要手术或操作标识不为1,序号需要为3表示第三次要手术或操作
	                    elseif (mainFlag '= "1")&&(oprnSn="3")
                        {
	                        set thirdOperationCode = oprnCode
	                    }
	                    
	                    //手术或操作1 + 手术或操作2
                        &sql(SELECT COUNT(DISTINCT ADRG) into :m FROM CB_DRGCoreGroupsList WHERE UnionFlag =1 AND ADRG=:adrgCode                                    
                             And SecondaryProcedure=:secOperationCode And ThirdlyProcedure=:thirdOperationCode)
                        // 如果SQL执行成功且有结果
                        if (SQLCODE = 0) && (m > 0) 
                        {
                            //set resultObj=..SetSuccessResult(adrgCode,adrgDesc)                            
                            set iGetValue=1
                            //continue
                        }	                    	                    			       
				    }
			    			    			          				   				    				    				   				    				    
                    //其他诊断 + 手术或操作2		        	
                    for j=0:1:diseinfo.%Size()-1 
                    {
                        // 获取诊断编码和名称                  
                        set item = diseinfo.%Get(j)
                        set mainFlag = item.mainFlag
                        set diagSn = item.diagSn
                        set diagCode = item.diagCode
                        set diagName = item.diagName
                        
                        //存在不作为分组规则疾病诊断表中
                        if (..CheckNoRulesList(diagCode)>0)
                        {
	                        continue
	                    }                        
            
                        if (mainFlag '="1") //其他诊断
                        {
                            &sql(SELECT COUNT(DISTINCT ADRG) into :n FROM CB_DRGCoreGroupsList WHERE UnionFlag =1
                                 AND ADRG=:adrgCode and (SecondaryDiagnosis=:diagCode OR ThirdlyDiagnosis=:diagCode) And ThirdlyProcedure=:thirdOperationCode)
                            // 如果SQL执行成功且有结果
                            if (SQLCODE = 0) && (n > 0) 
                            {
				                //set resultObj = ..SetSuccessResult(adrgCode,adrgDesc)				                
				                set iGetValue=1
				                //continue
                            }
	                    }                                                	                    	                                              
                    }			          
				}
				//包含以下主要诊断或其他诊断 
			    elseif ($listfind($lb("PS1","PS2","PS3","PS4","YR1","YR2"), adrgCode) = 1)
			    {
				    //遍历诊断数组
                    for j=0:1:diseinfo.%Size()-1 
                    {
                        // 获取诊断编码和名称                   
                        set item = diseinfo.%Get(j)
                        set mainFlag = item.mainFlag
                        set diagSn = item.diagSn
                        set diagCode = item.diagCode
                        set diagName = item.diagName
                        
                        //存在不作为分组规则疾病诊断表中
                        if (..CheckNoRulesList(diagCode)>0)
                        {
	                        continue
	                    } 
	                    	                                          
                        if (mainFlag '="1") //其他诊断
                        {
	                        set n=0
                            &sql(SELECT COUNT(DISTINCT ADRG) into :n FROM CB_DRGCoreGroupsList WHERE UnionFlag =1                                    
                                 AND ADRG=:adrgCode AND (PrincipalDiagnosis=:mainDiagCode OR SecondaryDiagnosis=:diagCode OR ThirdlyDiagnosis=:diagCode))
                            // 如果SQL执行成功且有结果
                            if (SQLCODE = 0) && (n > 0) 
                            {
				                //set resultObj = ..SetSuccessResult(adrgCode,adrgDesc)
				                set iGetValue=1
				                //continue
                            }
	                    }                                                	                    	                                              
                    }			
				}
				//包含全部手术或操作
				elseif (adrgCode="YC1")
				{
					//存在手术或操作并且存在诊断符合HIV感染疾病及相关操作,符合YC1-HIV相关疾病的手术
					if (mainOpCode '= "") || (diseinfo.%Size()>0)
					{
						//遍历诊断数组
						for j=0:1:diseinfo.%Size()-1
						{
                            // 获取诊断编码和名称                   
                            set item = diseinfo.%Get(j)
                            set mainFlag = item.mainFlag
                            set diagSn = item.diagSn
                            set diagCode = item.diagCode
                            set diagName = item.diagName
                        
                            //存在不作为分组规则疾病诊断表中
                            if (..CheckNoRulesList(diagCode)>0)
                            {
	                            continue
	                        } 
	                        
	                        set n=0
                            &sql(SELECT COUNT(DISTINCT ADRG) into :n FROM CB_DRGCoreGroupsList WHERE UnionFlag =1 AND ADRG=:adrgCode                                     
                                 AND (PrincipalDiagnosis=:diagCode OR SecondaryDiagnosis=:diagCode OR ThirdlyDiagnosis=:diagCode))
                            // 如果SQL执行成功且有结果
                            if (SQLCODE = 0) && (n > 0) 
                            {
	                            //set resultObj = ..SetSuccessResult(adrgCode,adrgDesc)
	                            set iGetValue=1	                            				                
				                //continue
                            }	                        	                        	                        
						}																		
					}
				}
				//包含以下主要诊断
				elseif ($listfind($lb("PR1","PU1","PV1"), adrgCode) = 1)
				{
	                set n=0
                    &sql(SELECT COUNT(DISTINCT ADRG) into :n FROM CB_DRGCoreGroupsList WHERE UnionFlag =0                                   
                         AND ADRG=:adrgCode AND PrincipalDiagnosis=:mainDiagCode)
                     // 如果SQL执行成功且有结果
                    if (SQLCODE = 0) && (n > 0) 
                    {
	                    //set resultObj = ..SetSuccessResult(adrgCode,adrgDesc)
	                    set iGetValue=1				        
				        //continue
                    }
				}
				//包含以下主要手术或操作
				elseif ($listfind($lb("AA1","AA2","AB1","AD1","AE1","AF1","AG1","AG2","AG3","AH1",
				                      "PB1","PC1","PD1","PJ1","PK1","ZB1","ZC1","ZD1","ZJ1"), adrgCode) = 1)
				{                   
                    if (mainOpCode '="")
                    {
                        if (..CheckNoRulesList(mainOpCode)=0)
                        {
	                        set n=0
                            &sql(SELECT COUNT(DISTINCT ADRG) into :n FROM CB_DRGCoreGroupsList WHERE UnionFlag =0                                   
                                 AND ADRG=:adrgCode AND MajorProcedure=:mainOpCode)
                             // 如果SQL执行成功且有结果
                            if (SQLCODE = 0) && (n > 0) 
                            {	                            
				                //set resultObj = ..SetSuccessResult(adrgCode,adrgDesc)
				                set iGetValue=1
				                //continue
                            }	                
	                    }    
	                } 		
				}	
				//符合 MDCZ 诊断表,且无手术或操作            
				elseif (adrgCode="ZZ1")
				{
					//主要手术及操作和手术及操作数组对象都为空
					if (mainOpCode="") && (oprninfo.%Size()=0)
					{
	                    set n=0
                        &sql(SELECT COUNT(DISTINCT ADRG) into :n FROM CB_DRGCoreGroupsList WHERE UnionFlag =1                                    
                             AND ADRG=:adrgCode AND PrincipalDiagnosis=:mainDiagCode)
                        // 如果SQL执行成功且有结果
                        if (SQLCODE = 0) && (n > 0) 
                        {	                        
				            //set resultObj = ..SetSuccessResult(adrgCode,adrgDesc)
				            set iGetValue=1
				            //continue
                        }	
					}
				}																		   		   		   
		    }
		    else //其他ADRG分组
		    {		
                //无手术/操作时：可以用主诊断来查找对应的ADRG（内科组）
                //有手术/操作时：不能仅用主诊断来查找ADRG，必须用主诊断锁定MDC，再用主手术锁定该MDC下的外科/操作组ADRG    			
    			   
		    	     			    			    
		    	     			    			    
		    	     			    			    
			    //同时包含以下手术或操作--同时包含CB4和CB5的手术或操作(CB2)--同时包含CB5和CB6的手术或操作(CB3)
			    if ($listfind($lb("BB1","CB2","CB3","FB1","FF1"), adrgCode) = 1)
			    {
				    set m=0
			       //遍历手术或操作
			       for i=0:1:oprninfo.%Size()-1 
			       {
                        // 获取手术或操作编码和名称                   
                        set item = oprninfo.%Get(i)
                        set mainFlag = item.mainFlag
                        set oprnSn = item.oprnSn
                        set oprnCode = item.oprnCode
                        set oprnName = item.oprnName
                        
                        //存在不作为分组规则手术及操作代码表中
                        if (..CheckNoRulesList(oprnCode)>0)
                        {
	                        continue
	                    }
	                    
                        &sql(SELECT COUNT(DISTINCT ADRG) into :iCount FROM CB_DRGCoreGroupsList WHERE UnionFlag =1 AND ADRG=:adrgCode 
                             AND (MajorProcedure=:oprnCode OR SecondaryProcedure=:oprnCode OR ThirdlyProcedure=:oprnCode))
                        // 如果SQL执行成功且有结果
                        if (SQLCODE = 0) && (iCount > 0) 
                        {
                            set m = m + 1
                        }
                        
                        if (m>1)
                        {	                        
				            //set resultObj = ..SetSuccessResult(adrgCode,adrgDesc)
				            set iGetValue=1
				            //continue	                    
	                    }	                                          	                         	                    	                    	                    			      
				    } 				    				    				   				   
				}
				//入组条件 1：主要诊断+主要手术或操作 1或入组条件 2：主要手术或操作 2或入组条件 3：手术或操作 3+手术或操作 4
				elseif (adrgCode="IB1")
				{
					continue
				}
				//入组条件 1：主要诊断+手术或操作 1+手术或操作 2或入组条件 2：主要诊断+手术或操作 1+手术或操作3+手术或操作4或入组条件 3：主要诊断+手术或操作 4+手术或操作5
				elseif (adrgCode="JA1")
				{
					continue
				}
				//入组条件 1：主要诊断+主要手术或操作 1或入组条件 2：主要诊断+手术或操作 2+手术或操作3
				elseif (adrgCode="JA2")
				{
					continue
				}	
				//入组条件 1：主要诊断+主要手术或操作 1或入组条件 2：主要诊断+手术或操作 2+手术或操作3
				elseif (adrgCode="NA1")
				{
					continue
				}
				//入组条件 1：主要诊断 1+主要手术或操作或入组条件 2：主要诊断 2+其他诊断+主要手术或操作
				elseif (adrgCode="OF1")
				{
					continue
				}
				//入组条件 1：主要诊断+其他诊断 1+主要手术或操作或入组条件 2：其他诊断 2+主要手术或操作
				elseif ($listfind($lb("WB1","WB2"), adrgCode) = 1)
				{
					continue
				}
				//入组条件：（主要诊断或其他诊断）+主要手术或操作
				elseif (adrgCode="WB3")
				{
					continue
				}		
				//包含 WB1、WB2、WB3 的所有主要手术或操作										
				elseif (adrgCode="WJ1")
				{
					continue
				}
				//包含以下其他诊断				
				elseif ($listfind($lb("WR1","OR1"), adrgCode) = 1)
				{
					continue
				}				
				//包含全部手术或操作
				elseif ($listfind($lb("SB1","TB1","XJ1"), adrgCode) = 1)
				{
					continue
				}							
			    else
			    {
				    if (selectionCriteria ["包含以下主要手术或操作")
				    {
					    set (iCount)=0
 					    &sql(SELECT COUNT(DISTINCT ADRG) into :iCount FROM CB_DRGCoreGroupsList WHERE UnionFlag =0 AND ADRG=:adrgCode AND MajorProcedure=:mainOpCode)
					    if (SQLCODE = 0)&&(iCount>0)
					    {
						    
                            //set resultObj = ..SetSuccessResult(adrgCode,adrgDesc)                            
                            //set adrgCodeList=adrgCodeList_":"_adrgCode
                            //set adrgDescList=adrgDescList_":"_adrgDesc		                            
                            //set resultObj = ..SetSuccessResult(adrgCodeList,adrgDescList)
                            set iGetValue=1
                            //continue
						}
						else
						{
                            //set resultObj = ..SetErrorResult("-1","ADRG核心疾病诊断相关分组表CB_DRGCoreGroupsList未维护:【"_adrgCode_"："_adrgDesc_"】分组规则！"_mainOpCode)	
                            continue	
						} 										                            
					}
					elseif (selectionCriteria ["包含以下主要诊断")
					{
						set (iCount)=0
		                &sql(SELECT COUNT(DISTINCT ADRG) into :iCount FROM CB_DRGCoreGroupsList WHERE UnionFlag =0 AND ADRG=:adrgCode AND PrincipalDiagnosis=:mainDiagCode)						
					    if (SQLCODE = 0)&&(iCount>0)
					    {								        					        			    
                            //set resultObj = ..SetSuccessResult(adrgCode,adrgDesc)	                            						
                            //set adrgCodeList=adrgCodeList_":"_adrgCode
                            //set adrgDescList=adrgDescList_":"_adrgDesc	                            
                            //set resultObj = ..SetSuccessResult(adrgCodeList,adrgDescList)
                            
                            //不存在手术操作的情况下参照诊断信息进行ADRG分组
                            if (mainOpCode ="")
                            {
	                            set iGetValue=1   
	                        }
                            
                            //continue						
						}
						else
						{
                            //set resultObj = ..SetErrorResult("-1","ADRG核心疾病诊断相关分组表CB_DRGCoreGroupsList未维护:【"_adrgCode_"："_adrgDesc_"】分组规则！")	                            							
						    continue
						}						 
					}
					elseif (selectionCriteria ["XXXXXXXXXX")
					{

					}	
					elseif (selectionCriteria ["XXXXXXXXXX")
					{

					}          				       
				}
		    }		    
		    		    
	        //在以下的业务逻辑中判断是否为true,如果为真则push一个adrgCode和adrgDesc的json对象,反之继续continue,一直到循环结束
            if (iGetValue=1)&&( adrgCode '="")
            {
	            set totalCount = totalCount+1
                set row={}
                set row.code = adrgCode
                set row.desc = adrgDesc  
                //set row.diagCode=diagCode
                //set row.diagName=diagName                  
                do rows.%Push(row)	
                //set resultObj=..SetSuccessResult(adrgCodeList,adrgDescList)                              	            
	        }	
	        else
	        {	            
                continue    
		    }	    
	    } 
	    
	    set resultObj=..SetJarraySuccessResult(rows,totalCount)                	                      
    } 
    catch(e) 
    {
        // 7. 异常处理（增强：包含错误码+详细信息）
        set status = e.AsStatus()
        set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
        set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
        set errorInfo = "ADRG核心诊断相关分组异常：类=" _ $ClassName() _ "，入参=" _ jsonObj.%ToJSON() _ "，错误：" _ errorMsg
        
        // 记录错误日志到数据库
        set errorLogID = ##class(src.Interface.Message).InsErrRecord("04000007", errorInfo, errorMsg)
        set resultObj = ..SetErrorResult("-99", "ADRG核心诊断相关分组异常(日志ID："_errorLogID_")："_errorMsg)
    }

    quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 第三步：并发症确认CC/MCC
/// code:		 
/// Input:{"params":[{"":""}]}
/// Debug：
ClassMethod GroupComplication(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
    //DRG分组器的核心逻辑是：如果患者同时患有多个次要诊断（其他诊断），其中只要存在一个被定义为MCC的诊断，那么该病例在“并发症与合并症”的层级上，
    //就直接被归类为 MCC层。即使病历中同时包含10个CC和1个MCC，分组结果依然是 MCC。
    //只有当一个MCC都没有，但存在至少一个CC时，才会被归为 CC层	
		
	//new (jsonObj)
	//set params = ##class(%DynamicArray).%New()			
	try
	{
        // 1. 初始化返回对象（标准化结构）
        set resultObj = ..SetSuccessResult("0","")
        
        // 2. 参数合法性校验（核心前置检查）
        if (jsonObj = "") || (jsonObj.params = "") 
        {
            set resultObj = ..SetErrorResult("-1", "入参异常：缺少params参数或参数为空")
            quit 
        }	    
        // 3. 提取入参并设置默认值（避免空值报错）
        set params = jsonObj.params.%Get(0)
        set mainDiagCode = params.mainDiagnosisCode  //主诊断代码         
        set diseinfo = params.diseInfo //诊断数组对象
        
        set rows=[],iCount=0
        
        //其他诊断 + 手术或操作2		        	
        for j=0:1:diseinfo.%Size()-1 
        {
            // 获取诊断编码和名称                  
            set item = diseinfo.%Get(j)
            set mainFlag = item.mainFlag
            set diagSn = item.diagSn
            set diagCode = item.diagCode
            set diagName = item.diagName
                        	                    	                                                       
            if (mainFlag '="1") //其他诊断
            {
                //存在不作为分组规则疾病诊断表中
                if (..CheckNoRulesList(diagCode)>0)
                {
	                 continue
	            }
	            else
	            {
	                set (levelA,levelB)=0			        	    
	                set (complication,complicationDesc)=""
	                &sql(SELECT SUM(CASE WHEN HBDictionaries_Dr->InsuCode = 'MCC' THEN 1 ELSE 0 END),
                                SUM(CASE WHEN HBDictionaries_Dr->InsuCode = 'CC' THEN 1 ELSE 0 END)
                         INTO :levelA, :levelB FROM HB_DRGBasicDataSub 
                         WHERE Code = :diagCode)	
                                
                    // 如果SQL执行成功且有结果
                    if (SQLCODE = 0)
                    {						                
                        // 确定并发症等级（MCC 优先级高于 CC）
                        If (levelA > 0) 
                        {
                            Set complication = "MCC"
                            Set complicationDesc = "严重并发症"
                        } 
                        ElseIf (levelB > 0) 
                        {
                            Set complication = "CC"
                            Set complicationDesc = "并发症"
                        }
                        
                        //存在MCC情况下直接抛出
                        if (complication = "MCC")
                        {
                            set row={}
                            set row.diagCode = diagCode
                            set row.diagName = diagName  
                            set row.complication= complication
                            set row.complicationDesc= complicationDesc                 
                            do rows.%Push(row)                             
                            set iCount =1   
                            
                            quit
	                    }
	                    //说明每一个其他诊断是否存在CC/MCC
	                    elseif (complication = "CC")
	                    {
                            set row={}
                            set row.diagCode = diagCode
                            set row.diagName = diagName  
                            set row.complication= complication
                            set row.complicationDesc= complicationDesc                 
                            do rows.%Push(row)
            
                            set iCount = iCount+1       
		                }                                                                                   				          
                    }    
		         }	                        	                        
	        }                                                	                    	                                              
        }        
        
        set resultObj=..SetJarraySuccessResult(rows,iCount)	                                                                               
	}
    catch(e) 
    {
        // 7. 异常处理（增强：包含错误码+详细信息）
        set status = e.AsStatus()
        set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
        set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
        set errorInfo = "确认并发症CC/MCC异常：类=" _ $ClassName() _ "，入参=" _ jsonObj.%ToJSON() _ "，错误：" _ errorMsg
        
        // 记录错误日志到数据库
        set errorLogID = ##class(src.Interface.Message).InsErrRecord("04000007", errorInfo, errorMsg)
        set resultObj = ..SetErrorResult("-99", "确认并发症CC/MCC异常（日志ID："_errorLogID_")："_errorMsg)
    }

    quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 第四步：DRG分组
/// code:		 
/// Input:{"params":[{"":""}]}
/// Debug：
ClassMethod GroupDRG(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
    ///第4位：表示并发症或其他信息，使用阿拉伯数字（0-9），标记病情复杂程度：
    ///1=表示伴有严重并发症与合并症
    ///3=表示伴有一般并发症与合并症
    ///5=表示不伴有并发症与合并症
    ///7=表示死亡或转院
    ///0=表示小于 17 岁组，儿童病例（<17岁）
    ///9=表示未作区分的情况
    ///QY=歧义（QY）组，指与主要诊断无关的手术病例组，可在多个MDC中出现，检查病例的主要诊断和主要手术/操作是否匹配，如果二者在临床逻辑上不匹配，或者不在同一个主要诊断大类（MDC）里，这个病例就会被判定为“歧义”，送入QY组
    ///0000=指由于疾病诊断编码不规范等原因导致的不能正常入组的病例进入的组。
    ///其他数字表示其他需单独分组的情况。
    
    //离院方式 1医嘱离院;2医嘱转院;3医嘱转社区卫生服务机构/乡镇卫生院;4非医嘱离院;5死亡;9其他。
    //具体作用节点：
    //分组器逻辑节点：分组器在完成MDC(主要诊断大类)和ADRG(核心组)划分后，在根据年龄、并发症/合并症(CC/MCC)进行细分的同时或之后，读取“离院方式”字段。
    //特定分组干预：代码2(医嘱转院)和4(非医嘱离院)在DRG分组中会被特别标记
    //如果离院方式为“医嘱转院”或“医嘱转社区卫生服务机构”，部分地区或特定分组器会将其划入“转院组”或影响费用消耗指数的计算。
    //如果离院方式为“非医嘱离院”，在计算时间消耗指数或费用消耗指数时，该病例可能被标记为“非正常离院”，在绩效评价或支付调整中予以区分。
    //如果离院方式为“死亡”，在分组时会进入特定的“死亡组”（通常权重较高），且会触发“低风险死亡率”的质控指标计算。    
                
	new (jsonObj)
	set params = ##class(%DynamicArray).%New()     	
	try
	{
        // 1. 初始化返回对象（标准化结构）
        set resultObj = ..SetSuccessResult("0","")
        
        // 2. 参数合法性校验（核心前置检查）
        if (jsonObj = "") || (jsonObj.params = "") 
        {
            set resultObj = ..SetErrorResult("-1", "入参异常：缺少params参数或参数为空")
            quit 
        }	    
        // 3. 提取入参并设置默认值（避免空值报错）
        set params = jsonObj.params.%Get(0)
        set adrgCode = params.adrg  // ADRG代码
        set adrgInfo = params.adrgInfo // ADRG数组对象
        set hospInfo = params.hospInfo  // 医疗机构-数组对象  
        set complication = params.complication  // 并发症 CC/MCC        
        set complicationInfo = params.complicationInfo  // 并发症 CC/MCC        
		set mainDiagCode = params.mainDiagnosisCode  // 主诊断代码
        set age = params.age                         // 年龄(默认0)	
        set dischargeType = params.dischargeType     //离院方式	
        
        if (hospInfo = "") || ('$ISOBJECT(hospInfo)) set hospInfo = []	
						
		//遍历并发症信息-MCC覆盖CC
		for i = 0:1:complicationInfo.%Size()-1 
		{
            set item = complicationInfo.%Get(i)
                set diagCode = item.diagCode
                set diagName = item.diagName                 
                set complicationDesc = item.complicationDesc
                set complication=item.complication  
                
            if (complication="MCC")
            {	            	        	            
	            quit 
	        }			
		}
		
        set rows = []
        set iCount=0
        // 遍历 result 数组
        for i = 0:1:adrgInfo.%Size()-1 
        {
            set item = adrgInfo.%Get(i)
            set adrgCode = item.code
            set adrgDesc = item.desc                                 
            
		    set num="9"
		    if (age>=17)
		    {
		        if (complication="CC")
		        {
		            set num="3"		    	
	    	    }
		        elseif (complication="MCC")
	    	    {
		            set num="1"		    	
	    	    }
	    	    elseif (complication="")&&(iCount>0)
		        {
		            set num="9"	
		        }	    	    
	    	    elseif (complication="")
		        {
		            set num="5"		    	
		        }	
	    	}
		    else
		    {
		        set num="0"			
		    }
		    		    
		    //判断离院方式
		    if (dischargeType="2")||(dischargeType="5")
		    {
			    set num="7"	
			}
			
			/*						
		    //方式一：基于CHS-DRG国家医保局发布细分规则为0表示该ADRG第四位编码确定为9，不再根据其它因素继续判断分组
            //先根据细分规则判断第四位编码
            set segFlag=0
            &sql(SELECT SegmentationFlag into :segFlag FROM HB_DRGSegmentationRules Where ADRG=:adrgCode)		    
		    if (segFlag="0")
		    {			  
		        set drg =adrgCode_"9" 
		        set desc=..GetComplicationDesc("9")		
		        set drgDesc= adrgDesc_"："_desc	  			    			    
		    }
		    else
		    {
		        set drg =adrgCode_num 
		        set desc=..GetComplicationDesc(num)		
		        set drgDesc= adrgDesc_"："_desc	  			    
			}
			*/
		
			set drg =adrgCode_num
			set desc=..GetComplicationDesc(num)	
			set drgDesc= adrgDesc_"："_desc		
		
		    //方式二：基于地方查找各地方的DRGs目录表，判断是否存在；优先匹配地方DRGs目录
		    //传医疗机构信息则查找对应机构所在地区维护的DRGs目录
		    if (hospInfo.%Size()>0) 
		    {			    
                for i = 0:1:hospInfo.%Size()-1 
                {
                    set itemObj = hospInfo.%Get(i)           
                    set hospCode = itemObj.code
                                        
                    set (provID,cityID)=""
                    &sql(SELECT ProvID_Dr,CityID_Dr into :provID,:cityID FROM CB_Hospital where OrganizationCode=:hospCode)
                		    
		            set iCount=0
                    &sql(SELECT Count(*) into :iCount FROM HB_DRGCataLog Where Code=:drg and Province_Dr=:provID AND City_Dr=:cityID)
                    if (iCount = 0)
	                {
		                //地方DRG目录没有这个DRGs编码,参考CHS-DRG国家医保局DRGs目录
                        //先根据细分规则判断第四位编码
                        set segFlag=0
                        &sql(SELECT SegmentationFlag into :segFlag FROM HB_DRGSegmentationRules Where ADRG=:adrgCode)		    
		                if (segFlag=0)
		                {			  
		                    set drg =adrgCode_"9" 
		                    set desc=..GetComplicationDesc("9")		
		                    set drgDesc= adrgDesc_"："_desc	  			    			    
		                }		                		                
		            }	                                  
                }   
			}
			else //没有传医疗机构信息，按CHS-DRG国家医保局DRGs目录处理
			{   
		        //地方DRG目录没有这个DRGs编码,参考CHS-DRG国家医保局DRGs目录 
                //先根据细分规则判断第四位编码
                set segFlag=0
                &sql(SELECT SegmentationFlag into :segFlag FROM HB_DRGSegmentationRules Where ADRG=:adrgCode)		    
		        if (segFlag="0")
		        {			  
		            set drg =adrgCode_"9" 
		            set desc=..GetComplicationDesc("9")		
		            set drgDesc= adrgDesc_"："_desc	  			    			    
		        }       
		    }
                		                		 		      
            set row={}
            set row.code = drg
            set row.desc = drgDesc                    
            do rows.%Push(row)
            
            set iCount = iCount+1		    		                                                            
        }		
				
		set resultObj=..SetJarraySuccessResult(rows,iCount)		
	}
    catch(e) 
    {
        // 7. 异常处理（增强：包含错误码+详细信息）
        set status = e.AsStatus()
        set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
        set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
        set errorInfo = "DRG分组异常：类=" _ $ClassName() _ "，入参=" _ jsonObj.%ToJSON() _ "，错误：" _ errorMsg
        
        // 记录错误日志到数据库
        set errorLogID = ##class(src.Interface.Message).InsErrRecord("04000007", errorInfo, errorMsg)
        set resultObj = ..SetErrorResult("-99", "DRG分组异常（日志ID："_errorLogID_")："_errorMsg)
    }

    quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 分组器
/// code:		 
/// Input:{"params":[{"":""}]}
/// Debug
ClassMethod Device(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
	///病例实际费用 ÷ 该病组标准费用（次均费用 / 支付标准）」算出倍率，再按当地医保阈值划分为：高倍率、正常倍率、低倍率。
	///DRG 权重RW与基准点数本质是同一个 “相对资源值”，只是单位与叫法不同：权重是小数（比值）基准点数 = DRG 权重 × 100（或 ×1000，各地不同）
	try
	{
        // 初始化返回对象（标准化结构）
        set resultObj = ..SetSuccessResult("0","")
        
        // 参数合法性校验（核心前置检查）
        if (jsonObj = "") || (jsonObj.params = "") 
        {
            set resultObj = ..SetErrorResult("-1", "入参异常：缺少params参数或参数为空")
            quit 
        }
        	    
        // 提取入参并设置默认值（避免空值报错）
        set params = jsonObj.params.%Get(0)
        set mainDiagCode = params.mainDiagnosisCode  
        set diseinfo = params.diseInfo  // 疾病诊断-数组对象   
		set mainOperationCode = params.mainOperationCode    // 主手术代码
    	set oprninfo = params.oprnInfo  // 手术操作-数组对象（兼容空数组）  
    	set hospinfo = params.hospInfo  // 医疗机构-数组对象   	
        set sex = params.sex                       // 性别
        set age = params.age                         // 年龄（默认0）
        set ageGroupDays = params.ageGroupDays        // 新生儿出生天数（默认0）
        set newbornFlag = params.newbornFlag        // 新生儿标志（默认0）
        set respiratorTime = params.respiratorTime    // 有创呼吸机时长（默认0）
        set ecmoFlag = params.ecmoFlag             // ECMO标志（默认0）
        set transplantFlag = params.transplantFlag  // 器官移植标志（默认0）
        set marrowTransplantFlag = params.marrowTransplantFlag // 骨髓移植标志
        set hivFlag = params.hivFlag                // HIV标志（默认0）
        set traumaLevel = params.traumaLevel          // 多发创伤等级（默认0）
		set department = params.department           // 科室编码
		set departmentDesc = params.departmentDesc   // 科室名称
		set dischargeType = params.dischargeType // 离院方式 1医嘱离院;2医嘱转院;3医嘱转社区卫生服务机构/乡镇卫生院;4非医嘱离院;5死亡;9其他 代码 2（医嘱转院） 和 4（非医嘱离院） 在DRG分组中会被特别标记
		set hospitalDays = params.hospitalDays   //住院天数 	
		set totalCost = params.totalCost             //住院已发生费用合计
		
		set patientName=params.patientName //患者姓名
		set deptCode=params.deptCode //HIS科室编码
		set deptName=params.deptName //HIS科室名称	
		
		set doctorCode=params.doctorCode //HIS医生编码
		set doctorName=params.doctorName //HIS医生名称
		set medicalRecordID=params.medicalRecordDr //病案号	
		set hisAdmID=params.hisAdmID //HIS就诊号				

		//增加HIS患者就诊信息
		set psnNo=params.psnNo //医保个人编号
		set insuranceAreaCode=params.insuranceAreaCode //参保地区划代码 
		set mdtrtareaAreaCode=params.mdtrtareaAreaCode //就医地区划代码
		set insuType=params.insuType //险种类型								
		set diagnosisCode=params.diagnosisCode //病种编码
		set diagnosisName=params.diagnosisName //病种名称
		set groupStage=params.groupStage  //分组阶段 1.事前 2.事中 3.事后
		set diaTypeCode=params.diaTypeCode //诊断类型编码 ADD入院 OPD门诊 DIS出院		
		set admDateTime=params.admDateTime //入院时间
		set discgDateTime=params.discgDateTime //出院时间
		set settleDateTime=params.settleDateTime //结算时间
		set unionOprnFlag=params.unionOprnFlag //联合手术标志 

    	// 如果为空字符串或非数组，设置为空数组
    	if (diseinfo = "") || ('$ISOBJECT(diseinfo)) set diseinfo = []
    	if (oprninfo = "") || ('$ISOBJECT(oprninfo)) set oprninfo = []		
    	if (hospinfo = "") || ('$ISOBJECT(hospinfo)) set hospinfo = []    	    		  	                    
							
		set (MDC,MDCDesc,ADRG,ADRGDesc,DRG,DRGDesc,Complication,ComplicationDesc)=""		
		         	
		//1.分组流程前 校验入参 
		set joRtn=..CheckRules(jsonObj)
		if (joRtn.errorCode '= "0")
		{
            set resultObj = ..SetErrorResult("-1", "进入分组流程前CheckRules校验失败："_joRtn.errorMessage)
            quit
		}

		//2.第一步：MDC先期分组      
		set joRtn=..GroupPreMDC(jsonObj)
		if (joRtn.errorCode '= "0")
		{
            set resultObj = ..SetErrorResult("-2", "2.MDC先期分组失败："_joRtn.errorMessage)
            quit
		}
		else
		{
			set MDC=joRtn.result.code
			set MDCDesc=joRtn.result.desc
		}
		
		//3.第二步：判断QY歧义组
        set params.mdc = MDC
        set params.mdcDesc = MDCDesc
		set joRtn=..CheckGroupQY(jsonObj)
		if (joRtn.errorCode '= "0")
		{	
		    //返回不为0表示 进入歧义组		
            set resultObj = ..SetErrorResult("-3", "3.QY歧义组判断："_joRtn.errorMessage)
            quit
		}

		//4.第三步：ADRG分组        
        set params.mdc = MDC
        set params.mdcDesc = MDCDesc
		set joRtn=..GroupADRG(jsonObj)
		
		if (joRtn.errorCode '= "0")
		{
            set resultObj = ..SetErrorResult("-4", "4.1 ADRG分组失败："_joRtn.errorMessage)
            quit
		}
		else
		{
			//返回结果是数组对象,可能存在多个ADRG分组结果
			set totalCount = joRtn.totalCount //返回记录数
			set jaADRG= joRtn.result	
			if (totalCount = 0)
			{
			    set resultObj=..SetErrorResult("-4","4.2 ADRG分组失败,请检查主诊断大类【"_MDC_"："_MDCDesc_"】的分组规则是否维护！0000组入组条件：主要诊断大类(MDC),或者未入任何ADRG分组！")	
			    quit
			}				
		}

		//第四步：并发症确认CC/MCC
		set params.adrgInfo = jaADRG
		set joRtn=..GroupComplication(jsonObj)	
				
		if (joRtn.errorCode '= "0")
		{
            set resultObj = ..SetErrorResult("-5", "5.1 并发症确认CC/MCC失败："_joRtn.errorMessage)
            quit
		}
		else
		{
			//返回结果是数组对象,可能存在多个ADRG分组结果
			set totalCount = joRtn.totalCount //返回记录数
			set jaComplication= joRtn.result
		}

		//第五步：DRG分组
        set params.complicationInfo= jaComplication                       
		set joRtn=..GroupDRG(jsonObj)								
		if (joRtn.errorCode '= "0")
		{
            set resultObj = ..SetErrorResult("-7", "7.1 DRG分组失败："_joRtn.errorMessage)
            quit
		}
		else
		{
			//返回数组对象,可能存在多个DRG分组结果
			set totalCount = joRtn.totalCount 
			set jaDRG= joRtn.result	
			if (totalCount =0)
			{
			    set resultObj=..SetErrorResult("-7","7.2 DRG分组失败："_joRtn.errorMessage)	
			    quit
			}
			
            set itemObj = jaDRG.%Get(0)
            set DRG = itemObj.code
            set DRGDesc = itemObj.desc									
		}
		
		//第六步：查询DRG对应医疗机构算法配置信息		
        //循环医疗机构信息数组
        set jaAlgorithm=[]
        for i = 0:1:hospinfo.%Size()-1 
        {
            set itemObj = hospinfo.%Get(i)
            set hisHospCode=itemObj.hisHospCode            
            set hospCode = itemObj.code
            set hospName = itemObj.name
            set mdtrtArea="",policyType=""
            set iCount=0
            //set (points,pipValue,dgdov,payStandard)="0.00"
            
            //根据医院信息获取对应的就医地区划代码 - 医疗机构信息表数据确保完善
            &sql(SELECT CityID_Dr->Code,PolicyType_Dr->Descripts into :mdtrtareaAreaCode,:policyType FROM CB_Hospital WHERE OrganizationCode=:hospCode)
            //根据参保地和就医地区划，解析获取 市本级/省直/异地	   
            set insuAreaDesc=..GetSettlementType(insuranceAreaCode,mdtrtareaAreaCode)	        
	        //查询算法配置表数据，获取当前医院是否配置 市本级、省直、异地	        
            &sql(SELECT Count(*) into :iCount FROM HB_DRGCoreAlgorithmData WHERE FixmedinsCode=:hospCode AND DRG=:DRG)	        
	        //如果存在多条数据表示,当前医院存在多个算法配置,DRG医疗机构算法配置表数据确保完善 
	        if (iCount>1)
	        {
		        if (insuAreaDesc="市本级")
		        {
			        set mdtrtArea=$E(mdtrtareaAreaCode,1,4)_"00"     
			    }
			    elseif (insuAreaDesc="省直")
		        {
			        set mdtrtArea=$E(mdtrtareaAreaCode,1,2)_"9900"     
			    }
			    elseif (insuAreaDesc="异地")
		        {
			        set mdtrtArea=$E(mdtrtareaAreaCode,1,2)_"0000"     
			    }
			    
                &sql(SELECT Points, PipValue, DGDOV, PayStandard into :points,:pipValue,:dgdov,:payStandard FROM HB_DRGCoreAlgorithmData 
                     WHERE FixmedinsCode=:hospCode AND DRG=:DRG AND MdtrtArea=:mdtrtArea)    			    
		    }
		    else //只存在一条记录，表示当前医院市本级、省直、异地算法配置都一样,直接取市本级数据
		    {
			    set insuAreaDesc="市本级"
                &sql(SELECT Points, PipValue, DGDOV, PayStandard into :points,:pipValue,:dgdov,:payStandard FROM HB_DRGCoreAlgorithmData 
                     WHERE FixmedinsCode=:hospCode AND DRG=:DRG)
			}	        
                                                           
		    if (payStandard="0.00")||(payStandard="")		    
		    {
			    set (points,pipValue,dgdov,payStandard)="0.00"
			}
			
			//continue:(payStandard ="0.00")||(payStandard ="")
            
            set jo={}
            set jo.hisHospCode = hisHospCode
            set jo.hospCode = hospCode
            set jo.hospName = hospName
            set jo.algorithm= insuAreaDesc
            set jo.policyType= policyType
            set jo.drg = DRG 
            set jo.drgDesc = DRGDesc                       
            set jo.points = points
            set jo.pipValue = pipValue
            set jo.dgdov = dgdov
            set jo.payStandard = payStandard                        
            set jo.totalCost = totalCost

            //差异率（相对差异） = （实际费用 - 预估费用） / 预估费用 × 100%                           
            if (payStandard="0.00")||(payStandard="")
            {
                set discrepancyRate = 100                    
                set discrepancyAmt = payStandard - totalCost
	        }
	        else
	        {
                set discrepancyRate = $FNUMBER(($ZABS(totalCost - payStandard)/payStandard)*100,"L",2)                       
                set discrepancyAmt = payStandard - totalCost   
		    }
                        
            if (discrepancyAmt > 0)
            {
	            set jo.preProfit = $FNUMBER(discrepancyAmt,"L",2) //盈利
	            set jo.preLoss = "0.00" //亏损
	            set jo.profitLoss = "盈利"  
	        }
	        elseif (discrepancyAmt < 0)
	        {
	            set jo.preProfit = "0.00" //盈利
	            set jo.preLoss = $FNUMBER(discrepancyAmt,"L",2) //亏损 
	            set jo.profitLoss = "亏损"  
		    }
	        elseif (discrepancyAmt = 0)
	        {
	            set jo.preProfit = "0.00" //盈利
	            set jo.preLoss = "0.00" //亏损 
	            set jo.profitLoss = ""  
		    }
		    	
		    set jo.discrepancyRate = discrepancyRate //差异率%
		    
			do jaAlgorithm.%Push(jo)     	                                                                     
        }
       
        //第七步：封装返回值
		set DRG=joRtn.result.code
		set DRGDesc=joRtn.result.desc
		set resultObj = ..SetSuccessResult(DRG,DRGDesc)

		set joRtn={}
		set joRtn.mdc=MDC
		set joRtn.mdcDesc=MDCDesc
		set joRtn.complicationInfo=jaComplication
		set joRtn.drgInfo=jaDRG
		set joRtn.hospAlgorithmInfo=jaAlgorithm
		set joRtn.checkTime = $ZDATETIME($HOROLOG,3)

    	set resultObj={}
	    set resultObj.errorCode = "0"
	    set resultObj.errorMessage = ""
	    set resultObj.result = joRtn    
	    set resultObj.params = params
	    
	    //第八步：分组成功插入分组记录表
	    /*
	    if (medicalRecordID '= "")
	    {
		    // 构造保存分组记录的入参
		    set saveParams = {}
		    set saveParams.admID = $GET(hisAdmID, "")
		    set saveParams.medcasNo = $GET(medicalRecordID, "")
		    set saveParams.patientName = patientName
		    set saveParams.psnNo = $GET(psnNo, "")
		    set saveParams.insuranceAreaCode = $GET(insuranceAreaCode, "")
		    set saveParams.mdtrtareaAreaCode = $GET(mdtrtareaAreaCode, "")
		    
		    set saveParams.insuType = $GET(insuType, "")
		    set saveParams.sex = $GET(sex, "")
		    set saveParams.age = $GET(age, "")
		    set saveParams.mainDiagnosisCode = $GET(mainDiagCode, "")
		    set saveParams.mainDiagnosisName = ""
		    set saveParams.diaTypeCode = $GET(diaTypeCode, "")
		    set saveParams.diagnosisCode = $GET(diagnosisCode, "")
		    set saveParams.diagnosisName = $GET(diagnosisName, "")
		    set saveParams.mainOperationCode = $GET(mainOperationCode, "")
		    set saveParams.mainOperationName = ""
		    set saveParams.department = $GET(deptCode, "")
		    set saveParams.departmentDesc = $GET(deptName, "")
		    set saveParams.drg = DRG
		    set saveParams.drgDesc = DRGDesc
		    set saveParams.weight = ""
		    set saveParams.benchmarkCost = ""
		    set saveParams.ccFlag = ""
		    set saveParams.mccFlag = ""
		 
		    set saveParams.groupTime = $ZDATETIME($HOROLOG, 3)
		    set saveParams.fixmedinsCode = ""
		    set saveParams.fixmedinsName = ""
		    set saveParams.groupStage = $GET(groupStage, "1")
		    set saveParams.admDateTime = $GET(admDateTime, "")
		    set saveParams.discgDateTime = $GET(discgDateTime, "")
		    set saveParams.settleDateTime = $GET(settleDateTime, "")
		    set saveParams.unionOprnFlag = unionOprnFlag
		    set saveParams.remark = params.%FromJson()
		    
		    // 从diseInfo中获取主诊断名称（mainFlag=1 且 diagSn=1）
		    if (mainDiagCode '= "") && ($ISOBJECT(diseinfo)) && (diseinfo.%Size() > 0)
		    {
			    for i=0:1:diseinfo.%Size()-1
			    {
				    set diagItem = diseinfo.%Get(i)
				    if ($GET(diagItem.mainFlag) = "1") && ($GET(diagItem.diagSn) = "1")
				    {
					    set saveParams.mainDiagnosisName = $GET(diagItem.diagName, "")
					    quit
				    }
			    }
		    }
		    
		    // 从oprnInfo中获取主手术名称（mainFlag=1 且 oprnSn=1）
		    if (mainOperationCode '= "") && ($ISOBJECT(oprninfo)) && (oprninfo.%Size() > 0)
		    {
			    for j=0:1:oprninfo.%Size()-1
			    {
				    set oprnItem = oprninfo.%Get(j)
				    if ($GET(oprnItem.mainFlag) = "1") && ($GET(oprnItem.oprnSn) = "1")
				    {
					    set saveParams.mainOperationName = $GET(oprnItem.oprnName, "")
					    quit
				    }
			    }
		    }
		    
		    // 构造SaveDRGGroupRecord接口入参
		    set paramsArr = ##class(%DynamicArray).%New()
		    do paramsArr.%Push(saveParams)
		    set saveJsonObj = ##class(%DynamicObject).%New()
		    set saveJsonObj.params = paramsArr
		    
		    // 调用保存方法（不阻塞主流程）
		    do ##class(src.DRG.GroupDevice).SaveDRGGroupRecord(saveJsonObj)
	    }
	    */
	    	
	}
    catch(e) 
    {
        // 7. 异常处理（增强：包含错误码+详细信息）
        set status = e.AsStatus()
        set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
        set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
        set errorInfo = "DRG分组异常：类=" _ $ClassName() _ "，入参=" _ jsonObj.%ToJSON() _ "，错误：" _ errorMsg
        
        // 记录错误日志到数据库
        set errorLogID = ##class(src.Interface.Message).InsErrRecord("04000007", errorInfo, errorMsg)
        set resultObj = ..SetErrorResult("-99", "DRG分组异常(日志ID："_errorLogID_")："_errorMsg)
    }

    quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: DRG分组器+费用预警
/// code:		 
/// Input:{"params":[{"":""}]}
/// Debug
ClassMethod DeviceFeeWarning(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
	new (jsonObj)
	set params = ##class(%DynamicArray).%New()	
	try
	{
        // 1. 初始化返回对象（标准化结构）
        set resultObj = ..SetSuccessResult("0","")
        
        // 2. 参数合法性校验（核心前置检查）
        if (jsonObj = "") || (jsonObj.params = "") 
        {
            set resultObj = ..SetErrorResult("-1", "入参异常：缺少params参数或参数为空")
            quit 
        }         
        
        //先获取分组结果
        set joDRGObj=..Device(jsonObj)
        if (joDRGObj.errorCode '=0)
        {
            set resultObj = ..SetErrorResult("-1", "DRG分组失败："_joDRGObj.errorMessage)
            quit   
	    }
	    else
	    {
		    set params = jsonObj.params.%Get(0)
		    //取DRG信息
            set drgParams = joDRGObj.result.drgInfo.%Get(0)
            set drgCode = drgParams.code
		    set drgDesc = drgParams.desc
		    
		    //取DRG算法信息
		    set payParams = joDRGObj.result.hospAlgorithmInfo.%Get(0)
		    set drgPayStandard=payParams.payStandard
		    
		    //组织入参调用02010107费用预警接口服务
		    set jsonObj.params.%Get(0).hisAdmId=params.hisAdmId
		    set jsonObj.params.%Get(0).patientName=params.patientName
		    set jsonObj.params.%Get(0).deptCode=params.deptCode
		    set jsonObj.params.%Get(0).deptName=params.deptName
		    set jsonObj.params.%Get(0).doctorCode=params.doctorCode
		    set jsonObj.params.%Get(0).doctorName=params.doctorName
		    set jsonObj.params.%Get(0).totalFee=params.totalFee
		    set jsonObj.params.%Get(0).drgCode=drgCode
		    set jsonObj.params.%Get(0).drgName=drgDesc
		    set jsonObj.params.%Get(0).drgPayStandard=drgPayStandard
		    set jsonObj.params.%Get(0).medicalRecordDr=params.medicalRecordDr
		    set jsonObj.params.%Get(0).insuranceFee=params.insuranceFee
		    set jsonObj.params.%Get(0).fixmedinsCode=params.fixmedinsCode		    
		    set jsonObj.params.%Get(0).fixmedinsName=params.fixmedinsName
		    set jsonObj.params.%Get(0).ruleType=params.ruleType		    
		    		    
		    set joRtn=##class(src.DRG.Warning).AddWarningRecord(jsonObj)	
		    if (joRtn.errorCode '=0) 
		    {
                set resultObj = ..SetErrorResult("-1", "DRG分组结果费用预警失败："_joRtn.errorMessage)
                quit   
			}   
			else
			{
			    set joWarningFee= []
			    set joWarningFee= joRtn.result
			    set joDRGObj.result.feeWarningInfo=joWarningFee		
			    
            	//set resultObj={}
	            //set resultObj.errorCode="0"
	            //set resultObj.errorMessage=""
	            //set resultObj.result=joDRGObj	
	            
	            set resultObj = joDRGObj			    	    
			}	    		    		    
		}				
	}
    catch(e)
    {
        set status = e.AsStatus()
        set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
        set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
        set errorInfo = "DRG分组结果费用预警异常：类=" _ $ClassName() _ "，错误：" _ errorMsg
        
        // 记录错误日志
        set errorLogID = ##class(src.Interface.Message).InsErrRecord("02010035", errorInfo, errorMsg)
        set resultObj.errorCode = "-99"
        set resultObj.errorMessage = "DRG分组结果费用预警异常（日志ID："_errorLogID_"）："_errorMsg
    }
    
    quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: DIP分组分值查询 - 通过主诊断和主手术模糊匹配DIP算法配置表，支持行政区划代码和医疗机构关联省市筛选
/// code:		 02010003
/// Input:{"params":[{"mainDiagnosisCode":"","mainOperationCode":"","mdtrtArea":"","fixmedinsCode":"","fixmedinsName":""}]}
/// Debug
ClassMethod GetDIPGroupScore(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
	new (jsonObj)
	set params = ##class(%DynamicArray).%New()
	try
	{
	    // 1. 初始化返回对象
	    set resultObj = ..SetSuccessResult("0","")
	    
	    // 2. 参数合法性校验
	    if (jsonObj = "") || (jsonObj.params = "")
	    {
	        set resultObj = ..SetErrorResult("-1", "入参异常：缺少params参数或参数为空")
	        quit
	    }
	    
	    // 3. 提取入参
	    set params = jsonObj.params.%Get(0)
	    set mainDiagCode = params.mainDiagnosisCode   // 主诊断代码（必填）
	    set mainDiagName = params.mainDiagnosisName   // 主诊断名称	    	    	    
	    set mainOpCode = params.mainOperationCode     // 主手术代码（选填）
	    set mainOpName = params.mainOperationName     // 主手术名称	    
	    set secOpCode = params.secondOperationCode     // 次要手术代码（选填）
	    set secOpName = params.secondOperationName     // 次要手术名称	 	   	       	    
	    set mdtrtArea = params.mdtrtArea              // 行政区划代码（选填）	   
	    set fixmedinsCode = params.fixmedinsCode      // 医疗机构代码（选填）
	    set fixmedinsName = params.fixmedinsName      // 医疗机构名称（选填）
	    
	    // 4. 必填项校验
	    if (mainDiagCode = "")
	    {
	        set resultObj = ..SetErrorResult("-1", "主诊断不能为空！")
	        quit
	    }
	    
	    // 5. 行政区划代码和医疗机构代码/名称不能同时为空
	    if (mdtrtArea = "") && (fixmedinsCode = "") && (fixmedinsName = "")
	    {
	        set resultObj = ..SetErrorResult("-1", "行政区划代码和医疗机构代码/名称不能同时为空！")
	        quit
	    }
	    
	    // 6. 医疗机构关联查询：通过CB_Hospital获取省市ID
	    set (provID, cityID) = ""
	    if (fixmedinsCode '= "")
	    {
	        // 优先使用医疗机构代码精确查询
	        &sql(SELECT ProvID_Dr, CityID_Dr INTO :provID, :cityID FROM CB_Hospital WHERE OrganizationCode = :fixmedinsCode)
	        if (SQLCODE '= 0) || (provID = "")
	        {
	            set resultObj = ..SetErrorResult("-1", "未找到对应医疗机构信息！")
	            quit
	        }
	    }
	    elseif (fixmedinsName '= "")
	    {
	        // 医疗机构代码为空时，通过名称模糊查询（取第一条）
	        &sql(SELECT TOP 1 ProvID_Dr, CityID_Dr INTO :provID, :cityID FROM CB_Hospital WHERE Descripts LIKE '%'_:fixmedinsName_'%')
	        if (SQLCODE '= 0) || (provID = "")
	        {
	            set resultObj = ..SetErrorResult("-1", "未找到对应医疗机构信息！")
	            quit
	        }
	    }
	    
	    // 7. 将入参编码拆分为列表（用于后续匹配）
	    set diagCodeList = ..SplitCodes(mainDiagCode)
	    set mainOpCodeList = ""
	    set secOpCodeList = ""
	    if (mainOpCode '= "")
	    {
	        set mainOpCodeList = ..SplitCodes(mainOpCode)
	    }
	    if (secOpCode '= "")
	    {
	        set secOpCodeList = ..SplitCodes(secOpCode)
	    }
	    
	    // 8. 构建动态SQL查询DIP算法配置数据
	    //    使用宽松筛选：只要表中字段包含任意一个入参编码即可命中
	    set sql = " SELECT ID, PrincipalDiagnosis, PrincipalDiagnosisName,"
	            _ " MajorProcedure, MajorProcedureName,"
	            _ " SecondaryProcedure, SecondaryProcedureName,"
	            _ " Province_Dr AS ProvinceID, Province_Dr->Descripts AS ProvinceDesc,"
	            _ " City_Dr AS CityID, City_Dr->Descripts AS CityDesc,"
	            _ " MdtrtArea, MedinsLv,"
	            _ " ScoreValue, AdjustCoefficient,"
	            _ " PrimaryAdjustCoefficient, SecondaryAdjustCoefficient, ThirdAdjustCoefficient,"
	            _ " AverageCost"
	            _ " FROM HB_DIPCoreAlgorithmData WHERE 1=1"
	    
	    // 主诊断匹配 - 每个输入编码独立做 INSTR 匹配，OR 组合（宽松筛选）
	    set sql = sql _ ..BuildMultiCodeWhere("PrincipalDiagnosis", diagCodeList)
	    
	    // 主手术匹配 - 选填
	    if (mainOpCodeList '= "")
	    {
	        set sql = sql _ ..BuildMultiCodeWhere("MajorProcedure", mainOpCodeList)
	    }
	    
	    // 次要手术匹配 - 选填
	    if (secOpCodeList '= "")
	    {
	        set sql = sql _ ..BuildMultiCodeWhere("SecondaryProcedure", secOpCodeList)
	    }

	    // 行政区划代码 - 等值匹配
	    if (mdtrtArea '= "")
	    {
	        set sql = sql _ " AND MdtrtArea = "_mdtrtArea
	    }
	    
	    // 省市条件 - 通过医疗机构关联获取
	    if (provID '= "")
	    {
	        set sql = sql _ " AND Province_Dr = "_provID
	    }
	    if (cityID '= "")
	    {
	        set sql = sql _ " AND City_Dr = "_cityID
	    }
	    
	    set sql = sql _ " ORDER BY ID DESC"
	    
	    // 9. 执行查询并对每条候选记录进行匹配度评分，保留最高分记录
	    set rows = ##class(%DynamicArray).%New()
	    set bestScore = -1
	    set bestRow = ""
	    
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set rs=sqlObj.%Execute()
		while rs.%Next(sc)
	    {
	        set storedDiag = rs.%Get("PrincipalDiagnosis")
	        set storedMajorProc = rs.%Get("MajorProcedure")
	        set storedSecProc = rs.%Get("SecondaryProcedure")
	        
	        // 计算匹配得分（权重：主诊断 > 主手术 > 次要手术）
	        set (diagMatch, opMatch, secMatch) = 0
	        set diagMatch = ..CountCodeMatches(diagCodeList, storedDiag)
	        set score = diagMatch * 100
	        
	        if (mainOpCodeList '= "")
	        {
	            set opMatch = ..CountCodeMatches(mainOpCodeList, storedMajorProc)
	            set score = score + opMatch * 50
	        }
	        
	        if (secOpCodeList '= "")
	        {
	            set secMatch = ..CountCodeMatches(secOpCodeList, storedSecProc)
	            set score = score + secMatch * 30
	        }
	        
	        // 精度惩罚：存储字段中多余的编码数（优先返回与入参最贴近的记录）
	        set extraPenalty = 0
	        if (diagMatch > 0)
	        {
	            set storedDiagCount = $LISTLENGTH(..SplitCodes(storedDiag))
	            if (storedDiagCount > diagMatch)
	            {
	                set extraPenalty = extraPenalty + (storedDiagCount - diagMatch) * 5
	            }
	        }
	        if (opMatch > 0)
	        {
	            set storedOpCount = $LISTLENGTH(..SplitCodes(storedMajorProc))
	            if (storedOpCount > opMatch)
	            {
	                set extraPenalty = extraPenalty + (storedOpCount - opMatch) * 3
	            }
	        }
	        if (secMatch > 0)
	        {
	            set storedSecCount = $LISTLENGTH(..SplitCodes(storedSecProc))
	            if (storedSecCount > secMatch)
	            {
	                set extraPenalty = extraPenalty + (storedSecCount - secMatch) * 2
	            }
	        }
	        set score = score - extraPenalty
	        
	        // 只保留得分最高的记录
	        if (score > bestScore)
	        {
	            set bestScore = score
	            set dataObj = {}
	            set dataObj.id = rs.%Get("ID")
	            set dataObj.principalDiagnosis = storedDiag
	            set dataObj.principalDiagnosisName = rs.%Get("PrincipalDiagnosisName")
	            set dataObj.majorProcedure = storedMajorProc
	            set dataObj.majorProcedureName = rs.%Get("MajorProcedureName")
	            set dataObj.secondaryProcedure = storedSecProc
	            set dataObj.secondaryProcedureName = rs.%Get("SecondaryProcedureName")
	            set dataObj.provinceID = rs.%Get("ProvinceID")
	            set dataObj.provinceDesc = rs.%Get("ProvinceDesc")
	            set dataObj.cityID = rs.%Get("CityID")
	            set dataObj.cityDesc = rs.%Get("CityDesc")
	            set dataObj.mdtrtArea = rs.%Get("MdtrtArea")
	            set dataObj.medinsLv = rs.%Get("MedinsLv")
	            set dataObj.scoreValue = rs.%Get("ScoreValue")
	            set dataObj.adjustCoefficient = rs.%Get("AdjustCoefficient")
	            set dataObj.primaryAdjustCoefficient = rs.%Get("PrimaryAdjustCoefficient")
	            set dataObj.secondaryAdjustCoefficient = rs.%Get("SecondaryAdjustCoefficient")
	            set dataObj.thirdAdjustCoefficient = rs.%Get("ThirdAdjustCoefficient")
	            set dataObj.averageCost = rs.%Get("AverageCost")
	            set bestRow = dataObj
	        }
	    }
	    
	    // 10. 封装返回结果 - 仅返回最佳匹配的一条记录
	    if (bestRow '= "")
	    {
	        do rows.%Push(bestRow)
	        set totalCount = 1
	    }
	    else
	    {
	        set totalCount = 0
	    }
	    
	    set resultObj = ..SetJarraySuccessResult(rows, totalCount)
	}
	catch(e)
	{
	    // 异常处理
	    set status = e.AsStatus()
	    set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
	    set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status, "cn"), "^", " ")
	    set errorInfo = "DIP分组分值查询异常：类=" _ $ClassName() _ "，入参=" _ jsonObj.%ToJSON() _ "，错误：" _ errorMsg
	    
	    // 记录错误日志
	    set errorLogID = ##class(src.Interface.Message).InsErrRecord("04000007", errorInfo, errorMsg)
	    set resultObj = ..SetErrorResult("-99", "DIP分组分值查询异常（日志ID："_errorLogID_"）："_errorMsg)
	}
	
	quit resultObj
}

/// 将分隔符分割的编码字符串拆分为$LIST列表
/// 支持：英文逗号"," 中文逗号"，" 分号";" 斜杠"/" 加号"+" 空格" "作为分隔符
ClassMethod SplitCodes(codeStr As %String) As %List
{
	if (codeStr = "")
	{
		quit ""
	}
	
	// 将所有分隔符统一替换为英文逗号
	set normalized = $TRANSLATE(codeStr, "，;/+ ", ",,,,,,")
	
	set list = ""
	set count = $LENGTH(normalized, ",")
	for i = 1:1:count
	{
		set oneCode = $ZSTRIP($PIECE(normalized, ",", i), "<>W")
		if (oneCode '= "")
		{
			set list = list _ $LISTBUILD(oneCode)
		}
	}
	quit list
}

/// 计算输入编码列表在存储字段中的匹配数量
/// 支持ICD编码层级：一方是另一方的前缀即视为匹配
/// inputList  : $LIST格式的入参编码列表
/// storedField: 表内存储的字段值（可能包含多个逗号分隔的编码）
/// 返回       : 匹配到的编码数量
ClassMethod CountCodeMatches(inputList As %List, storedField As %String) As %Integer
{
	if (inputList = "") || (storedField = "")
	{
		quit 0
	}
	
	// 将存储字段也拆分为列表
	set storedList = ..SplitCodes(storedField)
	set storedCount = $LISTLENGTH(storedList)
	if (storedCount = 0)
	{
		quit 0
	}
	
	set matchCount = 0
	set inputCount = $LISTLENGTH(inputList)
	
	// 逐个比较入参编码与存储编码（ICD层级匹配：前缀关系）
	for i = 1:1:inputCount
	{
		set oneInput = $LISTGET(inputList, i)
		if (oneInput = "") { continue }
		
		for j = 1:1:storedCount
		{
			set oneStored = $LISTGET(storedList, j)
			if (oneStored = "") { continue }
			
			// 双向前缀匹配：入参可能是存储编码的子类（如H25.900匹配H25.9），或反之
			if (..IsCodeMatch(oneInput, oneStored))
			{
				set matchCount = matchCount + 1
				quit  // 一个入参编码只匹配一次
			}
		}
	}
	quit matchCount
}

/// 判断两个ICD编码是否匹配（双向包含/前缀关系）
/// 入参H25.900 能匹配 存储的H25.9、H25（子类→父类）
/// 入参H25     能匹配 存储的H25.9、H25.001（父类→子类）
ClassMethod IsCodeMatch(code1 As %String, code2 As %String) As %Boolean
{
	if (code1 = "") || (code2 = "")
	{
		quit 0
	}
	
	// 精确相等直接匹配
	if (code1 = code2)
	{
		quit 1
	}
	
	// 双向包含判断：一方是另一方的子串
	// code1包含code2 → code2是code1的前缀（如code1=H25.900, code2=H25）
	if ($FIND(code1, code2) = ($LENGTH(code2) + 1))
	{
		quit 1
	}
	// code2包含code1 → code1是code2的前缀（如code1=H25, code2=H25.9）
	if ($FIND(code2, code1) = ($LENGTH(code1) + 1))
	{
		quit 1
	}
	
	quit 0
}

/// 构建多编码WHERE条件（OR组合）
/// fieldName: 表字段名
/// codeList : $LIST格式的编码列表
/// 支持ICD编码层级匹配：入参编码与存储编码双向包含（前缀关系）
ClassMethod BuildMultiCodeWhere(fieldName As %String, codeList As %List) As %String
{
	set codeCount = $LISTLENGTH(codeList)
	if (codeCount = 0)
	{
		quit ""
	}
	
	set where = " AND ("
	for i = 1:1:codeCount
	{
		set oneCode = $LISTGET(codeList, i)
		if (oneCode = "") { continue }
		
		if (i > 1)
		{
			set where = where _ " OR "
		}
		// 双向前缀匹配：支持ICD编码层级（如入参H25.900可匹配存储的H25.9、H25）
		set where = where _ " (INSTR("_fieldName_", '"_oneCode_"') > 0 "
		        _ " OR INSTR('"_oneCode_"', "_fieldName_") > 0) "
	}
	set where = where _ ")"
	quit where
}

/// Creator:     System
/// CreatDate:   2026-03-22
/// Description: 保存DRG分组记录（优化版 - 使用独立字段存储）
/// Table:       BS_DRGGroupRecord (User.BSDRGGroupRecord)
/// Code:        02010035
/// Input:       {"params":[{"admID":"","medcasNo":"","patientName":"","psnNo":"","insuranceAreaCode":"","insuType":"","sex":"","age":"","mainDiagnosisCode":"","mainDiagnosisName":"","diaTypeCode":"","diagnosisCode":"","diagnosisName":"","mainOperationCode":"","mainOperationName":"","department":"","departmentDesc":"","drg":"","drgDesc":"","weight":"","benchmarkCost":"","ccFlag":"","mccFlag":"","riskLevel":"","groupTime":"","fixmedinsCode":"","fixmedinsName":"","groupStage":"","admDateTime":"","discgDateTime":"","settleDateTime":"","remark":""}]}
/// Output:      {"errorCode":"0","errorMessage":"","result":{"id":123}}
ClassMethod SaveDRGGroupRecord(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
	new (jsonObj)
	set params = ##class(%DynamicArray).%New()	
    try
    {
        // 1. 初始化返回对象（标准化结构）
        set resultObj = ..SetSuccessResult("0","")
        
        // 2. 参数合法性校验（核心前置检查）
        if (jsonObj = "") || (jsonObj.params = "") 
        {
            set resultObj = ..SetErrorResult("-1", "入参异常：缺少params参数或参数为空")
            quit 
        } 	    	    	    
        
        // 3. 获取入参
        set params = jsonObj.params.%Get(0)
        set admID = $GET(params.admID, "")
        set medcasNo = $GET(params.medcasNo, "")           // 病案号
        set patientName = $GET(params.patientName, "")
        set psnNo = $GET(params.psnNo, "")                 // 医保个人编号
        set insuranceAreaCode = $GET(params.insuranceAreaCode, "")  // 参保地
        set mdtrtareaAreaCode = $GET(params.mdtrtareaAreaCode, "")  // 就医地
        
        set insuType = $GET(params.insuType, "")            // 医保险种
        set sex = $GET(params.sex, "")
        set age = $GET(params.age, "")
        set mainDiagnosisCode = $GET(params.mainDiagnosisCode, "")
        set mainDiagnosisName = $GET(params.mainDiagnosisName, "")
        set diaTypeCode = $GET(params.diaTypeCode, "")      // 主诊断类型编码
        set diagnosisCode = $GET(params.diagnosisCode, "")  // 病种编码
        set diagnosisName = $GET(params.diagnosisName, "")  // 病种名称
        set mainOperationCode = $GET(params.mainOperationCode, "")
        set mainOperationName = $GET(params.mainOperationName, "")
        set department = $GET(params.department, "")
        set departmentDesc = $GET(params.departmentDesc, "")  // 科室名称
        set drg = $GET(params.drg, "")
        set drgDesc = $GET(params.drgDesc, "")
        set weight = $GET(params.weight, "")
        set benchmarkCost = $GET(params.benchmarkCost, "")
        set ccFlag = $GET(params.ccFlag, "0")
        set mccFlag = $GET(params.mccFlag, "0")
        set riskLevel = $GET(params.riskLevel, "低")
        set groupTime = $GET(params.groupTime, "")
        set fixmedinsCode = $GET(params.fixmedinsCode, "")
        set fixmedinsName = $GET(params.fixmedinsName, "")
        set groupStage = $GET(params.groupStage, "1")      // 分组阶段 默认事前
        set admDateTime = $GET(params.admDateTime, "")        // 入院时间
        set discgDateTime = $GET(params.discgDateTime, "")    // 出院时间
        set settleDateTime = $GET(params.settleDateTime, "")  // 结算时间
        set remark = $GET(params.remark, "")                // 备注
        
        // 4. 必填项校验
        if (admID = "")
        {
            set resultObj = ..SetErrorResult("-1", "AdmID：HIS唯一就诊ID不能为空")
            quit 
        }
        if (drg = "")
        {            
            set resultObj = ..SetErrorResult("-1", "DRG：DRG编码不能为空")
            quit 
        }
        
        // 5. 使用类方法查找或创建记录
        set id=""
        set record={}       
        &sql(select ID into :id from BS_DRGGroupRecord where DRG=:drg and AdmID=:admID)	
	    set record = ##class(User.BSDRGGroupRecord).%OpenId(id)            
        
        set isNew = 0        
        if (record = "")
        {
            // 创建新记录
            set record = ##class(User.BSDRGGroupRecord).%New()
            set isNew = 1
            set record.AdmID = admID
            set record.CreateDate = +$Horolog
            set record.CreateTime = $Piece($Horolog, ",", 2)
            set record.ActiveFlag = "1"
        }
        else
        {
            // 更新现有记录 - 记录更新时间
            set record.UpdateDate = +$Horolog
            set record.UpdateTime = $Piece($Horolog, ",", 2)
        }
        
        // 6. 设置患者基本信息
        if (medcasNo '= "") set record.MedcasNo = medcasNo
        if (patientName '= "") set record.PatientName = patientName
        if (psnNo '= "") set record.PsnNo = psnNo
        if (insuranceAreaCode '= "") set record.InsuranceAreaCode = insuranceAreaCode
        if (mdtrtareaAreaCode '= "") set record.MdtrtareaAreaCode = mdtrtareaAreaCode
        if (insuType '= "") set record.InsuType = insuType
        if (sex '= "") set record.Sex = sex
        if (age '= "") set record.Age = age
        
        // 7. 设置诊断信息
        if (mainDiagnosisCode '= "") set record.MainDiagnosisCode = mainDiagnosisCode
        if (mainDiagnosisName '= "") set record.MainDiagnosisName = mainDiagnosisName
        if (diaTypeCode '= "") set record.DiaTypeCode = diaTypeCode
        if (diagnosisCode '= "") set record.DiagnosisCode = diagnosisCode
        if (diagnosisName '= "") set record.DiagnosisName = diagnosisName
        if (mainOperationCode '= "") set record.MainOperationCode = mainOperationCode
        if (mainOperationName '= "") set record.MainOperationName = mainOperationName
        if (department '= "") set record.Department = department
        if (departmentDesc '= "") set record.DepartmentDesc = departmentDesc
        
        // 8. 设置DRG分组结果（核心字段）
        set record.DRG = drg
        set record.DRGDesc = drgDesc
        set record.CCFlag = ccFlag
        set record.MCCFlag = mccFlag        
        
        // 数值型字段转换
        if (weight '= "") set record.Weight = +weight
        if (benchmarkCost '= "") set record.BenchmarkCost = +benchmarkCost
        
        // 分组时间解析
        if (groupTime '= "")
        {
            try {
                set record.GroupTime = $ZDATETIMEH(groupTime, 3)
            } catch {
                // 如果时间格式不正确，使用当前时间
                set record.GroupTime = $ZDATETIME($HOROLOG, 3)
            }
        }
        else
        {
            set record.GroupTime = $ZDATETIME($HOROLOG, 3)
        }
        
        // 9. 设置机构信息
        if (fixmedinsCode '= "") set record.FixmedinsCode = fixmedinsCode
        if (fixmedinsName '= "") set record.FixmedinsName = fixmedinsName
        
        // 10. 设置分组阶段和备注
        if (groupStage '= "") set record.GroupStage = groupStage
        if (remark '= "") set record.Remark = remark
        
        // 11. 设置就诊时间信息（入院时间、出院时间、结算时间）
        if (admDateTime '= "")
        {
            try {
                set record.AdmDateTime = $ZDATETIMEH(admDateTime, 3)
            } catch {
                set record.AdmDateTime = admDateTime
            }
        }
        if (discgDateTime '= "")
        {
            try {
                set record.DiscgDateTime = $ZDATETIMEH(discgDateTime, 3)
            } catch {
                set record.DiscgDateTime = discgDateTime
            }
        }
        if (settleDateTime '= "")
        {
            try {
                set record.SettleDateTime = $ZDATETIMEH(settleDateTime, 3)
            } catch {
                set record.SettleDateTime = settleDateTime
            }
        }
        
        // 11. 查询DRG指向（HB_DRGCoreAlgorithmData表）
        if (drg '= "")&&(mdtrtareaAreaCode '="")&&(fixmedinsCode '="")
        {
            set drgDr = ""
            &sql(SELECT ID INTO :drgDr FROM HB_DRGCoreAlgorithmData WHERE DRG = :drg and FixmedinsCode=:fixmedinsCode and MdtrtArea=:mdtrtareaAreaCode)
            if (drgDr '= "") set record.DRGDr = drgDr
        }
        
        // 10. 获取当前用户信息（从session）
        if ($DATA(jsonObj.session) && (jsonObj.session.%Size() > 0))
        {
            set session = jsonObj.session.%Get(0)
            if (isNew && (session.userId '= ""))
            {
                set record.CreateUserDr = session.userId
            }
            elseif (session.userId '= "")
            {
                set record.UpdateUserDr = session.userId
            }                       
        }
        
        // 12. 保存记录
        set sc = record.%Save()
        if ($$$ISERR(sc))
        {            
            set resultObj = ..SetErrorResult("-1", "保存记录失败："_StatusDisplayString(sc))
            quit 
        }
        
        // 12. 设置返回结果
        set resultObj=..SetSuccessResult("","保存成功")
        
    }
    catch(e)
    {
        set status = e.AsStatus()
        set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
        set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
        set errorInfo = "保存DRG分组记录异常：类=" _ $ClassName() _ "，错误：" _ errorMsg
        
        // 记录错误日志
        set errorLogID = ##class(src.Interface.Message).InsErrRecord("02010035", errorInfo, errorMsg)
        set resultObj.errorCode = "-99"
        set resultObj.errorMessage = "保存DRG分组记录异常（日志ID："_errorLogID_"）："_errorMsg
    }
    
    quit resultObj
}

/// Creator:     System
/// CreatDate:   2026-03-22
/// Description: 查询DRG分组记录表（优化版 - 使用对象查询）
/// Table:       BS_DRGGroupRecord (User.BSDRGGroupRecord)
/// Code:        02010036
/// Input:       {"params":[{"admID":"","medcasNo":"","patientName":"","psnNo":"","drg":"","mainDiagnosisCode":"","startDate":"","endDate":"","department":"","groupStage":"","admStartDate":"","admEndDate":"","discgStartDate":"","discgEndDate":"","settleStartDate":"","settleEndDate":""}],"pagination":{"pageSize":20,"currentPage":1}}
/// Output:      {"errorCode":"0","errorMessage":"","result":{"total":100,"rows":[{}]}}
ClassMethod QueryDRGGroupRecord(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    try
    {
    	new (postObj)
	    set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	    set pageSize="",currentPage=1,count=0,dataArr=[]

		if (postObj.%IsDefined("pagination")'=0) 
		{
	        set pagationObj=postObj.pagination.%Get(0)
			set pageSize=pagationObj.pageSize
		    set currentPage=pagationObj.currentPage
		}
        
        // 3. 获取查询条件
        set admID = $GET(params.admID, "")
        set medcasNo = $GET(params.medcasNo, "")
        set patientName = $GET(params.patientName, "")
        set psnNo = $GET(params.psnNo, "")
        set drg = $GET(params.drg, "")
        set mainDiagnosisCode = $GET(params.mainDiagnosisCode, "")
        set startDate = $GET(params.startDate, "")
        set endDate = $GET(params.endDate, "")
        set department = $GET(params.department, "")
        set groupStage = $GET(params.groupStage, "")
        // 就诊时间范围查询条件
        set admStartDate = $GET(params.admStartDate, "")
        set admEndDate = $GET(params.admEndDate, "")
        set discgStartDate = $GET(params.discgStartDate, "")
        set discgEndDate = $GET(params.discgEndDate, "")
        set settleStartDate = $GET(params.settleStartDate, "")
        set settleEndDate = $GET(params.settleEndDate, "")
        
        // 4. 构建SQL条件（使用参数化查询防止SQL注入）
        set sqlWhere = " WHERE ActiveFlag = '1'"
        set sqlParams = []
        
        if (admID '= "")
        {
            set sqlWhere = sqlWhere _ " AND AdmID = ?"
            do sqlParams.%Push(admID)
        }
        if (medcasNo '= "")
        {
            set sqlWhere = sqlWhere _ " AND MedcasNo = ?"
            do sqlParams.%Push(medcasNo)
        }
        if (patientName '= "")
        {
            set sqlWhere = sqlWhere _ " AND PatientName LIKE ?"
            do sqlParams.%Push("%"_patientName_"%")
        }
        if (psnNo '= "")
        {
            set sqlWhere = sqlWhere _ " AND PsnNo LIKE ?"
            do sqlParams.%Push("%"_psnNo_"%")
        }
        if (drg '= "")
        {
            set sqlWhere = sqlWhere _ " AND DRG = ?"
            do sqlParams.%Push(drg)
        }
        if (mainDiagnosisCode '= "")
        {
            set sqlWhere = sqlWhere _ " AND MainDiagnosisCode = ?"
            do sqlParams.%Push(mainDiagnosisCode)
        }
        if (department '= "")
        {
            set sqlWhere = sqlWhere _ " AND Department = ?"
            do sqlParams.%Push(department)
        }
        if (groupStage '= "")
        {
            set sqlWhere = sqlWhere _ " AND GroupStage = ?"
            do sqlParams.%Push(groupStage)
        }
        if (startDate '= "")
        {
            set sqlWhere = sqlWhere _ " AND CreateDate >= ?"
            do sqlParams.%Push($ZDATEH(startDate, 3))
        }
        if (endDate '= "")
        {
            set sqlWhere = sqlWhere _ " AND CreateDate <= ?"
            do sqlParams.%Push($ZDATEH(endDate, 3))
        }
        // 入院时间范围查询
        if (admStartDate '= "")
        {
            set sqlWhere = sqlWhere _ " AND AdmDateTime >= ?"
            do sqlParams.%Push($ZDATEH(admStartDate, 3))
        }
        if (admEndDate '= "")
        {
            set sqlWhere = sqlWhere _ " AND AdmDateTime <= ?"
            do sqlParams.%Push($ZDATEH(admEndDate, 3))
        }
        // 出院时间范围查询
        if (discgStartDate '= "")
        {
            set sqlWhere = sqlWhere _ " AND DiscgDateTime >= ?"
            do sqlParams.%Push($ZDATEH(discgStartDate, 3))
        }
        if (discgEndDate '= "")
        {
            set sqlWhere = sqlWhere _ " AND DiscgDateTime <= ?"
            do sqlParams.%Push($ZDATEH(discgEndDate, 3))
        }
        // 结算时间范围查询
        if (settleStartDate '= "")
        {
            set sqlWhere = sqlWhere _ " AND SettleDateTime >= ?"
            do sqlParams.%Push($ZDATEH(settleStartDate, 3))
        }
        if (settleEndDate '= "")
        {
            set sqlWhere = sqlWhere _ " AND SettleDateTime <= ?"
            do sqlParams.%Push($ZDATEH(settleEndDate, 3))
        }
        
        // 5. 查询总记录数
        set totalSql = "SELECT COUNT(*) AS total FROM BS_DRGGroupRecord" _ sqlWhere
        set stmt = ##class(%SQL.Statement).%New()
        set sc = stmt.%Prepare(totalSql)
        
        set total = 0
        if ($$$ISOK(sc))
        {
            set rs = stmt.%Execute(sqlParams...)
            if (rs.%Next())
            {
                set total = rs.total
            }
        }
        set resultObj.result.total = total
        
        // 6. 如果没有记录，直接返回
        if (total = 0)
        {
            return resultObj
        }
        
        // 7. 计算分页参数
        set page = $GET(currentPage, 1)
        set limit = $GET(pageSize, 20)
        set startRow = (page - 1) * limit
        
        // 8. 查询数据列表（使用对象方式构建返回结构）
        set dataSql = "SELECT ID FROM User.BSDRGGroupRecord " _ sqlWhere _ " ORDER BY CreateDate DESC, CreateTime DESC"
        set stmt = ##class(%SQL.Statement).%New()
        set sc = stmt.%Prepare(dataSql)
        
        set rows = []
        set rowIndex = 0
        set skipCount = 0
        
        if ($$$ISOK(sc))
        {
            set rs = stmt.%Execute(sqlParams...)
            
            while (rs.%Next())
            {
                set rowIndex = rowIndex + 1
                
                // 分页处理：跳过前面的记录
                if (rowIndex <= startRow)
                {
                    continue
                }
                
                // 限制返回数量
                if (rows.%Size() >= limit)
                {
                    quit
                }
                
                // 使用对象方式获取完整数据
                set record = ##class(User.BSDRGGroupRecord).%OpenId(rs.ID)
                if (record '= "")
                {
                    set row = {}
                    set row.id = record.%Id()
                    set row.admID = record.AdmID
                    set row.medcasNo = record.MedcasNo
                    set row.patientName = record.PatientName
                    set row.psnNo = record.PsnNo
                    set row.insuranceAreaCode = record.InsuranceAreaCode
                    set row.insuType = record.InsuType
                    set row.sex = record.Sex
                    set row.age = record.Age
                    
                    // 诊断信息
                    set row.mainDiagnosisCode = record.MainDiagnosisCode
                    set row.mainDiagnosisName = record.MainDiagnosisName
                    set row.diaTypeCode = record.DiaTypeCode
                    set row.diagnosisCode = record.DiagnosisCode
                    set row.diagnosisName = record.DiagnosisName
                    set row.mainOperationCode = record.MainOperationCode
                    set row.mainOperationName = record.MainOperationName
                    
                    // DRG分组结果
                    set row.drg = record.DRG
                    set row.drgDesc = record.DRGDesc
                    set row.weight = record.Weight
                    set row.benchmarkCost = record.BenchmarkCost
                    set row.ccFlag = record.CCFlag
                    set row.mccFlag = record.MCCFlag                    
                    set row.groupTime = $ZDATETIME(record.GroupTime, 3)
                    set row.groupStage = record.GroupStage
                    set row.remark = record.Remark
                    
                    // 科室信息
                    set row.department = record.Department
                    set row.departmentDesc = record.DepartmentDesc
                    
                    // 机构信息
                    set row.fixmedinsCode = record.FixmedinsCode
                    set row.fixmedinsName = record.FixmedinsName
                    
                    // 时间信息
                    set row.createDate = $ZD(record.CreateDate, 3)
                    set row.createTime = $ZT(record.CreateTime, 1)
                    set row.updateDate = $ZD(record.UpdateDate, 3)
                    set row.updateTime = $ZT(record.UpdateTime, 1)
                    
                    // 就诊时间信息
                    set row.admDateTime = ""
                    set row.discgDateTime = ""
                    set row.settleDateTime = ""
                    if (record.AdmDateTime '= "") set row.admDateTime = $ZDATETIME(record.AdmDateTime, 3)
                    if (record.DiscgDateTime '= "") set row.discgDateTime = $ZDATETIME(record.DiscgDateTime, 3)
                    if (record.SettleDateTime '= "") set row.settleDateTime = $ZDATETIME(record.SettleDateTime, 3)
                    
                    set count=count+1
                    if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
                    do rows.%Push(row)
                }
            }
        }

		set resultObj.result.rows=rows
		set resultObj.result.total=total
                
    }
    catch(e)
    {
        set status = e.AsStatus()
        set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
        set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
        set errorInfo = "查询DRG分组记录异常：类=" _ $ClassName() _ "，错误：" _ errorMsg
        
        // 记录错误日志
        set errorLogID = ##class(src.Interface.Message).InsErrRecord("02010036", errorInfo, errorMsg)
        set resultObj.errorCode = "-99"
        set resultObj.errorMessage = "查询DRG分组记录异常（日志ID："_errorLogID_"）："_errorMsg
    }
    
    quit resultObj
}

}
