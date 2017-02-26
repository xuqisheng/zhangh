
if exists(select 1 from sysobjects where name = "p_gds_reserve_grid_block_show")
	drop proc p_gds_reserve_grid_block_show;
create proc p_gds_reserve_grid_block_show
	@accnt		char(10)
as
----------------------------------------------------------------------------------------------
--		客房资源管理程序 - grid block show -- 显示用
----------------------------------------------------------------------------------------------
create table #grid (
	date		datetime			not null,
	type		char(5)			not null,
	quan		int 				null,
	t_seq		int default 0	null		-- 房类排序
)

-- Init
declare	@arr 		datetime, 
			@dep 		datetime, 
			@type 	char(5),
			@blkcode	char(10) 

-- 
select @blkcode='' 
if @accnt like 'B%' 
	select @arr=arr,@dep=dep from sc_master where accnt=@accnt
else
	select @arr=arr,@dep=dep, @blkcode=blkcode from master where accnt=@accnt
if @@rowcount = 0
begin
	select * from #grid
	return
end

-- 
if @blkcode = '' 
	select @blkcode = @accnt 

-- 注意如果一个团体是包含某个 block, 这里的抵离日期是取团体的，日期应该是block的一部分 
if datediff(dd, @arr, getdate()) > 0 
	select @arr = getdate()
select @arr = convert(datetime,convert(char(10),@arr,111)), @dep = convert(datetime,convert(char(10),@dep,111))

-- data
insert #grid (date, type, quan)
	select begin_, type, quantity from  rsvsrc where accnt=@blkcode and blkmark='T'
if @@rowcount > 0
begin
	select @type = min(type) from #grid
	while @arr < @dep
	begin
		if not exists(select 1 from #grid where date=@arr)
			insert #grid(date, type) values(@arr, @type)
		select @arr = dateadd(dd, 1, @arr)
	end
end

--
update #grid set t_seq=a.sequence from typim a where #grid.type=a.type

-- output
select * from #grid order by date, t_seq, type 

return
;