if  exists(select * from sysobjects where name = "p_gds_fec_def_show")
	drop proc p_gds_fec_def_show
;
create proc p_gds_fec_def_show
	@code		char(3),			-- 某个币种 
	@dbegin	datetime,
	@dend		datetime
as
-----------------------------------------------------------------------------
--	code =  '' 显示系统 @dend 时刻的外币牌价 
--	code <> '' 显示@code某段区间的外币牌价 
-----------------------------------------------------------------------------
declare
	@mcode				char(3), 
	@logmark				int

-- 
select * into #fec_def from fec_def where 1=2 
if @dend is null
	select @dend = getdate()

--
select @code=isnull(rtrim(@code),'')
if @code<>'' -- 单个代码的历史修改记录 
begin
	if @dbegin is null
		select @dbegin = dateadd(yy, -20, @dend)
	insert #fec_def select * from fec_def_log a 
		where a.code=@code and a.changed>=@dbegin and a.changed<=@dend 
end
else  -- 某个时刻的外汇牌价 
begin
	-- insert all code 
	create table #code (code char(3) null) 
	insert #code select distinct code from fec_def_log 
	
	declare c_code cursor for select code from #code 
	open c_code 
	fetch c_code into @mcode 
	while @@sqlstatus = 0
	begin
		select @logmark=max(logmark) from fec_def_log where code=@mcode and changed<=@dend 
		if @logmark is not null 
			insert #fec_def select * from fec_def_log a where a.code=@mcode and a.logmark=@logmark

		fetch c_code into @mcode 
	end
	close c_code
	deallocate cursor c_code
end

--
delete #fec_def where descript=''

-- output
-- SELECT code,descript,descript1,disc,base,price_in,price_out,price_cash,cby,changed,logmark FROM fec_def
select * from #fec_def order by code
return 0
;
