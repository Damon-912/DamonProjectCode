/// Author:      gjg
/// Data:        2022-2-17
/// Descripts:   封装的SQL工具
Class src.util.SQLUtil Extends (%RegisteredObject, %XML.Adaptor, %JSON.Adaptor) [ Not ProcedureBlock ]
{

/// 获得SQL执行对象，针对比较灵活的取值
/// params: sql （sql语句） sqlType（sql模式   0：逻辑模式  1：odbc模式 2：显示模式） 默认1
ClassMethod SqlBase(sql, sqlType = "")
{
	new (sql,sqlType)
	if (sqlType'=""){
		set st = ##class(%SQL.Statement).%New(sqlType)
	}else{
		set st = ##class(%SQL.Statement).%New(1)
	}
	set status = st.%Prepare(sql)
	if status'=1 {
		quit ##class(src.util.ResultSet).StatusFail(status)
	}
	set rset = st.%Execute()
	quit ##class(src.util.ResultSet).Success(rset)
}

/// 获取sql结果列表数据
/// params: sql （sql语句）pagination （分页） sqlType（sql模式   0：逻辑模式  1：odbc模式 2：显示模式）  默认1
/// 列名采用将字段名（AbAc=>abAc,AbAc_Dr=>abAcID）,sql取别名时不要和转换的名字冲突，否则会被覆盖。暂存问题：分页查询内不能再自定义continue条件，只能用SQL实现。待优化
/// w ##class(src.util.SQLUtil).SqlForList("select * from HB_User",{"pageSize":10,"currentPage":2}).%ToJSON()
ClassMethod SqlForList(sql, pagination = "", sqlType = "")
{
	new (sql,pagination,sqlType)
	set count=0,rows=[]
	if (pagination'=""){
		set pageSize=pagination.pageSize
		set currentPage=pagination.currentPage
		if ((pageSize<=0)||(pageSize="")||(currentPage<=0)||(currentPage="")){
			quit ##class(src.util.ResultSet).FailInfoByCode("03000004")
		}
		//set sort=pagination.sort
		//set dir=pagination.dir
		set start=((currentPage-1)*pageSize)+1
		set end=currentPage*pageSize
	}

	if (sqlType'=""){
		set st = ##class(%SQL.Statement).%New(sqlType)
	}else{
		set st = ##class(%SQL.Statement).%New(1)
	}
	set status = st.%Prepare(sql)
	if status'=1 {
		quit ##class(src.util.ResultSet).StatusFail(status)
	}
	set rset = st.%Execute()
	set rsmeta=rset.%GetMetadata()
	//set maxIndex=rsmeta.columns.Count()
	//获取列名，并对字段进行修改
	set colArr=[""],index=1
	while rsmeta.columns.GetAt(index) {
		set colName=rsmeta.columns.GetAt(index).colName
		//ID 字段处理为表名加ID
		if (colName'="ID"){
			if ($find(colName,"_")'=0){
				set colName=$p(colName,"_",1)_"ID"
			}
			set colName=$zcvt($e(colName,1),"L")_$e(colName,2,*)
		}else{
			set tabNameID=rsmeta.columns.GetAt(index).tableName
			set colName=$p(tabNameID,"_",2)_"ID"
			set colName=$zcvt($e(colName,1),"L")_$e(colName,2,*)
		}
		set index=index+1 
		do colArr.%Push(colName)
	}
	//获取数据，根据顺序set数据
	while rset.%Next(){
		set dataObj={}
		for i=1:1:colArr.%Size()-1{
			set colName=colArr.%Get(i)
			set colData=rset.%GetData(i)
			do dataObj.%Set(colName,colData)
		}
		set count=count+1
		if (pagination'=""){
			continue:count<start
			continue:count>end
		}
		do rows.%Push(dataObj)
	}
	quit ##class(src.util.ResultSet).Success({"total":(count),"rows":(rows)})
}

/// 获得sql结果的单个对象
/// params: sql （sql语句） sqlType（sql模式   0：逻辑模式  1：odbc模式 2：显示模式）  默认1
/// 列名采用将字段名（AbAc=>abAc,AbAc_Dr=>abAcID）,sql取别名时不要和转换的名字冲突，否则会被覆盖。
/// 如果查询结果是多条数据只取第一条。
/// w ##class(src.util.SQLUtil).SqlForObject("select * from HB_User").%ToJSON()
ClassMethod SqlForObject(sql, sqlType = "")
{
	new (sql,sqlType)
	set result={}
	if (sqlType'=""){
		set st = ##class(%SQL.Statement).%New(sqlType)
	}else{
		set st = ##class(%SQL.Statement).%New(1)
	}
	set status = st.%Prepare(sql)
	if status'=1 {
		quit ##class(src.util.ResultSet).StatusFail(status)
	}
	set rset = st.%Execute()
	set rsmeta=rset.%GetMetadata()
	//set maxIndex=rsmeta.columns.Count()
	//获取列名，并对字段进行修改
	set colArr=[""],index=1
	while rsmeta.columns.GetAt(index) {
		set colName=rsmeta.columns.GetAt(index).colName
		//ID 字段处理为表名加ID
		if (colName'="ID"){
			if ($find(colName,"_")'=0){
				set colName=$p(colName,"_",1)_"ID"
			}
			set colName=$zcvt($e(colName,1),"L")_$e(colName,2,*)
		}else{
			set tabNameID=rsmeta.columns.GetAt(index).tableName
			set colName=$p(tabNameID,"_",2)_"ID"
			set colName=$zcvt($e(colName,1),"L")_$e(colName,2,*)
		}
		set index=index+1 
		do colArr.%Push(colName)
	}
	//获取数据，根据顺序set数据
	while rset.%Next(){
		for i=1:1:colArr.%Size()-1{
			set colName=colArr.%Get(i)
			set colData=rset.%GetData(i)
			do result.%Set(colName,colData)
		}
		quit
	}
	quit ##class(src.util.ResultSet).Success(result)
}

}
