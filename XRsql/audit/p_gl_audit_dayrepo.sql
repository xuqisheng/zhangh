// 未完, 待续 ......

if exists (select * from sysobjects where name ='p_gl_audit_dayrepo' and type ='P')
	drop proc p_gl_audit_dayrepo;

create proc p_gl_audit_dayrepo
as

declare
	@bdate			datetime, 
	@date				datetime, 
	@bfdate			datetime

create table #dayrepo
(
	accnt			char(7)	not null, 
	number		integer	not null, 
	pccode		char(2)	default '' not null, 
	servcode		char(1)	default '' not null, 
	groupno		char(7)	null, 
	tag			char(3)	null, 
	charge		money		default 0 not null,			/* 借方 */
	credit		money		default 0 not null			/* 贷方 */
)

if exists ( select 1 from gate where audit='T')
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
delete dayrepo
insert dayrepo (bdate, class, pccode, descript) select @bdate, '1', pccode, descript from pccode where pccode < '9'
insert dayrepo (bdate, class, pccode, servcode, descript) values (@bdate, '3', 'AC', '', '')
insert dayrepo (bdate, class, pccode, servcode, descript) values (@bdate, '3', 'AC', 'B', '')
insert dayrepo (bdate, class, pccode, servcode, descript) 
	select @bdate, '1', pccode, 'B', descript2 
	from chgcod where rtrim(servcode) is null and pccode not in ('05', '06')
update dayrepo set descript = '散客房金' where pccode = '01'
update dayrepo set descript = '团体房金' where pccode = '02'
update dayrepo set descript = '写字间费' where pccode = '03'
update dayrepo set class = '2' where pccode in ('12', '13', '14', '15', '16', '17', '18')
/* scan gltemp */
insert #dayrepo select accnt, number, pccode, servcode, groupno, tag, charge, credit 
	from gltemp
update #dayrepo set pccode = 'AC', servcode = '' where pccode in ('03', '05', '06')
update #dayrepo set pccode = '01' where pccode in ('01', '02')
update #dayrepo set pccode = '02' where pccode = '01' and not rtrim(groupno) is null
update #dayrepo set pccode = '03' where pccode = '01' and substring(tag, 3, 1) = 'L'
/* GaoLiang for HZDS 1999/9/17 */
update #dayrepo set servcode = 'A' where pccode in ('01', '02', '03', '12') and servcode = 'B'
update dayrepo set dlos = dlos - isnull((select sum(charge) from #dayrepo a 
	where a.pccode = dayrepo.pccode and a.servcode in ('S', 'T')), 0) 
	where pccode <> 'AC' and servcode = ''
update dayrepo set ddis = ddis - isnull((select sum(charge) from #dayrepo a 
	where a.pccode = dayrepo.pccode and a.servcode = 'H'), 0) 
	where pccode <> 'AC' and servcode = ''
update dayrepo set ddeb = ddeb + isnull((select sum(charge) from #dayrepo a 
	where a.pccode = dayrepo.pccode and a.servcode = 'B'), 0) 
	where pccode <> 'AC' and servcode = 'B'
update dayrepo set ddeb = ddeb + isnull((select sum(charge) from #dayrepo a 
	where a.pccode = dayrepo.pccode and not a.servcode in ('S', 'T', 'H', 'B')), 0)
	where pccode <> 'AC' and servcode = ''
update dayrepo set dcre = dcre + isnull((select sum(credit) from #dayrepo a 
	where a.pccode = dayrepo.pccode), 0) 
	where pccode = 'AC' and servcode = ''
/* scan ostaacct, outtemp */
truncate table #dayrepo
insert #dayrepo select accnt, number, pccode, servcode, groupno, tag, charge, credit 
	from ostaacct
insert #dayrepo select accnt, number, pccode, servcode, groupno, tag, charge, credit 
	from outtemp
update #dayrepo set pccode = 'AC', servcode = '' where pccode in ('03', '05', '06')
update #dayrepo set pccode = '01' where pccode in ('01', '02')
update #dayrepo set pccode = '02' where pccode = '01' and not rtrim(groupno) is null
update #dayrepo set pccode = '03' where pccode = '01' and substring(tag, 3, 1) = 'L'
/* GaoLiang for HZDS 1999/9/17 */
update #dayrepo set servcode = 'A' where pccode in ('01', '02', '03', '12') and servcode = 'B'
update dayrepo set dcre = dcre + isnull((select sum(charge) from #dayrepo a 
	where a.pccode = dayrepo.pccode and a.servcode <> 'B'), 0) 
	where pccode <> 'AC' and servcode = ''
