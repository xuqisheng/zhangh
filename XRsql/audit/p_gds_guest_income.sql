
IF OBJECT_ID('p_gds_guest_income') IS NOT NULL
    DROP PROCEDURE p_gds_guest_income
;
create proc p_gds_guest_income
	@accnt		char(10)
as
------------------------------------------------------------------
--	由于 guest 表结构较大，而且有触发器处理，
--		因此需要尽量减少 update 的次数
------------------------------------------------------------------
--	Build one master income to profile, using in audit - dlmaster
------------------------------------------------------------------
declare	@class 		char(1),
			@rm 			money,			@fb 			money,
			@en 			money,			@mt 			money,
			@ot 			money,			@tl 			money,
			@i_days 		int,			@x_times		int,
			@n_times		int,			@i_times		int,
			@l_times		int,			@fb_times1	int,			@en_times2		int,
			@fv_date		datetime,	@fv_room 	char(5),		@fv_rate 		money,
			@lv_date 	datetime,	@lv_room 	char(5),		@lv_rate 		money

declare	@arr			datetime,
			@dep			datetime,
			@year			char(4),
			@month		int

select @rm=0,@fb=0,@en=0,@mt=0,@ot=0,@tl=0,
	@i_days=0,@x_times=0,@n_times=0,@i_times=0,@l_times=0,@fb_times1=0,@en_times2=0,
	@fv_date=null,@fv_room='',@fv_rate=0,
	@lv_date=null,@lv_room='',@lv_rate=0

-- 由于这里的 @arr, @dep 要用来决定业绩计算到那个月份，也许需要用 citime, cotime, deptime ?
select @class = class, @arr=arr, @dep=dep from hmaster where accnt=@accnt

-- 消费帐、应收帐不参与统计；
if @class in ('C', 'A') 
	return 

-- 计算房晚的费用码
declare	@rm_pccodes_nt	char(255)
select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')

-- Sum
exec p_gds_master_income @accnt, 'R'
exec p_gl_audit_vipcard_point @accnt, 'R'
select * into #income from master_income where accnt = @accnt

