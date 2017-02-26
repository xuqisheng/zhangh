if object_id('p_hbb_mkt_stat_report') is not null
	drop proc p_hbb_mkt_stat_report;

create proc p_hbb_mkt_stat_report
	@pc_id			char(4),
	@begin			datetime,
	@end				datetime,
	@langid			integer = 0

as

declare
	@vpos				integer,
	@date				datetime,
	@codes			varchar(255),
	@code				char(3),
	@pquan			integer,
	@rquan			numeric(10,1),
	@rincome			money,
	@tincome			money,
	@rsvc				money,
	@rpak				money,
	@cdate			char(10)

declare c_code cursor for select distinct code from ymktsummaryrep 
	where date >= @begin and date <= @end and class = 'M'
	order by code

open c_code
fetch c_code into @code
while @@sqlstatus = 0
	begin
	select @codes = @codes + @code + '#'
	fetch c_code into @code
	end
close c_code
deallocate cursor c_code

select @code = ''
select date,code,pquan = sum(pquan),rquan = sum(rquan),rincome = sum(rincome),tincome = sum(tincome),rsvc = sum(rsvc),
	rpak = sum(rpak) into #mktout
	from ymktsummaryrep where date >= @begin and date <= @end
group by date,code
order by date,code

-- begin process
delete mktrep where pc_id = @pc_id

declare c_mkt cursor for select date,code,pquan,rquan,rincome = rincome - rsvc,tincome,rsvc,rpak 
	from #mktout order by date,code

