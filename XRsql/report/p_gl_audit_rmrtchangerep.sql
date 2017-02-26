/* 夜审上日换房或改房价报表 */
if exists (select 1 from sysobjects where name = 'p_gl_audit_rmrtchangerep' and type = 'P' )
	drop proc p_gl_audit_rmrtchangerep;

create proc p_gl_audit_rmrtchangerep
as
	
declare 
	@accnt				char(10), 
	@groupno				char(10), 
	@name					varchar(50), 
	@fmroomno			char(5), 
	@fmsetrate			money, 
	@toroomno			char(5), 
	@tosetrate			money, 
	@cby					char(10), 
	@changed				datetime, 
	@fmlogmark			integer, 
	@tologmark			integer, 
	@fstlogmark			integer, 
	@logmark				integer,
	@tmproomno			char(5), 
	@tmpsetrate			money, 
	@invalid_sta		varchar(255),
	@duringaudit      char(1) ,
   @bdate            datetime,
   @bfdate           datetime

select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)

/* init */
truncate table rmrtchangerep

select @invalid_sta = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), 'ODEX')

/* scan master_last */
declare c_master_log cursor for select a.groupno, a.roomno, a.setrate, a.cby, a.changed, a.logmark, b.name
	from master_log a, guest b where a.accnt = @accnt and a.logmark >= @fstlogmark and a.logmark <= @tologmark and a.haccnt = b.no
	order by logmark
declare c_master_last cursor for select accnt, logmark
	from master_last where class = 'F' and charindex(sta, @invalid_sta) = 0
	order by accnt
open c_master_last
fetch c_master_last into @accnt, @fmlogmark
while @@sqlstatus = 0
	begin
	select @tologmark = logmark from master_till where accnt = @accnt 
	select @fstlogmark = min(logmark) from master_log  where accnt = @accnt and sta = 'I' and logmark >= @fmlogmark and logmark <= @tologmark 
	if @fstlogmark is null 
		begin
		fetch c_master_last into @accnt, @fmlogmark
		continue
		end 
	open c_master_log 
	fetch  c_master_log into @groupno, @tmproomno, @tmpsetrate, @cby, @changed, @logmark, @name
	while @@sqlstatus = 0 
		begin
		select @fmroomno = @tmproomno, @fmsetrate = @tmpsetrate
		fetch c_master_log into @groupno, @tmproomno, @tmpsetrate, @cby, @changed, @logmark, @name
		select @toroomno = @tmproomno, @tosetrate = @tmpsetrate
		if @@sqlstatus <> 0 
			break 
		if @fmroomno <> @toroomno or @fmsetrate <> @tosetrate
			insert rmrtchangerep values (@bdate,@accnt, @name, @groupno, '', @fmroomno, @fmsetrate, @toroomno, @tosetrate, @cby, @changed, @logmark)
		select @fmroomno = @toroomno, @fmsetrate = @tosetrate
		end 
	close  c_master_log 
	fetch c_master_last into @accnt, @fmlogmark
	end 
close c_master_last
deallocate cursor c_master_last
/* scan master_till */
declare c_master_till cursor for select accnt, logmark
	from master_till where accnt not in (select accnt from master_last)
	order by accnt
open c_master_till
fetch c_master_till into @accnt, @tologmark
while @@sqlstatus = 0
	begin
	select @fstlogmark = min(logmark) from master_log  where accnt = @accnt and sta = 'I' and logmark <= @tologmark 
	if @fstlogmark is null 
		begin
		fetch c_master_till into @accnt, @tologmark
		continue
		end 
	open c_master_log 
	fetch c_master_log into @groupno, @tmproomno, @tmpsetrate, @cby, @changed, @logmark, @name
	while @@sqlstatus = 0 
		begin
		select @fmroomno = @tmproomno, @fmsetrate = @tmpsetrate
		fetch  c_master_log into @groupno, @tmproomno, @tmpsetrate, @cby, @changed, @logmark, @name
		select @toroomno = @tmproomno, @tosetrate = @tmpsetrate
		if @@sqlstatus <> 0 
			break 
		if @fmroomno <> @toroomno or @fmsetrate <> @tosetrate
			insert rmrtchangerep values (@bdate,@accnt, @name, @groupno, '', @fmroomno, @fmsetrate, @toroomno, @tosetrate, @cby, @changed, @logmark)
		select @fmroomno = @toroomno, @fmsetrate = @tosetrate
		end 
	close  c_master_log 
	fetch c_master_till into @accnt, @tologmark
	end 
close c_master_till
deallocate cursor c_master_log
deallocate cursor c_master_till

update rmrtchangerep set groupname = b.name from master_till a, guest b
	where rmrtchangerep.groupno = a.accnt and a.haccnt = b.no

delete yrmrtchangerep where date = @bdate
insert yrmrtchangerep select * from rmrtchangerep

return 0
;
