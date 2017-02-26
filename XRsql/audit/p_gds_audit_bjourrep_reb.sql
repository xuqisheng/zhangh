
// 不含款待
//		----------- 指定日期重建  2001/07

if exists (select * from sysobjects where name  = 'p_gds_audit_bjourrep_reb' and type = 'P')
	drop proc p_gds_audit_bjourrep_reb;
create proc p_gds_audit_bjourrep_reb
	@bdate		datetime
as
declare 
	@duringaudit	char(1), 
	@isfstday		char(1), 
	@isyfstday		char(1), 
	@num1				int,
	@num2				int,
	@line				int,
	@ent				money

select * into #bjourrep from bjourrep where 1 = 2
// jierep
insert #bjourrep(date,item,class,descript,day,month)
	select @bdate,order_,class,descript,day99,month99 
		from yjierep where class<'999' and mode<>'E' and date=@bdate order by class

// line
update #bjourrep set line = (select count(1) from #bjourrep a where a.class <= #bjourrep.class)
select @num1 = count(1) from #bjourrep

// cashrep 
create table #gcashrep (
	paycode		char(3)			 not null,
	descript		varchar(12)		 not null,
	dm				money	default 0 null,
	mm				money	default 0 null
)
insert #gcashrep select paycode,descript2,0,0 from paymth where paycode<'C86'  // C53
declare @monthbeg  datetime
select @monthbeg = @bdate, @isfstday='F'
exec p_hry_audit_fstday @monthbeg, @isfstday out, @isyfstday out
while @isfstday = 'F'
	begin
	select @monthbeg=dateadd(dd,-1,@monthbeg)
	exec p_hry_audit_fstday @monthbeg,@isfstday out,@isyfstday out
	end 

update #gcashrep set dm = (select isnull(sum(credit),0) from ycashrep a
		where #gcashrep.paycode=a.ccode and a.date=@bdate)
update #gcashrep set mm = (select isnull(sum(credit),0) from ycashrep a
		where #gcashrep.paycode=a.ccode and a.date>=@monthbeg and a.date<=@bdate )
delete #gcashrep where dm=0 and mm=0
select @num2 = count(1) from #gcashrep

while @num1 < @num2 + 5
	begin
	select @num1 = @num1 + 1
	insert #bjourrep(date,class,descript,line)	select @bdate, '', '', @num1
	end
select @line = @num1 + 1  // + 合计
insert #bjourrep(date,class,descript,line)	select @bdate, '', '', @line

// 倒入 款项
declare 	@dm_tl	money, @mm_tl	money
declare 	@dm	money, @mm	money
declare 	@paycode char(3), @descript char(12)
select @dm_tl = isnull(sum(dm), 0), @mm_tl = isnull(sum(mm), 0) from #gcashrep
update #bjourrep set item1='1.', descript1='现金收入',day1 = @dm_tl, month1=@mm_tl where line=1
declare c_0 cursor for select paycode,descript,dm,mm from #gcashrep order by paycode
select @num1 = 1
open c_0
fetch c_0 into @paycode,@descript,@dm,@mm
while @@sqlstatus = 0
	begin
	select @num1 = @num1 + 1
	update #bjourrep set class1=@paycode, descript1='   '+@descript,day1 = @dm, month1=@mm where line=@num1
	fetch c_0 into @paycode,@descript,@dm,@mm
	end
close c_0
deallocate cursor c_0
select @num1 = @num1 + 1
update #bjourrep set item1='2.',descript1=a.descript,day1 = sumcre, month1=sumcrem from ydairep a
	where line=@num1 and a.class='02000' and a.date=@bdate
select @num1 = @num1 + 1
update #bjourrep set item1='3.',descript1=a.descript,day1 = sumcre, month1=sumcrem from ydairep a
	where line=@num1 and a.class='03000' and a.date=@bdate
select @num1 = @num1 + 1
update #bjourrep set item1='4.',descript1=a.descript,day1 = sumcre, month1=sumcrem from ydairep a
	where line=@num1 and a.class='04000' and a.date=@bdate
select @num1 = @num1 + 1

// 款待
//update #bjourrep set item1='5.',descript1=a.descript,day1 = sumcre, month1=sumcrem from ydairep a
//	where line=@num1 and a.class='08000' and a.date=@bdate

// 合计
select @ent = isnull(sum(day99),0) from yjierep where mode='E' and date=@bdate
update #bjourrep set item1='5.',descript1=a.descript,day1 = a.sumcre-@ent, month1=a.sumcrem-@ent from ydairep a
	where line=@line and a.class='09000' and a.date=@bdate
update #bjourrep set item=a.order_,class=a.class, descript=a.descript,day = a.day99-@ent, month=a.month99-@ent from yjierep a
	where line=@line and a.class='999' and a.date=@bdate

// 计划
update #bjourrep set pmonth = b.pmonth from jieplan b where #bjourrep.class=b.class

// 去年
update #bjourrep set lmonth = b.month from ybjourrep b
	where dateadd(#bjourrep.year, -1, @bdate) =  b.date 
			and #bjourrep.class = b.class

delete ybjourrep where date=@bdate
insert ybjourrep select * from #bjourrep

return 0
;
