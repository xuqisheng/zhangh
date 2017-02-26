
IF OBJECT_ID('p_zk_guest_statistic_reb') IS NOT NULL
    DROP PROCEDURE p_zk_guest_statistic_reb
;
create proc p_zk_guest_statistic_reb
	@no			char(7),		-- 主体		
	@no2			char(7)		
as
------------------------------------------------------------------
--	档案合并之后需要把statistic相关记录进行合并
--	statistic_m statistic_y
------------------------------------------------------------------
------------------------------------------------------------------
declare	
			@ret 			int


CREATE TABLE #statistic_m 
(
    year    int         NOT NULL,
    month   int         NOT NULL,
    cat     char(30)    NOT NULL,
    grp     char(10)    DEFAULT '' NOT NULL,
    code    char(10)    DEFAULT '' NOT NULL,
    day01   money       DEFAULT 0 NOT NULL,
    day02   money       DEFAULT 0 NOT NULL,
    day03   money       DEFAULT 0 NOT NULL,
    day04   money       DEFAULT 0 NOT NULL,
    day05   money       DEFAULT 0 NOT NULL,
    day06   money       DEFAULT 0 NOT NULL,
    day07   money       DEFAULT 0 NOT NULL,
    day08   money       DEFAULT 0 NOT NULL,
    day09   money       DEFAULT 0 NOT NULL,
    day10   money       DEFAULT 0 NOT NULL,
    day11   money       DEFAULT 0 NOT NULL,
    day12   money       DEFAULT 0 NOT NULL,
    day13   money       DEFAULT 0 NOT NULL,
    day14   money       DEFAULT 0 NOT NULL,
    day15   money       DEFAULT 0 NOT NULL,
    day16   money       DEFAULT 0 NOT NULL,
    day17   money       DEFAULT 0 NOT NULL,
    day18   money       DEFAULT 0 NOT NULL,
    day19   money       DEFAULT 0 NOT NULL,
    day20   money       DEFAULT 0 NOT NULL,
    day21   money       DEFAULT 0 NOT NULL,
    day22   money       DEFAULT 0 NOT NULL,
    day23   money       DEFAULT 0 NOT NULL,
    day24   money       DEFAULT 0 NOT NULL,
    day25   money       DEFAULT 0 NOT NULL,
    day26   money       DEFAULT 0 NOT NULL,
    day27   money       DEFAULT 0 NOT NULL,
    day28   money       DEFAULT 0 NOT NULL,
    day29   money       DEFAULT 0 NOT NULL,
    day30   money       DEFAULT 0 NOT NULL,
    day31   money       DEFAULT 0 NOT NULL,
    day99   money       DEFAULT 0 NOT NULL,
    hotelid varchar(20) DEFAULT '' NOT NULL
)

CREATE TABLE #statistic_y 
(
    year    int         NOT NULL,
    cat     char(30)    NOT NULL,
    grp     char(10)    DEFAULT '' NOT NULL,
    code    char(10)    DEFAULT '' NOT NULL,
    month01 money       DEFAULT 0 NOT NULL,
    month02 money       DEFAULT 0 NOT NULL,
    month03 money       DEFAULT 0 NOT NULL,
    month04 money       DEFAULT 0 NOT NULL,
    month05 money       DEFAULT 0 NOT NULL,
    month06 money       DEFAULT 0 NOT NULL,
    month07 money       DEFAULT 0 NOT NULL,
    month08 money       DEFAULT 0 NOT NULL,
    month09 money       DEFAULT 0 NOT NULL,
    month10 money       DEFAULT 0 NOT NULL,
    month11 money       DEFAULT 0 NOT NULL,
    month12 money       DEFAULT 0 NOT NULL,
    month99 money       DEFAULT 0 NOT NULL,
    hotelid varchar(20) DEFAULT '' NOT NULL
)

insert #statistic_m select * from statistic_m where code = @no2
insert #statistic_y select * from statistic_y where code = @no2

-- Update business data
begin tran
save tran statistic_combine

update statistic_m set statistic_m.day01 = statistic_m.day01 + b.day01 , statistic_m.day02 = statistic_m.day02 + b.day02 , statistic_m.day03 = statistic_m.day03 + b.day03 ,
	statistic_m.day04 = statistic_m.day04 + b.day04 , statistic_m.day05 = statistic_m.day05 + b.day05 , statistic_m.day06 = statistic_m.day06 + b.day06 
		from #statistic_m b where b.code = @no2 and statistic_m.code = @no and b.year = statistic_m.year and b.month = statistic_m.month and b.cat = statistic_m.cat