if exists(select 1 from #income)
begin
	-- 业绩需要计算到主单的所有档案
	create table #guest(no	char(7)	not null, class	char(1)	not null, nights	int  not null)
	declare @haccnt char(7),@cusno char(7),@agent char(7),@source char(7)
	select @haccnt=haccnt,@cusno=cusno,@agent=agent,@source=source from hmaster where accnt=@accnt
	insert #guest(no, class, nights) values(@haccnt, '', 0)
	if rtrim(@cusno) is not null
		insert #guest(no, class, nights) values(@cusno, '', 0)
	if rtrim(@agent) is not null
		insert #guest(no, class, nights) values(@agent, '', 0)
	if rtrim(@source) is not null
		insert #guest(no, class, nights) values(@source, '', 0)
	update #guest set class=a.class from guest a where a.no=#guest.no
	
	-- 累加
	select @rm = isnull((select sum(amount1) from #income a, pccode b where  a.pccode=b.pccode and b.deptno7='rm'),0)
	select @fb = isnull((select sum(amount1) from #income a, pccode b where  a.pccode=b.pccode and b.deptno7='fb'),0)
	select @en = isnull((select sum(amount1) from #income a, pccode b where  a.pccode=b.pccode and b.deptno7='en'),0)
	select @mt = isnull((select sum(amount1) from #income a, pccode b where  a.pccode=b.pccode and b.deptno7='mt'),0)
	select @ot = isnull((select sum(amount1) from #income a, pccode b where  a.pccode=b.pccode and b.deptno7='ot'),0)
	select @tl = @rm + @fb + @en + @mt + @ot

	select @x_times = isnull((select sum(amount2) from #income a where  a.item='X_TIMES'),0)
	select @n_times = isnull((select sum(amount2) from #income a where  a.item='N_TIMES'),0)
	select @i_times = isnull((select sum(amount2) from #income a where  a.item='I_TIMES'),0)

	update guest set rm=rm+@rm,fb=fb+@fb,en=en+@en,mt=mt+@mt,ot=ot+@ot,tl=tl+@tl,
		 		x_times=x_times+@x_times, n_times=n_times+@n_times, i_times=i_times+@i_times
		from #guest a where guest.no=a.no
	
	-- 房晚的更新要注意：个人和单位的不同（同住问题）
	update #guest set nights = isnull((select sum(a.amount2) from #income a where a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ),0) where class='F'
	update #guest set nights = isnull((select sum(a.amount2) from #income a where a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master),0) where class<>'F'
	update guest set i_days =i_days + a.nights from #guest a where guest.no=a.no

	-- fv_date (首次入住)
	update guest set fv_date=a.arr, fv_room=a.roomno, fv_rate=a.setrate 
		from hmaster a, #guest b
			where a.accnt=@accnt and a.sta='O' and guest.i_times = 1
				and guest.no = b.no
	
	-- lv_date (最近入住)
	update guest set lv_date=a.arr, lv_room=a.roomno, lv_rate=a.setrate 
		from hmaster a, #guest b
			where a.accnt=@accnt and a.sta='O'
				and guest.no = b.no

	-- 更新 guest_xfttl 2006.1.13 
	select @year = convert(char(4), datepart(year, @dep)), @month = datepart(month, @dep)

	insert guest_xfttl(no, year, tag) 
		select a.no, @year, b.code from #guest a, basecode b 
			where b.cat='guest_sumtag' 
				and a.no+@year+b.code not in (select no+year+tag from guest_xfttl c where a.no=c.no and c.year=@year) 
-- 以下写法导致武汉锦江夜审错误，插入重复键 
--	insert guest_xfttl(no, year, tag) 
--		select a.no, @year, b.code from #guest a, basecode b 
--			where b.cat='guest_sumtag' and not exists(select 1 from guest_xfttl c where a.no=c.no and c.year=@year and c.tag=b.code) 

	-- 目前的统计项目= RM, FB, OT, TTL, NIGHTS  (basecode - guest_sumtag)
	if @month = 1
	begin
		update guest_xfttl set m1=m1+@rm,			ttl=ttl+@rm 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='RM' 
		update guest_xfttl set m1=m1+@fb,			ttl=ttl+@fb 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='FB' 
		update guest_xfttl set m1=m1+@en+@mt+@ot,	ttl=ttl+@en+@mt+@ot 	from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='OT' 
		update guest_xfttl set m1=m1+@tl,			ttl=ttl+@tl 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='TTL' 
		update guest_xfttl set m1=m1+a.nights,		ttl=ttl+a.nights 		from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='NIGHTS' 
	end
	else if @month = 2
	begin
		update guest_xfttl set m2=m2+@rm,			ttl=ttl+@rm 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='RM' 
		update guest_xfttl set m2=m2+@fb,			ttl=ttl+@fb 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='FB' 
		update guest_xfttl set m2=m2+@en+@mt+@ot,	ttl=ttl+@en+@mt+@ot 	from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='OT' 
		update guest_xfttl set m2=m2+@tl,			ttl=ttl+@tl 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='TTL' 
		update guest_xfttl set m2=m2+a.nights,		ttl=ttl+a.nights 		from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='NIGHTS' 
	end
	else if @month = 3
	begin
		update guest_xfttl set m3=m3+@rm,			ttl=ttl+@rm 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='RM' 
		update guest_xfttl set m3=m3+@fb,			ttl=ttl+@fb 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='FB' 
		update guest_xfttl set m3=m3+@en+@mt+@ot,	ttl=ttl+@en+@mt+@ot 	from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='OT' 
		update guest_xfttl set m3=m3+@tl,			ttl=ttl+@tl 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='TTL' 
		update guest_xfttl set m3=m3+a.nights,		ttl=ttl+a.nights 		from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='NIGHTS' 
	end
	else if @month = 4
	begin
		update guest_xfttl set m4=m4+@rm,			ttl=ttl+@rm 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='RM' 
		update guest_xfttl set m4=m4+@fb,			ttl=ttl+@fb 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='FB' 
		update guest_xfttl set m4=m4+@en+@mt+@ot,	ttl=ttl+@en+@mt+@ot 	from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='OT' 
		update guest_xfttl set m4=m4+@tl,			ttl=ttl+@tl 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='TTL' 
		update guest_xfttl set m4=m4+a.nights,		ttl=ttl+a.nights 		from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='NIGHTS' 
	end
	else if @month = 5
	begin
		update guest_xfttl set m5=m5+@rm,			ttl=ttl+@rm 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='RM' 
		update guest_xfttl set m5=m5+@fb,			ttl=ttl+@fb 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='FB' 
		update guest_xfttl set m5=m5+@en+@mt+@ot,	ttl=ttl+@en+@mt+@ot 	from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='OT' 
		update guest_xfttl set m5=m5+@tl,			ttl=ttl+@tl 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='TTL' 
		update guest_xfttl set m5=m5+a.nights,		ttl=ttl+a.nights 		from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='NIGHTS' 
	end
	else if @month = 6
	begin
		update guest_xfttl set m6=m6+@rm,			ttl=ttl+@rm 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='RM' 
		update guest_xfttl set m6=m6+@fb,			ttl=ttl+@fb 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='FB' 
		update guest_xfttl set m6=m6+@en+@mt+@ot,	ttl=ttl+@en+@mt+@ot 	from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='OT' 
		update guest_xfttl set m6=m6+@tl,			ttl=ttl+@tl 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='TTL' 
		update guest_xfttl set m6=m6+a.nights,		ttl=ttl+a.nights 		from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='NIGHTS' 
	end
	else if @month = 7
	begin
		update guest_xfttl set m7=m7+@rm,			ttl=ttl+@rm 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='RM' 
		update guest_xfttl set m7=m7+@fb,			ttl=ttl+@fb 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='FB' 
		update guest_xfttl set m7=m7+@en+@mt+@ot,	ttl=ttl+@en+@mt+@ot 	from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='OT' 
		update guest_xfttl set m7=m7+@tl,			ttl=ttl+@tl 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='TTL' 
		update guest_xfttl set m7=m7+a.nights,		ttl=ttl+a.nights 		from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='NIGHTS' 
	end
	else if @month = 8
	begin
		update guest_xfttl set m8=m8+@rm,			ttl=ttl+@rm 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='RM' 
		update guest_xfttl set m8=m8+@fb,			ttl=ttl+@fb 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='FB' 
		update guest_xfttl set m8=m8+@en+@mt+@ot,	ttl=ttl+@en+@mt+@ot 	from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='OT' 
		update guest_xfttl set m8=m8+@tl,			ttl=ttl+@tl 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='TTL' 
		update guest_xfttl set m8=m8+a.nights,		ttl=ttl+a.nights 		from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='NIGHTS' 
	end
	else if @month = 9
	begin
		update guest_xfttl set m9=m9+@rm,			ttl=ttl+@rm 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='RM' 
		update guest_xfttl set m9=m9+@fb,			ttl=ttl+@fb 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='FB' 
		update guest_xfttl set m9=m9+@en+@mt+@ot,	ttl=ttl+@en+@mt+@ot 	from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='OT' 
		update guest_xfttl set m9=m9+@tl,			ttl=ttl+@tl 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='TTL' 
		update guest_xfttl set m9=m9+a.nights,		ttl=ttl+a.nights 		from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='NIGHTS' 
	end
	else if @month = 10
	begin
		update guest_xfttl set m10=m10+@rm,			ttl=ttl+@rm 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='RM' 
		update guest_xfttl set m10=m10+@fb,			ttl=ttl+@fb 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='FB' 
		update guest_xfttl set m10=m10+@en+@mt+@ot,ttl=ttl+@en+@mt+@ot from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='OT' 
		update guest_xfttl set m10=m10+@tl,			ttl=ttl+@tl 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='TTL' 
		update guest_xfttl set m10=m10+a.nights,	ttl=ttl+a.nights 		from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='NIGHTS' 
	end
	else if @month = 11
	begin
		update guest_xfttl set m11=m11+@rm,			ttl=ttl+@rm 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='RM' 
		update guest_xfttl set m11=m11+@fb,			ttl=ttl+@fb 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='FB' 
		update guest_xfttl set m11=m11+@en+@mt+@ot,ttl=ttl+@en+@mt+@ot from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='OT' 
		update guest_xfttl set m11=m11+@tl,			ttl=ttl+@tl 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='TTL' 
		update guest_xfttl set m11=m11+a.nights,	ttl=ttl+a.nights 		from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='NIGHTS' 
	end
	else if @month = 12
	begin
		update guest_xfttl set m12=m12+@rm,			ttl=ttl+@rm 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='RM' 
		update guest_xfttl set m12=m12+@fb,			ttl=ttl+@fb 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='FB' 
		update guest_xfttl set m12=m12+@en+@mt+@ot,ttl=ttl+@en+@mt+@ot from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='OT' 
		update guest_xfttl set m12=m12+@tl,			ttl=ttl+@tl 			from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='TTL' 
		update guest_xfttl set m12=m12+a.nights,	ttl=ttl+a.nights 		from #guest a where guest_xfttl.no=a.no and guest_xfttl.year=@year and guest_xfttl.tag='NIGHTS' 
	end
		
end

-- 统计标记 - 表示已经进行了统计 -- 似乎不需要 
-- update hmaster set sta_tm = 'S' where accnt = @accnt 

return 0
;


