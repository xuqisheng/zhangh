drop Proc p_cq_master_income_cusno;
create Proc p_cq_master_income_cusno
	@cusno		char(7),
	@begin_		datetime,
	@end_			datetime
as

declare	
	@mno			char(7),
	@date			datetime,
	@accnt		char(10),
	@saleid		char(12)

create table #goutput 
(
	saleid		char(12)								not null,
	descript		char(20)								null,
	accnt			char(10)								not null,
	resno			char(10)								null,
	sta			char(1)								null,
	haccnt		char(7)								null,
	cusno			char(7)								null,
	name		   varchar(50)	 	default ''		null,	 	-- ����1
	name2		   varchar(50)	 	default ''		null,	 	-- ����2
	i_days      int 				default 0 		not null,   -- ס������ 
	i_guests		int				default 0		not null,	-- ס������
	fb_times1    int 				default 0 		not null,   -- �������� 
	en_times2    int 				default 0 		not null,   -- ���ִ��� 
	rm          money 			default 0 		not null, 	-- ��������
	fb          money 			default 0 		not null, 	-- ��������
	en          money 			default 0 		not null, 	-- ��������
	mt          money 			default 0 		not null, 	-- ��������
	ot          money 			default 0 		not null, 	-- ��������
	tl          money 			default 0 		not null 	-- ������  

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
--����һ�겻ͳ��
if (select datediff(dd,@begin_,@end_)) > 365 or rtrim(@cusno) is null
	goto RETURN_1


--ǰ̨����׼��
insert #goutput (saleid,accnt,sta,resno,haccnt,cusno)
	select a.saleid,a.accnt,'','',a.haccnt,@cusno
	from hmaster a,saleid b where (a.cusno = @cusno or a.agent = @cusno or a.source = @cusno) and a.saleid = b.code
	and datediff(dd,a.dep,@begin_) <= 0 and datediff(dd,a.dep,@end_) >= 0 and a.sta = 'O'

------------------------

--��������׼��
insert #goutput (saleid,accnt,sta,resno,haccnt,cusno)
	select b.code,a.menu,a.sta,'',a.haccnt,a.cusno
	from pos_hmenu a,saleid b,guest c where (a.haccnt = c.no or a.cusno = c.no ) and c.saleid = b.code and c.no = @cusno
   	and datediff(dd,a.bdate,@begin_)<=0 and datediff(dd,a.bdate,@end_) >= 0 and a.sta = '3'

------------------------
update #goutput set name = a.name from guest a where #goutput.haccnt = a.no
update #goutput set name2 = a.name2 from guest a where #goutput.cusno = a.no


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
--���������
declare	@rm_pccodes_nt	char(255)
select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')
update #goutput set i_days  = isnull((select sum(a.amount2) from master_income a where a.accnt = #goutput.accnt and pccode <> '' and charindex(a.pccode, @rm_pccodes_nt) > 0 ),0)
update #goutput set i_guests  = isnull((select sum(a.amount2) from master_income a where a.accnt = #goutput.accnt and a.pccode = '' and item = 'I_GUESTS'),0)
update #goutput set descript = isnull(a.name,'') from saleid a where #goutput.saleid = a.code

RETURN_1:


select cusno+'-'+name2,cusno,haccnt,name,descript,i_guests, i_days,rm,fb,en,mt,ot,tl from #goutput where cusno <> '' order by cusno

return 0;


//_com_p_Э�鵥λҵ����ϸ����(������);
//(exec p_cq_master_income_cusno'#char08!������Э�鵥λ����! #','#date1!��������ʼ����!#Bdate1##','#date2!��������ֹ����!#Bdate1##'resultset=char61,char07,char12, char60, mone10_1, mone10_2, mone10_3, mone10_5, mone10_6, mone10_7, mone10_8,mone10_9);
//char12:����=5;char60:����=10;mone10_1:�˴�=5=0=alignment="2";mone10_2:����=6=0.0=alignment="2";mone10_3:����=9=0.00=alignment="1";mone08==mone10_3/mone10_2:ƽ������=8=0.00=alignment="1";mone10_5:�ͷ�=8=0.00=alignment="1";mone10_6:����=8=0.00=alignment="1";mone10_7:����=8=0.00=alignment="1";mone10_8:����=8=0.00=alignment="1";mone10_9:�ϼ�=10=0.00=alignment="1"
//headerds=[header=5 summary=2 styles=box autoappe=0]
//group_by=1:1:2:(  "char07"  ) 
//computes=c_1:sum( mone10_1 for group 1 ):trailer.1:1::mone10_1:mone10_1::alignment="2" format="0"!
//computes=c_2:sum( mone10_2 for group 1 ):trailer.1:1::mone10_2:mone10_2::alignment="2" format="0.0"!
//computes=c_3:sum( mone10_3 for group 1 ):trailer.1:1::mone10_3:mone10_3::alignment="1" format="0.00"!
//computes=c_5:sum( mone10_5 for group 1 ):trailer.1:1::mone10_5:mone10_5::alignment="1" format="0.00"!
//computes=c_6:sum( mone10_6 for group 1 ):trailer.1:1::mone10_6:mone10_6::alignment="1" format="0.00"!
//computes=c_7:sum( mone10_7 for group 1 ):trailer.1:1::mone10_7:mone10_7::alignment="1" format="0.00"!
//computes=c_8:sum( mone10_8 for group 1 ):trailer.1:1::mone10_8:mone10_8::alignment="1" format="0.00"!
//computes=c_8:sum( mone10_9 for group 1 ):trailer.1:1::mone10_9:mone10_9::alignment="1" format="0.00"!
//computes=c_0:c_3/c_2:trailer.1:1::mone08:mone08::alignment="1" format="0.00"!
//computes=c_11:sum( mone10_1 for all ):summary:1::mone10_1:mone10_1::alignment="2" format="0"!
//computes=c_21:sum( mone10_2 for all ):summary:1::mone10_2:mone10_2::alignment="2" format="0.0"!
//computes=c_31:sum( mone10_3 for all ):summary:1::mone10_3:mone10_3::alignment="1" format="0.00"!
//computes=c_51:sum( mone10_5 for all ):summary:1::mone10_5:mone10_5::alignment="1" format="0.00"!
//computes=c_61:sum( mone10_6 for all ):summary:1::mone10_6:mone10_6::alignment="1" format="0.00"!
//computes=c_71:sum( mone10_7 for all ):summary:1::mone10_7:mone10_7::alignment="1" format="0.00"!
//computes=c_81:sum( mone10_8 for all ):summary:1::mone10_8:mone10_8::alignment="1" format="0.00"!
//computes=c_82:sum( mone10_9 for all ):summary:1::mone10_9:mone10_9::alignment="1" format="0.00"!
//computes=c_0:c_31/c_21:summary:1::mone08:mone08::alignment="1" format="0.00"!
//computes=c_yshu:'ҳ��('+string(page(),'0')+'/'+string(pagecount(),'0')+')':header:4::mone10_9:mone10_9::alignment="2" border="0"!
//computes=c_g0:'Э�鵥λ---'+nodispchar61:header.1:1::char12:mone10_9::alignment="2"!
//computes=c_g0:'Э�鵥λ---'+nodispchar61:header:4::char12:mone10_9::alignment="0" border="0"!
//texttext=t_gtitle:��λС��:trailer.1:1::char12:char60::alignment="2"!
//texttext=t_title:#hotel#:header:1::char12:mone10_9::border="0" alignment="2" font.height="-12" font.italic="1"!
//texttext=t_title1:Э �� �� λ ҵ �� �� ϸ �� �� (������):header:2::char12:mone10_9::border="0" alignment="2" font.height="-12" font.italic="1"!
//texttext=t_title2:<#date1#-#date2#>:header:3::char12:mone10_9::border="0" alignment="2" font.height="-12" font.italic="1"!
//texttext=t_dte:Э�鵥λ === nodispchar61:header:4::char12:mone10_2::alignment="0" border="0"! 
//texttext=t_date:��ӡʱ�� #pdate#:summary:2::char12:mone10_2::alignment="0" border="0"! 
//texttext=t_heji:�ϼ�:summary:1::char12:char60::border="2"!