----------------------------------------
-- Э�鵥λӶ�𱨱� mike
-- 
-- ����ȷ������ simon 2006.5.7 
----------------------------------------

if exists(select 1 from sysobjects where name = 'p_wz_pubmkt_cmscode_query')
	drop proc p_wz_pubmkt_cmscode_query ;
//create proc p_wz_pubmkt_cmscode_query
//	@begin	datetime,
//	@end 		datetime,
//	@no		char(7)
//as
//----------------------------------------
//-- Э�鵥λӶ�𱨱� mike 
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

//_com_p_Э�鵥λӶ�𱨱�;
//(exec p_wz_pubmkt_cmscode_query '#date1!��������ʼ����!#Bdate1##','#date2!��������ֹ����!#Bdate0##','#char07!������Э�鵥λ����! #' resultset=char301,char10, char30,char04,date3,char101, mone10_1, mone10_2);
//char301:Э�鵥λ=25;char10:�ʺ�=8;char30:����=15;char04:����;date3:Ӫҵ����=10=yyyy/mm/dd=alignment="2";char101:Ӷ����;mone10_1:����=10=0.00=alignment="1";mone10_2:Ӷ��=10=0.00=alignment="1"
//headerds=[header=5 summary=2 styles=box]
//computes=c_yshu:'ҳ��('+string(page(),'0')+'/'+string(pagecount(),'0')+')':header:4::mone10_2:mone10_2::alignment="2" border="0"!
//computes=c_1:sum( mone10_1 for all ):summary:1::mone10_1:mone10_1::alignment="1" format="0.00"!
//computes=c_2:sum( mone10_2 for all ):summary:1::mone10_2:mone10_2::alignment="1" format="0.00"!
//texttext=t_title:#hotel#:header:1::char301,:mone10_2::border="0" alignment="2" font.height="-12" font.italic="1"!
//texttext=t_title1:Э�鵥λӶ�𱨱�:header:2::char301:mone10_2::border="0" alignment="2" font.height="-12" font.italic="1"!
//texttext=t_title2:<#date1#-#date2#>:header:3::char301:mone10_2::border="0" alignment="2" font.height="-12" font.italic="1"!
//texttext=t_date:��ӡʱ�� #pdate#:summary:2::char301:mone10_2::alignment="0" border="0"! 
//texttext=t_heji:�ϼ�:summary:1::char301:char101::border="2"!
//	1