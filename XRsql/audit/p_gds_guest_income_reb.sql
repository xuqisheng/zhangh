
IF OBJECT_ID('p_gds_guest_income_reb') IS NOT NULL
    DROP PROCEDURE p_gds_guest_income_reb
;
create proc p_gds_guest_income_reb
	@no			char(7),				-- Null Means All Guests.
	@mode			char(1)=''  		-- ''=重建所有，1=仅仅 guest_xfttl 
as
------------------------------------------------------------------
--	Rebuild xxx profile's income
--		if you want to rebuild all profile, it's very slow.
------------------------------------------------------------------
--	由于 guest 表结构较大，而且有触发器处理，
--		因此需要尽量减少 update 的次数
------------------------------------------------------------------
declare	@mno			char(7),
			@date			datetime,
			@accnt		char(10),
			@class		char(1),
			@rm 			money,
			@fb 			money,
			@en 			money,
			@mt 			money,
			@ot 			money,
			@tl 			money,
			@i_days 		int,			@x_times		int,
			@n_times		int,			@i_times		int,
			@l_times		int,			@fb_times1	int,			@en_times2		int,
			@fv_date		datetime,	@fv_room 	char(5),		@fv_rate 		money,
			@lv_date 	datetime,	@lv_room 	char(5),		@lv_rate 		money

-- Init 
select @rm=0,@fb=0,@en=0,@mt=0,@ot=0,@tl=0,
	@i_days=0,@x_times=0,@n_times=0,@i_times=0,@l_times=0,@fb_times1=0,@en_times2=0,
	@fv_date=null,@fv_room='',@fv_rate=0,
	@lv_date=null,@lv_room='',@lv_rate=0

-- test speed 
declare  @count  int
select @count = 0
if not exists(select 1 from process_flag where flag='guest_reb')
	insert process_flag(flag,value) values('guest_reb', '0')

select @no = rtrim(@no)
if @no is null or @no='' 
	select @no = '%'

-- 计算房晚的费用码
declare	@rm_pccodes_nt	char(255)
select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')

select * into #income from master_income where 1=2
create table #hmst (
	accnt		char(10)		not null,
	arr		datetime		not null,
	dep		datetime		not null,
	year		char(4)		not null,
	month		int			not null
)
create index accnt on #hmst(accnt, year, month)
create table #year (year	char(4)		not null)

