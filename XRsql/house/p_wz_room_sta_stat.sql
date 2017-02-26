//====================================================================
-- 客房中心房态统计过程
//====================================================================
drop proc p_wz_room_sta_stat;
create proc p_wz_room_sta_stat
		@empno		char(10)
as
declare
		@total		integer
create table #tmp(
		inspect		integer 		default	0,
		clean			integer		default	0,
		tuch			integer		default	0,
		dirty			integer		default	0,
		oo				integer		default	0,
		os				integer		default	0,
		gtmp			integer		default	0,
		htmp			integer		default	0
) 

insert #tmp select 0,0,0,0,0,0,0,0

select @total = count(*) from rmsta where sta = 'I'
update #tmp set inspect = @total
	
select @total = count(*) from rmsta where sta = 'R'
update #tmp set clean = @total

select @total = count(*) from rmsta where sta = 'T'
update #tmp set tuch = @total

select @total = count(*) from rmsta where sta = 'D'
update #tmp set dirty = @total

select @total = count(*) from rmsta where sta = 'O'
update #tmp set oo = @total

select @total = count(*) from rmsta where sta = 'S'
update #tmp set os = @total

select @total = count(*) from rmsta where tmpsta = 'B'
update #tmp set gtmp = @total

select @total = count(*) from rmsta where tmpsta <> 'B' and tmpsta <>''
update #tmp set htmp = @total

select * from #tmp

return 0;