open c_mkt
fetch c_mkt into @date,@code,@pquan,@rquan,@rincome,@tincome,@rsvc,@rpak
while @@sqlstatus = 0
	begin
	select @vpos = charindex(@code, @codes)
	select @vpos = (@vpos + 3) / 4
	select @cdate = convert(char(10),@date,111)
	if not exists(select 1 from mktrep where pc_id = @pc_id and date = @cdate and item = 'rms')
		insert mktrep(pc_id,date,item) values (@pc_id,@cdate,'rms')
	if not exists(select 1 from mktrep where pc_id = @pc_id and date = @cdate and item = 'adr')
		insert mktrep(pc_id,date,item) values (@pc_id,@cdate,'adr')
	if not exists(select 1 from mktrep where pc_id = @pc_id and date = @cdate and item = 'rmrev')
		insert mktrep(pc_id,date,item) values (@pc_id,@cdate,'rmrev')
	if not exists(select 1 from mktrep where pc_id = @pc_id and date = @cdate and item = 'tlrev')
		insert mktrep(pc_id,date,item) values (@pc_id,@cdate,'tlrev')

	if not exists(select 1 from mktrep where pc_id = @pc_id and date = @cdate and item = 'prs')
		insert mktrep(pc_id,date,item) values (@pc_id,@cdate,'prs')

	if @vpos = 1 
		begin
		update mktrep set mkt01 = mkt01 + @pquan 		 		where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt01 = mkt01 + @rquan 	 			where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt01 = mkt01 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt01 = mkt01 + @tincome 			where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt01 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 2 
		begin
		update mktrep set mkt02 = mkt02 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt02 = mkt02 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt02 = mkt02 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt02 = mkt02 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt02 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 3 
		begin
		update mktrep set mkt03 = mkt03 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt03 = mkt03 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt03 = mkt03 + @rincome	 		where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt03 = mkt03 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt03 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 4 
		begin
		update mktrep set mkt04 = mkt04 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt04 = mkt04 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt04 = mkt04 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt04 = mkt04 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt04 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 5 
		begin
		update mktrep set mkt05 = mkt05 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt05 = mkt05 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt05 = mkt05 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt05 = mkt05 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt05 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 6 
		begin
		update mktrep set mkt06 = mkt06 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt06 = mkt06 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt06 = mkt06 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt06 = mkt06 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt06 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 7 
		begin
		update mktrep set mkt07 = mkt07 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt07 = mkt07 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt07 = mkt07 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt07 = mkt07 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt07 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 8 
		begin
		update mktrep set mkt08 = mkt08 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt08 = mkt08 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt08 = mkt08 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt08 = mkt08 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt08 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 9 
		begin
		update mktrep set mkt09 = mkt09 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt09 = mkt09 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt09 = mkt09 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt09 = mkt09 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt09 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 10 
		begin
		update mktrep set mkt10 = mkt10 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt10 = mkt10 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt10 = mkt10 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt10 = mkt10 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt10 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 11 
		begin
		update mktrep set mkt11 = mkt11 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt11 = mkt11 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt11 = mkt11 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt11 = mkt11 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt11 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 12 
		begin
		update mktrep set mkt12 = mkt12 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt12 = mkt12 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt12 = mkt12 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt12 = mkt12 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt12 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 13 
		begin
		update mktrep set mkt13 = mkt13 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt13 = mkt13 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt13 = mkt13 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt13 = mkt13 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt13 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 14 
		begin
		update mktrep set mkt14 = mkt14 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt14 = mkt14 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt14 = mkt14 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt14 = mkt14 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt14 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 15 
		begin
		update mktrep set mkt15 = mkt15 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt15 = mkt15 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt15 = mkt15 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt15 = mkt15 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt15 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 16 
		begin
		update mktrep set mkt16 = mkt16 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt16 = mkt16 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt16 = mkt16 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt16 = mkt16 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt16 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 17 
		begin
		update mktrep set mkt17 = mkt17 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt17 = mkt17 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt17 = mkt17 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt17 = mkt17 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt17 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 18 
		begin
		update mktrep set mkt18 = mkt18 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt18 = mkt18 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt18 = mkt18 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt18 = mkt18 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt18 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 19 
		begin
		update mktrep set mkt19 = mkt19 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt19 = mkt19 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt19 = mkt19 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt19 = mkt19 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt19 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 20 
		begin
		update mktrep set mkt20 = mkt20 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt20 = mkt20 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt20 = mkt20 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt20 = mkt20 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt20 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end

	else if @vpos = 21 
		begin
		update mktrep set mkt21 = mkt21 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt21 = mkt21 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt21 = mkt21 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt21 = mkt21 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt21 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 22 
		begin
		update mktrep set mkt22 = mkt22 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt22 = mkt22 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt22 = mkt22 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt22 = mkt22 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt22 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 23 
		begin
		update mktrep set mkt23 = mkt23 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt23 = mkt23 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt23 = mkt23 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt23 = mkt23 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt23 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 24 
		begin
		update mktrep set mkt24 = mkt24 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt24 = mkt24 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt24 = mkt24 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt24 = mkt24 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt24 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 25 
		begin
		update mktrep set mkt25 = mkt25 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt25 = mkt25 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt25 = mkt25 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt25 = mkt25 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt25 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 26 
		begin
		update mktrep set mkt26 = mkt26 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt26 = mkt26 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt26 = mkt26 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt26 = mkt26 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt26 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 27 
		begin
		update mktrep set mkt27 = mkt27 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt27 = mkt27 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt27 = mkt27 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt27 = mkt27 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt27 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 28 
		begin
		update mktrep set mkt28 = mkt28 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt28 = mkt28 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt28 = mkt28 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt28 = mkt28 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt28 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 29 
		begin
		update mktrep set mkt29 = mkt29 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt29 = mkt29 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt29 = mkt29 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt29 = mkt29 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt29 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 30 
		begin
		update mktrep set mkt30 = mkt30 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt30 = mkt30 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt30 = mkt30 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt30 = mkt30 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt30 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
		 
	else if @vpos = 31 
		begin
		update mktrep set mkt31 = mkt31 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt31 = mkt31 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt31 = mkt31 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt31 = mkt31 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt31 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 32 
		begin
		update mktrep set mkt32 = mkt32 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt32 = mkt32 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt32 = mkt32 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt32 = mkt32 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt32 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 33 
		begin
		update mktrep set mkt33 = mkt33 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt33 = mkt33 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt33 = mkt33 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt33 = mkt33 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt33 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 34 
		begin
		update mktrep set mkt34 = mkt34 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt34 = mkt34 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt34 = mkt34 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt34 = mkt34 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt34 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 35 
		begin
		update mktrep set mkt35 = mkt35 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt35 = mkt35 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt35 = mkt35 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt35 = mkt35 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt35 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 36 
		begin
		update mktrep set mkt36 = mkt36 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt36 = mkt36 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt36 = mkt36 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt36 = mkt36 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt36 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 37 
		begin
		update mktrep set mkt37 = mkt37 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt37 = mkt37 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt37 = mkt37 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt37 = mkt37 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt37 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 38 
		begin
		update mktrep set mkt38 = mkt38 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt38 = mkt38 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt38 = mkt38 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt38 = mkt38 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt38 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 39 
		begin
		update mktrep set mkt39 = mkt39 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt39 = mkt39 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt39 = mkt39 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt39 = mkt39 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt39 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	else if @vpos = 40 
		begin
		update mktrep set mkt40 = mkt40 + @pquan 				where pc_id = @pc_id and date = @cdate and item = 'prs'
		update mktrep set mkt40 = mkt40 + @rquan 				where pc_id = @pc_id and date = @cdate and item = 'rms'
		update mktrep set mkt40 = mkt40 + @rincome 			where pc_id = @pc_id and date = @cdate and item = 'rmrev'
		update mktrep set mkt40 = mkt40 + @tincome		 	where pc_id = @pc_id and date = @cdate and item = 'tlrev'
		if @rquan != 0
			update mktrep set mkt40 = @rincome / @rquan  	where pc_id = @pc_id and date = @cdate and item = 'adr'
		end
	select @cdate = ''
	fetch c_mkt into @date,@code,@pquan,@rquan,@rincome,@tincome,@rsvc,@rpak
	end
