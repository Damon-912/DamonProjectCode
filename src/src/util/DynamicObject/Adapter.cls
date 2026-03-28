/// Dynamic Object Adapter<br>
/// Provides ToDynamicObj andFromDynamicObj implementations to classes that derive from it.<br>
/// Note: All properties of the class which derives from this adapter where the properties themselves are reference types <br>
/// 			to other objects need to have those objects' types also extend this adapter class - This is due to the Adapter<br>
/// 		calling ToDynamicObj/FromDynamicObj object on those instances to provide representation/consumption of the dynamic object.<br>
/// ToDynamicObj functionality provided through inheritance of src.util.DynamicObject.AdapterToDynamicObj<br>
/// FromDynamicObj functionality provided through inheritance of src.util.DynamicObject.AdapterFromDynamicObj<br>
/// 
/// 不可编译
/// Class src.util.DynamicObject.Adapter Extends (src.util.DynamicObject.AdapterToDynamicObj, src.util.DynamicObject.AdapterFromDynamicObj, src.util.ObjToSQL.operatetableadapter) [ Abstract ]
Class src.util.DynamicObject.Adapter Extends (src.util.DynamicObject.AdapterToDynamicObj, src.util.DynamicObject.AdapterFromDynamicObj, %JSON.Adaptor) [ Abstract ]
{

}
