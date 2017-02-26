----------------------------------------
-- 协议单位佣金报表 mike
-- 
-- 不正确，弃用 simon 2006.5.7 
----------------------------------------

if exists(select 1 from sysobjects where name = 'p_wz_pubmkt_cmscode_query')
	drop proc p_wz_pubmkt_cmscode_query ;
//create proc p_wz_pubmkt_cmscode_query
//	@begin	datetime,
//	@end 		datetime,
//	@no		char(7)
//as
//----------------------------------------
//-- 协议单位佣金报表 mike 
//----------------------------------------
//create table #woutput
//(	accnt			char(10)			not null,
//	name			varchar(30)		null,
//	roomno		char(4)			null,
//	bdate			datetime			,
//	source		char(7)			null,
//	agent			char(7)			null,
//	cusno			char(7)			null, 
//	descript		varchar(30)		null,
//	cmscode		char(10)			null,
//	rmrate		money				default 0,
//	cmsamt		money				default 0
//)
//
//
//insert #woutput(accnt,name,roomno,bdate,source,agent,cusno,cmscode,rmrate,cmsamt)
//	select accnt,name,roomno,bdate,source,agent,cusno,cmscode,rmrate,cms0 
//		from cms_rec
//		where datediff(dd,bdate,@begin)<=0 and datediff(dd,bdate,@end)>=0 
//		and ( rtrim(source)+rtrim(agent)+rtrim(cusno) like @no +'%' or rtrim(@no) is null )
//		and w_or_h >=1
//
//update #woutput set descript = a.name from guest a where #woutput.agent = a.no
//update #woutput set descript = a.name from guest a where #woutput.source = a.no
//update #woutput set descript = a.name from guest a where #woutput.cusno = a.no
//
//select descript,accnt,name,roomno,bdate,cmscode,rmrate,cmsamt from #woutput order by descript,bdate,roomno
//
//return 0
//;
//

//_com_p_协议单位佣金报表;
//(exec p_wz_pubmkt_cmscode_query '#date1!请输入起始日期!#Bdate1##','#date2!请输入终止日期!#Bdate0##','#char07!请输入协议单位编码! #' resultset=char301,char10, char30,char04,date3,char101, mone10_1, mone10_2);
//char301:协议单位=25;char10:帐号=8;char30:姓名=15;char04:房类;date3:营业日期=10=yyyy/mm/dd=alignment="2";char101:佣金码;mone10_1:房价=10=0.00=alignment="1";mone10_2:佣金=10=0.00=alignment="1"
//headerds=[header=5 summary=2 styles=box]
//computes=c_yshu:'页次('+string(page(),'0')+'/'+string(pagecount(),'0')+')':header:4::mone10_2:mone10_2::alignment="2" border="0"!
//computes=c_1:sum( mone10_1 for all ):summary:1::mone10_1:mone10_1::alignment="1" format="0.00"!
//computes=c_2:sum( mone10_2 for all ):summary:1::mone10_2:mone10_2::alignment="1" format="0.00"!
//texttext=t_title:#hotel#:header:1::char301,:mone10_2::border="0" alignment="2" font.height="-12" font.italic="1"!
//texttext=t_title1:协议单位佣金报表:header:2::char301:mone10_2::border="0" alignment="2" font.height="-12" font.italic="1"!
//texttext=t_title2:<#date1#-#date2#>:header:3::char301:mone10_2::border="0" alignment="2" font.height="-12" font.italic="1"!
//texttext=t_date:打印时间 #pdate#:summary:2::char301:mone10_2::alignment="0" border="0"! 
//texttext=t_heji:合计:summary:1::char301:char101::border="2"!
//	1