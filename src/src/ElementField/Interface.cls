Class src.ElementField.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     HYG
/// CreatDate:   2024-05-15
/// Description: 初始化公共元素集
/// code: 01010050
ClassMethod GetInitialize(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.ElementField.CBElementField).GetInitialize(postObj)
}

/// Creator:     HYG
/// CreatDate:   2024-05-15
/// Description: 查询公共元素集分页
/// code: 01010042
ClassMethod FindCBElementField(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.ElementField.CBElementField).FindCBElementField(postObj)
}

/// Creator:     HYG
/// CreatDate:   2024-05-15
/// Description: 保存公共元素集
/// code: 01010043
ClassMethod AddCBElementField(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.ElementField.CBElementField).AddCBElementField(postObj)
}

}
