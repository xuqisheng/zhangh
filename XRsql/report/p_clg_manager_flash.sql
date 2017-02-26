IF OBJECT_ID('dbo.p_clg_manager_flash') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_manager_flash
;
create proc p_clg_manager_flash
	@mode	char(2),
	@date	datetime,
	@last char(1),
	@gtype varchar(250),
	@lang	int
as
declare
	@code	varchar(40),
	@row	int,
	@days int,
	@seq	int,
	@date1	datetime,
	@ldate	datetime,
   @disp char(1),
   @dmode char(1),
	@reslt	money,
	@resltm	money,
	@reslty	money

create table #out
(	code			varchar(40),
	day01			money default 0,
	day02			money default 0,
	day03			money default 0,
	day04			money default 0,
	day05			money default 0,
	day06			money default 0,
	day07			money default 0,
	ttl			money default 0,
	lday01		money default 0,
	lday02		money default 0,
	lday03		money default 0,
	lday04		money default 0,
	lday05		money default 0,
	lday06		money default 0,
	lday07		money default 0,
	lttl			money default 0,
	seq		int
)

--gtype
if @gtype<>'%'
	select @gtype=','+rtrim(@gtype)+','

select @seq=0
select @disp=substring(@mode,2,1),@dmode=substring(@mode,1,1),@ldate = dateadd(yy,-1,@date)
		
if @disp='A'
    declare c_cur cursor for select class,row from audit_impdata order by sequence
else
    declare c_cur cursor for select class,row from audit_impdata where halt='F' order by sequence
