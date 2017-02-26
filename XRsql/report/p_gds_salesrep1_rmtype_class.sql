
---------------------------------------------------------------------
--	Ϊ�人����������������������
--	
--	��ʱ����������������  -  hxw, simon 
---------------------------------------------------------------------

IF OBJECT_ID('p_gds_salesrep1_rmtype_class') IS NOT NULL
    DROP PROCEDURE p_gds_salesrep1_rmtype_class
;
create proc p_gds_salesrep1_rmtype_class
	@cusno      varchar(10),
	@rmtype		varchar(5),
	@begin_		datetime,
	@end_			datetime
as

create table #cusno
(
	no       char(7)  default ''  not null
)

create table #gout
(
	cusno       char(7)  default ''  not null,
	cname       varchar(50) default '' null, -- Э�鵥λ����  
	code			varchar(12)				not null,
	descript		varchar(30)				not null,
	accnt			char(10)					not null,
	t_arr			char(1)					not null,
	master		char(10)					not null,
	rm				money		default 0	not null,
	gstno			money		default 0	not null,
	days			money		default 0	not null
)

if @begin_ is null
	select @begin_ = '1980/1/1'
if @end_ is null
	select @end_ = '2020/1/1'
if rtrim(@cusno) = null or rtrim(@rmtype) = null
	begin
	select cusno,cname,code, descript, sum(gstno),sum(days), sum(rm)
	from #gout
	group by cusno,cname,code,descript
	order by cusno,cname,code,descript
	return 0
	end
select @cusno='%'+isnull(ltrim(rtrim(@cusno)), ' ')+'%'
select @rmtype=isnull(ltrim(rtrim(@rmtype)), ' ')
--if @rmtype<>'%' select @rmtype=@rmtype+'%' 

insert #cusno select no from guest where class in ('C', 'A', 'S') 
	and ( no like @cusno or name like @cusno or name2 like @cusno)

