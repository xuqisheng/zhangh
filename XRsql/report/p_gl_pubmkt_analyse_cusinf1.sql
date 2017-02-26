if object_id('p_gl_pubmkt_analyse_cusinf1') is not null
	drop proc p_gl_pubmkt_analyse_cusinf1
;
create proc p_gl_pubmkt_analyse_cusinf1
	@no			char(7),
	@begin_		datetime,
	@end_			datetime
as
-------------------------------------------------------------------------------
--	协议单位业绩报表 - 按离日/明细
-------------------------------------------------------------------------------

create table #gout
(
	no				char(7)					not null,	--  单位号码
	sno			char(15)					null,
	name			varchar(60)				not null,
	actcls		char(1)					not null,
	actno			char(10)					not null,	--  前台账号，或者餐饮账号
	haccnt		char(7)	default ''	not null,
	gstname		varchar(60)				null,	
	arr			datetime					null,
	dep			datetime					null,
	roomno		char(5)					null,			--  房号，桌号
	rate			money		default 0	null,			--  房价
	rm				money		default 0	not null,	--  房费
	gstno			money		default 0	not null,	--  餐费
	days			money		default 0	not null,	--  人数
	fb				money		default 0	not null,	--  间天
	en				money		default 0	not null,	--  康乐
	ot				money		default 0	not null,	--  其他
	tl				money		default 0	not null		--  合计
)

if @begin_ is null
	select @begin_ = '1980/1/1'
if @end_ is null
	select @end_ = '2020/1/1'
if rtrim(@no) is null
	select @no = '%'
   
--  插入明细记录
insert #gout (no, sno, name, actcls, actno, haccnt, gstname, arr, dep, roomno, fb)
	select cusno , setmodes, paid, 'P', menu, '', '', bdate, bdate, tableno, amount
	from pos_hmenu Where bdate >= @begin_ and bdate <= @end_ and cusno like @no
delete #gout where name <> '1' or sno in ('986', '986*')
-- delete #gout where name <> '1' or sno in ('986', '986*', '988', '988*')
-- 
insert #gout (no, sno, name, actcls, actno, haccnt, gstname, arr, dep, roomno, rate)
	select cusno , sta, '', class, accnt, haccnt, '', arr, dep, roomno, setrate
	from hmaster Where cusno like @no and dep >= @begin_ and dep <= @end_ and cusno <> ''
insert #gout (no, sno, name, actcls, actno, haccnt, gstname, arr, dep, roomno, rate)
	select agent , sta, '', class, accnt, haccnt, '', arr, dep, roomno, setrate
	from hmaster Where agent like @no and dep >= @begin_ and dep <= @end_ and agent <> ''
insert #gout (no, sno, name, actcls, actno, haccnt, gstname, arr, dep, roomno, rate)
	select source , sta, '', class, accnt, haccnt, '', arr, dep, roomno, setrate
	from hmaster Where source like @no and dep >= @begin_ and dep <= @end_ and source <> ''
-- 
delete #gout where sno in ('X', 'N')
update #gout set gstname = a.name from guest a where #gout.haccnt=a.no
update #gout set sno=a.sno, name = a.name from guest a where #gout.no=a.no
-- 
update #gout set days = days + a.amount2 from master_income a where a.accnt = #gout.actno and a.pccode in ('000', 'rm')
update #gout set rm = rm + isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #gout.actno and a.pccode = b.pccode and b.deptno7 = 'rm'), 0)
update #gout set fb = fb + isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #gout.actno and a.pccode = b.pccode and b.deptno7 = 'fb'), 0)
update #gout set en = en + isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #gout.actno and a.pccode = b.pccode and b.deptno7 = 'en'), 0)
update #gout set ot = ot + isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #gout.actno and a.pccode = b.pccode and b.deptno7 = 'ot'), 0)
--  JJH
update #gout set rm = rm + isnull((select sum(a.amount1) from master_income a where a.accnt = #gout.actno and a.pccode = 'rm'), 0)
update #gout set fb = fb + isnull((select sum(a.amount1) from master_income a where a.accnt = #gout.actno and a.pccode = 'fb'), 0)
update #gout set en = en + isnull((select sum(a.amount1) from master_income a where a.accnt = #gout.actno and a.pccode = 'en'), 0)
update #gout set ot = ot + isnull((select sum(a.amount1) from master_income a where a.accnt = #gout.actno and a.pccode = 'ot'), 0)
update #gout set tl = rm + fb + en + ot
--  输出
select actno,gstname,arr,dep,roomno,rate,days,rm,fb,en,ot,tl,no+'-'+sno+'-'+name
	from #gout order by actno,arr

return 0
;

/*
_com_p_协议单位消费明细报告(按离日);
(exec p_gl_pubmkt_analyse_cusinf1 '#char07!请输入协议单位代码<----必须输入>#','#date1!请输入起始日期!#Bdate1##','#date2!请输入终止日期!#Bdate1##','t' resultset=char10,char60,date11,date12,char05,mone10_1,mone10_2,mone10_3,mone10_5,mone10_6,mone10_7,mone10_8,char80);
char10:账号=8;char60:姓名=20;date11:到日=7=yy/mm/dd=alignment="2";date12:离日=7=yy/mm/dd=alignment="2";char05:房号=4=[general]=alignment="2";mone10_1:房价=6=0.00=alignment="1";mone10_2:间夜=4=0.0=alignment="1";mone10_3:房费=7=0.00=alignment="1";mone10_5:餐费=7=0.00=alignment="1";mone10_6:康乐=7=0.00=alignment="1";mone10_7:其他=7=0.00=alignment="1";mone10_8:合计=8=0.00=alignment="1"
headerds=[header=5 summary=2 styles=box autoappe=0]
computes=c_yshu:'页次('+string(page(),'0')+'/'+string(pagecount(),'0')+')':header:4::mone10_8:mone10_8::alignment="2" border="0"!
computes=c_1:'协议单位 = '+nodispchar80:header:4::char12:mone10_6::alignment="0" border="0"! 
computes=c_2:sum( mone10_2 for all ):summary:1::mone10_2:mone10_2::alignment="2" format="0.0"!
computes=c_3:sum( mone10_3 for all ):summary:1::mone10_3:mone10_3::alignment="1" format="0.00"!
computes=c_5:sum( mone10_5 for all ):summary:1::mone10_5:mone10_5::alignment="1" format="0.00"!
computes=c_6:sum( mone10_6 for all ):summary:1::mone10_6:mone10_6::alignment="1" format="0.00"!
computes=c_7:sum( mone10_7 for all ):summary:1::mone10_7:mone10_7::alignment="1" format="0.00"!
computes=c_8:sum( mone10_8 for all ):summary:1::mone10_8:mone10_8::alignment="1" format="0.00"!
computes=c_0:c_3/c_2:summary:1::mone08:mone08::alignment="1" format="0.00"!
texttext=t_title:#hotel#:header:1::char10:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title1:协议单位消费明细报告(按离日):header:2::char10:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title2:<#date1#-#date2#>:header:3::char10:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_date:打印时间 #pdate#:summary:2::char10:mone10_2::alignment="0" border="0"! 
texttext=t_heji:合计:summary:1::char10:mone10_1::alignment="2"!
*/