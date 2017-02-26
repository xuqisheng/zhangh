
if object_id('p_yhk_profile_combine_summary') is not null
	drop proc p_yhk_profile_combine_summary;
create proc p_yhk_profile_combine_summary
	@history_a 		char(7),
	@history_b		char(7)
as
------------------------------------------------------------------------------------
-- 合并档案的业绩数据显示 - 在合并功能窗口的下方 
------------------------------------------------------------------------------------
create table #combine_summary
(
	no char(7) not null,
	name varchar(60) null,
	rm	money default 0 null,
	fb	money default 0 null,
	en	money default 0 null,
	mt	money default 0 null,
	ot	money default 0 null,
	tl	money default 0 null,
	i_days int default 0 null,
	i_times int default 0 null,
	x_times int default 0 null,
	n_times int default 0 null,
	l_times int default 0 null,
	fv_rate money default 0 null,
	lv_rate money default 0 null,
	fv_date datetime null,
	lv_date datetime null,
	fv_room varchar(20) null,
	lv_room varchar(20) null,
	vipcard_charge money default 0 null,
	vipcard_credit money default 0 null,
	deals_now int default 0 null

)

--  SELECT a.no, a.fv_date, a.fv_room, a.fv_rate, a.lv_date, a.lv_room, a.lv_rate, a.i_times, a.x_times, a.n_times, 
--			a.l_times, a.i_days, a.fb_times1, a.en_times2, a.rm, a.fb, a.en, a.mt, a.ot, a.tl, b.charge, b.credit  
--    FROM guest a, vipcard b 
--   WHERE a.no = :no and a.cardno *= b.no

-- Insert data 
insert into #combine_summary (no,name,rm,fb,en,mt,ot,tl,i_days,i_times,x_times,n_times,l_times,fv_rate,lv_rate,fv_date,lv_date,fv_room,lv_room,vipcard_charge,vipcard_credit) 
	select a.no,a.name,a.rm,a.fb,a.en,a.mt,a.ot,a.tl,a.i_days,a.i_times,a.x_times,a.n_times,a.l_times,a.fv_rate,a.lv_rate,a.fv_date,a.lv_date,a.fv_room,a.lv_room,b.charge,b.credit 
		from guest a,vipcard b 
		where (a.no = @history_a or a.no = @history_b) and a.cardno *= b.no

-- 当前预订订单数量 
update #combine_summary set deals_now = (select count(accnt)  from master where haccnt = @history_a and sta in ('I','R') ) where no = @history_a
update #combine_summary set deals_now = (select count(accnt)  from master where haccnt = @history_b and sta in ('I','R')) where no = @history_b

-- output 
select no,name,rm,fb,en,mt,ot,tl,i_days,i_times,x_times,n_times,l_times,
		fv_date,fv_room,fv_rate,lv_date,lv_room,lv_rate,vipcard_charge,vipcard_credit,deals_now 
from #combine_summary	
;

