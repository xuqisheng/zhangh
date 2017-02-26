
IF OBJECT_ID('p_gds_reserve_rms_pickup1') IS NOT NULL
    DROP PROCEDURE p_gds_reserve_rms_pickup1
;
create proc p_gds_reserve_rms_pickup1
	@parm		char(6)		-- yyyymm 
as
-----------------------------------------------------------------
-- 显示当月预留历史和未来。
-- 历史：根据历史营业数据  未来：根据预订情况
--
-- 收益管理使用 - hz sofitel 
-----------------------------------------------------------------

create table #pickup (
	code  			char(10)	not null, 
	descript			varchar(30)	not null,
	sequence			int		not null , 
	day01 			money	default 0	not null, 
	day02 			money	default 0	not null,  
	day03 			money	default 0	not null,  
	day04 			money	default 0	not null,  
	day05 			money	default 0	not null,  
	day06 			money	default 0	not null,  
	day07 			money	default 0	not null,  
	day08 			money	default 0	not null,  
	day09 			money	default 0	not null,  
	day10 			money	default 0	not null,  
	day11 			money	default 0	not null,  
	day12 			money	default 0	not null,  
	day13 			money	default 0	not null,  
	day14 			money	default 0	not null,  
	day15 			money	default 0	not null,  
	day16 			money	default 0	not null,  
	day17 			money	default 0	not null,  
	day18 			money	default 0	not null,  
	day19 			money	default 0	not null,  
	day20 			money	default 0	not null,  
	day21 			money	default 0	not null,  
	day22 			money	default 0	not null,  
	day23 			money	default 0	not null,  
	day24 			money	default 0	not null,  
	day25 			money	default 0	not null,  
	day26 			money	default 0	not null,  
	day27 			money	default 0	not null,  
	day28 			money	default 0	not null,  
	day29 			money	default 0	not null,  
	day30 			money	default 0	not null,  
	day31 			money	default 0	not null,  
	ttl 				money	default 0	not null
) 
                                                                                                                                                                                                                                
insert #pickup (code,descript,sequence) select 'occ','Room Occupied (-House Use)', 100 
insert #pickup (code,descript,sequence) select 'revenue','Room Revenue', 200 
insert #pickup (code,descript,sequence) select 'rebate','Rebates', 300 
insert #pickup (code,descript,sequence) select 'ten_rn','TEN R/Ns ', 400 
insert #pickup (code,descript,sequence) select 'ten_rev','TEN Revenue', 500 
insert #pickup (code,descript,sequence) select 'walkin','Walk-in', 600 
insert #pickup (code,descript,sequence) select 'exten','Extension', 700 
insert #pickup (code,descript,sequence) select 'samres','Sameday Res. Made', 800 
insert #pickup (code,descript,sequence) select 'edep','Early Departure', 900 
insert #pickup (code,descript,sequence) select 'noshow','No-show', 1000 
insert #pickup (code,descript,sequence) select 'samcxl','Sameday Cancellation', 1100 
insert #pickup (code,descript,sequence) select 'cxltarr','CXL of today arrival', 1200 

if @parm not like '[1-2][09][0-9][0-9][0-1][0-9]' 
	goto gout 

declare	@begin		datetime,
			@end			datetime,
			@day			int,
			@bdate		datetime

declare	@occ			money,
			@revenue		money,
			@rebate		money,
			@ten_rn		money,
			@ten_rev		money,
			@walkin		money,
			@exten		money,
			@samres		money,
			@edep			money,
			@noshow		money,
			@samcxl		money,
			@cxltarr		money 

select @bdate = bdate1 from sysdata 
select @begin=convert(datetime, @parm+'01')
select @end=dateadd(dd, -1, dateadd(mm, 1, @begin))  

