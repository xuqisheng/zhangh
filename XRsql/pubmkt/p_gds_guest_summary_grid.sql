
if  exists(select * from sysobjects where name = "p_gds_guest_summary_grid")
	drop proc p_gds_guest_summary_grid
;
create proc p_gds_guest_summary_grid
	@no		char(7)
as

create table #goutput
(
	year			char(4)			default ''	not null,	-- 年份
	ttl			money				default 0 not null,		-- 总消费
	rm				money				default 0 not null,		-- 客房消费
	fb				money				default 0 not null,		-- 餐饮消费
	ot				money				default 0 not null,		-- 其他消费
	non			money				default 0 not null,		-- 代收
	nights		money				default 0 not null,		-- 房晚
	rate			money				default 0 not null,		-- 平均房价 
	m1				money				default 0 not null,
	m2				money				default 0 not null,
	m3				money				default 0 not null,
	m4				money				default 0 not null,
	m5				money				default 0 not null,
	m6				money				default 0 not null,
	m7				money				default 0 not null,
	m8				money				default 0 not null,
	m9				money				default 0 not null,
	m10			money				default 0 not null,
	m11			money				default 0 not null,
	m12			money				default 0 not null
)

-- 总消费
insert #goutput(year,ttl,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12)
	select year,ttl,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12
		from guest_xfttl where no=@no and tag='TTL'

-- 房费
update #goutput set rm = isnull((select sum(a.ttl) from guest_xfttl a where a.no=@no and #goutput.year=a.year and a.tag='RM'), 0)

-- 餐费
update #goutput set fb = isnull((select sum(a.ttl) from guest_xfttl a where a.no=@no and #goutput.year=a.year and a.tag='FB'), 0)

-- 其他
update #goutput set ot = isnull((select sum(a.ttl) from guest_xfttl a where a.no=@no and #goutput.year=a.year and a.tag='OT'), 0)
	
-- 房晚
update #goutput set nights = isnull((select sum(a.ttl) from guest_xfttl a where a.no=@no and #goutput.year=a.year and a.tag='NIGHTS'), 0)

-- 平均房价 
update #goutput set rate = round(rm/nights, 2) where nights<>0 

select year, ttl, rm, fb, ot, non, nights, rate, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12 
	from #goutput order by year 

return 0
;
