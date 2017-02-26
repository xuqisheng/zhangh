if exists (select 1 from sysobjects where name = 'p_guest_income_resum_accnt' and type = 'P')
   drop procedure p_guest_income_resum_accnt
;

create procedure p_guest_income_resum_accnt
	@hotelid			char(20), 				
	@accnt			char(10)				
as
begin 
	create table #lst
	(
		no 			char(7)								not null,
		i_times     int 				default 0 		not null,   -- 住店次数
		x_times     int 				default 0 		not null,   -- 取消预订次数
		n_times     int 				default 0 		not null,   -- 应到未到次数
		l_times     int 				default 0 		not null,   -- 其它次数
		i_days      int 				default 0 		not null,   -- 住店天数
		fb_times1   int 				default 0 		not null,   -- 餐饮次数
		en_times2   int 				default 0 		not null,   -- 娱乐次数
		rm          money 			default 0 		not null, 	-- 房租收入
		fb       	money 			default 0 		not null, 	-- 餐饮收入
		en          money 			default 0 		not null, 	-- 娱乐收入
		mt          money 			default 0 		not null, 	-- 会议收入
		ot          money 			default 0 		not null, 	-- 其它收入
		tl          money 			default 0 		not null, 	-- 总收入
	)
	insert into #lst
	select no,sum(i_times),sum(x_times),sum(n_times),sum(l_times),sum(i_days),sum(fb_times1),
			 sum(en_times2),sum(rm),sum(fb),sum(en),sum(mt),sum(ot),sum(tl) 
	from guest_income 
	where no in(select no from guest_income where hotelid = @hotelid and accnt = @accnt and sync<>'0')
	group by no

	update guest set i_times = a.i_times,x_times = a.x_times,n_times = a.n_times,l_times = a.l_times,
		i_days =a.i_days,fb_times1 = a.fb_times1,en_times2 = a.en_times2,rm=a.rm,fb = a.fb,en=a.en,
		mt=a.mt,ot=a.ot,tl=a.tl 
	from guest,#lst a 
	where guest.no = a.no 
	
	update guest_income set sync = '0' where hotelid = @hotelid and accnt = @accnt and sync<>'0'

	return 0
end
;


