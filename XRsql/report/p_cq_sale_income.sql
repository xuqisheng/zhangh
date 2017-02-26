IF OBJECT_ID('p_cq_sale_income') IS NOT NULL
    DROP PROCEDURE p_cq_sale_income
;
create Proc p_cq_sale_income
	@saleid		char(12),
	@begin_		datetime,
	@end_			datetime
as
------------------------------------------------------------------------------------
--	销售员业绩报表- 按照离日/汇总
------------------------------------------------------------------------------------
declare	
	@mno			char(7),
	@date			datetime,
	@accnt		char(10)

create table #goutput 
(
	saleid		char(12)								not null,
	descript		char(20)								null,
	accnt			char(10)								not null,
	resno			char(10)								null,
	sta			char(1)								null,
	haccnt		char(7)								null,
	cusno			char(7)								null,
	name		   varchar(50)	 	default ''		null,	 	-- 姓名1
	name2		   varchar(50)	 	default ''		null,	 	-- 姓名2
	i_days      int 				default 0 		not null,   -- 住店天数 
	i_guests		int				default 0		not null,	-- 住店人数
	fb_times1    int 				default 0 		not null,   -- 餐饮次数 
	en_times2    int 				default 0 		not null,   -- 娱乐次数 
	rm          money 			default 0 		not null, 	-- 房租收入
	fb          money 			default 0 		not null, 	-- 餐饮收入
	en          money 			default 0 		not null, 	-- 娱乐收入
	mt          money 			default 0 		not null, 	-- 会议收入
	ot          money 			default 0 		not null, 	-- 其它收入
	tl          money 			default 0 		not null 	-- 总收入  

)


create table #master
(
accnt			char(10)			null,
deptno7		char(5)			null,
amount1		money				null
)

select * into #menu from pos_hmenu where 1 = 2


if @begin_ is null
select @begin_ = '1980/1/1'
if @end_ is null
select @end_ = '2020/1/1'
if rtrim(@saleid) is null
	select @saleid = '%'
--超出一年不统计
if (select datediff(dd,@begin_,@end_)) > 365 
	goto RETURN_1


--前台数据准备
insert #goutput (saleid,accnt,sta,resno,haccnt,cusno)
select a.saleid,a.accnt,'','',a.haccnt,''
from hmaster a,saleid b where a.saleid like @saleid and a.saleid = b.code
and datediff(dd,a.dep,@begin_) <= 0 and datediff(dd,a.dep,@end_) >= 0 and a.sta = 'O'
------------------------

--餐饮数据准备
insert #menu select * from pos_hmenu where datediff(dd,bdate,@begin_) <= 0 and datediff(dd,bdate,@end_) >= 0
and sta = '3' and (haccnt <> '' or cusno <> '')
insert #goutput (saleid,accnt,sta,resno,haccnt,cusno)
select c.saleid,a.menu,a.sta,'',a.haccnt,''
from #menu a,saleid b,guest c where a.haccnt = c.no  and c.saleid like @saleid and c.saleid = b.code
union
select b.code,a.menu,a.sta,'','',a.cusno
from #menu a,saleid b,guest c where a.cusno = c.no  and c.saleid like @saleid and c.saleid = b.code

------------------------
update #goutput set name = a.name, name2 = a.name2 from guest a where #goutput.haccnt = a.no
update #goutput set name = a.name, name2 = a.name2 from guest a where #goutput.cusno = a.no


-- Sum
insert #master (accnt,deptno7,amount1)
select c.accnt,b.deptno7,isnull(sum(a.amount1),0)
from #goutput c, master_income a,pccode b where a.accnt = c.accnt and a.pccode=b.pccode
group by c.accnt,b.deptno7