update dayrepo set dcre = dcre + isnull((select sum(charge) from #dayrepo a 
	where a.pccode = dayrepo.pccode and a.servcode = 'B'), 0)
	where pccode <> 'AC' and servcode = 'B'
update dayrepo set dcre = dcre + isnull((select sum(credit) from #dayrepo a 
	where a.pccode = dayrepo.pccode and a.servcode <> 'B'), 0)
	where pccode = 'AC' and servcode = ''
update dayrepo set dcre = dcre + isnull((select sum(credit) from #dayrepo a 
	where a.pccode = dayrepo.pccode and a.servcode = 'B'), 0)
	where pccode = 'AC' and servcode = 'B'
/* GaoLiang for HZDS 1999/9/17 房费,餐费倒扣服务费*/
update dayrepo set 
	ddeb	= (select round(ddeb * 0.10 / 1.20, 2) from dayrepo a where a.servcode = '' and a.pccode = dayrepo.pccode), 
	ddis	= (select round(ddis * 0.10 / 1.20, 2) from dayrepo b where b.servcode = '' and b.pccode = dayrepo.pccode), 
	dcre	= (select round(dcre * 0.10 / 1.20, 2) from dayrepo c where c.servcode = '' and c.pccode = dayrepo.pccode), 
	dlos	= (select round(dlos * 0.10 / 1.20, 2) from dayrepo d where d.servcode = '' and d.pccode = dayrepo.pccode) 
	where servcode = 'B' and pccode in ('01', '02', '03')
update dayrepo set 
	ddeb	= ddeb - (select ddeb from dayrepo a where a.servcode = 'B' and a.pccode = dayrepo.pccode), 
	ddis	= ddis - (select ddis from dayrepo b where b.servcode = 'B' and b.pccode = dayrepo.pccode), 
	dcre	= dcre - (select dcre from dayrepo c where c.servcode = 'B' and c.pccode = dayrepo.pccode), 
	dlos	= dlos - (select dlos from dayrepo d where d.servcode = 'B' and d.pccode = dayrepo.pccode) 
	where servcode = '' and pccode in ('01', '02', '03')
update dayrepo set 
	ddeb	= (select round(ddeb * 0.10 / 1.15, 2) from dayrepo a where a.servcode = '' and a.pccode = dayrepo.pccode), 
	ddis	= (select round(ddis * 0.10 / 1.15, 2) from dayrepo b where b.servcode = '' and b.pccode = dayrepo.pccode), 
	dcre	= (select round(dcre * 0.10 / 1.15, 2) from dayrepo c where c.servcode = '' and c.pccode = dayrepo.pccode), 
	dlos	= (select round(dlos * 0.10 / 1.15, 2) from dayrepo d where d.servcode = '' and d.pccode = dayrepo.pccode) 
	where servcode = 'B' and pccode in ('12')
update dayrepo set 
	ddeb	= ddeb - (select ddeb from dayrepo a where a.servcode = 'B' and a.pccode = dayrepo.pccode), 
	ddis	= ddis - (select ddis from dayrepo b where b.servcode = 'B' and b.pccode = dayrepo.pccode), 
	dcre	= dcre - (select dcre from dayrepo c where c.servcode = 'B' and c.pccode = dayrepo.pccode), 
	dlos	= dlos - (select dlos from dayrepo d where d.servcode = 'B' and d.pccode = dayrepo.pccode) 
	where servcode = '' and pccode in ('12')
/*  */
select @date = max(bdate) from ydayrepo
//if @date is null
//	begin
//	update dayrepo set last = last + (select isnull(sum(charge - credit), 0) from account a 
//		where a.pccode = dayrepo.pccode and a.servcode <> 'B') where servcode = ''
//	update dayrepo set last = last + (select isnull(sum(charge - credit), 0) from account a 
//		where a.pccode = dayrepo.pccode and a.servcode = 'B') where servcode = 'B'
//	end
//else
	update dayrepo set last = a.till from ydayrepo a 
		where a.bdate = @date and dayrepo.pccode = a.pccode and dayrepo.servcode = a.servcode
update dayrepo set till = last + ddeb - ddis - dcre
begin tran 
delete ydayrepo where bdate = @bdate
insert ydayrepo select * from dayrepo
commit tran 
return 0
;