if exists(select 1 from #cusno)
begin
	insert #gout
		select b.cusno,'',a.type, a.descript, b.accnt, b.t_arr, b.master, b.rm, b.gstno, b.i_days
			From typim a, ycus_xf b
			Where (a.type = @rmtype or @rmtype='%') 
					and a.type = b.type
					and b.cusno in (select no from #cusno) 
					and b.date>=@begin_ and b.date<=@end_  
	
	insert #gout
		select b.agent,'',a.type, a.descript, b.accnt, b.t_arr, b.master, b.rm, b.gstno, b.i_days
			From typim a, ycus_xf b
			Where (a.type = @rmtype or @rmtype='%') 
					and a.type = b.type
					and b.agent in (select no from #cusno)
					and b.date>=@begin_ and b.date<=@end_  
	
	insert #gout
		select b.source,'',a.type, a.descript, b.accnt, b.t_arr, b.master, b.rm, b.gstno, b.i_days
			From typim a, ycus_xf b
			Where (a.type = @rmtype or @rmtype='%') 
					and a.type = b.type
					and b.source in (select no from #cusno)
					and b.date>=@begin_ and b.date<=@end_  
	
	update #gout set gstno=0 where t_arr<>'T' 
	update #gout set days = 0 where accnt <> master
	
	update #gout set cname = b.name from guest b where  b.no = #gout.cusno 
end

select cusno,cname,code, descript, sum(gstno),sum(days), sum(rm)
	from #gout
	group by cusno,cname,code,descript
	order by cusno,cname,code,descript

return 0
;

//delete auto_report where id ='rep!FGSALERM';
//INSERT INTO auto_report VALUES (
//	'U',
//	'tab',
//	'rep!FGSALERM',
//	'STT402',
//	'�������۷�������-2',
//	'�������۷�������-2',
//	'�������۷�������-2',
//	'1,5,7,M',
//	'1',
//	'_com_p_�������۷�������-2;(exec p_gds_salesrep1_rmtype_class ''#char07!������Э�鵥λ�Ż�������!%#'',''#char05!�����뷿�����!%#'',''#date1!��������ʼ����!#Bdate&-30&&##'',''#date2!��������ֹ����!#Bdate1##'',''f'' resultset=char07,char50,char12, char30, mone10_11, mone10_12, mone10_13);char12:����=5;char30:����=20;mone10_11:����=7=0=alignment="2";mone10_12:����=7=0=alignment="2";mone10_16==mone10_13/mone10_12:ƽ������=9=0.00=alignment="1";mone10_13:����=10=0.00=alignment="1"headerds=[header=5 summary=2 autoappe=0]group_by=1:1:2:(  "nodispchar50"  ) computes=c_yshu:''ҳ��(''+string(page(),''0'')+''/''+string(pagecount(),''0'')+'')'':header:4::mone10_13:mone10_13::alignment="2" border="0"!computes=c_g1t:nodispchar07+''---''+nodispchar50:header.1:1::char12:mone10_16::alignment="0" !computes=c_g11:sum( mone10_11 for group 1 ):trailer.1:1::mone10_11:mone10_11::alignment="2" format="0"!computes=c_g12:sum( mone10_12 for group 1 ):trailer.1:1::mone10_12:mone10_12::alignment="2" format="0"!computes=c_g13:sum( mone10_13 for group 1 ):trailer.1:1::mone10_13:mone10_13::alignment="1" format="0.00"!computes=c_g16:c_g13/c_g12:trailer.1:1::mone10_16:mone10_16::alignment="1" format="0.00"!computes=c_11:sum( mone10_11 for all ):summary:1::mone10_11:mone10_11::alignment="2" format="0"!computes=c_12:sum( mone10_12 for all ):summary:1::mone10_12:mone10_12::alignment="2" format="0"!computes=c_13:sum( mone10_13 for all ):summary:1::mone10_13:mone10_13::alignment="1" format="0.00"!computes=c_16:c_13/c_12:summary:1::mone10_16:mone10_16::alignment="1" format="0.00"!texttext=t_title:#hotel#:header:1::char12:mone10_13::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=t_title1:�������۷�������-2:header:2::char12:mone10_13::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=t_title2:<#date1#-#date2#>:header:3::char12:mone10_13::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=t_dte:���� = #char05#:header:4::char12:mone10_12::alignment="0" border="0"! texttext=t_date:��ӡʱ�� #pdate#:summary:2::char12:mone10_16::alignment="0" border="0"! texttext=t_heji:�ϼ�:summary:1::char12:char30::border="4"!',
//	'',
//	'',
//	'F',
//	'F',
//	'GDS',
//	'10-16-2006 17:28:15.243',
//	'FOX',
//	'10-31-2006 15:52:41.333',
//	'500');


// hxw 
//
//IF OBJECT_ID('p_gds_salesrep1_rmtype_class') IS NOT NULL
//    DROP PROCEDURE p_gds_salesrep1_rmtype_class
//;
//create proc p_gds_salesrep1_rmtype_class
//	@cusno      char(10),
//	@rmtype		char(5),
//	@begin_		datetime,
//	@end_			datetime,
//	@zero			char(1) = 't'
//as
//
//create table #gout
//(
//	class       char(5)  default 'ɢ��'   null,
//	cusno       char(7)  default ''  not null,
//	cname       varchar(50) default '' null, -- Э�鵥λ����  
//	code			varchar(12)				not null,
//	descript		varchar(30)				not null,
//	accnt			char(10)					not null,
//	master		char(10)					not null,
//	rm				money		default 0	not null,
//	gstno			money		default 0	not null,
//	days			money		default 0	not null,
//	fb				money		default 0	not null,
//	en				money		default 0	not null,
//	ot				money		default 0	not null,
//	tl				money		default 0	not null
//)
//
//if @begin_ is null
//	select @begin_ = '1980/1/1'
//if @end_ is null
//	select @end_ = '2020/1/1'
//if rtrim(@rmtype) is null
//	select @rmtype = '%'
//
//insert #gout
//	select '1ɢ��',b.cusno,'',a.type, a.descript, b.accnt, b.master, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
//		From typim a, ycus_xf b
//		Where a.type like @rmtype  and a.type = b.type
//			and b.date>=@begin_ and b.date<=@end_ and b.groupno =''
//insert #gout
//	select '2�Ŷ�',b.cusno,'',a.type, a.descript, b.accnt, b.master, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
//		From typim a, ycus_xf b
//		Where a.type like @rmtype and a.type = b.type
//			and b.date>=@begin_ and b.date<=@end_ and substring(b.groupno,1,1) ='G'
//insert #gout
//	select '3����',b.cusno,'',a.type, a.descript, b.accnt, b.master, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
//		From typim a, ycus_xf b
//		Where a.type like @rmtype and a.type = b.type
//			and b.date>=@begin_ and b.date<=@end_ and substring(b.groupno,1,1) ='M'
//
//
//
//update #gout set days = 0 where accnt <> master
//
//
//if charindex(@zero, 'tTyY') = 0
//	delete #gout where rm=0 and fb=0 and en=0 and ot=0 and tl=0 and days=0 and gstno=0
//else
//	insert #gout(class,cusno,code, descript,accnt,master,rm,gstno,days,fb,en,ot,tl) 
//     select '����','',type, descript, '', '',0,0,0,0,0,0,0 from typim where type not in (select distinct code from #gout)
//
//--cq modify
//--insert #gout(code, descript) select code, descript from saleid where code not in (select distinct code from #gout)
//update #gout set cname = b.name from guest b where  b.no = #gout.cusno 
//	
//
//select class,cname,code, descript, sum(gstno),
//		sum(days), sum(rm), sum(fb), sum(en+ot), sum(tl), ''
//	from #gout
//	group by class,cname,code,descript
//	order by class,cname,code,descript
//
//return 0
//;
//
//delete auto_report where id ='rep!FGSALERM';
//INSERT INTO auto_report VALUES (
//	'EA',
//	'tab',
//	'rep!FGSALERM',
//	'RMSALE1',
//	'ɢ���Ŷӷ�������ҵ������',
//	'ɢ���Ŷӷ�������ҵ������',
//	'ɢ���Ŷӷ�������ҵ������',
//	'02',
//	'1',
//	'_com_p_��������ҵ������;(exec p_gds_salesrep1_rmtype_class ''#char07!������Э�鵥λ��!%#'',''#char03!�����뷿�����!%#'',''#date1!��������ʼ����!#Bdate&-30&&##'',''#date2!��������ֹ����!#Bdate1##'',''f'' resultset=char05,char50,char12, char30, mone10_1, mone10_2, mone10_3, mone10_5, mone10_6, mone10_8);char05:���;char50:Э�鵥λ=30;char12:����=5;char30:����=20;mone10_2:����=7=0=alignment="2";mone10_3:����=10=0=alignment="1";mone08==mone10_3/mone10_2:ƽ������=9=0=alignment="1";mone10_5:�ͷ�=10=0=alignment="1";mone10_6:����=9=0=alignment="1";mone10_8:�ϼ�=10=0=alignment="1"headerds=[header=5 summary=2 autoappe=0]computes=c_yshu:''ҳ��(''+string(page(),''0'')+''/''+string(pagecount(),''0'')+'')'':header:4::mone10_8:mone10_8::alignment="2" border="0"!computes=c_2:sum( mone10_2 for all ):summary:1::mone10_2:mone10_2::alignment="2" format="0"!computes=c_3:sum( mone10_3 for all ):summary:1::mone10_3:mone10_3::alignment="1" format="0"!computes=c_5:sum( mone10_5 for all ):summary:1::mone10_5:mone10_5::alignment="1" format="0"!computes=c_6:sum( mone10_6 for all ):summary:1::mone10_6:mone10_6::alignment="1" format="0"!computes=c_8:sum( mone10_8 for all ):summary:1::mone10_8:mone10_8::alignment="1" format="0"!computes=c_0:c_3/c_2:summary:1::mone08:mone08::alignment="1" format="0"!texttext=t_title:#hotel#:header:1::char04:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=t_title1:��������ҵ������ (������):header:2::char05:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=t_title2:<#date1#-#date2#>:header:3::char05:mone10_8::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=t_dte:���� === #char03#:header:4::char05:mone10_2::alignment="0" border="0"! texttext=t_date:��ӡʱ�� #pdate#:summary:2::char05:mone10_2::alignment="0" border="0"! texttext=t_heji:�ϼ�:summary:1::char05:char30::border="4"!',
//	'',
//	'',
//	'F',
//	'F',
//	'GDS',
//	'10-16-2006 17:28:15.243',
//	'HXW',
//	'10-18-2006 14:45:5.803');

