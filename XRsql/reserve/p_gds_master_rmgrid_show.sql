IF OBJECT_ID('p_gds_master_rmgrid_show') IS NOT NULL
    DROP PROCEDURE p_gds_master_rmgrid_show
;
create proc p_gds_master_rmgrid_show
	@accnt		char(10),
	@mode			char(10)=''  -- 预留参数=显示方式，比如是否包含已经分配账号的成员
as
----------------------------------------------------------------------------------------------
--		客房资源管理程序 - grid block show -- 显示用 - 预订主单 - 仅团队 
----------------------------------------------------------------------------------------------
create table #grid (
	date		datetime			not null,
	type		char(5)			not null,
	quan		int 				null,
	t_seq		int default 0	null		-- 房类排序
)

-- Init
declare		@arr 			datetime, 
				@dep 			datetime, 
				@date			datetime,
				@type 		char(5)

select @arr=arr,@dep=dep from master where accnt=@accnt
if @@rowcount = 0
begin
	select * from #grid
	return
end
if datediff(dd, @arr, getdate()) > 0 
	select @arr = getdate()
if datediff(dd, @dep, getdate()) > 0 
	select @dep = getdate()
select @arr = convert(datetime,convert(char(10),@arr,111)), @dep = convert(datetime,convert(char(10),@dep,111))

-- data
select @date = @arr
while @date<@dep
begin
	insert #grid (date, type, quan)
		select @date, type, sum(quantity) from rsvsrc 
			where accnt=@accnt and id>0 and @date>=begin_ and @date<end_
				   and blkmark='T'  -- 包含两种纯预留的数据 = 行预留 + grid ? 暂时只计算 grid 
				group by type 
	select @date = dateadd(dd, 1, @date)
end

-- 按照日期插入记录，让数据显示出连续的日期
if exists(select 1 from #grid)
begin
	select @type = min(type) from #grid
	select @date = @arr
	while @date<@dep
	begin
		if not exists(select 1 from #grid where date=@arr)
			insert #grid(date, type) values(@arr, @type)
		select @date = dateadd(dd, 1, @date)
	end
end

--
update #grid set t_seq=a.sequence from typim a where #grid.type=a.type

-- output
select * from #grid order by date, t_seq, type 

return
;