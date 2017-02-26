/* 四川锦江代收费用收回明细帐 */

if exists (select * from sysobjects where name ='p_gl_audit_backrepo' and type ='P')
	drop proc p_gl_audit_backrepo;
create proc p_gl_audit_backrepo
	@back				char(2), 		/* 第一位:T.统计收回;F.统计未收;
												第二位:D.按部门码;P.按费用码。*/
	@code				char(5), 
	@begin			datetime,
	@end				datetime
as

declare
	@count			integer, 
	@lastdate		datetime, 
	@date				datetime, 
	@sbegin			char(10),
	@send				char(10)

create table #detail
(
	pccode		char(5)			null, 
	name			char(60)			null, 
	accnt			char(10)			null, 
	roomno		char(5)			null, 
	date			datetime			null, 
	date0			datetime			null, 
	amount		money				default 0 not null, 
	billno		char(10)			null, 
)
select @sbegin = convert(char(10), @begin, 111), @send = convert(char(10), @end, 111)
select @sbegin = 'B' + substring(@sbegin, 4, 1) + substring(@sbegin, 6, 2) + substring(@sbegin, 9, 2) + '0000', 
	@send = 'B' + substring(@send, 4, 1) + substring(@send, 6, 2) + substring(@send, 9, 2) + '9999'
if @back = 'TD'
	begin
	insert #detail (pccode, accnt, date, amount, billno)
		select a.pccode, a.accnt, a.log_date, a.charge, a.billno from account a, pccode b 
		where a.billno >= @sbegin and a.billno <= @send and a.pccode = b.pccode and b.deptno5 = @code
	//
	insert #detail (pccode, accnt, date, amount, billno)
		select a.pccode, a.accnt, a.log_date, a.charge, a.billno from haccount a, pccode b 
		where a.billno >= @sbegin and a.billno <= @send and a.pccode = b.pccode and b.deptno5 = @code
	update #detail set date0 = convert(datetime, '200' + substring(billno, 2, 1) + '/' + 
		substring(billno, 3, 2) + '/' + substring(billno, 5, 2))
	end
else if @back = 'TP'
	begin
	insert #detail (pccode, accnt, date, amount, billno)
		select a.pccode, a.accnt, a.log_date, a.charge, a.billno from account a
		where a.billno >= @sbegin and a.billno <= @send and a.pccode = @code
	//
	insert #detail (pccode, accnt, date, amount, billno)
		select a.pccode, a.accnt, a.log_date, a.charge, a.billno from haccount a
		where a.billno >= @sbegin and a.billno <= @send and a.pccode = @code
	update #detail set date0 = convert(datetime, '200' + substring(billno, 2, 1) + '/' + 
		substring(billno, 3, 2) + '/' + substring(billno, 5, 2))
	end
else if @back = 'FD'
	begin
	insert #detail (pccode, accnt, date, amount, billno)
		select a.pccode, a.accnt, a.log_date, a.charge, a.billno from account a, pccode b 
		where a.billno = ''and a.pccode = b.pccode and b.deptno5 = @code
	end
else if @back = 'FP'
	begin
	insert #detail (pccode, accnt, date, amount, billno)
		select a.pccode, a.accnt, a.log_date, a.charge, a.billno from account a
		where a.billno = '' and a.pccode = @code
	end
//
update #detail set roomno = a.roomno, name = b.name from master a,guest b where a.accnt = #detail.accnt and a.haccnt = b.no
update #detail set roomno = a.roomno, name = b.name from hmaster a,guest b where a.accnt = #detail.accnt and a.haccnt = b.no
select b.descript + b.descript1, c.descript, a.date, a.date0, a.amount, a.roomno, a.name,a.pccode
	from #detail a, pccode b, basecode c
	where a.pccode = b.pccode and b.deptno5 = c.code and c.cat = 'chgcod_deptno5'
return 0
;
