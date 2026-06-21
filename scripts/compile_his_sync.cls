# HIS数据同步方案 - IRIS 编译脚本（修复版）
# 在 IRIS 终端中执行此脚本

# ========== 1. 编译表类 ==========
write "========== 编译表类 ==========",!
set tSC = $system.OBJ.Compile("User.BSHISPatAdm", "ck")
write "User.BSHISPatAdm: ",$select($$$ISERR(tSC):"❌ 编译失败",1:"✅ 编译成功"),!

set tSC = $system.OBJ.Compile("User.BSHISDRGParams", "ck")
write "User.BSHISDRGParams: ",$select($$$ISERR(tSC):"❌ 编译失败",1:"✅ 编译成功"),!

set tSC = $system.OBJ.Compile("User.BSHISOprnInfo", "ck")
write "User.BSHISOprnInfo: ",$select($$$ISERR(tSC):"❌ 编译失败",1:"✅ 编译成功"),!

set tSC = $system.OBJ.Compile("User.BSHISSyncLog", "ck")
write "User.BSHISSyncLog: ",$select($$$ISERR(tSC):"❌ 编译失败",1:"✅ 编译成功"),!

set tSC = $system.OBJ.Compile("User.BSHISDiseInfo", "ck")
write "User.BSHISDiseInfo: ",$select($$$ISERR(tSC):"❌ 编译失败",1:"✅ 编译成功"),!

# ========== 2. 编译业务类 ==========
write !,"========== 编译业务类 ==========",!
set tSC = $system.OBJ.Compile("src.DRG.HISData.HisDataService", "ck")
write "src.DRG.HISData.HisDataService: ",$select($$$ISERR(tSC):"❌ 编译失败",1:"✅ 编译成功"),!

set tSC = $system.OBJ.Compile("src.DRG.HISData.DataMapper", "ck")
write "src.DRG.HISData.DataMapper: ",$select($$$ISERR(tSC):"❌ 编译失败",1:"✅ 编译成功"),!

set tSC = $system.OBJ.Compile("src.DRG.HISData.SyncEngine", "ck")
write "src.DRG.HISData.SyncEngine: ",$select($$$ISERR(tSC):"❌ 编译失败",1:"✅ 编译成功"),!

set tSC = $system.OBJ.Compile("src.DRG.HISData.ConfigService", "ck")
write "src.DRG.HISData.ConfigService: ",$select($$$ISERR(tSC):"❌ 编译失败",1:"✅ 编译成功"),!

# ========== 3. 编译REST调度类 ==========
write !,"========== 编译REST调度类 ==========",!
set tSC = $system.OBJ.Compile("src.Rest.DRGHisInvoke", "ck")
write "src.Rest.DRGHisInvoke: ",$select($$$ISERR(tSC):"❌ 编译失败",1:"✅ 编译成功"),!

# ========== 4. 显示编译结果 ==========
write !,"========== 编译完成 ==========",!
write "如有编译失败，请复制错误信息反馈。",!

# ========== 5. 简单测试 ==========
write !,"========== 简单测试 ==========",!
try {
    set tObj = ##class(src.DRG.HISData.ConfigService).%New()
    write "✅ ConfigService 实例化成功",!
} catch tEx {
    write "❌ ConfigService 实例化失败: ",tEx.DisplayString(),!
}

try {
    set tObj = ##class(src.DRG.HISData.DataMapper).%New()
    write "✅ DataMapper 实例化成功",!
} catch tEx {
    write "❌ DataMapper 实例化失败: ",tEx.DisplayString(),!
}

try {
    set tObj = ##class(src.DRG.HISData.SyncEngine).%New()
    write "✅ SyncEngine 实例化成功",!
} catch tEx {
    write "❌ SyncEngine 实例化失败: ",tEx.DisplayString(),!
}

try {
    set tObj = ##class(src.DRG.HISData.HisDataService).%New()
    write "✅ HisDataService 实例化成功",!
} catch tEx {
    write "❌ HisDataService 实例化失败: ",tEx.DisplayString(),!
}

write !,"请检查以上输出，如有错误请反馈。",!
