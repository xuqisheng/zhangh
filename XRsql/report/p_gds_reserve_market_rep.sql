-----------------------------------------------------------------------------
--	Market List Report 
-----------------------------------------------------------------------------

if  exists(select * from sysobjects where name = "p_gds_reserve_market_rep")
	drop proc p_gds_reserve_market_rep
;
create proc p_gds_reserve_market_rep
	@mkt			char(3),
	@begin		datetime,
	@end			datetime
as
create table #goutput (
	accnt			char(10)						 	not null,
	haccnt		char(7)						 	not null,
	name			varchar(60)		default ''	not null,
	cusno			char(7)			default '' 	null,
	cname			varchar(60)		default ''	null,
	arr			datetime							not null,
	dep			datetime							not null,
	type			char(5)							not null,
	roomno		char(5)							not null,
	rate			money			default 0		not null,
	charge		money			default 0		not null,
	ciby			char(10)		default ''		not null,
	ref			varchar(100)	default ''		not null
)

--  and type>='A' => ��������ǽ������ݵ�

insert #goutput 
	select accnt,haccnt,'',cusno,'',arr,dep,type,roomno,setrate,charge,ciby,ref from master 
		where class='F' and bdate>=@begin and bdate<=@end and market=@mkt --and type>='A'
union 
	select accnt,haccnt,'',cusno,'',arr,dep,type,roomno,setrate,charge,ciby,ref from hmaster 
		where class='F' and bdate>=@begin and bdate<=@end and market=@mkt --and type>='A'

update #goutput set name=a.name from guest a where #goutput.haccnt=a.no
update #goutput set cname=a.name from guest a where #goutput.cusno=a.no

select accnt,name,cname,arr,dep,type,roomno,rate,charge,ciby,ref from #goutput  order by type, arr
return 0
;

/*

_com_p_��ѷ�����;
(exec p_gds_reserve_market_rep 'COM', '#date1!��������ʼ����!#Bdate1##','#date2!��������ֹ����!#Bdate1##' resultset=char10, char601, char602, date11, date12, char03, char05, mone101,mone102,char101,char99);
char05:����=5=[general]=alignment="2";char03:����=3=[general]=alignment="2";char601:����=12;date11:����=10=mm/dd hh|mm=alignment="2";date12:�뿪=10=mm/dd hh|mm=alignment="2";mone101:����=7=0.00=alignment="1";mone102:����=8=0.00=alignment="1";char101:�Ǽ�Ա;char602:��λ=26;char10:�˺�=9;char99:��ע=30=[general]=alignment="0"
headerds=[header=4 footer=2]
group_by=1:0:2:( "char03" )
computes=c_yshu:'ҳ��('+string(page(),'0')+'/'+string(pagecount(),'0')+')':header:3::char99:char99::alignment="2" border="0"!
computes=c_g1:count( char05 for group 1 distinct ):trailer.1:1::char601:char601::alignment="2" format="0"!
computes=c_g2:sum( mone101 for group 1 )/c_g1:trailer.1:1::date12:date12::alignment="2" format="0.00"!
computes=c_g3:sum( mone102 for group 1 ):trailer.1:1::mone102:mone102::alignment="2" format="0.00"!
computes=c_type:( char03 ):trailer.1:1::char05:char03::alignment="2" !
computes=c_1:count( char05 for all distinct ):footer:1::char601:char601::alignment="2" format="0"!
computes=c_2:sum( mone101 )/c_1:footer:1::date12:date12::alignment="2" format="0.00"!
computes=c_3:sum( mone102 ):footer:1::mone102:mone102::alignment="2" format="0.00"!
texttext=t_title:#hotel#:header:1::char05:char99::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title1:��ѷ�����:header:2::char05:char99::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title2:ͳ��ʱ�� = < #date1# - #date2# >:header:3::char05:char101::border="0" alignment="0"!
texttext=t_date:��ӡʱ�� #pdate#:footer:2::char05:date11::alignment="0" border="0"! 
texttext=t_heji1:����:footer:1::char05:char03::border="0"  alignment="2"!
texttext=t_heji2:����:footer:1::date11:date11::border="0"  alignment="2"!
texttext=t_heji3:������:footer:1::mone101:mone101::border="0"  alignment="2"!

*/
