if object_id('p_gl_pubmkt_analyse_cusinf') is not null
	drop proc p_gl_pubmkt_analyse_cusinf
;
create proc p_gl_pubmkt_analyse_cusinf
	@classkey	char(1),  --  1, 2, 3, 4 - 类别
	@class		char(3),
	@begin_		datetime,
	@end_			datetime,
	@zero			char(1) = 't'	--  0 是否显示
as
-------------------------------------------------------------------------------
--	协议单位业绩报表 - 按离日/汇总 - 需要确认类别
-------------------------------------------------------------------------------
declare
	@cat			char(10)

create table #gout
(
	code			char(3)					not null,	--  类别
	descript		varchar(12)				not null,	--  类别名称&账号
	no				char(7)					not null,	--  协议单位
	sno			char(15)					null,			--  手工编号
	name			varchar(60)				not null,
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
if charindex(@classkey, '1234')=0
	select @classkey = '1'
select @cat = 'cuscls' + @classkey
if rtrim(@class) is null
	select @class = '%'
-- 
insert #gout (code, descript, no, sno, name, gstno, fb) select '', b.menu, b.cusno, b.setmodes, b.paid, b.guest, b.amount
	From pos_hmenu b Where b.bdate >= @begin_ and b.bdate <= @end_ and b.cusno <> ''
delete #gout where name <> '1' or sno in ('986', '986*')
-- delete #gout where name <> '1' or sno in ('986', '986*', '988', '988*')
-- 
insert #gout (code, descript, no, sno, name, gstno) select '', b.accnt, b.cusno, sta, '', gstno
	From hmaster b Where b.dep >= @begin_ and b.dep <= @end_ and b.cusno <> ''
insert #gout (code, descript, no, sno, name, gstno) select '', b.accnt, b.agent, sta, '', gstno
	From hmaster b Where b.dep >= @begin_ and b.dep <= @end_ and b.agent <> ''
insert #gout (code, descript, no, sno, name, gstno) select '', b.accnt, b.source, sta, '', gstno
	From hmaster b Where b.dep >= @begin_ and b.dep <= @end_ and b.source <> ''
delete #gout where sno in ('X', 'N')
update #gout set code = a.class1, sno = a.sno, name = a.name from guest a where #gout.no = a.no
delete #gout where not code like @class
-- 
update #gout set days = days + a.amount2 from master_income a where a.accnt = #gout.descript and a.pccode in ('000', 'rm')
update #gout set rm = rm + isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #gout.descript and a.pccode = b.pccode and b.deptno7 = 'rm'), 0)
update #gout set fb = fb + isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #gout.descript and a.pccode = b.pccode and b.deptno7 = 'fb'), 0)
update #gout set en = en + isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #gout.descript and a.pccode = b.pccode and b.deptno7 = 'en'), 0)
update #gout set ot = ot + isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #gout.descript and a.pccode = b.pccode and b.deptno7 = 'ot'), 0)
--  JJH
update #gout set rm = rm + isnull((select sum(a.amount1) from master_income a where a.accnt = #gout.descript and a.pccode = 'rm'), 0)
update #gout set fb = fb + isnull((select sum(a.amount1) from master_income a where a.accnt = #gout.descript and a.pccode = 'fb'), 0)
update #gout set en = en + isnull((select sum(a.amount1) from master_income a where a.accnt = #gout.descript and a.pccode = 'en'), 0)
update #gout set ot = ot + isnull((select sum(a.amount1) from master_income a where a.accnt = #gout.descript and a.pccode = 'ot'), 0)
update #gout set tl = rm + fb + en + ot
-- 
update #gout set descript = isnull(a.descript, '') from basecode a where a.cat = @cat and #gout.code *= a.code

-- 全部为 0 记录是否显示
if charindex(@zero, 'tTyY') = 0      
	delete #gout where rm=0 and fb=0 and en=0 and ot=0 and tl=0 and days=0 and gstno=0 
else
	if @classkey='1'
		insert #gout(code, descript, no, sno, name) 
			select b.code, b.descript, a.no, a.sno, a.name from guest a, basecode b 
				where b.cat='cuscls1' and a.class1=b.code and a.class in ('C','A','S') and a.no not in (select distinct no from #gout)
	else if @classkey='2'
		insert #gout(code, descript, no, sno, name) 
			select b.code, b.descript, a.no, a.sno, a.name from guest a, basecode b 
				where b.cat='cuscls2' and a.class2=b.code and a.class in ('C','A','S') and a.no not in (select distinct no from #gout)
	else if @classkey='3'
		insert #gout(code, descript, no, sno, name) 
			select b.code, b.descript, a.no, a.sno, a.name from guest a, basecode b 
				where b.cat='cuscls3' and a.class3=b.code and a.class in ('C','A','S') and a.no not in (select distinct no from #gout)
	else if @classkey='4'
		insert #gout(code, descript, no, sno, name) 
			select b.code, b.descript, a.no, a.sno, a.name from guest a, basecode b 
				where b.cat='cuscls4' and a.class4=b.code and a.class in ('C','A','S') and a.no not in (select distinct no from #gout)

select descript, no, sno, name, sum(gstno),sum(days),sum(rm), sum(fb), sum(en), sum(ot), sum(tl), ''
	from #gout
	group by code,descript, no, sno, name 
	order by code,descript, no, sno, name

return 0
;

/*
_com_p_协议单位消费报告(按离日);
(exec p_gl_pubmkt_analyse_cusinf '#char01!请输入分析类别键<1-4>!1#','#char03!请输入类别代码! #','#date1!请输入起始日期!#Bdate1##','#date2!请输入终止日期!#Bdate1##','f' resultset=char12, char07, char15, char60, mone10_1, mone10_2, mone10_3, mone10_5, mone10_6, mone10_7, mone10_8);
char07:代码=6;char15:自编号=6;char60:名称=20;mone10_1:人次=4=0=alignment="2";mone10_2:间天=5=0.0=alignment="2";mone10_3:房费=8=0.00=alignment="1";mone08==mone10_3/mone10_2:平均房价=8=0.00=alignment="1";mone10_5:餐费=7=0.00=alignment="1";mone10_6:康乐=7=0.00=alignment="1";mone10_7:其他=7=0.00=alignment="1";mone10_8:合计=9=0.00=alignment="1"
headerds=[header=5 summary=2 styles=box autoappe=0]
group_by=1:1:2:(  "nodispchar12"  ) 
computes=c_yshu:'页次('+string(page(),'0')+'/'+string(pagecount(),'0')+')':header:4::mone10_8:mone10_8::alignment="2" border="0"!
computes=c_g1:sum( mone10_1 for group 1 ):trailer.1:1::mone10_1:mone10_1::alignment="2" format="0"!
computes=c_g2:sum( mone10_2 for group 1 ):trailer.1:1::mone10_2:mone10_2::alignment="2" format="0.0"!
computes=c_g3:sum( mone10_3 for group 1 ):trailer.1:1::mone10_3:mone10_3::alignment="1" format="0.00"!
computes=c_g5:sum( mone10_5 for group 1 ):trailer.1:1::mone10_5:mone10_5::alignment="1" format="0.00"!
computes=c_g6:sum( mone10_6 for group 1 ):trailer.1:1::mone10_6:mone10_6::alignment="1" format="0.00"!
computes=c_g7:sum( mone10_7 for group 1 ):trailer.1:1::mone10_7:mone10_7::alignment="1" format="0.00"!
computes=c_g8:sum( mone10_8 for group 1 ):trailer.1:1::mone10_8:mone10_8::alignment="1" format="0.00"!
computes=c_g0:c_g3/c_g2:trailer.1:1::mone08:mone08::alignment="1" format="0.00"!
computes=c_1:sum( mone10_1 for all ):summary:1::mone10_1:mone10_1::alignment="2" format="0"!
computes=c_2:sum( mone10_2 for all ):summary:1::mone10_2:mone10_2::alignment="2" format="0.0"!
computes=c_3:sum( mone10_3 for all ):summary:1::mone10_3:mone10_3::alignment="1" format="0.00"!
computes=c_5:sum( mone10_5 for all ):summary:1::mone10_5:mone10_5::alignment="1" format="0.00"!
computes=c_6:sum( mone10_6 for all ):summary:1::mone10_6:mone10_6::alignment="1" format="0.00"!
computes=c_7:sum( mone10_7 for all ):summary:1::mone10_7:mone10_7::alignment="1" format="0.00"!
computes=c_8:sum( mone10_8 for all ):summary:1::mone10_8:mone10_8::alignment="1" format="0.00"!
computes=c_0:c_3/c_2:summary:1::mone08:mone08::alignment="1" format="0.00"!
computes=c_gtitle:nodispchar12:header.1:1::mone10_1:mone10_8::alignment="2"!
texttext=t_gtitle:类别名称:header.1:1::char07:char60::alignment="2"!
texttext=t_gfooter:类别小计:trailer.1:1::char07:char60::alignment="2"!
texttext=t_title:#hotel#:header:1::char07:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title1:协议单位消费报告(按离日):header:2::char07:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title2:<#date1#-#date2#>:header:3::char07:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_dte:类别键=#char01# 类别=#char03#:header:4::char07:mone10_2::alignment="0" border="0"! 
texttext=t_date:打印时间 #pdate#:summary:2::char07:mone10_2::alignment="0" border="0"! 
texttext=t_heji:合计:summary:1::char07:char60::alignment="2"!

*/