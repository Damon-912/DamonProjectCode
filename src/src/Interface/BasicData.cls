Import SQLUser

///      Author: TT<br>
///   CreatDate: 2018-12-28<br>
/// Description: 获取基础数据类<br>
Class src.Interface.BasicData Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

///      Author: LYF<br>
///   CreatDate: 2019-03-14<br>
/// Description: 获取产品模块信息<br>
///      Remark: 只返回描述及ID、主要用于下拉选项<br>
ClassMethod GetProductModule() As %Library.DynamicAbstractObject
{
	;##class(src.Interface.BasicData).GetCBMarital()
	new 
	
	set modelData=[]
	set catId=0
	for{
		set catId=$o(^CBProductModuleI("ProductCat",catId))	
		Quit:catId=""
		set startDate=$lg(^CBProductCatD(catId),6)
		set endDate=$lg(^CBProductCatD(catId),7)
		set id=0
		for{
			set id=$o(^CBProductModuleI("ProductCat",catId,id))
			Quit:id=""	
			set data=$g(^CBProductModuleD(id))
			set startDate=$lg(data,6)
			set endDate=$lg(data,7)
			set descripts=$lg(data,3)
			set enDescripts=$lg(data,5)
			set descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(descripts)
			set itemData={}
			set itemData.id=id
			set itemData.descripts=descripts
			set itemData.enDescripts=enDescripts
			set itemData.descriptsSPCode=descriptsSPCode
			set itemData.catDr=catId
			do modelData.%Push(itemData)
		}
	}
	Quit modelData
}

///      Author: LYF<br>
///   CreatDate: 2019-03-14<br>
/// Description: 获取产品分类信息<br>
///      Remark: 只返回描述及ID、主要用于下拉选项<br>
ClassMethod GetProductCat() As %Library.DynamicAbstractObject
{
	;##class(src.Interface.BasicData).GetProductCat()
	new 
	
	set modelData=[]
	set id=0
	for{
		set id=$o(^CBProductCatD(id))	
		Quit:id=""
		set itemData=$g(^CBProductCatD(id))
		set descripts=$lg(itemData,4)
		set enDescripts=$lg(itemData,5)
		set descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(descripts)
		set itemData={}
		set itemData.id=id
		set itemData.descripts=descripts
		set itemData.enDescripts=enDescripts
		set itemData.descriptsSPCode=descriptsSPCode
		do modelData.%Push(itemData)
	}
	Quit modelData
}

}
