if exists(select 1 from sysobjects where name = "p_gds_reserve_grid_block_sim")
	drop proc p_gds_reserve_grid_block_sim;
create proc p_gds_reserve_grid_block_sim
	@accnt		char(10)
as
----------------------------------------------------------------------------------------------
--		客房资源管理程序 - grid block
----------------------------------------------------------------------------------------------
create table #grid (
	date		datetime			not null,
	type		char(5)			not null,
	quan		int default 0	null,
	grow		int default 0	null,
	gcol		int default 0	null
)

declare	@arr datetime, @dep datetime
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
insert #grid (date, type, quan)
	select begin_, type, quantity from  rsvsrc where accnt=@accnt and blkmark='T' and begin_>=@arr and end_<=@dep

-- for grow 
update #grid set grow = datediff(dd, @arr, date) + 1

-- for gcol
create table #typim (
	type		char(5)		not null,
	comb		char(13)		not null,
	gcol		int default 0	null
)
insert #typim(type,comb) select type, right(space(10)+rtrim(convert(char(10),sequence)),10)+type from typim
update #typim set gcol=(select count(1) from #typim a where a.comb <= #typim.comb)
update #grid set gcol = a.gcol from #typim a where #grid.type=a.type

-- output
select * from #grid

return
;