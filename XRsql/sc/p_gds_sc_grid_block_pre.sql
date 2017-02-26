
if exists(select * from sysobjects where name = "p_gds_sc_grid_block_pre")
   drop proc p_gds_sc_grid_block_pre;
create proc p_gds_sc_grid_block_pre
	@accnt		char(10),
	@begin_		datetime,	-- 团体的到达日期
	@arr			datetime,
	@dep			datetime,
	@types		varchar(100)
	
as
----------------------------------------------------------------------------------------------
--		客房资源管理程序 - grid block
--
--			计算指定设置区间在 团体 block grid 中的位置 
----------------------------------------------------------------------------------------------
create table #grid (
	date		datetime			not null,
	type		char(5)			not null,
	grow		int default 0	null,
	gcol		int default 0	null
)

declare @larr datetime

if datediff(dd, @arr, getdate()) > 0 
	select @arr = getdate()
if datediff(dd, @dep, getdate()) > 0 
	select @dep = getdate()
select @arr = convert(datetime,convert(char(10),@arr,111)), @dep = convert(datetime,convert(char(10),@dep,111))

-- data
select @larr=@arr
while @larr < @dep
begin
	insert #grid (date, type) select @larr, type from typim 
		where @types='%' or charindex(','+rtrim(type)+',', ','+@types+',')>0 order by sequence, type

	select @larr = dateadd(dd,1,@larr)
end

-- for grow 
update #grid set grow = datediff(dd, @arr, date) + 1 + datediff(dd, @begin_, @arr)

-- for gcol
create table #typim (
	type		char(5)		not null,
	gcol		numeric(10,0) IDENTITY
)
insert #typim(type) select type  from typim order by sequence,type
                                                                                                               
update #grid set gcol = a.gcol from #typim a where #grid.type=a.type

-- output
select * from #grid

return
;