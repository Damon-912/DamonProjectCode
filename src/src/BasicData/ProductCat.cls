/// 产品分类相关
Class src.BasicData.ProductCat Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// w ##class(src.BasicData.ProductCat).GetProductCat().%ToJSON()
ClassMethod GetProductCat() As %Library.DynamicObject
{
	new
    try{
	    set errorCode=0,errorMessage="成功",dataArr=[]
        set id=0
        for{
            set id=$o(^CBProductCatD(+id))
            quit:id=""
            set itemData=$g(^CBProductCatD(+id))
            continue:itemData=""
            set item={}
            set item.id=id
            set item.code=$lg(itemData,3)
            set item.descripts="("_$lg(itemData,3)_")"_$lg(itemData,4)
            set item.enDescripts=$lg(itemData,5)
            set item.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(item.descripts)
            do dataArr.%Push(item)
        }
    }catch(e){
	    set dataArr=[]
    }
    set retObj={
        "errorCode":(errorCode),
        "errorMessage":(errorMessage),
        "result":(dataArr)
   	}
    quit retObj
}

/// w ##class(src.BasicData.ProductCat).GetProductModule({"params":[{"productCatID":10}]}).%ToJSON()
ClassMethod GetProductModule(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
    try{
	    set errorCode=0,errorMessage="成功",dataArr=[]
	    set productCatID=jsonObj.params.%Get(0).productCatID
	    quit:productCatID=""
        set id=0
        for{
            set id=$o(^CBProductModuleD(+id))
            quit:id=""
            set itemData=$g(^CBProductModuleD(+id))
            continue:itemData=""
            continue:productCatID'=$lg(itemData,4)
            set item={}
            set item.id=id
            set item.code=$lg(itemData,2)
            set item.descripts="("_$lg(itemData,2)_")"_$lg(itemData,3)
            set item.enDescripts=$lg(itemData,5)
            set item.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(item.descripts)
            do dataArr.%Push(item)
        }
    }catch(e){
	    set dataArr=[]
    }
    set retObj={
        "errorCode":(errorCode),
        "errorMessage":(errorMessage),
        "result":(dataArr)
   	}
    quit retObj
}

}
