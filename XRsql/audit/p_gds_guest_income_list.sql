-- ---------------------------------------------------------
--		p_gds_guest_income_list
-- ---------------------------------------------------------
IF OBJECT_ID('p_gds_guest_income_list') IS NOT NULL
    DROP PROCEDURE p_gds_guest_income_list
;
create proc p_gds_guest_income_list
	@no			char(7),
	@begin		datetime = null,
	@end			datetime = null,
	@sta			char(1)	= '%'
as
-- ---------------------------------------------------------
--  宾客消费明细：临时生成记录。似乎影响速度！？
--		改良方向：1。速度 2。按照时间段统计
-- ---------------------------------------------------------
declare	@mno			char(7),
			@date			datetime,
			@accnt		char(10)

--
if @begin is null select @begin = convert(datetime, '1970/1/1')
if @end is null select @end = convert(datetime, '2040/1/1')
select @end = dateadd(dd, 1, @end) 
if @sta is null 
	select @sta = '%'

-- 
create table #goutput (
	accnt			char(10)								not null,
	master		char(10)								not null,
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
	packages		char(50)			default ''		not null,	-- 包价
	charge		money				default 0		null,
	ref			varchar(100)						null,
   i_times     int 				default 0 		not null,   -- 住店次数 
   x_times     int 				default 0 		not null,   -- 取消预订次数 
   n_times     int 				default 0 		not null,   -- 应到未到次数 
   l_times     int 				default 0 		not null,   -- 其它次数 
   i_days      int 				default 0 		not null,   -- 住店天数 
   fb_times1    int 				default 0 		not null,   -- 餐饮次数 
   en_times2    int 				default 0 		not null,   -- 娱乐次数 
   rm          money 			default 0 		not null, 	-- 房租收入
   fb          money 			default 0 		not null, 	-- 餐饮收入
   en          money 			default 0 		not null, 	-- 娱乐收入
   mt          money 			default 0 		not null, 	-- 会议收入
   ot          money 			default 0 		not null, 	-- 其它收入
   tl          money 			default 0 		not null 	-- 总收入  
)

-- Get Records
insert #goutput (accnt,master,sta,resno,arr,dep,type,roomno,setrate,haccnt,gstno,rmnum,packages,ref)
	select accnt,master,sta,resno,arr,dep,type,roomno,setrate,haccnt,gstno,rmnum,packages,ref
		from hmaster 
		where (haccnt = @no or cusno = @no or agent = @no or source = @no)
				and dep>=@begin and dep<=@end 	-- 以离开日期为标准  
				and sta like @sta 
update #goutput set name=a.name, name2=a.name2 from guest a where #goutput.haccnt=a.no

-- Sum 
update #goutput set rm=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=#goutput.accnt and a.pccode=b.pccode and b.deptno7='rm'),0)
update #goutput set fb=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=#goutput.accnt and a.pccode=b.pccode and b.deptno7='fb'),0)
update #goutput set en=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=#goutput.accnt and a.pccode=b.pccode and b.deptno7='en'),0)
update #goutput set mt=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=#goutput.accnt and a.pccode=b.pccode and b.deptno7='mt'),0)
update #goutput set ot=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=#goutput.accnt and a.pccode=b.pccode and b.deptno7='ot'),0)
update #goutput set tl = rm+fb+en+mt+ot

-- 计算房晚的费用码
declare	@rm_pccodes_nt	char(255)
select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')
update #goutput set i_days  = isnull((select sum(a.amount2) from master_income a where a.accnt=#goutput.accnt and a.pccode<>'' and charindex(a.pccode, @rm_pccodes_nt)>0 ),0)
--
update #goutput set i_days = 0 where accnt <> master

-- 计算其他
update #goutput set i_times = isnull((select sum(a.amount2) from master_income a where a.accnt=#goutput.accnt and a.item='I_TIMES'),0)
update #goutput set x_times = isnull((select sum(a.amount2) from master_income a where a.accnt=#goutput.accnt and a.item='X_TIMES'),0)
update #goutput set n_times = isnull((select sum(a.amount2) from master_income a where a.accnt=#goutput.accnt and a.item='N_TIMES'),0)

-- output
select accnt,sta, resno,arr,dep,type,roomno,setrate,name,name2,gstno,rmnum,packages,charge,ref,
	i_times,x_times,n_times,i_days,rm,fb,en,mt,ot,tl from #goutput order by arr desc 

return 0
;
