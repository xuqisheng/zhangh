if object_id('p_hbb_forecast_get_data') is not null
	drop proc p_hbb_forecast_get_data;

-- 取得预测数据
create proc p_hbb_forecast_get_data
	@pc_id			char(4),
	@begin			datetime,
	@end				datetime,
	@type				char(10) = '',		-- 统计入口: saleid, market, src, ratecode, restype, channel
	@langid			integer = 0

as

select * into #temp from forecast_rep where 1 = 2
delete forecast_rep where pc_id = @pc_id

if @type = 'saleid'
	begin
	while	@begin < @end
		begin
		insert #temp(pc_id,date,code,gstno,quantity,rate)
			select @pc_id,@begin,b.saleid,sum(a.gstno),count(distinct a.roomno),sum( a.quantity * a.rate ) from rsvsrc a, master b
				where a.accnt = b.accnt and a.accnt = a.master and a.begin_ <= @begin and a.end_ > @begin and a.roomno != ''
					and rtrim(b.saleid) is not null  
		group by b.saleid		

		insert #temp(pc_id,date,code,gstno,quantity,rate)
			select @pc_id,@begin,b.saleid,sum(a.gstno),sum(a.quantity),sum( a.quantity * a.rate ) from rsvsrc a, master b
				where a.accnt = b.accnt and a.accnt = a.master and a.begin_ <= @begin and a.end_ > @begin and a.roomno = ''
					and rtrim(b.saleid) is not null  
		group by b.saleid		

		insert forecast_rep(pc_id,date,code,gstno,quantity,rate)
			select pc_id,date,code,sum(gstno),sum(quantity),sum(rate) from #temp 
		group by pc_id,date,code

		truncate table #temp
	
		select @begin = dateadd(day, 1, @begin)
		end
	end
else if @type = 'market' 
	begin
	while	@begin < @end
		begin

		insert #temp(pc_id,date,code,gstno,quantity,rate)
			select @pc_id,@begin,a.market,sum(a.gstno),count(distinct a.roomno),sum( a.quantity * a.rate ) from rsvsrc a,master b
				where a.accnt = b.accnt and a.begin_ <= @begin and a.end_ > @begin and a.roomno != ''
		group by a.market

		insert #temp(pc_id,date,code,gstno,quantity,rate)
			select @pc_id,@begin,a.market,sum(a.gstno),sum(a.quantity),sum(a.quantity * rate) from rsvsrc a,master b
				where a.accnt = b.accnt and a.begin_ <= @begin and a.end_ > @begin and a.roomno = ''
		group by a.market
		
		insert forecast_rep(pc_id,date,code,gstno,quantity,rate)
			select pc_id,date,code,sum(gstno),sum(quantity),sum(rate) from #temp 
		group by pc_id,date,code

		truncate table #temp

		select @begin = dateadd(day, 1, @begin)
		end
	end
else if @type = 'src' 
	begin
	while	@begin < @end
		begin

		insert #temp(pc_id,date,code,gstno,quantity,rate)
			select @pc_id,@begin,a.src,sum(a.gstno),count(distinct a.roomno),sum(a.quantity * rate) from rsvsrc a,master b
				where a.accnt = b.accnt and a.begin_ <= @begin and a.end_ > @begin and a.roomno != ''
		group by a.src

		insert #temp(pc_id,date,code,gstno,quantity,rate)
			select @pc_id,@begin,a.src,sum(a.gstno),sum(a.quantity),sum(a.quantity * rate) from rsvsrc a,master b
				where a.accnt = b.accnt and a.begin_ <= @begin and a.end_ > @begin and a.roomno = ''
		group by a.src

		insert forecast_rep(pc_id,date,code,gstno,quantity,rate)
			select pc_id,date,code,sum(gstno),sum(quantity),sum(rate) from #temp 
		group by pc_id,date,code

		truncate table #temp
	
		select @begin = dateadd(day, 1, @begin)
		end
	end
else if @type = 'ratecode' 
	begin
	while	@begin < @end
		begin

		insert #temp(pc_id,date,code,gstno,quantity,rate)
			select @pc_id,@begin,a.ratecode,sum(a.gstno),count(distinct a.roomno),sum(a.quantity * rate) from rsvsrc a,master b
				where a.accnt = b.accnt and a.begin_ <= @begin and a.end_ > @begin and a.roomno != ''
		group by a.ratecode

		insert #temp(pc_id,date,code,gstno,quantity,rate)
			select @pc_id,@begin,a.ratecode,sum(a.gstno),sum(a.quantity),sum(a.quantity * rate) from rsvsrc a,master b
				where a.accnt = b.accnt and a.begin_ <= @begin and a.end_ > @begin and a.roomno = ''
		group by a.ratecode

		insert forecast_rep(pc_id,date,code,gstno,quantity,rate)
			select pc_id,date,code,sum(gstno),sum(quantity),sum(rate) from #temp 
		group by pc_id,date,code

		truncate table #temp
		select @begin = dateadd(day, 1, @begin)
		end
	end

else if @type = 'restype'
	begin
	while	@begin < @end
		begin
		insert #temp(pc_id,date,code,gstno,quantity,rate)
			select @pc_id,@begin,b.restype,sum(a.gstno),count(distinct a.roomno),sum( a.quantity * a.rate ) from rsvsrc a, master b
				where a.accnt = b.accnt and a.accnt = a.master and a.begin_ <= @begin and a.end_ > @begin and a.roomno != ''
					and rtrim(b.restype) is not null  
		group by b.restype		

		insert #temp(pc_id,date,code,gstno,quantity,rate)
			select @pc_id,@begin,b.restype,sum(a.gstno),sum(a.quantity),sum( a.quantity * a.rate ) from rsvsrc a, master b
				where a.accnt = b.accnt and a.accnt = a.master and a.begin_ <= @begin and a.end_ > @begin and a.roomno = ''
					and rtrim(b.restype) is not null  
		group by b.restype		

		insert forecast_rep(pc_id,date,code,gstno,quantity,rate)
			select pc_id,date,code,sum(gstno),sum(quantity),sum(rate) from #temp 
		group by pc_id,date,code

		truncate table #temp
	
		select @begin = dateadd(day, 1, @begin)
		end
	end
else if @type = 'channel'
	begin
	while	@begin < @end
		begin
		insert #temp(pc_id,date,code,gstno,quantity,rate)
			select @pc_id,@begin,b.channel,sum(a.gstno),count(distinct a.roomno),sum( a.quantity * a.rate ) from rsvsrc a, master b
				where a.accnt = b.accnt and a.accnt = a.master and a.begin_ <= @begin and a.end_ > @begin and a.roomno != ''
					and rtrim(b.channel) is not null  
		group by b.channel		

		insert #temp(pc_id,date,code,gstno,quantity,rate)
			select @pc_id,@begin,b.channel,sum(a.gstno),sum(a.quantity),sum( a.quantity * a.rate ) from rsvsrc a, master b
				where a.accnt = b.accnt and a.accnt = a.master and a.begin_ <= @begin and a.end_ > @begin and a.roomno = ''
					and rtrim(b.channel) is not null  
		group by b.channel		

		insert forecast_rep(pc_id,date,code,gstno,quantity,rate)
			select pc_id,date,code,sum(gstno),sum(quantity),sum(rate) from #temp 
		group by pc_id,date,code

		truncate table #temp
	
		select @begin = dateadd(day, 1, @begin)
		end
	end

delete forecast_rep where pc_id = @pc_id and quantity = 0 

return;