
---------------------------------------------------------------------
--	为武汉锦江房类分析报表需求而作
--	
--	临时制作报表，还需斟酌  -  hxw, simon 
---------------------------------------------------------------------

IF OBJECT_ID('p_gds_salesrep1_rmtype') IS NOT NULL
    DROP PROCEDURE p_gds_salesrep1_rmtype
;
create proc p_gds_salesrep1_rmtype
	@rmtype		char(5),
	@begin_		datetime,
	@end_			datetime,
	@zero			char(1) = 't'
as

create table #gout
(
	code			varchar(12)				not null,	-- rmtype 
	descript		varchar(30)				not null,
	accnt			char(10)					not null,
	master		char(10)					not null,
	groupno		char(10)					not null,
	parm1			int		default 1	not null,
	rm1			money		default 0	not null,
	gstno1		money		default 0	not null,
	days1			money		default 0	not null,
	parm2			int		default 0	not null,
	rm2			money		default 0	not null,
	gstno2		money		default 0	not null,
	days2			money		default 0	not null,
	roomno		char(5)					 null,
	date			datetime					null
)

if @begin_ is null
	select @begin_ = '1980/1/1'
if @end_ is null
	select @end_ = '2020/1/1'
if rtrim(@rmtype) is null
	select @rmtype = '%'

insert #gout(code,descript,accnt,master,groupno,rm1,gstno1,days1,rm2,gstno2,days2,roomno,date) 
	select a.type, a.descript, b.master, b.master, '', (isnull(b.rmrate,0)), (isnull(b.gstno,0)), (isnull(b.quantity,0)), (isnull(b.rmrate,0)), (isnull(b.gstno,0)), (isnull(b.quantity,0)),b.roomno,b.date
		From typim a, rmuserate b
			where a.type like @rmtype  and a.type = b.type and b.market not in (select code from mktcode where flag = 'HSE')
				and b.date>=@begin_ and b.date<=@end_
					

