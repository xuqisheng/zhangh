--------------------------------------------------------------------------------
-- ar 帐户明细消费报告
--------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_accnt_ardetail_rep" and type = "P")
	drop proc p_gds_accnt_ardetail_rep;
create proc  p_gds_accnt_ardetail_rep
	@accnt				varchar(11), 
	@begin				datetime, 
	@end					datetime,
	@printall			char(1) = 'F'

as

create table #account_ar
(
	ar					char(10)			not null,
	arname			varchar(60)		null,
	sta				char(1)			null,
	accnt				char(10)			default ''	null,			/*账号*/
	number			integer			default 0	null,			/*账次*/
	fmaccnt			char(10)			default ''	null,			/*转帐的账号*/
	fmroomno			char(5)			default ''	null,			/*转帐的房号*/
	modu_id			char(2)			default ''	null,
	pccode			char(5)			default ''	null,
	charge			money				default 0	null,
	credit			money				default 0	null,
	amount			money				default 0	null,
	amount1			money				default 0	null,
	ref				char(24)			null,
	ref1				char(10)			null,							/*转帐的billno*/
	ref2				char(50)			null,
	bdate				datetime			default getdate() null,
	log_date			datetime			default getdate() null,
	shift				char(1)			default ''	null,
	empno				char(10)			default ''	null,
	billno			char(10)			null
)

------------------------
-- Condition: accnt
------------------------
select @accnt = ltrim(rtrim(@accnt))
if @accnt is null
	select @accnt = '%'
else
	select @accnt = @accnt + '%'

------------------------
-- Data Ready for FO
------------------------
insert #account_ar (ar, arname, sta, accnt, charge, credit, amount, amount1, ref, ref1, ref2, shift, empno, billno)
	select accnt, '', 'F', a.accnt, sum(a.charge), sum(a.credit), sum(a.charge - a.credit), sum(a.charge - a.credit), 'Transfer from F/O', a.mode1, '', '', '', a.billno
	from account a 
	where a.accnt like @accnt and a.mode1 like 'T%' and a.billno=''
	group by a.accnt, a.mode1, a.billno
-- 结账信息 - 1
update #account_ar set fmaccnt = a.accnt, shift = a.shift1, empno = a.empno1, bdate = a.bdate, log_date = a.date1
	from billno a where #account_ar.ref1 = a.billno
-- 结账信息 - 2
update #account_ar set fmroomno = a.roomno, ref2 = b.name
	from master a, guest b where #account_ar.fmaccnt = a.accnt and a.haccnt = b.no
update #account_ar set fmroomno = a.roomno, ref2 = b.name
	from hmaster a, guest b	where #account_ar.fmaccnt = a.accnt and a.haccnt = b.no

------------------------
-- Other Data
------------------------
insert #account_ar (ar, arname, sta, accnt, number, modu_id, pccode, charge, credit, amount, amount1, ref, ref1, ref2, shift, empno, bdate, log_date, billno)
	select @accnt, '', 'P', a.accnt, a.number, a.modu_id, a.pccode, a.charge, a.credit, a.charge + a.credit, a.charge - a.credit, a.ref, a.ref1, a.ref2, a.shift, a.empno, a.bdate, a.log_date, a.billno
		from account a 
			where a.accnt like @accnt and a.mode1 not like 'T%' and a.pccode<>'9' and a.billno='' --   and a.charge<>0   -- 只显示费用

------------------------
-- Outupt
------------------------
update #account_ar set arname=substring(a.accnt+a.haccnt,1,60) from master_des a where #account_ar.accnt=a.accnt
--select log_date, isnull(pccode, ''), charge-credit, fmroomno,
--	substring(ref + space(24), 1, 24) + substring(ref2 + space(50), 1, 50), 
--	isnull(ref1, ''), empno
select arname, log_date, substring(ref + space(24), 1, 24), charge-credit, 
    isnull(ref1, ''), fmroomno, substring(ref2 + space(50), 1, 50), empno
from #account_ar order by accnt, log_date

;



/*

_com_p_Walk-In 报表;
(exec p_gds_accnt_ardetail_rep '#char11!请输入帐户!AR#',null,null,'' resultset=char601, date11, char602, mone101, char603, char05, char604,char10);
date11:日期=18=yyyy/mm/dd hh|mm=alignment="2";char602:营业项目=16=[general]=alignment="0";mone101:金额=10=0.00=alignment="1";char603:单据号=16=[general]=alignment="2";char05:房号=5=[general]=alignment="2";char604:摘要=28=[general]=alignment="0";char10:工号=10=[general]=alignment="0"
headerds=[header=4 player=3 summary=2 autoappe=0]
group_by=1:2:3:( "char601" )
computes=c_yshu:'页次('+string(page(),'0')+'/'+string(pagecount(),'0')+')':header:3::char10:char10::alignment="2" border="0"!
computes=c_h:char601:header.1:1::date11:char10::alignment="0" !
computes=c_g:sum( mone101 for group 1 ):trailer.1:1::mone101:mone101::alignment="2" format="0.00"!
computes=c_s:sum( mone101 for all ):summary:1::mone101:mone101::alignment="2" format="0.00"!
texttext=t_title:#hotel#:header:1::date11:char10::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_title1:AR帐户明细帐目报表:header:2::date11:char10::border="0" alignment="2" font.height="-12" font.italic="1"!
texttext=t_date:打印时间 #pdate#:header:3::date11:char602::alignment="0" border="0"! 
texttext=t_heji1:合计:trailer.1:1::char602:char602::border="0"  alignment="2"!
texttext=t_heji2:总计:summary:1::char602:char602::border="0"  alignment="2"!

*/