while @begin <= @end
begin
	-- 计算
	if @begin<@bdate 
	begin
		select @occ = isnull((select amount from yaudit_impdata where date=@begin and class='sold' ), 0) 
		select @revenue = isnull((select amount from yaudit_impdata where date=@begin and class='income'), 0) 
		select @rebate = isnull((select day07 from yjierep where date=@begin and class='010' ), 0)
		select @ten_rn = 0
		select @ten_rev = 0
		select @walkin = 0
		select @exten = 0
		select @samres = 0
		select @edep = 0
		select @noshow = 0
		select @samcxl = 0
		select @cxltarr = 0
	end
	else
	begin
		exec p_gds_reserve_rsv_index @begin, '%', 'Occupied Tonight-HU','R', @occ output
		exec p_gds_reserve_rsv_index @begin, '%', 'Room Revenue','R', @revenue output   -- Room Revenue Include SVC 总收入
		select @rebate = 0
		exec p_gds_reserve_rsv_index @begin, '%', 'Tentative Reservation','R', @ten_rn output
		select @ten_rev = isnull((select sum(a.quantity*rate) from rsvsrc a, master b
			where ((a.begin_<=@begin and a.end_>@begin) or (a.begin_=@begin and a.end_=@begin)) and a.accnt=b.accnt and b.restype not in (select code from restype where definite='T')),0)
		select @walkin = 0
		select @exten = 0
		select @samres = 0
		select @edep = 0
		select @noshow = 0
		select @samcxl = 0
		select @cxltarr = 0
	end	

	-- 赋值 
	select @day=datepart(day, @begin) 
	if @day=1 
	begin
		update #pickup set day01=@occ where code='occ'
		update #pickup set day01=@revenue where code='revenue'
		update #pickup set day01=@rebate where code='rebate'
		update #pickup set day01=@ten_rn where code='ten_rn'
		update #pickup set day01=@ten_rev where code='ten_rev'
		update #pickup set day01=@walkin where code='walkin'
		update #pickup set day01=@exten where code='exten'
		update #pickup set day01=@samres where code='samres'
		update #pickup set day01=@edep where code='edep'
		update #pickup set day01=@noshow where code='noshow'
		update #pickup set day01=@samcxl where code='samcxl'
		update #pickup set day01=@cxltarr where code='cxltarr' 
	end
	else if @day=2 
	begin
		update #pickup set day02=@occ where code='occ'
		update #pickup set day02=@revenue where code='revenue'
		update #pickup set day02=@rebate where code='rebate'
		update #pickup set day02=@ten_rn where code='ten_rn'
		update #pickup set day02=@ten_rev where code='ten_rev'
		update #pickup set day02=@walkin where code='walkin'
		update #pickup set day02=@exten where code='exten'
		update #pickup set day02=@samres where code='samres'
		update #pickup set day02=@edep where code='edep'
		update #pickup set day02=@noshow where code='noshow'
		update #pickup set day02=@samcxl where code='samcxl'
		update #pickup set day02=@cxltarr where code='cxltarr' 
	end
	else if @day=3 
	begin
		update #pickup set day03=@occ where code='occ'
		update #pickup set day03=@revenue where code='revenue'
		update #pickup set day03=@rebate where code='rebate'
		update #pickup set day03=@ten_rn where code='ten_rn'
		update #pickup set day03=@ten_rev where code='ten_rev'
		update #pickup set day03=@walkin where code='walkin'
		update #pickup set day03=@exten where code='exten'
		update #pickup set day03=@samres where code='samres'
		update #pickup set day03=@edep where code='edep'
		update #pickup set day03=@noshow where code='noshow'
		update #pickup set day03=@samcxl where code='samcxl'
		update #pickup set day03=@cxltarr where code='cxltarr' 
	end
	else if @day=4 
	begin
		update #pickup set day04=@occ where code='occ'
		update #pickup set day04=@revenue where code='revenue'
		update #pickup set day04=@rebate where code='rebate'
		update #pickup set day04=@ten_rn where code='ten_rn'
		update #pickup set day04=@ten_rev where code='ten_rev'
		update #pickup set day04=@walkin where code='walkin'
		update #pickup set day04=@exten where code='exten'
		update #pickup set day04=@samres where code='samres'
		update #pickup set day04=@edep where code='edep'
		update #pickup set day04=@noshow where code='noshow'
		update #pickup set day04=@samcxl where code='samcxl'
		update #pickup set day04=@cxltarr where code='cxltarr' 
	end
	else if @day=5 
	begin
		update #pickup set day05=@occ where code='occ'
		update #pickup set day05=@revenue where code='revenue'
		update #pickup set day05=@rebate where code='rebate'
		update #pickup set day05=@ten_rn where code='ten_rn'
		update #pickup set day05=@ten_rev where code='ten_rev'
		update #pickup set day05=@walkin where code='walkin'
		update #pickup set day05=@exten where code='exten'
		update #pickup set day05=@samres where code='samres'
		update #pickup set day05=@edep where code='edep'
		update #pickup set day05=@noshow where code='noshow'
		update #pickup set day05=@samcxl where code='samcxl'
		update #pickup set day05=@cxltarr where code='cxltarr' 
	end
	else if @day=6 
	begin
		update #pickup set day06=@occ where code='occ'
		update #pickup set day06=@revenue where code='revenue'
		update #pickup set day06=@rebate where code='rebate'
		update #pickup set day06=@ten_rn where code='ten_rn'
		update #pickup set day06=@ten_rev where code='ten_rev'
		update #pickup set day06=@walkin where code='walkin'
		update #pickup set day06=@exten where code='exten'
		update #pickup set day06=@samres where code='samres'
		update #pickup set day06=@edep where code='edep'
		update #pickup set day06=@noshow where code='noshow'
		update #pickup set day06=@samcxl where code='samcxl'
		update #pickup set day06=@cxltarr where code='cxltarr' 
	end
	else if @day=7 
	begin
		update #pickup set day07=@occ where code='occ'
		update #pickup set day07=@revenue where code='revenue'
		update #pickup set day07=@rebate where code='rebate'
		update #pickup set day07=@ten_rn where code='ten_rn'
		update #pickup set day07=@ten_rev where code='ten_rev'
		update #pickup set day07=@walkin where code='walkin'
		update #pickup set day07=@exten where code='exten'
		update #pickup set day07=@samres where code='samres'
		update #pickup set day07=@edep where code='edep'
		update #pickup set day07=@noshow where code='noshow'
		update #pickup set day07=@samcxl where code='samcxl'
		update #pickup set day07=@cxltarr where code='cxltarr' 
	end
	else if @day=8 
	begin
		update #pickup set day08=@occ where code='occ'
		update #pickup set day08=@revenue where code='revenue'
		update #pickup set day08=@rebate where code='rebate'
		update #pickup set day08=@ten_rn where code='ten_rn'
		update #pickup set day08=@ten_rev where code='ten_rev'
		update #pickup set day08=@walkin where code='walkin'
		update #pickup set day08=@exten where code='exten'
		update #pickup set day08=@samres where code='samres'
		update #pickup set day08=@edep where code='edep'
		update #pickup set day08=@noshow where code='noshow'
		update #pickup set day08=@samcxl where code='samcxl'
		update #pickup set day08=@cxltarr where code='cxltarr' 
	end
	else if @day=9 
	begin
		update #pickup set day09=@occ where code='occ'
		update #pickup set day09=@revenue where code='revenue'
		update #pickup set day09=@rebate where code='rebate'
		update #pickup set day09=@ten_rn where code='ten_rn'
		update #pickup set day09=@ten_rev where code='ten_rev'
		update #pickup set day09=@walkin where code='walkin'
		update #pickup set day09=@exten where code='exten'
		update #pickup set day09=@samres where code='samres'
		update #pickup set day09=@edep where code='edep'
		update #pickup set day09=@noshow where code='noshow'
		update #pickup set day09=@samcxl where code='samcxl'
		update #pickup set day09=@cxltarr where code='cxltarr' 
	end
	else if @day=10 
	begin
		update #pickup set day10=@occ where code='occ'
		update #pickup set day10=@revenue where code='revenue'
		update #pickup set day10=@rebate where code='rebate'
		update #pickup set day10=@ten_rn where code='ten_rn'
		update #pickup set day10=@ten_rev where code='ten_rev'
		update #pickup set day10=@walkin where code='walkin'
		update #pickup set day10=@exten where code='exten'
		update #pickup set day10=@samres where code='samres'
		update #pickup set day10=@edep where code='edep'
		update #pickup set day10=@noshow where code='noshow'
		update #pickup set day10=@samcxl where code='samcxl'
		update #pickup set day10=@cxltarr where code='cxltarr' 
	end
	else if @day=11 
	begin
		update #pickup set day11=@occ where code='occ'
		update #pickup set day11=@revenue where code='revenue'
		update #pickup set day11=@rebate where code='rebate'
		update #pickup set day11=@ten_rn where code='ten_rn'
		update #pickup set day11=@ten_rev where code='ten_rev'
		update #pickup set day11=@walkin where code='walkin'
		update #pickup set day11=@exten where code='exten'
		update #pickup set day11=@samres where code='samres'
		update #pickup set day11=@edep where code='edep'
		update #pickup set day11=@noshow where code='noshow'
		update #pickup set day11=@samcxl where code='samcxl'
		update #pickup set day11=@cxltarr where code='cxltarr' 
	end
	else if @day=12 
	begin
		update #pickup set day12=@occ where code='occ'
		update #pickup set day12=@revenue where code='revenue'
		update #pickup set day12=@rebate where code='rebate'
		update #pickup set day12=@ten_rn where code='ten_rn'
		update #pickup set day12=@ten_rev where code='ten_rev'
		update #pickup set day12=@walkin where code='walkin'
		update #pickup set day12=@exten where code='exten'
		update #pickup set day12=@samres where code='samres'
		update #pickup set day12=@edep where code='edep'
		update #pickup set day12=@noshow where code='noshow'
		update #pickup set day12=@samcxl where code='samcxl'
		update #pickup set day12=@cxltarr where code='cxltarr' 
	end
	else if @day=13 
	begin
		update #pickup set day13=@occ where code='occ'
		update #pickup set day13=@revenue where code='revenue'
		update #pickup set day13=@rebate where code='rebate'
		update #pickup set day13=@ten_rn where code='ten_rn'
		update #pickup set day13=@ten_rev where code='ten_rev'
		update #pickup set day13=@walkin where code='walkin'
		update #pickup set day13=@exten where code='exten'
		update #pickup set day13=@samres where code='samres'
		update #pickup set day13=@edep where code='edep'
		update #pickup set day13=@noshow where code='noshow'
		update #pickup set day13=@samcxl where code='samcxl'
		update #pickup set day13=@cxltarr where code='cxltarr' 
	end
	else if @day=14 
	begin
		update #pickup set day14=@occ where code='occ'
		update #pickup set day14=@revenue where code='revenue'
		update #pickup set day14=@rebate where code='rebate'
		update #pickup set day14=@ten_rn where code='ten_rn'
		update #pickup set day14=@ten_rev where code='ten_rev'
		update #pickup set day14=@walkin where code='walkin'
		update #pickup set day14=@exten where code='exten'
		update #pickup set day14=@samres where code='samres'
		update #pickup set day14=@edep where code='edep'
		update #pickup set day14=@noshow where code='noshow'
		update #pickup set day14=@samcxl where code='samcxl'
		update #pickup set day14=@cxltarr where code='cxltarr' 
	end
	else if @day=15 
	begin
		update #pickup set day15=@occ where code='occ'
		update #pickup set day15=@revenue where code='revenue'
		update #pickup set day15=@rebate where code='rebate'
		update #pickup set day15=@ten_rn where code='ten_rn'
		update #pickup set day15=@ten_rev where code='ten_rev'
		update #pickup set day15=@walkin where code='walkin'
		update #pickup set day15=@exten where code='exten'
		update #pickup set day15=@samres where code='samres'
		update #pickup set day15=@edep where code='edep'
		update #pickup set day15=@noshow where code='noshow'
		update #pickup set day15=@samcxl where code='samcxl'
		update #pickup set day15=@cxltarr where code='cxltarr' 
	end
	else if @day=16 
	begin
		update #pickup set day16=@occ where code='occ'
		update #pickup set day16=@revenue where code='revenue'
		update #pickup set day16=@rebate where code='rebate'
		update #pickup set day16=@ten_rn where code='ten_rn'
		update #pickup set day16=@ten_rev where code='ten_rev'
		update #pickup set day16=@walkin where code='walkin'
		update #pickup set day16=@exten where code='exten'
		update #pickup set day16=@samres where code='samres'
		update #pickup set day16=@edep where code='edep'
		update #pickup set day16=@noshow where code='noshow'
		update #pickup set day16=@samcxl where code='samcxl'
		update #pickup set day16=@cxltarr where code='cxltarr' 
	end
	else if @day=17 
	begin
		update #pickup set day17=@occ where code='occ'
		update #pickup set day17=@revenue where code='revenue'
		update #pickup set day17=@rebate where code='rebate'
		update #pickup set day17=@ten_rn where code='ten_rn'
		update #pickup set day17=@ten_rev where code='ten_rev'
		update #pickup set day17=@walkin where code='walkin'
		update #pickup set day17=@exten where code='exten'
		update #pickup set day17=@samres where code='samres'
		update #pickup set day17=@edep where code='edep'
		update #pickup set day17=@noshow where code='noshow'
		update #pickup set day17=@samcxl where code='samcxl'
		update #pickup set day17=@cxltarr where code='cxltarr' 
	end
	else if @day=18 
	begin
		update #pickup set day18=@occ where code='occ'
		update #pickup set day18=@revenue where code='revenue'
		update #pickup set day18=@rebate where code='rebate'
		update #pickup set day18=@ten_rn where code='ten_rn'
		update #pickup set day18=@ten_rev where code='ten_rev'
		update #pickup set day18=@walkin where code='walkin'
		update #pickup set day18=@exten where code='exten'
		update #pickup set day18=@samres where code='samres'
		update #pickup set day18=@edep where code='edep'
		update #pickup set day18=@noshow where code='noshow'
		update #pickup set day18=@samcxl where code='samcxl'
		update #pickup set day18=@cxltarr where code='cxltarr' 
	end
	else if @day=19 
	begin
		update #pickup set day19=@occ where code='occ'
		update #pickup set day19=@revenue where code='revenue'
		update #pickup set day19=@rebate where code='rebate'
		update #pickup set day19=@ten_rn where code='ten_rn'
		update #pickup set day19=@ten_rev where code='ten_rev'
		update #pickup set day19=@walkin where code='walkin'
		update #pickup set day19=@exten where code='exten'
		update #pickup set day19=@samres where code='samres'
		update #pickup set day19=@edep where code='edep'
		update #pickup set day19=@noshow where code='noshow'
		update #pickup set day19=@samcxl where code='samcxl'
		update #pickup set day19=@cxltarr where code='cxltarr' 
	end
	else if @day=20 
	begin
		update #pickup set day20=@occ where code='occ'
		update #pickup set day20=@revenue where code='revenue'
		update #pickup set day20=@rebate where code='rebate'
		update #pickup set day20=@ten_rn where code='ten_rn'
		update #pickup set day20=@ten_rev where code='ten_rev'
		update #pickup set day20=@walkin where code='walkin'
		update #pickup set day20=@exten where code='exten'
		update #pickup set day20=@samres where code='samres'
		update #pickup set day20=@edep where code='edep'
		update #pickup set day20=@noshow where code='noshow'
		update #pickup set day20=@samcxl where code='samcxl'
		update #pickup set day20=@cxltarr where code='cxltarr' 
	end
	else if @day=21 
	begin
		update #pickup set day21=@occ where code='occ'
		update #pickup set day21=@revenue where code='revenue'
		update #pickup set day21=@rebate where code='rebate'
		update #pickup set day21=@ten_rn where code='ten_rn'
		update #pickup set day21=@ten_rev where code='ten_rev'
		update #pickup set day21=@walkin where code='walkin'
		update #pickup set day21=@exten where code='exten'
		update #pickup set day21=@samres where code='samres'
		update #pickup set day21=@edep where code='edep'
		update #pickup set day21=@noshow where code='noshow'
		update #pickup set day21=@samcxl where code='samcxl'
		update #pickup set day21=@cxltarr where code='cxltarr' 
	end
	else if @day=22 
	begin
		update #pickup set day22=@occ where code='occ'
		update #pickup set day22=@revenue where code='revenue'
		update #pickup set day22=@rebate where code='rebate'
		update #pickup set day22=@ten_rn where code='ten_rn'
		update #pickup set day22=@ten_rev where code='ten_rev'
		update #pickup set day22=@walkin where code='walkin'
		update #pickup set day22=@exten where code='exten'
		update #pickup set day22=@samres where code='samres'
		update #pickup set day22=@edep where code='edep'
		update #pickup set day22=@noshow where code='noshow'
		update #pickup set day22=@samcxl where code='samcxl'
		update #pickup set day22=@cxltarr where code='cxltarr' 
	end
	else if @day=23 
	begin
		update #pickup set day23=@occ where code='occ'
		update #pickup set day23=@revenue where code='revenue'
		update #pickup set day23=@rebate where code='rebate'
		update #pickup set day23=@ten_rn where code='ten_rn'
		update #pickup set day23=@ten_rev where code='ten_rev'
		update #pickup set day23=@walkin where code='walkin'
		update #pickup set day23=@exten where code='exten'
		update #pickup set day23=@samres where code='samres'
		update #pickup set day23=@edep where code='edep'
		update #pickup set day23=@noshow where code='noshow'
		update #pickup set day23=@samcxl where code='samcxl'
		update #pickup set day23=@cxltarr where code='cxltarr' 
	end
	else if @day=24 
	begin
		update #pickup set day24=@occ where code='occ'
		update #pickup set day24=@revenue where code='revenue'
		update #pickup set day24=@rebate where code='rebate'
		update #pickup set day24=@ten_rn where code='ten_rn'
		update #pickup set day24=@ten_rev where code='ten_rev'
		update #pickup set day24=@walkin where code='walkin'
		update #pickup set day24=@exten where code='exten'
		update #pickup set day24=@samres where code='samres'
		update #pickup set day24=@edep where code='edep'
		update #pickup set day24=@noshow where code='noshow'
		update #pickup set day24=@samcxl where code='samcxl'
		update #pickup set day24=@cxltarr where code='cxltarr' 
	end
	else if @day=25 
	begin
		update #pickup set day25=@occ where code='occ'
		update #pickup set day25=@revenue where code='revenue'
		update #pickup set day25=@rebate where code='rebate'
		update #pickup set day25=@ten_rn where code='ten_rn'
		update #pickup set day25=@ten_rev where code='ten_rev'
		update #pickup set day25=@walkin where code='walkin'
		update #pickup set day25=@exten where code='exten'
		update #pickup set day25=@samres where code='samres'
		update #pickup set day25=@edep where code='edep'
		update #pickup set day25=@noshow where code='noshow'
		update #pickup set day25=@samcxl where code='samcxl'
		update #pickup set day25=@cxltarr where code='cxltarr' 
	end
	else if @day=26 
	begin
		update #pickup set day26=@occ where code='occ'
		update #pickup set day26=@revenue where code='revenue'
		update #pickup set day26=@rebate where code='rebate'
		update #pickup set day26=@ten_rn where code='ten_rn'
		update #pickup set day26=@ten_rev where code='ten_rev'
		update #pickup set day26=@walkin where code='walkin'
		update #pickup set day26=@exten where code='exten'
		update #pickup set day26=@samres where code='samres'
		update #pickup set day26=@edep where code='edep'
		update #pickup set day26=@noshow where code='noshow'
		update #pickup set day26=@samcxl where code='samcxl'
		update #pickup set day26=@cxltarr where code='cxltarr' 
	end
	else if @day=27 
	begin
		update #pickup set day27=@occ where code='occ'
		update #pickup set day27=@revenue where code='revenue'
		update #pickup set day27=@rebate where code='rebate'
		update #pickup set day27=@ten_rn where code='ten_rn'
		update #pickup set day27=@ten_rev where code='ten_rev'
		update #pickup set day27=@walkin where code='walkin'
		update #pickup set day27=@exten where code='exten'
		update #pickup set day27=@samres where code='samres'
		update #pickup set day27=@edep where code='edep'		
		update #pickup set day27=@noshow where code='noshow'
		update #pickup set day27=@samcxl where code='samcxl'
		update #pickup set day27=@cxltarr where code='cxltarr' 
	end
	else if @day=28 
	begin
		update #pickup set day28=@occ where code='occ'
		update #pickup set day28=@revenue where code='revenue'
		update #pickup set day28=@rebate where code='rebate'
		update #pickup set day28=@ten_rn where code='ten_rn'
		update #pickup set day28=@ten_rev where code='ten_rev'
		update #pickup set day28=@walkin where code='walkin'
		update #pickup set day28=@exten where code='exten'
		update #pickup set day28=@samres where code='samres'
		update #pickup set day28=@edep where code='edep'
		update #pickup set day28=@noshow where code='noshow'
		update #pickup set day28=@samcxl where code='samcxl'
		update #pickup set day28=@cxltarr where code='cxltarr' 
	end
	else if @day=29 
	begin
		update #pickup set day29=@occ where code='occ'
		update #pickup set day29=@revenue where code='revenue'
		update #pickup set day29=@rebate where code='rebate'
		update #pickup set day29=@ten_rn where code='ten_rn'
		update #pickup set day29=@ten_rev where code='ten_rev'
		update #pickup set day29=@walkin where code='walkin'
		update #pickup set day29=@exten where code='exten'
		update #pickup set day29=@samres where code='samres'
		update #pickup set day29=@edep where code='edep'
		update #pickup set day29=@noshow where code='noshow'
		update #pickup set day29=@samcxl where code='samcxl'
		update #pickup set day29=@cxltarr where code='cxltarr' 
	end
	else if @day=30 
	begin
		update #pickup set day30=@occ where code='occ'
		update #pickup set day30=@revenue where code='revenue'
		update #pickup set day30=@rebate where code='rebate'
		update #pickup set day30=@ten_rn where code='ten_rn'
		update #pickup set day30=@ten_rev where code='ten_rev'
		update #pickup set day30=@walkin where code='walkin'
		update #pickup set day30=@exten where code='exten'
		update #pickup set day30=@samres where code='samres'
		update #pickup set day30=@edep where code='edep'
		update #pickup set day30=@noshow where code='noshow'
		update #pickup set day30=@samcxl where code='samcxl'
		update #pickup set day30=@cxltarr where code='cxltarr' 
	end
	else if @day=31 
	begin
		update #pickup set day31=@occ where code='occ'
		update #pickup set day31=@revenue where code='revenue'
		update #pickup set day31=@rebate where code='rebate'
		update #pickup set day31=@ten_rn where code='ten_rn'
		update #pickup set day31=@ten_rev where code='ten_rev'
		update #pickup set day31=@walkin where code='walkin'
		update #pickup set day31=@exten where code='exten'
		update #pickup set day31=@samres where code='samres'
		update #pickup set day31=@edep where code='edep'
		update #pickup set day31=@noshow where code='noshow'
		update #pickup set day31=@samcxl where code='samcxl'
		update #pickup set day31=@cxltarr where code='cxltarr' 
	end

	select @begin = dateadd(dd, 1, @begin) 
end
update #pickup set ttl=day01+day02+day03+day04+day05+day06+day07+day08+day09+day10+
	day11+day12+day13+day14+day15+day16+day17+day18+day19+day20+
	day21+day22+day23+day24+day25+day26+day27+day28+day29+day30+day31 

gout:
select * from #pickup order by sequence, code 
return 0
;