close c_mkt
deallocate cursor c_mkt

update mktrep set mkttt = mkt01 + mkt02 + mkt03 + mkt04 + mkt05 + mkt06 + mkt07 + mkt08 + mkt09 + mkt10 
							 	+ mkt11 + mkt12 + mkt13 + mkt14 + mkt15 + mkt16 + mkt17 + mkt18 + mkt19 + mkt20 
							 	+ mkt21 + mkt22 + mkt23 + mkt24 + mkt25 + mkt26 + mkt27 + mkt28 + mkt29 + mkt30 
							 	+ mkt31 + mkt32 + mkt33 + mkt34 + mkt35 + mkt36 + mkt37 + mkt38 + mkt39 + mkt40 
 	where pc_id = @pc_id

insert mktrep(pc_id,date,item,
								 mkt01, mkt02, mkt03, mkt04, mkt05, mkt06, mkt07, mkt08, mkt09, mkt10,
							 	 mkt11, mkt12, mkt13, mkt14, mkt15, mkt16, mkt17, mkt18, mkt19, mkt20,
							 	 mkt21, mkt22, mkt23, mkt24, mkt25, mkt26, mkt27, mkt28, mkt29, mkt30, 
							 	 mkt31, mkt32, mkt33, mkt34, mkt35, mkt36, mkt37, mkt38, mkt39, mkt40,mkttt 
)
select @pc_id,'Total',item,sum(mkt01), sum(mkt02), sum(mkt03), sum(mkt04), sum(mkt05), sum(mkt06), sum(mkt07), sum(mkt08), sum(mkt09), sum(mkt10),
							 	 sum(mkt11), sum(mkt12), sum(mkt13), sum(mkt14), sum(mkt15), sum(mkt16), sum(mkt17), sum(mkt18), sum(mkt19), sum(mkt20),
							 	 sum(mkt21), sum(mkt22), sum(mkt23), sum(mkt24), sum(mkt25), sum(mkt26), sum(mkt27), sum(mkt28), sum(mkt29), sum(mkt30), 
							 	 sum(mkt31), sum(mkt32), sum(mkt33), sum(mkt34), sum(mkt35), sum(mkt36), sum(mkt37), sum(mkt38), sum(mkt39), sum(mkt40),sum(mkttt)
from mktrep where pc_id = @pc_id and not item in ('adr','occ') 
group by pc_id,item

insert mktrep
	select @pc_id,date,'','occ',mkt01, mkt02, mkt03, mkt04, mkt05, mkt06, mkt07, mkt08, mkt09, mkt10,
							 	 	 mkt11, mkt12, mkt13, mkt14, mkt15, mkt16, mkt17, mkt18, mkt19, mkt20,
							 	 	 mkt21, mkt22, mkt23, mkt24, mkt25, mkt26, mkt27, mkt28, mkt29, mkt30, 
							 	 	 mkt31, mkt32, mkt33, mkt34, mkt35, mkt36, mkt37, mkt38, mkt39, mkt40,mkttt 
from mktrep where item = 'rms' and pc_id = @pc_id 

