
/* realtime room change and rate change report */
/* 本日实时换房或改房价报表 */

if exists (select 1 from sysobjects where name = 'pre_rmrtchangerep' and type = 'U' )
	drop table pre_rmrtchangerep;
create table pre_rmrtchangerep
(
	pc_id		char(4)		not null, 
	accnt		char(10)		not null, 
	name		varchar(50)	default '' not null, 
	groupno	char(10)		default '' null, 
	fmroomno	char(5)		default '' null, 
	fmrate	money			default 0  null, 
	toroomno	char(5)		default '' null, 
	torate	money			default 0  null, 
	cby		char(10)		default '' null, 
	changed	datetime		null, 
	logmark	integer		default 0, 
)
exec sp_primarykey pre_rmrtchangerep, pc_id, accnt, logmark
create unique index index1 on pre_rmrtchangerep(pc_id, accnt, logmark)
;

if exists (select 1 from sysobjects where name = 'p_gds_pre_rmrtchangerep' and type = 'P' )
	drop proc p_gds_pre_rmrtchangerep;
create proc p_gds_pre_rmrtchangerep
	@pc_id			char(4)
as

declare
	@accnt			char(10),
	@groupno			char(10),
	@fmroomno		char(5),
	@fmsetrate		money,
	@toroomno		char(5),
	@tosetrate		money,
	@cby				char(10),
	@changed			datetime,
	@fmlogmark		integer,
	@tologmark		integer,
	@fstlogmark		integer,
	@logmark			integer,

	@tmproomno		char(5),
	@tmpsetrate		money,
	@invalid_sta	varchar(255)



delete pre_rmrtchangerep where pc_id = @pc_id
select @invalid_sta = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), 'ODEX')

declare c_master_log cursor for select groupno, roomno, setrate, cby, changed, logmark
	from master_log where accnt = @accnt and logmark >= @fstlogmark and logmark <= @tologmark
	order by logmark
declare c_master_till cursor for select accnt, logmark
	from master_till where class='F' and charindex(sta, @invalid_sta) = 0
	order by accnt
open c_master_till
fetch c_master_till into @accnt, @fmlogmark
while @@sqlstatus = 0
	begin
	select @tologmark = logmark from master where accnt = @accnt
	select @fstlogmark = min(logmark) from master_log  where accnt = @accnt and sta = 'I' and logmark >= @fmlogmark and logmark <= @tologmark
	if @fstlogmark is null
		begin
		fetch c_master_till into @accnt, @fmlogmark
		continue
		end
	open c_master_log
	fetch c_master_log into @groupno, @tmproomno, @tmpsetrate, @cby, @changed, @logmark
	while @@sqlstatus = 0
		begin
		select @fmroomno=@tmproomno, @fmsetrate=@tmpsetrate
		fetch  c_master_log into @groupno, @tmproomno, @tmpsetrate, @cby, @changed, @logmark
		select @toroomno=@tmproomno, @tosetrate=@tmpsetrate
		if @@sqlstatus <> 0
			break
		if @fmroomno <> @toroomno or @fmsetrate <> @tosetrate
			insert pre_rmrtchangerep values (@pc_id, @accnt, '', @groupno, @fmroomno, @fmsetrate, @toroomno, @tosetrate, @cby, @changed, @logmark)
		select @fmroomno = @toroomno, @fmsetrate=@tosetrate
		end
	close  c_master_log
	fetch c_master_till into @accnt, @fmlogmark
	end
close c_master_till
deallocate cursor c_master_till

declare c_master cursor for select accnt, logmark
	from master where accnt not in (select accnt from master_till) and class='F'
	order by accnt
open c_master
fetch c_master into @accnt, @tologmark
while @@sqlstatus = 0
	begin
	select @fstlogmark = min(logmark) from master_log  where accnt = @accnt and sta = 'I' and logmark <= @tologmark
	if @fstlogmark is null
		begin
		fetch c_master into @accnt, @tologmark
		continue
		end
	open c_master_log
	fetch  c_master_log into @groupno, @tmproomno, @tmpsetrate, @cby, @changed, @logmark
	while @@sqlstatus = 0
		begin
		select @fmroomno=@tmproomno, @fmsetrate=@tmpsetrate
		fetch  c_master_log into @groupno, @tmproomno, @tmpsetrate, @cby, @changed, @logmark
		select @toroomno=@tmproomno, @tosetrate=@tmpsetrate
		if @@sqlstatus <> 0
			break
		if @fmroomno <> @toroomno or @fmsetrate <> @tosetrate
			insert pre_rmrtchangerep values (@pc_id, @accnt, '', @groupno, @fmroomno, @fmsetrate, @toroomno, @tosetrate, @cby, @changed, @logmark)
		select @fmroomno = @toroomno, @fmsetrate=@tosetrate
		end
	close c_master_log
	fetch c_master into @accnt, @tologmark
	end
close c_master
deallocate cursor c_master_log
deallocate cursor c_master

update pre_rmrtchangerep set name = b.haccnt	from master_des b	where pre_rmrtchangerep.pc_id = @pc_id and b.accnt=pre_rmrtchangerep.accnt

return 0
;

