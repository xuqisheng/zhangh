-- ---------------------------------------------------------
--		p_crs_guest_income_accnt ���� p_gds_guest_income_list
-- ---------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_crs_guest_income_accnt'  and type = 'P')
	drop procedure p_crs_guest_income_accnt
;


create proc p_crs_guest_income_accnt
	@hotelid			char(20), 				
	@accnt			char(10)				
as
declare	@mno			char(7),
			@date			datetime 

create table #goutput (
   hotelid     varchar(20)                   not null,
	no 			char(7)								not null,
	accnt			char(10)								not null,
	resno			char(10)								null,
	sta			char(1)								null,
	arr			datetime								null,
	dep			datetime								null,
	type			char(3)								null,
	roomno		char(5)								null,
	setrate		money				default 0		null,
	haccnt		char(7)								not null,
	name		   varchar(50)	 	default ''		null,	 	-- ����1
	name2		   varchar(50)	 	default ''		null,	 	-- ����2
	gstno			int				default 0		not null,
	rmnum			int				default 0		not null,
	packages		varchar(50)		default ''		not null,	-- ����
	charge		money				default 0		null,
	ref			varchar(100)						null,
   i_times     int 				default 0 		not null,   -- ס����� 
   x_times     int 				default 0 		not null,   -- ȡ��Ԥ������ 
   n_times     int 				default 0 		not null,   -- Ӧ��δ������ 
   l_times     int 				default 0 		not null,   -- �������� 
   i_days      int 				default 0 		not null,   -- ס������ 
   fb_times1   int 				default 0 		not null,   -- �������� 
   en_times2   int 				default 0 		not null, -- ���ִ��� 
   rm          money 			default 0 		not null, 	-- ��������
   fb          money 			default 0 		not null, 	-- ��������
   en          money 			default 0 		not null, 	-- ��������
   mt          money 			default 0 		not null, 	-- ��������
   ot          money 			default 0 		not null, 	-- ��������
   tl          money 			default 0 		not null, 	-- ������
   cardcode      char(10)                        null, --����
   cardno        char(20)                        null  
)

-- Get Records
insert #goutput (hotelid,no,accnt,sta,resno,arr,dep,type,roomno,setrate,haccnt,gstno,rmnum,packages,ref,cardno,cardcode)
	select @hotelid,'',accnt,sta,resno,arr,dep,type,roomno,setrate,haccnt,gstno,rmnum,packages,ref,cardno,cardcode
	from hmaster where accnt = @accnt 
update #goutput set no=a.censeq,name=a.name, name2=a.name2 from guest a where #goutput.haccnt=a.no

-- Sum 
update #goutput set rm=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=#goutput.accnt and a.pccode=b.pccode and b.deptno7='rm'),0)
update #goutput set fb=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=#goutput.accnt and a.pccode=b.pccode and b.deptno7='fb'),0)
update #goutput set en=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=#goutput.accnt and a.pccode=b.pccode and b.deptno7='en'),0)
update #goutput set mt=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=#goutput.accnt and a.pccode=b.pccode and b.deptno7='mt'),0)
update #goutput set ot=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=#goutput.accnt and a.pccode=b.pccode and b.deptno7='ot'),0)
update #goutput set tl = rm+fb+en+mt+ot

-- ���㷿��ķ����� add by yb 2005.04.26
declare	@rm_pccodes	char(255)
select @rm_pccodes    = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes'), '')


update #goutput set i_days  = isnull((select sum(a.amount2) from master_income a where a.accnt=#goutput.accnt and a.pccode<>'' and charindex(a.pccode,@rm_pccodes)>0),0)
update #goutput set i_times = isnull((select sum(a.amount2) from master_income a where a.accnt=#goutput.accnt and a.item='I_TIMES'),0)
update #goutput set x_times = isnull((select sum(a.amount2) from master_income a where a.accnt=#goutput.accnt and a.item='X_TIMES'),0)
update #goutput set n_times = isnull((select sum(a.amount2) from master_income a where a.accnt=#goutput.accnt and a.item='N_TIMES'),0)

-- output 
select * from #goutput 

return 0
;