update mktrep set 
			mkt01 = mkt01 / mkttt * 100,mkt02 = mkt02 / mkttt * 100,mkt03 = mkt03 / mkttt * 100,mkt04 = mkt04 / mkttt * 100,mkt05 = mkt05 / mkttt * 100,
			mkt06 = mkt06 / mkttt * 100,mkt07 = mkt07 / mkttt * 100,mkt08 = mkt08 / mkttt * 100,mkt09 = mkt09 / mkttt * 100,mkt10 = mkt10 / mkttt * 100,
			mkt11 = mkt11 / mkttt * 100,mkt12 = mkt12 / mkttt * 100,mkt13 = mkt13 / mkttt * 100,mkt14 = mkt14 / mkttt * 100,mkt15 = mkt15 / mkttt * 100,
			mkt16 = mkt16 / mkttt * 100,mkt17 = mkt17 / mkttt * 100,mkt18 = mkt18 / mkttt * 100,mkt19 = mkt19 / mkttt * 100,mkt20 = mkt20 / mkttt * 100,
			mkt21 = mkt21 / mkttt * 100,mkt22 = mkt22 / mkttt * 100,mkt23 = mkt23 / mkttt * 100,mkt24 = mkt24 / mkttt * 100,mkt25 = mkt25 / mkttt * 100,
			mkt26 = mkt26 / mkttt * 100,mkt27 = mkt27 / mkttt * 100,mkt28 = mkt28 / mkttt * 100,mkt29 = mkt29 / mkttt * 100,mkt30 = mkt30 / mkttt * 100,
			mkt31 = mkt31 / mkttt * 100,mkt32 = mkt32 / mkttt * 100,mkt33 = mkt33 / mkttt * 100,mkt34 = mkt34 / mkttt * 100,mkt35 = mkt35 / mkttt * 100,
			mkt36 = mkt36 / mkttt * 100,mkt37 = mkt37 / mkttt * 100,mkt38 = mkt38 / mkttt * 100,mkt39 = mkt39 / mkttt * 100,mkt40 = mkt40 / mkttt * 100,
			mkttt = mkttt / mkttt
	where pc_id = @pc_id and item = 'occ' and mkttt != 0

-- 计算合计平均房价
declare c_tmkt cursor for select code,sum(rquan),sum(rincome - rsvc) from #mktout group by code order by code

open c_tmkt
fetch c_tmkt into @code,@rquan,@rincome
while @@sqlstatus = 0
	begin
	if not exists(select 1 from mktrep where pc_id = @pc_id and date = 'Total' and item = 'adr')
		insert mktrep(pc_id,date,item) values (@pc_id,'Total','adr')

	select @vpos = charindex(@code, @codes)
	select @vpos = (@vpos + 3) / 4
	if @rquan ! = 0 
		begin
		if @vpos = 1
			update mktrep set mkt01 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 2
			update mktrep set mkt02 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 3
			update mktrep set mkt03 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 4
			update mktrep set mkt04 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 5
			update mktrep set mkt05 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 6
			update mktrep set mkt06 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 7
			update mktrep set mkt07 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 8
			update mktrep set mkt08 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 9
			update mktrep set mkt09 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 10
			update mktrep set mkt10 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		
		else if @vpos = 11
			update mktrep set mkt11 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 12
			update mktrep set mkt12 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 13
			update mktrep set mkt13 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 14
			update mktrep set mkt14 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 15
			update mktrep set mkt15 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 16
			update mktrep set mkt16 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 17
			update mktrep set mkt17 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 18
			update mktrep set mkt18 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 19
			update mktrep set mkt19 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 20
			update mktrep set mkt20 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		
		else if @vpos = 21
			update mktrep set mkt21 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 22
			update mktrep set mkt22 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 23
			update mktrep set mkt23 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 24
			update mktrep set mkt24 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 25
			update mktrep set mkt25 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 26
			update mktrep set mkt26 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 27
			update mktrep set mkt27 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 28
			update mktrep set mkt28 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 29
			update mktrep set mkt29 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 30
			update mktrep set mkt30 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		
		else if @vpos = 31
			update mktrep set mkt31 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 32
			update mktrep set mkt32 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 33
			update mktrep set mkt33 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 34
			update mktrep set mkt34 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 35
			update mktrep set mkt35 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 36
			update mktrep set mkt36 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 37
			update mktrep set mkt37 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 38
			update mktrep set mkt38 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else if @vpos = 39
			update mktrep set mkt39 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		else
			update mktrep set mkt40 = @rincome / @rquan where pc_id = @pc_id and date = 'Total' and item = 'adr'
		end
	fetch c_tmkt into @code,@rquan,@rincome
	end
close c_tmkt
deallocate cursor c_tmkt
--

insert mktrep(pc_id,date,item) values (@pc_id,'Total',' ')
//select * from mktrep where pc_id = @pc_id
return ;