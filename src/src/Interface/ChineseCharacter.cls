Import Sqluser

///      Author: HYG<br>
///   CreatDate: 2022-06-28<br>
/// Description: 汉字信息处理类<br>
Class src.Interface.ChineseCharacter Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

///      Author: HYG<br>
///   CreatDate: 2022-06-28<br>
/// Description: 根据汉字获取拼音首拼(多音字按读音个数组织)<br>
///       Input: 汉字符串  <br>
///      Output: 返回首拼  使用 # 分隔<br>
/// w ##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew("买参参参参吗")
/// MCCCCM^MCCCSM^MCCSCM^MCCSSM^MCSCCM^MCSCSM^MCSSCM^MCSSSM^MSCCCM^MSCCSM^MSCSCM^MSCSSM^MSSCCM^MSSCSM^MSSSCM^MSSSSM
/// w ##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew("人参")
ClassMethod GetSPCodeByDescNew(Chinese)
{
	new (Chinese)
	set outPut=""
	quit:$g(Chinese)="" outPut
	set Chinese=$system.SQL.ALPHAUP(Chinese)
	
	;ArrayChi 记录汉字首拼
	;ArrayChin 记录总的返回串数
	;ArrayCh 中间临时数组
	kill ArrayChi
	set ArrayChin(1)="" ; 记录总返回串数
	for i=1:1:$l(Chinese) do
	.set chin=$e(Chinese,i)
	.if $d(^CBChineseCharacterI("Character",chin))=0 do
	..set ArrayChi(i)=$ZCVT(chin,"U")
	.else  do
	..set rowid=""
	..for  set rowid=$o(^CBChineseCharacterI("Character",chin,rowid)) quit:rowid=""  do
	...quit:rowid=0
	...set pinyinsp=$lg(^CBChineseCharacterD(rowid),5)
	...if $g(ArrayChi(i))="" set ArrayChi(i)=pinyinsp
	...else  set:ArrayChi(i)'[pinyinsp ArrayChi(i)=ArrayChi(i)_"^"_pinyinsp
	..set num=$l(ArrayChi(i),"^")
	..for j=1:1:($o(ArrayChin(""),-1)*num) do
	...set ArrayChin(j)=""
	
	; 转换算法
	kill ArrayCh
	set i=0,num=$o(ArrayChin(""),-1)
	set total=num
	for  set i=$o(ArrayChi(i)) quit:i=""  do
	.set shang=num\$l(ArrayChi(i),"^")
	.for j=1:1:total do
	..q:$p(ArrayChi(i),"^",((j-1)\shang+1))=""
	..set $p(ArrayCh(i),"^",j)=$p(ArrayChi(i),"^",((j-1)\shang+1))
	.if $l(ArrayCh(i),"^")'=total do
	..set linshi=ArrayCh(i)
	..for j=1:1:(total\$l(ArrayCh(i),"^")-1) do
	...set ArrayCh(i)=ArrayCh(i)_"^"_linshi
	.set num=shang
	
	for i=1:1:total do
	.set rowid="",tempstr=""
	.for  set rowid=$o(ArrayCh(rowid)) quit:rowid=""  do
	..if tempstr="" set tempstr=$p(ArrayCh(rowid),"^",i)
	..else  set tempstr=tempstr_$p(ArrayCh(rowid),"^",i)
	.if outPut="" set outPut=tempstr
	.else  set outPut=outPut_"^"_tempstr
	quit outPut
}

///      Author: TT<br>
///   CreatDate: 2018-12-25<br>
/// Description: 根据汉字获取拼音全拼(多音字全返)<br>
///       Input: 汉字符串  买人参吗<br>
///      Output: 返回全拼  MAI^REN^CAN#CEN#SHEN^MA <br>
///              w ##class(src.Interface.ChineseCharacter).GetQPCodeByDesc("买人参吗")
ClassMethod GetQPCodeByDesc(Chinese)
{
	new (Chinese)
	set outPut=""
	quit:$g(Chinese)="" outPut
	
	for i=1:1:$l(Chinese) do
	.set chin=$e(Chinese,i)
	.if $d(^CBChineseCharacterI("Character",chin))=0 do
	..if outPut="" set outPut="?"
	..else  set outPut=outPut_"^"_"?"
	.else  do
	..set rowid="",tempStr=""
	..for  set rowid=$o(^CBChineseCharacterI("Character",chin,rowid)) quit:rowid=""  do
	...quit:rowid=0
	...set pinyinqp=$lg(^CBChineseCharacterD(rowid),4)
	...if tempStr="" set tempStr=pinyinqp
	...else  set tempStr=tempStr_"#"_pinyinqp
	..if outPut="" set outPut=tempStr
	..else  set outPut=outPut_"^"_tempStr
	
	quit outPut
}

///      Author: TT<br>
///   CreatDate: 2018-12-25<br>
/// Description: 根据汉字获取拼音全拼(多音字全返)<br>
///       Input: 汉字符串  买人参吗<br>
///      Output: 返回全拼  MAI^REN^CAN#CEN#SHEN^MA <br>
///              w ##class(src.Interface.ChineseCharacter).GetQPLinkCodeByDesc("买人参吗")
ClassMethod GetQPLinkCodeByDesc(Chinese)
{
	new (Chinese)
	set outPut=""
	quit:$g(Chinese)="" outPut
	
	for i=1:1:$l(Chinese) do
	.set chin=$e(Chinese,i)
	.if $d(^CBChineseCharacterI("Character",chin))=0 do
	..set pingi="?"
	..if (($a(chin)>64)&&($a(chin)<123))  do
	...set pingi=chin
	..set outPut=outPut_pingi
	..//if outPut="" set outPut=pingi
	..//else  set outPut=outPut_pingi
	.else  do
	..set rowid=$o(^CBChineseCharacterI("Character",chin,""))
	..quit:rowid=0
	..set pinyinqp=$lg(^CBChineseCharacterD(rowid),4)
	..if outPut="" set outPut=pinyinqp
	..else  set outPut=outPut_pinyinqp
	
	quit outPut
}

}
