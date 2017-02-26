------------------------------------------------------------------
-- (新)档案消费业绩重建 -(上)  准备部分 
------------------------------------------------------------------

------------------------------------------------------------------
-- 创建临时表 -- 用来保存中间成果。-- 重建完毕后需要清除该表  
------------------------------------------------------------------
IF OBJECT_ID('hmst') IS NOT NULL
    DROP table hmst
;
create table hmst (													-- 主单信息
	accnt			char(10)			not null,
	accnt1		char(20)			not null,
	sta			char(1)			not null,
	master		char(10)			not null,
	haccnt		char(7)			not null,
	cusno			char(7)			not null,
	agent			char(7)			not null,
	source		char(7)			not null,
	arr			datetime			not null,
	dep			datetime			not null,
	year			char(4)			not null,
	month			int				not null,
	roomno		char(5)			not null,
	setrate		money				not null,
   i_times     int 				default 0 		not null,
   x_times     int 				default 0 		not null,
   n_times     int 				default 0 		not null,
   l_times     int 				default 0 		not null,
   i_days1     int 				default 0 		not null,	-- for 客人
   i_days2     int 				default 0 		not null,	-- for 单位

   fb_times1    int 				default 0 		not null,
   en_times2    int 				default 0 		not null,

   rm          money 			default 0 		not null,
   fb          money 			default 0 		not null,
   en          money 			default 0 		not null,
   mt          money 			default 0 		not null,
   ot          money 			default 0 		not null,
   tl          money 			default 0 		not null
);
create index accnt on hmst(accnt, year, month);


------------------------------------------------------------------
-- 生成 hmst, 更新 guest 基本消费数据
-- 监控: select * from gdsmsg; 
------------------------------------------------------------------
IF OBJECT_ID('p_greb01') IS NOT NULL
    DROP PROCEDURE p_greb01;
create proc p_greb01
as

delete gdsmsg 
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' Begin'

-- 计算房晚的费用码
declare	@rm_pccodes_nt	char(255)
select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')


-- 插入数据 -- 需要排除 AR帐，消费帐 
insert hmst (accnt,accnt1,sta,master,haccnt,cusno,agent,source,
					arr,dep,year,month,roomno,setrate) 
	select accnt,convert(char(10),arr,111)+accnt,sta,master,haccnt,cusno,agent,source,
					arr,dep,convert(char(4),datepart(year,dep)),datepart(month,dep),roomno,setrate
		from hmaster where accnt not like '[AC]%'

insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' Insert hmst over'

update hmst set i_times	= isnull((select sum(a.amount2) from master_income a where a.accnt=hmst.accnt and a.item='I_TIMES'), 0) 
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update hmst 11-1'
update hmst set x_times	= isnull((select sum(a.amount2) from master_income a where a.accnt=hmst.accnt and a.item='X_TIMES'), 0) 
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update hmst 11-2'
update hmst set n_times	= isnull((select sum(a.amount2) from master_income a where a.accnt=hmst.accnt and a.item='N_TIMES'), 0) 
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update hmst 11-3'
update hmst set i_days1	= isnull((select sum(a.amount2) from master_income a where a.accnt=hmst.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0), 0) 
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update hmst 11-4'
update hmst set i_days2	= isnull((select sum(a.amount2) from master_income a where a.accnt=a.master and a.accnt=hmst.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0), 0) 
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update hmst 11-5'

update hmst set rm	= isnull((select sum(a.amount1) from master_income a, pccode c where a.accnt=hmst.accnt and a.pccode=c.pccode and c.deptno7='rm'), 0) 
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update hmst 11-6'
update hmst set fb	= isnull((select sum(a.amount1) from master_income a, pccode c where a.accnt=hmst.accnt and a.pccode=c.pccode and c.deptno7='fb'), 0) 
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update hmst 11-7'
update hmst set en	= isnull((select sum(a.amount1) from master_income a, pccode c where a.accnt=hmst.accnt and a.pccode=c.pccode and c.deptno7='en'), 0) 
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update hmst 11-8'
update hmst set mt	= isnull((select sum(a.amount1) from master_income a, pccode c where a.accnt=hmst.accnt and a.pccode=c.pccode and c.deptno7='mt'), 0) 
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update hmst 11-9'
update hmst set ot	= isnull((select sum(a.amount1) from master_income a, pccode c where a.accnt=hmst.accnt and a.pccode=c.pccode and c.deptno7='ot'), 0) 
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update hmst 11-10'
update hmst set tl	= rm+fb+en+mt+ot
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update hmst 11-11'

