------------------------------------------------------------------
--	Rebuild profile income
------------------------------------------------------------------
--	由于 guest 表结构较大，而且有触发器处理，
--		因此需要尽量减少 update 的次数
------------------------------------------------------------------


------------------------------------------------------------------
-- 创建临时表 -- 用来保存中间成果。-- 重建完毕后需要清除该表  
------------------------------------------------------------------
IF OBJECT_ID('hmst') IS NOT NULL
    DROP PROCEDURE hmst
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


IF OBJECT_ID('p_gds_guest_income_reb1') IS NOT NULL
    DROP PROCEDURE p_gds_guest_income_reb1;
create proc p_gds_guest_income_reb1
as
------------------------------------------------------------------
-- 重建档案业绩-1：生成 hmst, 更新 guest 基本消费数据
------------------------------------------------------------------
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

/*  如下写法错误,需要采用子查询才 Ok  

update guest set i_times=isnull(sum(a.i_times),0),
						x_times=isnull(sum(a.x_times),0),
						n_times=isnull(sum(a.n_times),0),
						i_days=isnull(sum(a.i_days1),0),
						rm=isnull(sum(a.rm),0),
						fb=isnull(sum(a.fb),0),
						en=isnull(sum(a.en),0),
						mt=isnull(sum(a.mt),0),
						ot=isnull(sum(a.ot),0),
						tl=isnull(sum(a.rm+a.fb+a.en+a.mt+a.ot),0)
		from hmst a where guest.class in ('F', 'G') and guest.no=a.haccnt 
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update guest 6-1'

update guest set i_times=isnull(sum(a.i_times),0),
						x_times=isnull(sum(a.x_times),0),
						n_times=isnull(sum(a.n_times),0),
						i_days=isnull(sum(a.i_days2),0),
						rm=isnull(sum(a.rm),0),
						fb=isnull(sum(a.fb),0),
						en=isnull(sum(a.en),0),
						mt=isnull(sum(a.mt),0),
						ot=isnull(sum(a.ot),0),
						tl=isnull(sum(a.rm+a.fb+a.en+a.mt+a.ot),0)
		from hmst a where guest.class in ('C', 'A', 'S') 
					and (guest.no=a.cusno or guest.no=a.agent or guest.no=a.source)
*/

insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update guest 6-2'
return ;


IF OBJECT_ID('p_gds_guest_income_reb2') IS NOT NULL
    DROP PROCEDURE p_gds_guest_income_reb2;
create proc p_gds_guest_income_reb2
as
------------------------------------------------------------------
-- 重建档案业绩-2：更新 guest 最早和最迟抵店记录 
------------------------------------------------------------------
update guest set fv_date=a.arr, fv_room=a.roomno, fv_rate=a.setrate 
	from hmst a where a.accnt1 = (select min(b.accnt1) from hmst b where guest.class in ('F', 'G') and guest.no=b.haccnt)
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update guest 6-3'
update guest set lv_date=a.arr, lv_room=a.roomno, lv_rate=a.setrate 
	from hmst a where a.accnt1 = (select max(b.accnt1) from hmst b where guest.class in ('F', 'G') and guest.no=b.haccnt)
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update guest 6-4'

update guest set fv_date=a.arr, fv_room=a.roomno, fv_rate=a.setrate 
	from hmst a where a.accnt1 = (select min(b.accnt1) from hmst b where guest.class in ('C', 'A', 'S') and (guest.no=b.cusno or guest.no=b.agent or guest.no=b.source) )
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update guest 6-5'
update guest set lv_date=a.arr, lv_room=a.roomno, lv_rate=a.setrate 
	from hmst a where a.accnt1 = (select max(b.accnt1) from hmst b where guest.class in ('C', 'A', 'S') and (guest.no=b.cusno or guest.no=b.agent or guest.no=b.source) )
insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' update guest 6-6'

return ;


IF OBJECT_ID('p_gds_guest_income_reb3') IS NOT NULL
    DROP PROCEDURE p_gds_guest_income_reb3;
create proc p_gds_guest_income_reb3
as
------------------------------------------------------------------
-- 重建档案业绩-3：生成 guest_xfttl 
------------------------------------------------------------------
truncate table guest_xfttl

-- 目前的统计项目= RM, FB, OT, TTL, NIGHTS  (basecode - guest_sumtag)
-- *** ??? distinct maybe very slowly ... 
insert guest_xfttl(no, year, tag) 
	select distinct c.no, a.year, b.code from hmst a, basecode b, guest c 
		where a.haccnt=c.no and c.class in ('F', 'G') and b.cat='guest_sumtag' 
