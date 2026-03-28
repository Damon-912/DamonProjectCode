/// 角色菜单权限
Class src.Group.GroupMenuAuth Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     HYG
/// CreatDate:   2024-05-15
/// Description: 初始化	 
/// Debug:   w ##Class(src.Group.MenuDetail).GetInitialize({"params":[{"code":"","descripts":"","fieldClassID":""}],"code":"01010042","pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"Code","sortOrder":"asc"}]}).%ToJSON()
ClassMethod GetInitialize(postObj)
{
	new (postObj)
}

}
