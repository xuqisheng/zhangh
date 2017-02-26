IF OBJECT_ID('p_yjw_lgfl_rsvsrc_detail') IS NOT NULL
	drop proc p_yjw_lgfl_rsvsrc_detail;
create proc p_yjw_lgfl_rsvsrc_detail
	@accnt			char(10),
   @date_         datetime
as
declare
	@laccnt				char(7),
	@lguestid			char(7),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer,
   @ldate            datetime

declare
	@old_ratecode		varchar(10),			@new_ratecode		varchar(10),
	@old_rate			money,					@new_rate			money,
	@old_src 			char(3),					@new_src				char(3),
	@old_market			char(3),					@new_market			char(3),
	@old_packages		varchar(50),			@new_packages		char(50)


if @accnt is null
	declare c_rsvdtl cursor for select distinct accnt,date_ from rsvsrc_detail_log
else
	declare c_rsvdtl cursor for select distinct accnt,date_ from rsvsrc_detail_log where accnt = @accnt and date_=@date_

-- name 字段已经没有了
declare c_log_rsvdtl cursor for 
  	SELECT ratecode,rate,src,market,packages,cby,changed
		from rsvsrc_detail_log where accnt = @accnt and date_=@date_ 
	order by logmark

open c_rsvdtl
fetch c_rsvdtl into @laccnt,@ldate
while @@sqlstatus =0
   begin
	select @row = 0
	open c_log_rsvdtl
	fetch c_log_rsvdtl into @new_ratecode,@new_rate,@new_src,@new_market,@new_packages,@cby,@changed

	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
				if @new_ratecode != @old_ratecode
					insert lgfl values ('r_ratecode', 'r:'+@laccnt, @old_ratecode, @new_ratecode, @cby, @changed)
				if @new_src != @old_src
					insert lgfl values ('r_src', 'r:'+@laccnt, @old_src, @new_src, @cby, @changed)
				if @new_rate != @old_rate
					insert lgfl values ('r_rate', 'r:'+@laccnt, @old_rate, @new_rate, @cby, @changed)
				if @new_market != @old_market
					insert lgfl values ('r_market',  'r:'+@laccnt, @old_market, @new_market, @cby, @changed)
				if @new_packages != @old_packages
					insert lgfl values ('r_packages',  'r:'+@laccnt, @old_packages, @new_packages, @cby, @changed)
			end
		select 	@old_ratecode = @new_ratecode,
					@old_rate = @new_rate,
					@old_src = @new_src,
					@old_market = @new_market,
					@old_packages = @new_packages
			

		fetch c_log_rsvdtl into @new_ratecode,@new_rate,@new_src,@new_market,@new_packages,@cby,@changed
		end
	close c_log_rsvdtl
	if @row > 0
		delete rsvsrc_detail_log where accnt = @laccnt and  date_=@date_ and logmark <= @logmark
	fetch c_rsvdtl into @laccnt,@ldate
	end

deallocate cursor c_log_rsvdtl
close c_rsvdtl
deallocate cursor c_rsvdtl

return
;
