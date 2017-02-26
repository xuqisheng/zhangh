
---------------------------------------------------------------------
--	Ϊ�人����������������������
--	
--	��ʱ����������������  -  hxw, simon 
---------------------------------------------------------------------

IF OBJECT_ID('p_gds_salesrep1_rmtype_class2') IS NOT NULL
    DROP PROCEDURE p_gds_salesrep1_rmtype_class2
;
create proc p_gds_salesrep1_rmtype_class2
	@saleid      varchar(10),
	@rmtype		varchar(5),
	@begin_		datetime,
	@end_			datetime
as

create table #saleid
(
	code       char(10)  default ''  not null
)

create table #gout
(
	saleid       char(7)  default ''  not null,
	sname       varchar(50) default '' null, -- Э�鵥λ����  
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
select @saleid=isnull(ltrim(rtrim(@saleid)), '%')
select @rmtype=isnull(ltrim(rtrim(@rmtype)), '%')
--if @rmtype<>'%' select @rmtype=@rmtype+'%' 

insert #saleid select code from saleid where code=@saleid or name like '%'+@saleid+'%' or name2 like '%'+@saleid+'%'

if exists(select 1 from #saleid)
begin
	insert #gout
		select b.saleid,'',a.type, a.descript, b.accnt, b.t_arr, b.master, b.rm, b.gstno, b.i_days
			From typim a, ycus_xf b
			Where (a.type = @rmtype or @rmtype='%') 
					and a.type = b.type
					and b.saleid in (select code from #saleid) 
					and b.date>=@begin_ and b.date<=@end_  
	
	update #gout set gstno=0 where t_arr<>'T' 
	update #gout set days = 0 where accnt <> master
	
	update #gout set sname = b.name from saleid b where  b.code = #gout.saleid 
end

select saleid,sname,code, descript, sum(gstno),sum(days), sum(rm)
	from #gout
	group by saleid,sname,code,descript
	order by saleid,sname,code,descript

return 0
;

delete auto_report where id ='rep!FGSALERM1';
INSERT INTO auto_report VALUES (
	'EA',
	'tab',
	'rep!FGSALERM1',
	'RMSALE2',
	'�������۷�������-3',
	'�������۷�������-3',
	'�������۷�������-3',
	'02',
	'1',
	'_com_p_�������۷�������-3;(exec p_gds_salesrep1_rmtype_class2 ''#char11!����������Ա�Ż�������!%#'',''#char05!�����뷿�����!%#'',''#date1!��������ʼ����!#Bdate&-30&&##'',''#date2!��������ֹ����!#Bdate1##'',''f'' resultset=char10,char50,char12, char30, mone10_11, mone10_12, mone10_13);char12:����=5;char30:����=20;mone10_11:����=7=0=alignment="2";mone10_12:����=7=0=alignment="2";mone10_16==mone10_13/mone10_12:ƽ������=9=0.00=alignment="1";mone10_13:����=10=0.00=alignment="1"headerds=[header=5 summary=2 autoappe=0]group_by=1:1:2:(  "nodispchar50"  ) computes=c_yshu:''ҳ��(''+string(page(),''0'')+''/''+string(pagecount(),''0'')+'')'':header:4::mone10_13:mone10_13::alignment="2" border="0"!computes=c_g1t:nodispchar10+''---''+nodispchar50:header.1:1::char12:mone10_16::alignment="0" !computes=c_g11:sum( mone10_11 for group 1 ):trailer.1:1::mone10_11:mone10_11::alignment="2" format="0"!computes=c_g12:sum( mone10_12 for group 1 ):trailer.1:1::mone10_12:mone10_12::alignment="2" format="0"!computes=c_g13:sum( mone10_13 for group 1 ):trailer.1:1::mone10_13:mone10_13::alignment="1" format="0.00"!computes=c_g16:c_g13/c_g12:trailer.1:1::mone10_16:mone10_16::alignment="1" format="0.00"!computes=c_11:sum( mone10_11 for all ):summary:1::mone10_11:mone10_11::alignment="2" format="0"!computes=c_12:sum( mone10_12 for all ):summary:1::mone10_12:mone10_12::alignment="2" format="0"!computes=c_13:sum( mone10_13 for all ):summary:1::mone10_13:mone10_13::alignment="1" format="0.00"!computes=c_16:c_13/c_12:summary:1::mone10_16:mone10_16::alignment="1" format="0.00"!texttext=t_title:#hotel#:header:1::char12:mone10_13::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=t_title1:�������۷�������-3:header:2::char12:mone10_13::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=t_title2:<#date1#-#date2#>:header:3::char12:mone10_13::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=t_dte:���� = #char05#:header:4::char12:mone10_12::alignment="0" border="0"! texttext=t_date:��ӡʱ�� #pdate#:summary:2::char12:mone10_16::alignment="0" border="0"! texttext=t_heji:�ϼ�:summary:1::char12:char30::border="4"!',
	'',
	'',
	'F',
	'F',
	'GDS',
	'10-16-2006 17:28:15.243',
	'FOX',
	'10-31-2006 15:52:10.203');
