if exists(select 1 from sysobjects where name = "p_gds_sc_grid_block_sim")
	drop proc p_gds_sc_grid_block_sim;
create proc p_gds_sc_grid_block_sim
	@accnt		char(10)
as
----------------------------------------------------------------------------------------------
--		sc 客房资源管理程序 - 辅助程序
--
--			产生资源显示的 grid, 清晰描述各个数据显示的列、行等  
----------------------------------------------------------------------------------------------
create table #grid (
	date		datetime			not null,
	type		char(5)			not null,
	quan		int default 0	null,
	rate		money default 0	null,
	grow		int default 0	null,
	gcol		int default 0	null
)

declare		@arr 		datetime, 
				@dep 		datetime,
				@sta		char(1)

select @arr=arr,@dep=dep,@sta=sta from sc_master where accnt=@accnt
if @@rowcount = 0 or @sta not in ('R', 'W', 'I')
begin
	select * from #grid
	return
end

if datediff(dd, @arr, getdate()) > 0 
	select @arr = getdate()
select @arr = convert(datetime,convert(char(10),@arr,111)), @dep = convert(datetime,convert(char(10),@dep,111))

-- data
if @sta = 'W' 
	insert #grid (date, type, quan, rate)
		select begin_, type, quantity, rate from  rsvsrc_wait where accnt=@accnt and blkmark='T' and begin_>=@arr and end_<=@dep
else
	insert #grid (date, type, quan, rate)
		select begin_, type, quantity, rate from  rsvsrc where accnt=@accnt and blkmark='T' and begin_>=@arr and end_<=@dep

-- for grow 
update #grid set grow = datediff(dd, @arr, date) + 1

-- for gcol
create table #typim (
	type		char(5)		not null,
	comb		char(15)		not null,
	gcol		int default 0	null
)
insert #typim(type,comb) select type, right(space(10)+rtrim(convert(char(10),sequence)),10)+type from typim
update #typim set gcol=(select count(1) from #typim a where a.comb <= #typim.comb)
update #grid set gcol = a.gcol from #typim a where #grid.type=a.type

-- output
select * from #grid

return
;