insert guest_xfttl(no, year, tag) 
	select distinct c.no, a.year, b.code from hmst a, basecode b, guest c 
		where (a.cusno=c.no or a.agent=c.no or a.source=c.no) and c.class in ('C', 'A', 'S') and b.cat='guest_sumtag' 

insert gdsmsg select 'Guest Income Reb: ' + convert(char(8), getdate(), 8) + ' Init guest_xfttl over, and begin to update '
return 0;


IF OBJECT_ID('p_gds_guest_income_reb4') IS NOT NULL
    DROP PROCEDURE p_gds_guest_income_reb4;
create proc p_gds_guest_income_reb4
as
------------------------------------------------------------------
-- 重建档案业绩-4：更新 guest_xfttl 
------------------------------------------------------------------

--  总收入 
update guest_xfttl set m1 =isnull((select sum(a.tl) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=1  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='TTL'
update guest_xfttl set m2 =isnull((select sum(a.tl) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=2  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='TTL'
update guest_xfttl set m3 =isnull((select sum(a.tl) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=3  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='TTL'
update guest_xfttl set m4 =isnull((select sum(a.tl) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=4  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='TTL'
update guest_xfttl set m5 =isnull((select sum(a.tl) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=5  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='TTL'
update guest_xfttl set m6 =isnull((select sum(a.tl) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=6  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='TTL'
update guest_xfttl set m7 =isnull((select sum(a.tl) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=7  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='TTL'
update guest_xfttl set m8 =isnull((select sum(a.tl) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=8  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='TTL'
update guest_xfttl set m9 =isnull((select sum(a.tl) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=9  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='TTL'
update guest_xfttl set m10=isnull((select sum(a.tl) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=10 and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='TTL'
update guest_xfttl set m11=isnull((select sum(a.tl) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=11 and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='TTL'
update guest_xfttl set m12=isnull((select sum(a.tl) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=12 and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='TTL'

-- 房费 
update guest_xfttl set m1 =isnull((select sum(a.rm) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=1  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='RM'
update guest_xfttl set m2 =isnull((select sum(a.rm) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=2  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='RM'
update guest_xfttl set m3 =isnull((select sum(a.rm) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=3  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='RM'
update guest_xfttl set m4 =isnull((select sum(a.rm) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=4  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='RM'
update guest_xfttl set m5 =isnull((select sum(a.rm) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=5  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='RM'
update guest_xfttl set m6 =isnull((select sum(a.rm) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=6  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='RM'
update guest_xfttl set m7 =isnull((select sum(a.rm) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=7  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='RM'
update guest_xfttl set m8 =isnull((select sum(a.rm) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=8  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='RM'
update guest_xfttl set m9 =isnull((select sum(a.rm) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=9  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='RM'
update guest_xfttl set m10=isnull((select sum(a.rm) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=10 and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='RM'
update guest_xfttl set m11=isnull((select sum(a.rm) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=11 and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='RM'
update guest_xfttl set m12=isnull((select sum(a.rm) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=12 and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='RM'


--  餐费 
update guest_xfttl set m1 =isnull((select sum(a.fb) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=1  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='FB'
update guest_xfttl set m2 =isnull((select sum(a.fb) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=2  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='FB'
update guest_xfttl set m3 =isnull((select sum(a.fb) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=3  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='FB'
update guest_xfttl set m4 =isnull((select sum(a.fb) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=4  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='FB'
update guest_xfttl set m5 =isnull((select sum(a.fb) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=5  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='FB'
update guest_xfttl set m6 =isnull((select sum(a.fb) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=6  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='FB'
update guest_xfttl set m7 =isnull((select sum(a.fb) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=7  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='FB'
update guest_xfttl set m8 =isnull((select sum(a.fb) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=8  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='FB'
update guest_xfttl set m9 =isnull((select sum(a.fb) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=9  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='FB'
update guest_xfttl set m10=isnull((select sum(a.fb) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=10 and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='FB'
update guest_xfttl set m11=isnull((select sum(a.fb) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=11 and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='FB'
update guest_xfttl set m12=isnull((select sum(a.fb) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=12 and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='FB'


--  其他消费 
update guest_xfttl set m1 =isnull((select sum(a.en+a.mt+a.ot) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=1  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='OT'
update guest_xfttl set m2 =isnull((select sum(a.en+a.mt+a.ot) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=2  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='OT'
update guest_xfttl set m3 =isnull((select sum(a.en+a.mt+a.ot) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=3  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='OT'
update guest_xfttl set m4 =isnull((select sum(a.en+a.mt+a.ot) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=4  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='OT'
update guest_xfttl set m5 =isnull((select sum(a.en+a.mt+a.ot) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=5  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='OT'
update guest_xfttl set m6 =isnull((select sum(a.en+a.mt+a.ot) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=6  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='OT'
update guest_xfttl set m7 =isnull((select sum(a.en+a.mt+a.ot) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=7  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='OT'
update guest_xfttl set m8 =isnull((select sum(a.en+a.mt+a.ot) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=8  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='OT'
update guest_xfttl set m9 =isnull((select sum(a.en+a.mt+a.ot) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=9  and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='OT'
update guest_xfttl set m10=isnull((select sum(a.en+a.mt+a.ot) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=10 and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='OT'
update guest_xfttl set m11=isnull((select sum(a.en+a.mt+a.ot) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=11 and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='OT'
update guest_xfttl set m12=isnull((select sum(a.en+a.mt+a.ot) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=12 and (b.no=a.haccnt or b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='OT'


--  房晚 - 客人 
update guest_xfttl set m1 =isnull((select sum(a.i_days1) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=1  and (b.no=a.haccnt)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m2 =isnull((select sum(a.i_days1) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=2  and (b.no=a.haccnt)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m3 =isnull((select sum(a.i_days1) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=3  and (b.no=a.haccnt)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m4 =isnull((select sum(a.i_days1) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=4  and (b.no=a.haccnt)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m5 =isnull((select sum(a.i_days1) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=5  and (b.no=a.haccnt)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m6 =isnull((select sum(a.i_days1) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=6  and (b.no=a.haccnt)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m7 =isnull((select sum(a.i_days1) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=7  and (b.no=a.haccnt)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m8 =isnull((select sum(a.i_days1) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=8  and (b.no=a.haccnt)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m9 =isnull((select sum(a.i_days1) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=9  and (b.no=a.haccnt)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m10=isnull((select sum(a.i_days1) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=10 and (b.no=a.haccnt)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m11=isnull((select sum(a.i_days1) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=11 and (b.no=a.haccnt)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m12=isnull((select sum(a.i_days1) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=12 and (b.no=a.haccnt)), 0) where guest_xfttl.tag='NIGHTS'


--  房晚 - 协议单位 
update guest_xfttl set m1 =isnull((select sum(a.i_days2) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=1  and (b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m2 =isnull((select sum(a.i_days2) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=2  and (b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m3 =isnull((select sum(a.i_days2) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=3  and (b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m4 =isnull((select sum(a.i_days2) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=4  and (b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m5 =isnull((select sum(a.i_days2) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=5  and (b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m6 =isnull((select sum(a.i_days2) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=6  and (b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m7 =isnull((select sum(a.i_days2) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=7  and (b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m8 =isnull((select sum(a.i_days2) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=8  and (b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m9 =isnull((select sum(a.i_days2) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=9  and (b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m10=isnull((select sum(a.i_days2) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=10 and (b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m11=isnull((select sum(a.i_days2) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=11 and (b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='NIGHTS'
update guest_xfttl set m12=isnull((select sum(a.i_days2) from hmst a, guest b where guest_xfttl.no=b.no and guest_xfttl.year=a.year and a.month=12 and (b.no=a.cusno or b.no=a.agent or b.no=a.source)), 0) where guest_xfttl.tag='NIGHTS'


-- over 
update guest_xfttl set ttl = m1+m2+m3+m4+m5+m6+m7+m8+m9+m10+m11+m12  where no=@mno 
delete guest_xfttl where no=@mno and m1=0 and m2=0 and m3=0 and m4=0 and m5=0 and m6=0 
		and m7=0 and m8=0 and m9=0 and m10=0 and m11=0 and m12=0

return 0
;


IF OBJECT_ID('p_gds_guest_income_reb5') IS NOT NULL
    DROP PROCEDURE p_gds_guest_income_reb5;
create proc p_gds_guest_income_reb5
as
truncate table hmst
return ;


//select * from hmaster where accnt like 'F4%';
// exec sp_who;
//select * from gdsmsg; 
// exec sp_helpdb foxhis;
//exec sp_helpdb tempdb;



