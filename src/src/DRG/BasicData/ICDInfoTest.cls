Class src.DRG.BasicData.ICDInfoTest Extends %RegisteredObject
{

/// 测试Base64解码和中文字符处理
ClassMethod TestBase64Decoding() As %Library.DynamicObject
{
    set resultObj = {"errorCode":"0","errorMessage":"","result":{}}
    
    // 测试数据 - 包含中文字符的Base64
    set fileData = "SUNEQ29kZSxJQ0REZXNjLFZlcnNpb24sU3RhcnREYXRlLEVuZERhdGUsUmVtYXJrDQpRUTEsuf65/ixJQ0QtMTAsMjAyNC8xLzEsMjA5OS8xMi8zMSxOYXRpb25hbCBTdGFuZGFyZA0KUVEyLLrHuscsSUNELTEwLDIwMjQvMS8xLCwNCg=="
    
    // 方法1: $zcvt直接解码
    try {
        set result1 = $zcvt(fileData, "I", "BASE64")
        set resultObj.result.method1 = result1
        set resultObj.result.method1Length = $length(result1)
    } catch e1 {
        set resultObj.result.method1Error = $system.Status.GetErrorText(e1.AsStatus())
    }
    
    // 方法2: %SYSTEM.Encryption.Base64Decode
    try {
        set binaryData = ##class(%SYSTEM.Encryption).Base64Decode(fileData)
        set resultObj.result.method2Binary = binaryData
        set resultObj.result.method2BinaryLength = $length(binaryData)
        
        // 尝试UTF-8转换
        try {
            set result2 = $zcvt(binaryData, "I", "UTF8")
            set resultObj.result.method2UTF8 = result2
            set resultObj.result.method2UTF8Length = $length(result2)
        } catch e2utf8 {
            set resultObj.result.method2UTF8Error = $system.Status.GetErrorText(e2utf8.AsStatus())
        }
    } catch e2 {
        set resultObj.result.method2Error = $system.Status.GetErrorText(e2.AsStatus())
    }
    
    // 方法3: 尝试不同的编码
    try {
        set binaryData = ##class(%SYSTEM.Encryption).Base64Decode(fileData)
        // 不转换，直接使用
        set resultObj.result.method3Direct = binaryData
    } catch e3 {
        set resultObj.result.method3Error = $system.Status.GetErrorText(e3.AsStatus())
    }
    
    quit resultObj
}

}
