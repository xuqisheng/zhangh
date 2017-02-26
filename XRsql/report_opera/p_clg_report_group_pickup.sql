--E61的过程,计算分房数
drop proc p_clg_report_group_pickup;
create proc p_clg_report_group_pickup
	@s_time	datetime,
	@e_time	datetime
as
declare
	@accnt 	char(10),
	@orig		char(99),
	@current	char(99),
	@pickup	char(99),
	@avail	char(99),
	@ori		char(50),
	@cdate	char(6),
	@cur		int,
	@pck		int
create table #accnt(accnt char(10))
create table #goutput(
	accnt		char(10),
	day		char(6),
	item		varchar(99),
	value		integer,
	sequence	integer)

if datediff(dd,@s_time,@e_time) > 31
	select @e_time  =dateadd(dd,31, @s_time)    -- 30 days
else if datediff(dd,@s_time,@e_time) < 0
	select @e_time  =dateadd(dd, 15, @s_time)    -- 15 days

declare c_accnt cursor for select accnt from #accnt

while @s_time <= @e_time
begin
	truncate table #accnt
	insert into #accnt select accnt from master where class='G' and charindex(sta,'IR')>0 
		and datediff(dd,arr,@s_time)>=0 and datediff(dd,dep,@s_time)<=0
	open c_accnt
	fetch c_accnt into @accnt
	while @@sqlstatus=0
	begin
		--为了产生报表的左部分，如自由格式。
		select @orig=convert(char(54),b.name)+'Orig' from master a,guest b where b.no=a.haccnt and a.accnt=@accnt
		select @current='Block Code '+blkcode+'          Start Date   '+convert(char(10),arr,11)+'   Current' from master where accnt=@accnt
		select @pickup='Src    '+src+'                      Status                           Pickup' from master where accnt=@accnt
		select @avail='Mkt    '+market+'       Owner '+convert(char(16),saleid)+'Rate '+ratecode+'   Avail' from master where accnt=@accnt
		select @ori='Origin            Cutoff Days/Dat      0/'
		--统计当天房数
		select @cur=sum(a.quantity) from rsvsaccnt a where datediff(dd,a.begin_,@s_time)>=0 and datediff(dd,a.end_,@s_time)<=0
			and (a.accnt=@accnt or exists(select 1 from master b where b.accnt=a.accnt and b.groupno=@accnt))
		select @pck=@cur
		--报表中Orig,Avail的房数都是0 ?
		select @cdate=convert(char(6),@s_time,7)
		insert into #goutput values(@accnt,@cdate,@orig,0,1)
		insert into #goutput values(@accnt,@cdate,@current,@cur,2)
		insert into #goutput values(@accnt,@cdate,@pickup,@pck,3)
		insert into #goutput values(@accnt,@cdate,@avail,0,4)
		insert into #goutput values(@accnt,@cdate,@ori,null,5)
	
		fetch c_accnt into @accnt
	end
	close c_accnt
	select @s_time = dateadd(day, 1, @s_time)
end
deallocate cursor c_accnt

select * from #goutput
;