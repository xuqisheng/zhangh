
if  exists(select * from sysobjects where name = "p_gds_guest_summary_grid")
	drop proc p_gds_guest_summary_grid
;
create proc p_gds_guest_summary_grid
	@no		char(7)
as

create table #goutput
(
	year			char(4)			default ''	not null,	-- ���
	ttl			money				default 0 not null,		-- ������
	rm				money				default 0 not null,		-- �ͷ�����
	fb				money				default 0 not null,		-- ��������
	ot				money				default 0 not null,		-- ��������
	non			money				default 0 not null,		-- ����
	nights		money				default 0 not null,		-- ����
	rate			money				default 0 not null,		-- ƽ������ 
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

-- ������
insert #goutput(year,ttl,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12)
	select year,ttl,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12
		from guest_xfttl where no=@no and tag='TTL'

-- ����
update #goutput set rm = isnull((select sum(a.ttl) from guest_xfttl a where a.no=@no and #goutput.year=a.year and a.tag='RM'), 0)

-- �ͷ�
update #goutput set fb = isnull((select sum(a.ttl) from guest_xfttl a where a.no=@no and #goutput.year=a.year and a.tag='FB'), 0)

-- ����
update #goutput set ot = isnull((select sum(a.ttl) from guest_xfttl a where a.no=@no and #goutput.year=a.year and a.tag='OT'), 0)
	
-- ����
update #goutput set nights = isnull((select sum(a.ttl) from guest_xfttl a where a.no=@no and #goutput.year=a.year and a.tag='NIGHTS'), 0)

-- ƽ������ 
update #goutput set rate = round(rm/nights, 2) where nights<>0 

select year, ttl, rm, fb, ot, non, nights, rate, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12 
	from #goutput order by year 

return 0
;