open c_cur
fetch c_cur into @code,@row
while @@sqlstatus=0
	begin
	select @seq=@seq+1
	insert into #out(code,seq) values(@code,@seq)

	if @dmode = 'M'
		begin
        if @gtype='%'
            select @reslt = sum(amount_m) from yaudit_impdata where datediff(dd,date,@date)=0 and class=@code
        else
		select @reslt = sum(amount_m) from ymanager_report where datediff(dd,date,@date)=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
		update #out set day01=@reslt where code=@code
		end
	else if @dmode = 'W'
		begin
		--如何判断第一天？mon=2，sun=1
		select @days = 2 - datepart(weekday,@date)
		if @days = 1
			select @days = -6
		select @date1 = dateadd(dd,@days,@date)
        if @gtype='%'
           select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,@date1)=0 and class=@code
        else
		select @reslt = sum(amount) from ymanager_report where datediff(dd,date,@date1)=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
		update #out set day01=@reslt where code=@code
        if @gtype='%'
            select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,dateadd(dd,1,@date1))=0 and class=@code
        else
		select @reslt = sum(amount) from ymanager_report where datediff(dd,date,dateadd(dd,1,@date1))=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
		update #out set day02=@reslt where code=@code
        if @gtype='%'
            select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,dateadd(dd,2,@date1))=0 and class=@code
        else
		select @reslt = sum(amount) from ymanager_report where datediff(dd,date,dateadd(dd,2,@date1))=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
		update #out set day03=@reslt where code=@code
        if @gtype='%'
            select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,dateadd(dd,3,@date1))=0 and class=@code
        else
		select @reslt = sum(amount) from ymanager_report where datediff(dd,date,dateadd(dd,3,@date1))=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
		update #out set day04=@reslt where code=@code
        if @gtype='%'
            select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,dateadd(dd,4,@date1))=0 and class=@code
        else
		select @reslt = sum(amount) from ymanager_report where datediff(dd,date,dateadd(dd,4,@date1))=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
		update #out set day05=@reslt where code=@code
        if @gtype='%'
            select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,dateadd(dd,5,@date1))=0 and class=@code
        else
		select @reslt = sum(amount) from ymanager_report where datediff(dd,date,dateadd(dd,5,@date1))=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
		update #out set day06=@reslt where code=@code
        if @gtype='%'
            select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,dateadd(dd,6,@date1))=0 and class=@code
        else
		select @reslt = sum(amount) from ymanager_report where datediff(dd,date,dateadd(dd,6,@date1))=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
		update #out set day07=@reslt where code=@code
		update #out set ttl=isnull(day01,0)+isnull(day02,0)+isnull(day03,0)+isnull(day04,0)+isnull(day05,0)+isnull(day06,0)+isnull(day07,0) where code<>''
		end
	else if @dmode = 'D'
		begin
        if @gtype='%'
        select @reslt = sum(amount),@resltm=sum(amount_m),@reslty=sum(amount_y) from yaudit_impdata where datediff(dd,date,@date)=0 and class=@code
        else
		select @reslt = sum(amount),@resltm=sum(amount_m),@reslty=sum(amount_y) from ymanager_report where datediff(dd,date,@date)=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
		update #out set day01=@reslt,day02=@resltm,day03=@reslty where code=@code
		end
	if @last='T'
		begin
		if @dmode = 'M'
			begin
            if @gtype='%'
                select @reslt = sum(amount_m) from yaudit_impdata where datediff(dd,date,@ldate)=0 and class=@code
            else
    			select @reslt = sum(amount_m) from ymanager_report where datediff(dd,date,@ldate)=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0) 
			update #out set lday01=@reslt where code=@code
			end
		else if @dmode = 'W'
			begin
			--如何判断第一天？
			select @days = 2 - datepart(weekday,@ldate)
			if @days = 1
				select @days = -6
			select @date1 = dateadd(dd,@days,@ldate)
            if @gtype='%'
                select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,@date1)=0 and class=@code
            else
			select @reslt = sum(amount) from ymanager_report where datediff(dd,date,@date1)=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
			update #out set lday01=@reslt where code=@code
            if @gtype='%'
                select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,dateadd(dd,1,@date1))=0 and class=@code
            else
			select @reslt = sum(amount) from ymanager_report where datediff(dd,date,dateadd(dd,1,@date1))=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
			update #out set lday02=@reslt where code=@code
            if @gtype='%'
                select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,dateadd(dd,2,@date1))=0 and class=@code
            else
			select @reslt = sum(amount) from ymanager_report where datediff(dd,date,dateadd(dd,2,@date1))=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
			update #out set lday03=@reslt where code=@code
            if @gtype='%'
                select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,dateadd(dd,3,@date1))=0 and class=@code
            else
			select @reslt = sum(amount) from ymanager_report where datediff(dd,date,dateadd(dd,3,@date1))=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
			update #out set lday04=@reslt where code=@code
            if @gtype='%'
                select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,dateadd(dd,4,@date1))=0 and class=@code
            else
			select @reslt = sum(amount) from ymanager_report where datediff(dd,date,dateadd(dd,4,@date1))=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
			update #out set lday05=@reslt where code=@code
            if @gtype='%'
                select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,dateadd(dd,5,@date1))=0 and class=@code
            else
			select @reslt = sum(amount) from ymanager_report where datediff(dd,date,dateadd(dd,5,@date1))=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
			update #out set lday06=@reslt where code=@code
            if @gtype='%'
            	select @reslt = sum(amount) from yaudit_impdata where datediff(dd,date,dateadd(dd,6,@date1))=0 and class=@code
            else
			select @reslt = sum(amount) from ymanager_report where datediff(dd,date,dateadd(dd,6,@date1))=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0)
			update #out set lday07=@reslt where code=@code
			update #out set lttl=isnull(lday01,0)+isnull(lday02,0)+isnull(lday03,0)+isnull(lday04,0)+isnull(lday05,0)+isnull(lday06,0)+isnull(lday07,0) where code<>''
			end
		else if @dmode = 'D'
			begin
            if @gtype='%'
                select @reslt = sum(amount),@resltm=sum(amount_m),@reslty=sum(amount_y) from yaudit_impdata where datediff(dd,date,@ldate)=0 and class=@code
            else
			 select @reslt = sum(amount),@resltm=sum(amount_m),@reslty=sum(amount_y) from ymanager_report where datediff(dd,date,@ldate)=0 and class=@code and (@gtype='%' or charindex(','+rtrim(gtype)+',',@gtype)>0) 
			update #out set lday01=@reslt,lday02=@resltm,lday03=@reslty where code=@code
			end
		end



	while @row>0
		begin
		select @row=@row - 1,@seq=@seq+1
		insert into #out(code,seq) values('',@seq)
		end
	fetch c_cur into @code,@row
	end
close c_cur
deallocate cursor c_cur

--用法修改 clg b.line改成显示格式 b。row同时控制下划线,空行
if @lang=0
	select b.class,b.descript,a.day01,a.day02,a.day03,a.day04,a.day05,a.day06,a.day07,a.ttl,a.lday01,a.lday02,a.lday03,a.lday04,a.lday05,a.lday06,a.lday07,a.lttl,b.line,b.row
	 from #out a,audit_impdata b
	 where a.code*=b.class order by a.seq
else
	select b.class,b.descript1,a.day01,a.day02,a.day03,a.day04,a.day05,a.day06,a.day07,a.ttl,a.lday01,a.lday02,a.lday03,a.lday04,a.lday05,a.lday06,a.lday07,a.lttl,b.line,b.row
	 from #out a,audit_impdata b
	 where a.code*=b.class order by a.seq
;