return ;


------------------------------------------------------------------
-- 生成 guest_xfttl 骨架 
-- 监控: select * from process_flag where flag='guest_reb';   
------------------------------------------------------------------
IF OBJECT_ID('p_greb02') IS NOT NULL
    DROP PROCEDURE p_greb02;
create proc p_greb02
as
declare	@no			char(7),
			@class		char(1),
			@i_days		int

-- test speed 
declare  @count  		int,
			@ii 			int,
			@rows			int,
			@rows_str	char(20)
select @count = 0, @ii = 0

truncate table guest_xfttl

delete process_flag where flag='guest_reb'
insert process_flag(flag,value) values('guest_reb', '0')

select @rows = count(1) from guest -- where class in ('C','A','S')
select @rows_str = convert(char(20), @rows)

-- Begin
declare	c_guest cursor for select no, class from guest -- where class in ('C','A','S')
open c_guest
fetch c_guest into @no, @class
while @@sqlstatus = 0
begin
	-- test speed 
	select @count = @count + 1, @ii = @ii + 1
	if @ii > 100 
	begin
		update process_flag set value = convert(char(10), @count) + '  :  ' + @rows_str where flag='guest_reb'
		select @ii = 0
	end

	if @class in ('F', 'G') 
		insert guest_xfttl(no, year, tag) 
			select distinct @no, a.year, b.code 
				from hmst a, basecode b 
					where a.haccnt=@no 
						and b.cat='guest_sumtag'
	else
		insert guest_xfttl(no, year, tag) 
			select distinct @no, a.year, b.code 
				from hmst a, basecode b 
					where (a.cusno=@no or a.agent=@no or a.source=@no) 
						and b.cat='guest_sumtag'

	fetch c_guest into @no, @class
end

gout:
close c_guest
deallocate cursor c_guest

return 0
;


------------------------------------------------------------------
-- 更新消费记录：guest, guest_xfttl  
-- 监控: select * from process_flag where flag='guest_reb';   
------------------------------------------------------------------
IF OBJECT_ID('p_greb03') IS NOT NULL
    DROP PROCEDURE p_greb03;
create proc p_greb03
as
declare	@no			char(7),
			@class		char(1),
			@i_days		int,
			@rm 			money,
			@fb 			money,
			@en 			money,
			@mt 			money,
			@ot 			money,
			@tl 			money,
			@x_times		int,
			@n_times		int,			
			@i_times		int


-- test speed 
declare  @count  int, @ii int, @rows int, @rows_str char(20)  
select @count = 0, @ii = 0

delete process_flag where flag='guest_reb'
insert process_flag(flag,value) values('guest_reb', '0')
select @rows = count(1) from guest -- where class in ('C','A','S')
select @rows_str = convert(char(20), @rows)

select * into #hmst from hmst where 1=2


