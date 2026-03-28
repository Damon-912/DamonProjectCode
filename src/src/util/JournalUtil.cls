/// gjg
/// 2022-7-8
/// 日志工具类   复原数据
Class src.util.JournalUtil Extends (%RegisteredObject, %XML.Adaptor, %JSON.Adaptor) [ Not ProcedureBlock ]
{

/// filePath ：messagement portal中 系统 > Journals > 查看 Journal  根据日期获取url地址
/// globalName ： 需要修改的global名字   例如：^CBMessageD    暂不支持父子表， 不要改索引global
/// type ： 为空全部修改，INSERT 只复原新增的 UPDATE  只复原更新的  DELETE   只复原删除的
/// 如果只修改部分global，精确修改时，可以查询到偏移量范围然后修改  startRecord 开始偏移量  endRecord 结束偏移量
/// w ##class(src.util.Encryption).RestoreDataByJournal()
ClassMethod RestoreDataByJournal(filePath, globalName, type = "", startRecord = "", endRecord = "") As %String
{
	new (filePath,globalName,type,startRecord,endRecord)
	quit:filePath="" -1
	quit:globalName="" -1
	set jrnforef = ##class(%SYS.Journal.File).%OpenId(filePath)
	set firstAddress=jrnforef.FirstRecord.Address    ;初始偏移量
	set lastAddress=jrnforef.LastRecord.Address      ;最终偏移量
	set curRecord=jrnforef.FirstRecord               
	while (curRecord){
		//获取当前偏移量
		set address=curRecord.Address
		if ((startRecord'="")&&(address<startRecord)){
			set curRecord=curRecord.NextGet()
			continue
		}
		if ((endRecord'="")&&(address>endRecord)){
			set curRecord=curRecord.NextGet()
			continue
		}
		//类型，存在SET(新增和修改)和KILL(删除)
		set typeName=curRecord.TypeName
		if ((typeName="")||((typeName'="SET")&&(typeName'="KILL"))){
			set curRecord=curRecord.NextGet()
            continue
		}
        set global=curRecord.GlobalNode   ;global节点
		if (global'[globalName){
			set curRecord=curRecord.NextGet()
            continue
		}
		Set jrecoref = ##class(%SYS.Journal.Record).%OpenId(address)
		s node=$p($p(global,"(",2),")")
		if (node=""){
			set curRecord=curRecord.NextGet()
			continue
		}
		
		set oldValue=jrecoref.OldValue
		set newValue=jrecoref.NewValue
		if (type=""){
			//全修改
			if ((oldValue'="")&&(newValue'="")){
				//新值旧值都有，更新，恢复旧值
				xecute "set "_globalName_"(node)=jrecoref.OldValue"
				set curRecord=curRecord.NextGet()
	        	continue
			}
			if ((oldValue'="")&&(newValue="")){
				//删除的数据，重新添加
				xecute "set "_globalName_"(node)=jrecoref.OldValue"
				set curRecord=curRecord.NextGet()
	        	continue
			}
			if ((oldValue="")&&(newValue'="")){
				//新增的数据，删除
				xecute "k ^CBMessageD(node)"
				set curRecord=curRecord.NextGet()
	        	continue
			}
		}else{
			//只修改新增的
			if (type="INSERT"){
				if ((oldValue="")&&(newValue'="")){
					//新增的数据，删除
					xecute "k ^CBMessageD(node)"
					set curRecord=curRecord.NextGet()
		        	continue
				}
			}
			if (type="DELETE"){
				if ((oldValue'="")&&(newValue="")){
					//删除的数据，重新添加
					xecute "set "_globalName_"(node)=jrecoref.OldValue"
					set curRecord=curRecord.NextGet()
		        	continue
				}
			}
			if (type="UPDATE"){
				if ((oldValue'="")&&(newValue'="")){
					//新值旧值都有，更新，恢复旧值
					xecute "set "_globalName_"(node)=jrecoref.OldValue"
					set curRecord=curRecord.NextGet()
		        	continue
				}
			}
		}
		set curRecord=curRecord.NextGet()
	}
	set sc= jrnforef.%Close()  
	quit 0
}

}