update statistic_m set statistic_m.day07 = statistic_m.day07 + b.day07 , statistic_m.day08 = statistic_m.day08 + b.day08 , statistic_m.day09 = statistic_m.day09 + b.day09 ,
	statistic_m.day10 = statistic_m.day10 + b.day10 , statistic_m.day11 = statistic_m.day11 + b.day11 , statistic_m.day12 = statistic_m.day12 + b.day12 
		from #statistic_m b where b.code = @no2 and statistic_m.code = @no and b.year = statistic_m.year and b.month = statistic_m.month and b.cat = statistic_m.cat
update statistic_m set statistic_m.day13 = statistic_m.day13 + b.day13 , statistic_m.day14 = statistic_m.day14 + b.day14 , statistic_m.day15 = statistic_m.day15 + b.day15 ,
	statistic_m.day16 = statistic_m.day16 + b.day16 , statistic_m.day17 = statistic_m.day17 + b.day17 , statistic_m.day18 = statistic_m.day18 + b.day18 
		from #statistic_m b where b.code = @no2 and statistic_m.code = @no and b.year = statistic_m.year and b.month = statistic_m.month and b.cat = statistic_m.cat
update statistic_m set statistic_m.day19 = statistic_m.day19 + b.day19 , statistic_m.day20 = statistic_m.day20 + b.day20 , statistic_m.day21 = statistic_m.day21 + b.day21 ,
	statistic_m.day22 = statistic_m.day22 + b.day22 , statistic_m.day23 = statistic_m.day23 + b.day23 , statistic_m.day24 = statistic_m.day24 + b.day24 
		from #statistic_m b where b.code = @no2 and statistic_m.code = @no and b.year = statistic_m.year and b.month = statistic_m.month and b.cat = statistic_m.cat
update statistic_m set statistic_m.day25 = statistic_m.day25 + b.day25 , statistic_m.day26 = statistic_m.day26 + b.day26 , statistic_m.day27 = statistic_m.day27 + b.day27 ,
	statistic_m.day28 = statistic_m.day28 + b.day28 , statistic_m.day29 = statistic_m.day29 + b.day29 , statistic_m.day30 = statistic_m.day30 + b.day30 , statistic_m.day31 = statistic_m.day31 + b.day31
		from #statistic_m b where b.code = @no2 and statistic_m.code = @no and b.year = statistic_m.year and b.month = statistic_m.month and b.cat = statistic_m.cat
update statistic_m set day99 = day01 + day02 + day03 + day04 + day05 +  day06 + day07 + day08 + day09 + day10 +  day11 + day12 + day13 + day14 + day15
		+ day16 + day17 + day18 + day19 + day20 +  day21 + day22 + day23 + day24 + day25 +  day26 + day27 + day28 + day29 + day30 + day31
				where code = @no

update statistic_y set statistic_y.month01 = statistic_y.month01 + b.month01 , statistic_y.month02 = statistic_y.month02 + b.month02 , statistic_y.month03 = statistic_y.month03 + b.month03 ,
	statistic_y.month04 = statistic_y.month04 + b.month04 , statistic_y.month05 = statistic_y.month05 + b.month05 , statistic_y.month06 = statistic_y.month06 + b.month06 
		from #statistic_y b where b.code = @no2 and statistic_y.code = @no and b.year = statistic_y.year and b.cat = statistic_y.cat
update statistic_y set statistic_y.month07 = statistic_y.month07 + b.month07 , statistic_y.month08 = statistic_y.month08 + b.month08 , statistic_y.month09 = statistic_y.month09 + b.month09 ,
	statistic_y.month10 = statistic_y.month10 + b.month10 , statistic_y.month11 = statistic_y.month11 + b.month11 , statistic_y.month12 = statistic_y.month12 + b.month12 
		from #statistic_y b where b.code = @no2 and statistic_y.code = @no and b.year = statistic_y.year and b.cat = statistic_y.cat
update statistic_y set month99 = month01 + month02 + month03 + month04 + month05 +  month06 + month07 + month08 + month09 + month10 +  month11 + month12
				where code = @no

delete from statistic_m where code = @no2
delete from statistic_y where code = @no2

//pout:
//if @ret<>0
//	rollback tran statistic_combine

commit tran

return 0
;

