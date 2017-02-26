if object_id('p_gl_pubmkt_analyse_cusinf1') is not null
	drop proc p_gl_pubmkt_analyse_cusinf1
;
create proc p_gl_pubmkt_analyse_cusinf1
	@no			char(7),
	@begin_		datetime,
	@end_			datetime
as
-------------------------------------------------------------------------------
--	Э�鵥λҵ������ - ������/��ϸ
-------------------------------------------------------------------------------

create table #gout
(
	no				char(7)					not null,	--  ��λ����
	sno			char(15)					null,
	name			varchar(60)				not null,
	actcls		char(1)					not null,
	actno			char(10)					not null,	--  ǰ̨�˺ţ����߲����˺�
	haccnt		char(7)	default ''	not null,
	gstname		varchar(60)				null,	
	arr			datetime					null,
	dep			datetime					null,
	roomno		char(5)					null,			--  ���ţ�����
	rate			money		default 0	null,			--  ����
	rm				money		default 0	not null,	--  ����
	gstno			money		default 0	not null,	--  �ͷ�
	days			money		default 0	not null,	--  ����
	fb				money		default 0	not null,	--  ����
	en				money		default 0	not null,	--  ����
	ot				money		default 0	not null,	--  ����
	tl				money		default 0	not null		--  �ϼ�
)

if @begin_ is null
	select @begin_ = '1980/1/1'
if @end_ is null
	select @end_ = '2020/1/1'
if rtrim(@no) is null
	select @no = '%'
   
--  ������ϸ��¼
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
--  ���
select actno,gstname,arr,dep,roomno,rate,days,rm,fb,en,ot,tl,no+'-'+sno+'-'+name
	from #gout order by actno,arr

return 0
;

/*
_com_p_Э�鵥λ������ϸ����(������);
(exec p_gl_pubmkt_analyse_cusinf1 '#char07!������Э�鵥λ����<----��������>#','#date1!��������ʼ����!#Bdate1##','#date2!��������ֹ����!#Bdate1##','t' resultset=char10,char60,date11,date12,char05,mone10_1,mone10_2,mone10_3,mone10_5,mone10_6,mone10_7,mone10_8,char80);
char10:�˺�=8;char60:����=20;date11:����=7=yy/mm/dd=alignment="2";date12:����=7=yy/mm/dd=alignment="2";char05:����=4=[general]=alignment="2";mone10_1:����=6=0.00=alignment="1";mone10_2:��ҹ=4=0.0=alignment="1";mone10_3:����=7=0.00=alignment="1";mone10_5:�ͷ�=7=0.00=alignment="1";mone10_6:����=7=0.00=alignment="1";mone10_7:����=7=0.00=alignment="1";mone10_8:�ϼ�=8=0.00=alignment="1"
headerds=[header=5 summary=2 styles=box autoappe=0]
computes=c_yshu:'ҳ��('+string(page(),'0')+'/'+string(pagecount(),'0')+')':header:4::mone10_8:mone10_8::alignment="2" border="0"!
computes=c_1:'Э�鵥λ = '+nodispchar80:header:4::char12:mone10_6::alignment="0" border="0"! 
computes=c_2:sum( mone10_2 for all ):summary:1::mone10_2:mone10_2::alignment="2" format="0.0"!
computes=c_3:sum( mone10_3 for all ):summary:1::mone10_3:mone10_3::alignment="1" format="0.00"!
computes=c_5:sum( mone10_5 for all ):summary:1::mone10_5:mone10_5::alignment="1" format="0.00"!
computes=c_6:sum( mone10_6 for all ):summary:1::mone10_6:mone10_6::alignment="1" format="0.00"!
computes=c_7:sum( mone10_7 for all ):summary:1::mone10_7:mone10_7::alignment="1" format="0.00"!
computes=c_8:sum( mone10_8 for all ):summary:1::mone10_8:mone10_8::alignment="1" format="0.00"!
computes=c_0:c_3/c_2:summary:1::mone08:mone08::alignment="1" format="0.00"!
texttext=t_title:#hotel#:header:1::char10:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title1:Э�鵥λ������ϸ����(������):header:2::char10:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title2:<#date1#-#date2#>:header:3::char10:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_date:��ӡʱ�� #pdate#:summary:2::char10:mone10_2::alignment="0" border="0"! 
texttext=t_heji:�ϼ�:summary:1::char10:mone10_1::alignment="2"!
*/