//update #gout set rm1 = isnull((select sum(rincome) from ymktsummaryrep_detail b where b.date>=@begin_ and b.date<=@end_ 
//					and rtrim(b.roomno) = rtrim(#gout.roomno)  group by b.roomno),0)
update #gout set gstno1 = isnull((select sum(pquan) from ymktsummaryrep_detail b where b.date>=@begin_ and b.date<=@end_ 
					and rtrim(b.roomno) = rtrim(#gout.roomno) and market not in (select code from mktcode where flag = 'HSE')
						 and b.date = #gout.date group by b.date,b.roomno ),0)

update #gout set rm2 = rm1,gstno2 = gstno1

update #gout set groupno = isnull(b.groupno,'') from master b where #gout.master = b.accnt
update #gout set groupno = isnull(b.groupno,'') from hmaster b where #gout.master = b.accnt

//insert #gout(code,descript,accnt,master,groupno,rm1,gstno1,days1,rm2,gstno2,days2) 
//	select a.type, a.descript, b.accnt, b.master, b.groupno, b.rm, b.gstno, b.i_days, b.rm, b.gstno, b.i_days
//		From typim a, ycus_xf b
//		Where a.type like @rmtype  and a.type = b.type
//			and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'
//insert #gout(code,descript,accnt,master,groupno,rm1,gstno1,days1,rm2,gstno2,days2) 
//	select a.type, a.descript, b.accnt, b.master, b.groupno, b.rm, 0, b.i_days, b.rm, 0, b.i_days
//		From typim a, ycus_xf b
//		Where a.type like @rmtype and a.type = b.type
//			and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'

//update #gout set days1 = 0, days2=0 where accnt <> master
update #gout set parm1=0, parm2=1 where accnt like '[GM]%' //or groupno<>'' 

if charindex(@zero, 'tTyY') = 0
	delete #gout where rm1=0 and days1=0 and gstno1=0
else
	insert #gout(code, descript,accnt,master,groupno) 
     select type, descript, '', '','' from typim where type not in (select distinct code from #gout)

select code, descript, sum(gstno1*parm1),sum(days1*parm1), sum(rm1*parm1), sum(gstno2*parm2), sum(days2*parm2), sum(rm2*parm2)
	from #gout
	group by code,descript
	order by code,descript

return 0
;

//delete  auto_report where id ='rep!RMTYPESAILE';
//INSERT INTO auto_report VALUES (
//	'U',
//	'tab',
//	'rep!RMTYPESAILE',
//	'RMSALE',
//	'房类销售分析报表-1',
//	'房类销售分析报表-1',
//	'房类销售分析报表-1',
//	'1,5,7,M',
//	'1,5,7,M',
//	'_com_p_房类销售分析报表-1;(exec p_gds_salesrep1_rmtype ''#char05!请输入房类代码!%#'',''#date1!请输入起始日期!#Bdate&-30&&##'',''#date2!请输入终止日期!#Bdate1##'',''f'' resultset=char12, char30, mone10_11, mone10_12, mone10_13, mone10_21, mone10_22, mone10_23);char12:代码=5;char30:描述=20;mone10_11:人数=7=0=alignment="2";mone10_12:间天=7=0=alignment="2";mone10_13:房费=10=0=alignment="1";mone10_16==mone10_13/mone10_12:平均房价=9=0=alignment="1";mone10_21:人数=7=0=alignment="2";mone10_22:间天=10=0=alignment="1";mone10_23:房费=9=0=alignment="1";mone10_26==mone10_23/mone10_22:平均房价=9=0=alignment="1"headerds=[header=6 summary=2 autoappe=0]computes=c_yshu:''页次(''+string(page(),''0'')+''/''+string(pagecount(),''0'')+'')'':header:4::mone10_26:mone10_26::alignment="2" border="0"!computes=c_11:sum( mone10_11 for all ):summary:1::mone10_11:mone10_11::alignment="2" format="0"!computes=c_12:sum( mone10_12 for all ):summary:1::mone10_12:mone10_12::alignment="2" format="0"!computes=c_13:sum( mone10_13 for all ):summary:1::mone10_13:mone10_13::alignment="1" format="0"!computes=c_21:sum( mone10_21 for all ):summary:1::mone10_21:mone10_21::alignment="1" format="0"!computes=c_22:sum( mone10_22 for all ):summary:1::mone10_22:mone10_22::alignment="1" format="0"!computes=c_23:sum( mone10_23 for all ):summary:1::mone10_23:mone10_23::alignment="1" format="0"!computes=c_16:c_13/c_12:summary:1::mone10_16:mone10_16::alignment="1" format="0"!computes=c_26:c_23/c_22:summary:1::mone10_26:mone10_26::alignment="1" format="0"!texttext=t_title:#hotel#:header:1::char12:mone10_26::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=t_title1:房类销售分析报表-1:header:2::char12:mone10_26::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=t_title2:<#date1#-#date2#>:header:3::char12:mone10_26::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=t_dte:房类 = #char05#:header:4::char12:mone10_12::alignment="0" border="0"! texttext=t_code::header:5::char12:char30::alignment="2" border="4"! texttext=t_fit:散客:header:5::mone10_11:mone10_16::alignment="2" border="4"! texttext=t_grp:团体会议:header:5::mone10_21:mone10_26::alignment="2" border="4"! texttext=t_date:打印时间 #pdate#:summary:2::char12:mone10_12::alignment="0" border="0"! texttext=t_heji:合计:summary:1::char12:char30::border="4"!',
//	'release 6;datawindow(units=1 timer_interval=0 color=79741120 processing=0 print.documentname=""  print.orientation=0 print.margin.left=110 print.margin.right=110 print.margin.top=96 print.margin.bottom=96 print.paper.size=0 print.paper.source=0 selected.mouse=no)header(height=0 )summary(height=0 color="536870912" )footer(height=0 color="536870912" )detail(height=183 color="536870912" )table(column=(type=char(254) updatewhereclause=no name=char05 dbname="char05"  )column=(type=datetime updatewhereclause=no name=date1 dbname="date1"  values=""  )column=(type=datetime updatewhereclause=no name=date2 dbname="date2"  values=""  ))text(name=char05_t band=detail font.charset="0" font.face="Tahoma" font.family="2" font.height="-9" font.pitch="2" font.weight="400" background.mode="1" background.color="536870912" color="0" alignment="1" border="0" x="25" y="14" height="18" width="63" text="房类:" )column(name=char05 tag="" band=detail id=1 x="93" y="14" height="18" width="99" color="0" border="5" alignment="0" format="[general]" edit.focusrectangle=no edit.autohscroll=yes edit.autoselect=yes edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="2" background.color="1090519039" font.charset="0" font.face="Tahoma" font.family="2" font.height="-9" font.pitch="2" font.weight="400" tabsequence=1 )text(name=date1_t band=detail font.charset="0" font.face="Tahoma" font.family="2" font.height="-9" font.pitch="2" font.weight="400" background.mode="1" background.color="536870912" color="0" alignment="1" border="0" x="25" y="38" height="18" width="63" text="开始日期:" )column(name=date1 tag="" band=detail id=2 x="93" y="38" height="18" width="99" color="0" border="5" alignment="0" format="YYYY/MM/DD" ddlb.allowedit=yes ddlb.autohscroll=no ddlb.imemode=0 ddlb.limit=0 ddlb.showlist=no ddlb.sorted=no ddlb.useasborder=no ddlb.vscrollbar=yes ddlb.nilisnull=no ddlb.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="2" background.color="1090519039" font.charset="0" font.face="Tahoma" font.family="2" font.height="-9" font.pitch="2" font.weight="400" tabsequence=2 )text(name=date2_t band=detail font.charset="0" font.face="Tahoma" font.family="2" font.height="-9" font.pitch="2" font.weight="400" background.mode="1" background.color="536870912" color="0" alignment="1" border="0" x="25" y="62" height="18" width="63" text="截至日期:" )column(name=date2 tag="" band=detail id=3 x="93" y="62" height="18" width="99" color="0" border="5" alignment="0" format="YYYY/MM/DD" ddlb.allowedit=yes ddlb.autohscroll=no ddlb.imemode=0 ddlb.limit=0 ddlb.showlist=no ddlb.sorted=no ddlb.useasborder=no ddlb.vscrollbar=yes ddlb.nilisnull=no ddlb.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="2" background.color="1090519039" font.charset="0" font.face="Tahoma" font.family="2" font.height="-9" font.pitch="2" font.weight="400" tabsequence=3 )',
//	'',
//	'F',
//	'F',
//	'GDS',
//	'10-16-2006 14:43:15.860',
//	'FOX',
//	'10-31-2006 15:29:44.660',
//	'');