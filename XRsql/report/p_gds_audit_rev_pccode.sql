
if object_id('p_gds_audit_rev_pccode') is not null
	drop proc p_gds_audit_rev_pccode;
create proc p_gds_audit_rev_pccode
as
-- for Opera Report : Payment and Revenue 
declare
	@duringaudit	char(1),
	@isfstday		char(1),
	@isyfstday		char(1),
	@bdate			datetime,
	@bfdate			datetime,
	@reslt			money,
	@reslt1			money,
	@reslt2			money,
	@cdate			char(6),
	@modu_ids		varchar(255),
	@hotel			varchar(255)

-- audit date 
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)

-- init data 
truncate table rev_pccode
insert rev_pccode(date,pccode,day,month,year)
	select @bfdate,a.pccode,0,isnull(b.month,0),isnull(b.year,0) 
	from pccode a, yrev_pccode b 
		where a.pccode*=b.pccode and b.date = @bfdate

-- parms
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#05#')

-- data src: gltemp
update rev_pccode set day = isnull((select sum(a.charge) from gltemp a where a.pccode=rev_pccode.pccode and charindex(a.modu_id, @modu_ids) > 0),0) from pccode where rev_pccode.pccode=pccode.pccode and pccode.argcode<'9'
update rev_pccode set day = isnull((select sum(a.credit) from gltemp a where a.pccode=rev_pccode.pccode and charindex(a.modu_id, @modu_ids) > 0),0) from pccode where rev_pccode.pccode=pccode.pccode and pccode.argcode>='9'

-- data src: bos 
select @hotel = value from sysoption where catalog = 'hotel' and item='ename'
if @hotel = 'State Guest Hotel Beijing'  -- 
begin
	update rev_pccode set day = day + isnull((select sum(a.fee - a.fee_serve) from bos_hfolio a where 
		a.chgcod=rev_pccode.pccode and a.chgcod >= '300' and a.chgcod <= '309' and a.sta = 'O' and a.bdate = @bdate),0)
	update rev_pccode set day = day + isnull((select sum(a.fee_serve) from bos_hfolio a where 
		rev_pccode.pccode = '309' and a.chgcod >= '300' and a.chgcod <= '309' and a.sta = 'O' and a.bdate = @bdate),0)
	update rev_pccode set day = day + isnull((select sum(a.fee) from bos_hfolio a where 
		a.chgcod=rev_pccode.pccode and (a.chgcod < '300' or a.chgcod > '309') and a.sta = 'O' and a.bdate = @bdate),0)
end
else
	update rev_pccode set day = day + isnull((select sum(a.fee) from bos_hfolio a where a.chgcod=rev_pccode.pccode and a.sta = 'O' and a.bdate = @bdate),0)
update rev_pccode set day = day + isnull((select sum(a.amount) from bos_haccount a where a.code=rev_pccode.pccode and a.bdate = @bdate),0)

-- data src: pos 
update rev_pccode set day = day + isnull((select sum(a.feed) from ydeptjie a,pos_int_pccode b where a.pccode=b.pos_pccode and a.shift=b.shift and b.class= '2'
	and a.code = '6' and a.empno = '{{{' and a.date=@bdate and b.pccode=rev_pccode.pccode),0)
update rev_pccode set day = day + isnull((select sum(a.feed) from ydeptjie a,pos_pccode b where a.pccode=b.pccode
 and a.code = '6' and a.empno = '{{{' and a.date=@bdate and b.chgcod=rev_pccode.pccode and b.pccode not in (select pos_pccode from pos_int_pccode)),0)
update rev_pccode set day = day + isnull((select sum(a.creditd) from ydeptdai a,pccode b where a.empno='{{{' and a.shift='9' and a.date=@bdate
 and a.paycode=b.deptno1 and b.pccode=rev_pccode.pccode),0)
update rev_pccode set day = isnull((select sumcre from ydairep where class='02000' and date=@bdate),0) where pccode in (select pccode from pccode where deptno2='TOA')

-- 
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday ='T'
	update rev_pccode set month = 0
if @isyfstday ='T'
	update rev_pccode set month = 0,year=0
update rev_pccode set month = month  +  day,year = year  +  day, date=@bdate
delete yrev_pccode where date = @bdate
insert yrev_pccode select * from rev_pccode

return 0;
