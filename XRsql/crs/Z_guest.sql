if exists (select 1
            from  sysobjects
            where  id = object_id('guest_income')
            and    type = 'U')
   drop table guest_income
;

/* ============================================================ */
/*   Table: guest_income                                        */
/* ============================================================ */
create table guest_income
(
   hotelid     varchar(20)                   not null,
	no 			char(7)								not null,
	accnt			char(10)								not null,
	resno			char(10)								null,
	sta			char(1)								null,
	arr			datetime								null,
	dep			datetime								null,
	type			char(5)								null,
	roomno		char(5)								null,
	setrate		money				default 0		null,
	haccnt		char(7)								not null,
	name		   varchar(50)	 	default ''		null,	 	-- 姓名1
	name2		   varchar(50)	 	default ''		null,	 	-- 姓名2
	gstno			int				default 0		not null,
	rmnum			int				default 0		not null,
	packages		varchar(50)			default ''		not null,	-- 包价
	charge		money				default 0		null,
	ref			varchar(255)						null,
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
	sync      	char(1)			default ''		not null,	    
	lastdate		datetime					  			null,        
	cardcode char(10) null,
	cardno char(20) null
)
;
exec sp_primarykey guest_income,hotelid,accnt
create unique index index1 on guest_income(hotelid,accnt)
;