create index index1 on #master(accnt,deptno7)
update #goutput set rm = a.amount1 from #master a where a.accnt = #goutput.accnt  and a.deptno7 = 'rm'
update #goutput set fb = a.amount1 from #master a where a.accnt = #goutput.accnt  and a.deptno7 = 'fb'
update #goutput set en = a.amount1 from #master a where a.accnt = #goutput.accnt  and a.deptno7 = 'en'
update #goutput set mt = a.amount1 from #master a where a.accnt = #goutput.accnt  and a.deptno7 = 'mt'
update #goutput set ot = a.amount1 from #master a where a.accnt = #goutput.accnt  and a.deptno7 = 'ot'
update #goutput set fb = a.amount from pos_hmenu a where a.menu = #goutput.accnt
update #goutput set tl = rm+fb+en+mt+ot

delete #goutput where tl = 0
--房晚和人数
declare	@rm_pccodes_nt	char(255)
select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')
update #goutput set i_days  = isnull((select sum(a.amount2) from master_income a where a.accnt = #goutput.accnt and pccode <> '' and charindex(a.pccode, @rm_pccodes_nt) > 0 ),0)
update #goutput set i_guests  = isnull((select sum(a.amount2) from master_income a where a.accnt = #goutput.accnt and a.pccode = '' and item = 'I_GUESTS'),0)
update #goutput set descript = isnull(a.name,'') from saleid a where #goutput.saleid = a.code

RETURN_1:

select saleid,descript,sum(i_guests), sum(i_days),sum(rm),sum(fb),sum(en),sum(mt),sum(ot),sum(tl) from #goutput
group by saleid,descript

return 0
;

/*

_com_p_销售员业绩报表;
(exec p_cq_sale_income  '#char13!请输入销售员代码! #','#date1!请输入起始日期!#Bdate1##','#date2!请输入终止日期!#Bdate1##'resultset=char12, char30, mone10_1, mone10_2, mone10_3, mone10_5, mone10_6, mone10_7, mone10_8,mone10_9);
char12:代码=5;char30:姓名=10;mone10_1:人次=5=0=alignment="2";mone10_2:间天=6=0.0=alignment="2";mone10_3:房费=9=0.00=alignment="1";mone08==mone10_3/mone10_2:平均房价=8=0.00=alignment="1";mone10_5:餐费=8=0.00=alignment="1";mone10_6:康乐=8=0.00=alignment="1";mone10_7:会议=8=0.00=alignment="1";mone10_8:其他=8=0.00=alignment="1";mone10_9:合计=10=0.00=alignment="1"
headerds=[header=5 summary=2 styles=box]
computes=c_yshu:'页次('+string(page(),'0')+'/'+string(pagecount(),'0')+')':header:4::mone10_9:mone10_9::alignment="2" border="0"!
computes=c_1:sum( mone10_1 for all ):summary:1::mone10_1:mone10_1::alignment="2" format="0"!
computes=c_2:sum( mone10_2 for all ):summary:1::mone10_2:mone10_2::alignment="2" format="0.0"!
computes=c_3:sum( mone10_3 for all ):summary:1::mone10_3:mone10_3::alignment="1" format="0.00"!
computes=c_5:sum( mone10_5 for all ):summary:1::mone10_5:mone10_5::alignment="1" format="0.00"!
computes=c_6:sum( mone10_6 for all ):summary:1::mone10_6:mone10_6::alignment="1" format="0.00"!
computes=c_7:sum( mone10_7 for all ):summary:1::mone10_7:mone10_7::alignment="1" format="0.00"!
computes=c_8:sum( mone10_8 for all ):summary:1::mone10_8:mone10_8::alignment="1" format="0.00"!
computes=c_8:sum( mone10_9 for all ):summary:1::mone10_9:mone10_9::alignment="1" format="0.00"!
computes=c_0:c_3/c_2:summary:1::mone08:mone08::alignment="1" format="0.00"!
texttext=t_title:#hotel#:header:1::char12:mone10_9::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title1:销 售 员 业 绩 报 告 (按结帐日期):header:2::char12:mone10_9::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title2:<#date1#-#date2#>:header:3::char12:mone10_9::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_dte:销售员 === #char13#:header:4::char12:mone10_2::alignment="0" border="0"! 
texttext=t_date:打印时间 #pdate#:summary:2::char12:mone10_2::alignment="0" border="0"! 
texttext=t_heji:合计:summary:1::char12:char30::border="2"!


*/