-- Begin
declare	c_guest cursor for select no, class from guest where no like @no
open c_guest
fetch c_guest into @mno, @class
while @@sqlstatus = 0
begin
	-- test speed 
	select @count = @count + 1
	update process_flag set value = convert(char(10), @count) where flag='guest_reb'

	delete #hmst
	delete #year
	delete #income 

	insert #hmst (accnt, arr, dep, year, month) 
		select accnt,arr,dep,convert(char(4),datepart(year,dep)), datepart(month,dep) 
			from hmaster where haccnt=@mno or cusno=@mno or agent=@mno or source=@mno
	insert #year select distinct year from #hmst 
	insert #income select a.* from master_income a, #hmst	b where a.accnt=b.accnt

	if @mode = '' 
	begin 
		select @rm=isnull((select sum(a.amount1) from #income a, pccode b where  a.pccode=b.pccode and b.deptno7='rm'),0)
		select @fb=isnull((select sum(a.amount1) from #income a, pccode b where  a.pccode=b.pccode and b.deptno7='fb'),0)
		select @en=isnull((select sum(a.amount1) from #income a, pccode b where  a.pccode=b.pccode and b.deptno7='en'),0)
		select @mt=isnull((select sum(a.amount1) from #income a, pccode b where  a.pccode=b.pccode and b.deptno7='mt'),0)
		select @ot=isnull((select sum(a.amount1) from #income a, pccode b where  a.pccode=b.pccode and b.deptno7='ot'),0)
		select @tl = @rm+@fb+@en+@mt+@ot
	
		if @class = 'F' 
			select @i_days  = isnull((select sum(a.amount2) from #income a where a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0),0)
		else
			select @i_days  = isnull((select sum(a.amount2) from #income a where a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master),0)
		select @x_times = isnull((select sum(a.amount2) from #income a where  a.item='X_TIMES'),0)
		select @n_times = isnull((select sum(a.amount2) from #income a where  a.item='N_TIMES'),0)
		select @i_times = isnull((select sum(a.amount2) from #income a where  a.item='I_TIMES'),0)
	
		if @i_times > 0  -- 注意如何计算‘最早’与 ‘最迟’
		begin
			-- fv_date
			select @accnt = isnull(substring((select min(convert(char(10),b.arr,111)+a.accnt) from #income a, hmaster b where a.accnt=b.accnt and a.item='I_TIMES' and a.amount2>0),11,10),'')
			if @accnt is not null and @accnt <> ''
				select @fv_date=a.arr, @fv_room=a.roomno, @fv_rate=a.setrate from hmaster a where a.accnt=@accnt
		
			-- lv_date
			select @accnt = isnull(substring((select max(convert(char(10),b.arr,111)+a.accnt) from #income a, hmaster b where a.accnt=b.accnt and a.item='I_TIMES' and a.amount2>0),11,10),'')
			if @accnt is not null and @accnt <> ''
				select @lv_date=a.arr, @lv_room=a.roomno, @lv_rate=a.setrate from hmaster a where a.accnt=@accnt
		end
	
		-- update 
		update guest set i_times=@i_times,x_times=@x_times,n_times=@n_times,l_times=@l_times,i_days=@i_days,
				fb_times1=@fb_times1,en_times2=@en_times2,rm=@rm,fb=@fb,en=@en,mt=@mt,ot=@ot,tl=@tl,
				fv_date=@fv_date,fv_room=@fv_room,fv_rate=@fv_rate,lv_date=@lv_date,lv_room=@lv_room,lv_rate=@lv_rate
		where no=@mno
	end 

	-----------------------------------------------------------------------------
	-- 更新 guest_xfttl  2006.1.13 
	-----------------------------------------------------------------------------
	delete guest_xfttl where no=@mno 
	-- 目前的统计项目= RM, FB, OT, TTL, NIGHTS  (basecode - guest_sumtag)
	insert guest_xfttl(no, year, tag) 
		select @mno, a.year, b.code from #year a, basecode b where b.cat='guest_sumtag' 

--	注意这个 错误的脚本 -- 需要采用下面的方式 
--	update guest_xfttl set m1=isnull((a.amount1), 0) from #income a, pccode b, #hmst c 
--		where guest_xfttl.no=@mno and guest_xfttl.tag='RM' and guest_xfttl.year=c.year and c.month=1
--			and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'

	--  总收入 
	update guest_xfttl set m1=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=1	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7<>''), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='TTL'
	update guest_xfttl set m2=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=2	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7<>''), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='TTL'
	update guest_xfttl set m3=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=3	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7<>''), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='TTL'
	update guest_xfttl set m4=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=4	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7<>''), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='TTL'
	update guest_xfttl set m5=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=5	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7<>''), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='TTL'
	update guest_xfttl set m6=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=6	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7<>''), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='TTL'
	update guest_xfttl set m7=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=7	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7<>''), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='TTL'
	update guest_xfttl set m8=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=8	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7<>''), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='TTL'
	update guest_xfttl set m9=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=9	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7<>''), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='TTL'
	update guest_xfttl set m10=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=10	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7<>''), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='TTL'
	update guest_xfttl set m11=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=11	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7<>''), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='TTL'
	update guest_xfttl set m12=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=12	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7<>''), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='TTL'

	-- 房费 
	update guest_xfttl set m1=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=1	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='RM'
	update guest_xfttl set m2=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=2	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='RM'
	update guest_xfttl set m3=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=3	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='RM'
	update guest_xfttl set m4=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=4	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='RM'
	update guest_xfttl set m5=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=5	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='RM'
	update guest_xfttl set m6=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=6	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='RM'
	update guest_xfttl set m7=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=7	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='RM'
	update guest_xfttl set m8=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=8	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='RM'
	update guest_xfttl set m9=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=9	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='RM'
	update guest_xfttl set m10=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=10	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='RM'
	update guest_xfttl set m11=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=11	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='RM'
	update guest_xfttl set m12=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=12	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='rm'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='RM'

	--  餐费 
	update guest_xfttl set m1=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=1	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='fb'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='FB'
	update guest_xfttl set m2=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=2	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='fb'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='FB'
	update guest_xfttl set m3=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=3	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='fb'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='FB'
	update guest_xfttl set m4=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=4	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='fb'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='FB'
	update guest_xfttl set m5=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=5	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='fb'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='FB'
	update guest_xfttl set m6=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=6	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='fb'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='FB'
	update guest_xfttl set m7=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=7	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='fb'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='FB'
	update guest_xfttl set m8=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=8	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='fb'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='FB'
	update guest_xfttl set m9=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=9	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='fb'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='FB'
	update guest_xfttl set m10=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=10	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='fb'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='FB'
	update guest_xfttl set m11=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=11	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='fb'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='FB'
	update guest_xfttl set m12=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=12	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7='fb'), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='FB'

	--  其他消费 
	update guest_xfttl set m1=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=1	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7 in ('en', 'mt', 'ot') ), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='OT'
	update guest_xfttl set m2=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=2	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7 in ('en', 'mt', 'ot') ), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='OT'
	update guest_xfttl set m3=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=3	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7 in ('en', 'mt', 'ot') ), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='OT'
	update guest_xfttl set m4=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=4	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7 in ('en', 'mt', 'ot') ), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='OT'
	update guest_xfttl set m5=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=5	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7 in ('en', 'mt', 'ot') ), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='OT'
	update guest_xfttl set m6=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=6	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7 in ('en', 'mt', 'ot') ), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='OT'
	update guest_xfttl set m7=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=7	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7 in ('en', 'mt', 'ot') ), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='OT'
	update guest_xfttl set m8=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=8	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7 in ('en', 'mt', 'ot') ), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='OT'
	update guest_xfttl set m9=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=9	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7 in ('en', 'mt', 'ot') ), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='OT'
	update guest_xfttl set m10=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=10	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7 in ('en', 'mt', 'ot') ), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='OT'
	update guest_xfttl set m11=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=11	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7 in ('en', 'mt', 'ot') ), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='OT'
	update guest_xfttl set m12=isnull((select sum(a.amount1) from #income a, pccode b, #hmst c 
		 	where guest_xfttl.year=c.year and c.month=12	and a.accnt=c.accnt and a.pccode=b.pccode and b.deptno7 in ('en', 'mt', 'ot') ), 0)
		where guest_xfttl.no=@mno and guest_xfttl.tag='OT'

	if @class = 'F' 
	begin
		update guest_xfttl set m1=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=1	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m2=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=2	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m3=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=3	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m4=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=4	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m5=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=5	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m6=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=6	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m7=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=7	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m8=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=8	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m9=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=9	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m10=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=10	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m11=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=11	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m12=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=12	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
	end
	else
	begin 
		update guest_xfttl set m1=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=1	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m2=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=2	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m3=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=3	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m4=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=4	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m5=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=5	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m6=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=6	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m7=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=7	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m8=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=8	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m9=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=9	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m10=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=10	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m11=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=11	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m12=isnull((select sum(a.amount2) from #income a, #hmst c 
				where guest_xfttl.year=c.year and c.month=12	and a.accnt=c.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 and a.accnt=a.master ), 0)
			where guest_xfttl.no=@mno and guest_xfttl.tag='NIGHTS'
	end

	update guest_xfttl set ttl = m1+m2+m3+m4+m5+m6+m7+m8+m9+m10+m11+m12  where no=@mno 
	delete guest_xfttl where no=@mno and m1=0 and m2=0 and m3=0 and m4=0 and m5=0 and m6=0 
			and m7=0 and m8=0 and m9=0 and m10=0 and m11=0 and m12=0

	fetch c_guest into @mno, @class
end

gout:
close c_guest
deallocate cursor c_guest

return 0
;