-- Begin
declare	c_guest cursor for select no, class from guest -- where class in ('C','A','S')
open c_guest
fetch c_guest into @no, @class
while @@sqlstatus = 0
begin
	-- test speed 
	select @count = @count + 1, @ii = @ii + 1
	if @ii > 100 
	begin
		update process_flag set value = convert(char(10), @count) + ' : ' + @rows_str where flag='guest_reb'
		select @ii = 0
	end

	delete #hmst 
	if @class in ('F', 'G') 
	begin
		insert #hmst select a.* from hmst a where @no=a.haccnt
		select @i_times=isnull(sum(a.i_times),0),
				@x_times=isnull(sum(a.x_times),0),
				@n_times=isnull(sum(a.n_times),0),
				@i_days=isnull(sum(a.i_days1),0),
				@rm=isnull(sum(a.rm),0),
				@fb=isnull(sum(a.fb),0),
				@en=isnull(sum(a.en),0),
				@mt=isnull(sum(a.mt),0),
				@ot=isnull(sum(a.ot),0),
				@tl=isnull(sum(a.rm+a.fb+a.en+a.mt+a.ot),0)
			from #hmst a 
	end
	else
	begin
		insert #hmst select a.* from hmst a where @no=a.cusno or @no=a.agent or @no=a.source
		select @i_times=isnull(sum(a.i_times),0),
				@x_times=isnull(sum(a.x_times),0),
				@n_times=isnull(sum(a.n_times),0),
				@i_days=isnull(sum(a.i_days2),0),
				@rm=isnull(sum(a.rm),0),
				@fb=isnull(sum(a.fb),0),
				@en=isnull(sum(a.en),0),
				@mt=isnull(sum(a.mt),0),
				@ot=isnull(sum(a.ot),0),
				@tl=isnull(sum(a.rm+a.fb+a.en+a.mt+a.ot),0)
			from #hmst a 
	end

	update guest set i_times=@i_times,x_times=@x_times,n_times=@n_times,i_days=@i_days,
			rm=@rm,fb=@fb,en=@en,mt=@mt,ot=@ot,tl=@tl
	where no=@no

	--  总收入 
	update guest_xfttl set m1 =isnull((select sum(a.tl) from #hmst a where guest_xfttl.year=a.year and a.month=1), 0) where guest_xfttl.no=@no and guest_xfttl.tag='TTL'
	update guest_xfttl set m2 =isnull((select sum(a.tl) from #hmst a where guest_xfttl.year=a.year and a.month=2), 0) where guest_xfttl.no=@no and guest_xfttl.tag='TTL'
	update guest_xfttl set m3 =isnull((select sum(a.tl) from #hmst a where guest_xfttl.year=a.year and a.month=3), 0) where guest_xfttl.no=@no and guest_xfttl.tag='TTL'
	update guest_xfttl set m4 =isnull((select sum(a.tl) from #hmst a where guest_xfttl.year=a.year and a.month=4), 0) where guest_xfttl.no=@no and guest_xfttl.tag='TTL'
	update guest_xfttl set m5 =isnull((select sum(a.tl) from #hmst a where guest_xfttl.year=a.year and a.month=5), 0) where guest_xfttl.no=@no and guest_xfttl.tag='TTL'
	update guest_xfttl set m6 =isnull((select sum(a.tl) from #hmst a where guest_xfttl.year=a.year and a.month=6), 0) where guest_xfttl.no=@no and guest_xfttl.tag='TTL'
	update guest_xfttl set m7 =isnull((select sum(a.tl) from #hmst a where guest_xfttl.year=a.year and a.month=7), 0) where guest_xfttl.no=@no and guest_xfttl.tag='TTL'
	update guest_xfttl set m8 =isnull((select sum(a.tl) from #hmst a where guest_xfttl.year=a.year and a.month=8), 0) where guest_xfttl.no=@no and guest_xfttl.tag='TTL'
	update guest_xfttl set m9 =isnull((select sum(a.tl) from #hmst a where guest_xfttl.year=a.year and a.month=9), 0) where guest_xfttl.no=@no and guest_xfttl.tag='TTL'
	update guest_xfttl set m10=isnull((select sum(a.tl) from #hmst a where guest_xfttl.year=a.year and a.month=10), 0) where guest_xfttl.no=@no and guest_xfttl.tag='TTL'
	update guest_xfttl set m11=isnull((select sum(a.tl) from #hmst a where guest_xfttl.year=a.year and a.month=11), 0) where guest_xfttl.no=@no and guest_xfttl.tag='TTL'
	update guest_xfttl set m12=isnull((select sum(a.tl) from #hmst a where guest_xfttl.year=a.year and a.month=12), 0) where guest_xfttl.no=@no and guest_xfttl.tag='TTL'
	
	-- 房费 
	update guest_xfttl set m1 =isnull((select sum(a.rm) from #hmst a where guest_xfttl.year=a.year and a.month=1), 0) where guest_xfttl.no=@no and guest_xfttl.tag='RM'
	update guest_xfttl set m2 =isnull((select sum(a.rm) from #hmst a where guest_xfttl.year=a.year and a.month=2), 0) where guest_xfttl.no=@no and guest_xfttl.tag='RM'
	update guest_xfttl set m3 =isnull((select sum(a.rm) from #hmst a where guest_xfttl.year=a.year and a.month=3), 0) where guest_xfttl.no=@no and guest_xfttl.tag='RM'
	update guest_xfttl set m4 =isnull((select sum(a.rm) from #hmst a where guest_xfttl.year=a.year and a.month=4), 0) where guest_xfttl.no=@no and guest_xfttl.tag='RM'
	update guest_xfttl set m5 =isnull((select sum(a.rm) from #hmst a where guest_xfttl.year=a.year and a.month=5), 0) where guest_xfttl.no=@no and guest_xfttl.tag='RM'
	update guest_xfttl set m6 =isnull((select sum(a.rm) from #hmst a where guest_xfttl.year=a.year and a.month=6), 0) where guest_xfttl.no=@no and guest_xfttl.tag='RM'
	update guest_xfttl set m7 =isnull((select sum(a.rm) from #hmst a where guest_xfttl.year=a.year and a.month=7), 0) where guest_xfttl.no=@no and guest_xfttl.tag='RM'
	update guest_xfttl set m8 =isnull((select sum(a.rm) from #hmst a where guest_xfttl.year=a.year and a.month=8), 0) where guest_xfttl.no=@no and guest_xfttl.tag='RM'
	update guest_xfttl set m9 =isnull((select sum(a.rm) from #hmst a where guest_xfttl.year=a.year and a.month=9), 0) where guest_xfttl.no=@no and guest_xfttl.tag='RM'
	update guest_xfttl set m10=isnull((select sum(a.rm) from #hmst a where guest_xfttl.year=a.year and a.month=10), 0) where guest_xfttl.no=@no and guest_xfttl.tag='RM'
	update guest_xfttl set m11=isnull((select sum(a.rm) from #hmst a where guest_xfttl.year=a.year and a.month=11), 0) where guest_xfttl.no=@no and guest_xfttl.tag='RM'
	update guest_xfttl set m12=isnull((select sum(a.rm) from #hmst a where guest_xfttl.year=a.year and a.month=12), 0) where guest_xfttl.no=@no and guest_xfttl.tag='RM'
	
	
	--  餐费 
	update guest_xfttl set m1 =isnull((select sum(a.fb) from #hmst a where guest_xfttl.year=a.year and a.month=1), 0) where guest_xfttl.no=@no and guest_xfttl.tag='FB'
	update guest_xfttl set m2 =isnull((select sum(a.fb) from #hmst a where guest_xfttl.year=a.year and a.month=2), 0) where guest_xfttl.no=@no and guest_xfttl.tag='FB'
	update guest_xfttl set m3 =isnull((select sum(a.fb) from #hmst a where guest_xfttl.year=a.year and a.month=3), 0) where guest_xfttl.no=@no and guest_xfttl.tag='FB'
	update guest_xfttl set m4 =isnull((select sum(a.fb) from #hmst a where guest_xfttl.year=a.year and a.month=4), 0) where guest_xfttl.no=@no and guest_xfttl.tag='FB'
	update guest_xfttl set m5 =isnull((select sum(a.fb) from #hmst a where guest_xfttl.year=a.year and a.month=5), 0) where guest_xfttl.no=@no and guest_xfttl.tag='FB'
	update guest_xfttl set m6 =isnull((select sum(a.fb) from #hmst a where guest_xfttl.year=a.year and a.month=6), 0) where guest_xfttl.no=@no and guest_xfttl.tag='FB'
	update guest_xfttl set m7 =isnull((select sum(a.fb) from #hmst a where guest_xfttl.year=a.year and a.month=7), 0) where guest_xfttl.no=@no and guest_xfttl.tag='FB'
	update guest_xfttl set m8 =isnull((select sum(a.fb) from #hmst a where guest_xfttl.year=a.year and a.month=8), 0) where guest_xfttl.no=@no and guest_xfttl.tag='FB'
	update guest_xfttl set m9 =isnull((select sum(a.fb) from #hmst a where guest_xfttl.year=a.year and a.month=9), 0) where guest_xfttl.no=@no and guest_xfttl.tag='FB'
	update guest_xfttl set m10=isnull((select sum(a.fb) from #hmst a where guest_xfttl.year=a.year and a.month=10), 0) where guest_xfttl.no=@no and guest_xfttl.tag='FB'
	update guest_xfttl set m11=isnull((select sum(a.fb) from #hmst a where guest_xfttl.year=a.year and a.month=11), 0) where guest_xfttl.no=@no and guest_xfttl.tag='FB'
	update guest_xfttl set m12=isnull((select sum(a.fb) from #hmst a where guest_xfttl.year=a.year and a.month=12), 0) where guest_xfttl.no=@no and guest_xfttl.tag='FB'
	
	
	--  其他消费 
	update guest_xfttl set m1 =isnull((select sum(a.en+a.mt+a.ot) from #hmst a where guest_xfttl.year=a.year and a.month=1), 0) where guest_xfttl.no=@no and guest_xfttl.tag='OT'
	update guest_xfttl set m2 =isnull((select sum(a.en+a.mt+a.ot) from #hmst a where guest_xfttl.year=a.year and a.month=2), 0) where guest_xfttl.no=@no and guest_xfttl.tag='OT'
	update guest_xfttl set m3 =isnull((select sum(a.en+a.mt+a.ot) from #hmst a where guest_xfttl.year=a.year and a.month=3), 0) where guest_xfttl.no=@no and guest_xfttl.tag='OT'
	update guest_xfttl set m4 =isnull((select sum(a.en+a.mt+a.ot) from #hmst a where guest_xfttl.year=a.year and a.month=4), 0) where guest_xfttl.no=@no and guest_xfttl.tag='OT'
	update guest_xfttl set m5 =isnull((select sum(a.en+a.mt+a.ot) from #hmst a where guest_xfttl.year=a.year and a.month=5), 0) where guest_xfttl.no=@no and guest_xfttl.tag='OT'
	update guest_xfttl set m6 =isnull((select sum(a.en+a.mt+a.ot) from #hmst a where guest_xfttl.year=a.year and a.month=6), 0) where guest_xfttl.no=@no and guest_xfttl.tag='OT'
	update guest_xfttl set m7 =isnull((select sum(a.en+a.mt+a.ot) from #hmst a where guest_xfttl.year=a.year and a.month=7), 0) where guest_xfttl.no=@no and guest_xfttl.tag='OT'
	update guest_xfttl set m8 =isnull((select sum(a.en+a.mt+a.ot) from #hmst a where guest_xfttl.year=a.year and a.month=8), 0) where guest_xfttl.no=@no and guest_xfttl.tag='OT'
	update guest_xfttl set m9 =isnull((select sum(a.en+a.mt+a.ot) from #hmst a where guest_xfttl.year=a.year and a.month=9), 0) where guest_xfttl.no=@no and guest_xfttl.tag='OT'
	update guest_xfttl set m10=isnull((select sum(a.en+a.mt+a.ot) from #hmst a where guest_xfttl.year=a.year and a.month=10), 0) where guest_xfttl.no=@no and guest_xfttl.tag='OT'
	update guest_xfttl set m11=isnull((select sum(a.en+a.mt+a.ot) from #hmst a where guest_xfttl.year=a.year and a.month=11), 0) where guest_xfttl.no=@no and guest_xfttl.tag='OT'
	update guest_xfttl set m12=isnull((select sum(a.en+a.mt+a.ot) from #hmst a where guest_xfttl.year=a.year and a.month=12), 0) where guest_xfttl.no=@no and guest_xfttl.tag='OT'
	
	--  房晚 - 客人 
	if @class in ('F', 'G')
	begin
		update guest_xfttl set m1 =isnull((select sum(a.i_days1) from #hmst a where guest_xfttl.year=a.year and a.month=1), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m2 =isnull((select sum(a.i_days1) from #hmst a where guest_xfttl.year=a.year and a.month=2), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m3 =isnull((select sum(a.i_days1) from #hmst a where guest_xfttl.year=a.year and a.month=3), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m4 =isnull((select sum(a.i_days1) from #hmst a where guest_xfttl.year=a.year and a.month=4), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m5 =isnull((select sum(a.i_days1) from #hmst a where guest_xfttl.year=a.year and a.month=5), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m6 =isnull((select sum(a.i_days1) from #hmst a where guest_xfttl.year=a.year and a.month=6), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m7 =isnull((select sum(a.i_days1) from #hmst a where guest_xfttl.year=a.year and a.month=7), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m8 =isnull((select sum(a.i_days1) from #hmst a where guest_xfttl.year=a.year and a.month=8), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m9 =isnull((select sum(a.i_days1) from #hmst a where guest_xfttl.year=a.year and a.month=9), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m10=isnull((select sum(a.i_days1) from #hmst a where guest_xfttl.year=a.year and a.month=10), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m11=isnull((select sum(a.i_days1) from #hmst a where guest_xfttl.year=a.year and a.month=11), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m12=isnull((select sum(a.i_days1) from #hmst a where guest_xfttl.year=a.year and a.month=12), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
	end
	else
	begin
		--  房晚 - 协议单位 
		update guest_xfttl set m1 =isnull((select sum(a.i_days2) from #hmst a where guest_xfttl.year=a.year and a.month=1 ), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m2 =isnull((select sum(a.i_days2) from #hmst a where guest_xfttl.year=a.year and a.month=2 ), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m3 =isnull((select sum(a.i_days2) from #hmst a where guest_xfttl.year=a.year and a.month=3 ), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m4 =isnull((select sum(a.i_days2) from #hmst a where guest_xfttl.year=a.year and a.month=4 ), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m5 =isnull((select sum(a.i_days2) from #hmst a where guest_xfttl.year=a.year and a.month=5 ), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m6 =isnull((select sum(a.i_days2) from #hmst a where guest_xfttl.year=a.year and a.month=6 ), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m7 =isnull((select sum(a.i_days2) from #hmst a where guest_xfttl.year=a.year and a.month=7 ), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m8 =isnull((select sum(a.i_days2) from #hmst a where guest_xfttl.year=a.year and a.month=8 ), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m9 =isnull((select sum(a.i_days2) from #hmst a where guest_xfttl.year=a.year and a.month=9 ), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m10=isnull((select sum(a.i_days2) from #hmst a where guest_xfttl.year=a.year and a.month=10), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m11=isnull((select sum(a.i_days2) from #hmst a where guest_xfttl.year=a.year and a.month=11), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
		update guest_xfttl set m12=isnull((select sum(a.i_days2) from #hmst a where guest_xfttl.year=a.year and a.month=12), 0) where guest_xfttl.no=@no and guest_xfttl.tag='NIGHTS'
	end

	fetch c_guest into @no, @class
end

gout:
close c_guest
deallocate cursor c_guest

return 0
;


------------------------------------------------------------------
-- 更新消费记录 guest：from foxhis1 --> foxhis  -- 选用过程
------------------------------------------------------------------
/*
IF OBJECT_ID('p_greb04') IS NOT NULL
    DROP PROCEDURE p_greb04;
create proc p_greb04
as
declare	@no			char(7),
			@i_days		int,
			@rm 			money,
			@fb 			money,
			@en 			money,
			@mt 			money,
			@ot 			money,
			@tl 			money,
			@x_times		int,
			@n_times		int,			
			@i_times		int


-- test speed 
declare  @count  int, @ii int, @rows int, @rows_str char(20)  
select @count = 0, @ii = 0
delete process_flag where flag='guest_reb'
insert process_flag(flag,value) values('guest_reb', '0')
select @rows = count(1) from guest 
select @rows_str = convert(char(20), @rows)

-- Begin
declare	c_guest cursor for select no,i_times,x_times,n_times,i_days,rm,fb,en,mt,ot,tl from foxhis1..guest  -- 
open c_guest
fetch c_guest into @no,@i_times,@x_times,@n_times,@i_days,@rm,@fb,@en,@mt,@ot,@tl
while @@sqlstatus = 0
begin
	-- test speed 
	select @count = @count + 1, @ii = @ii + 1
	if @ii > 100 
	begin
		update process_flag set value = convert(char(10), @count) + ' : ' + @rows_str where flag='guest_reb'
		select @ii = 0
	end
	
	-- update 
	update guest set i_times=@i_times,x_times=@x_times,n_times=@n_times,i_days=@i_days,
			rm=@rm,fb=@fb,en=@en,mt=@mt,ot=@ot,tl=@tl
		where no=@no

   fetch c_guest into @no,@i_times,@x_times,@n_times,@i_days,@rm,@fb,@en,@mt,@ot,@tl
end
close c_guest
deallocate cursor c_guest

return ;
*/
