IF OBJECT_ID('dbo.p_clg_statistic_retotal') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_statistic_retotal
;
create proc p_clg_statistic_retotal
	@bdate	datetime,
    @table  char(30)
as
declare
-- 判断是否为重建，是，需要清除statistic_m上日数据
   @year   money,
   @month  money,
	@day			money,
   @duringaudit    char(1),
   @cat         char(30)
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	begin
	
    if @table='master_income'
        select @cat='yieldar_%'
    else if @table='cus_xf'
        select @cat='yielddb_%'

	select @year = datepart(yy, @bdate),@month = datepart(mm, @bdate),@day = datepart(dd, @bdate)
	if @day = 1
		update statistic_m set day01 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 2
		update statistic_m set day02 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 3
		update statistic_m set day03 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 4
		update statistic_m set day04 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 5
		update statistic_m set day05 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 6
		update statistic_m set day06 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 7
		update statistic_m set day07 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 8
		update statistic_m set day08 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 9
		update statistic_m set day09 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 10
		update statistic_m set day10 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 11
		update statistic_m set day11 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 12
		update statistic_m set day12 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 13
		update statistic_m set day13 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 14
		update statistic_m set day14 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 15
		update statistic_m set day15 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 16
		update statistic_m set day16 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 17
		update statistic_m set day17 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 18
		update statistic_m set day18 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 19
		update statistic_m set day19 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 20
		update statistic_m set day20 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 21
		update statistic_m set day21 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 22
		update statistic_m set day22 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 23
		update statistic_m set day23 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 24
		update statistic_m set day24 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 25
		update statistic_m set day25 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 26
		update statistic_m set day26 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 27
		update statistic_m set day27 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 28
		update statistic_m set day28 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 29
		update statistic_m set day29 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 30
		update statistic_m set day30 = 0 where year = @year and month = @month and cat like @cat
	else if @day = 31
	   update statistic_m set day31 = 0 where year = @year and month = @month and cat like @cat
	end
;