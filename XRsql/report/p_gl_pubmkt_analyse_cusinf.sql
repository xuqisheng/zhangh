if object_id('p_gl_pubmkt_analyse_cusinf') is not null
	drop proc p_gl_pubmkt_analyse_cusinf
;
create proc p_gl_pubmkt_analyse_cusinf
	@classkey	char(1),  --  1, 2, 3, 4 - ���
	@class		char(3),
	@begin_		datetime,
	@end_			datetime,
	@zero			char(1) = 't'	--  0 �Ƿ���ʾ
as
-------------------------------------------------------------------------------
--	Э�鵥λҵ������ - ������/���� - ��Ҫȷ�����
-------------------------------------------------------------------------------
declare
	@cat			char(10)

create table #gout
(
	code			char(3)					not null,	--  ���
	descript		varchar(12)				not null,	--  �������&�˺�
	no				char(7)					not null,	--  Э�鵥λ
	sno			char(15)					null,			--  �ֹ����
	name			varchar(60)				not null,
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

-- ȫ��Ϊ 0 ��¼�Ƿ���ʾ
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
_com_p_Э�鵥λ���ѱ���(������);
(exec p_gl_pubmkt_analyse_cusinf '#char01!�������������<1-4>!1#','#char03!������������! #','#date1!��������ʼ����!#Bdate1##','#date2!��������ֹ����!#Bdate1##','f' resultset=char12, char07, char15, char60, mone10_1, mone10_2, mone10_3, mone10_5, mone10_6, mone10_7, mone10_8);
char07:����=6;char15:�Ա��=6;char60:����=20;mone10_1:�˴�=4=0=alignment="2";mone10_2:����=5=0.0=alignment="2";mone10_3:����=8=0.00=alignment="1";mone08==mone10_3/mone10_2:ƽ������=8=0.00=alignment="1";mone10_5:�ͷ�=7=0.00=alignment="1";mone10_6:����=7=0.00=alignment="1";mone10_7:����=7=0.00=alignment="1";mone10_8:�ϼ�=9=0.00=alignment="1"
headerds=[header=5 summary=2 styles=box autoappe=0]
group_by=1:1:2:(  "nodispchar12"  ) 
computes=c_yshu:'ҳ��('+string(page(),'0')+'/'+string(pagecount(),'0')+')':header:4::mone10_8:mone10_8::alignment="2" border="0"!
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
texttext=t_gtitle:�������:header.1:1::char07:char60::alignment="2"!
texttext=t_gfooter:���С��:trailer.1:1::char07:char60::alignment="2"!
texttext=t_title:#hotel#:header:1::char07:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title1:Э�鵥λ���ѱ���(������):header:2::char07:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title2:<#date1#-#date2#>:header:3::char07:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_dte:����=#char01# ���=#char03#:header:4::char07:mone10_2::alignment="0" border="0"! 
texttext=t_date:��ӡʱ�� #pdate#:summary:2::char07:mone10_2::alignment="0" border="0"! 
texttext=t_heji:�ϼ�:summary:1::char07:char60::alignment="2"!

*/