IF OBJECT_ID('p_sync_guest_income') IS NOT NULL
    DROP PROCEDURE p_sync_guest_income
;
create procedure p_sync_guest_income
	@no			char(7)
as
begin
	-- Get Records
	insert sync_guest_income (syncsta,no,accnt,sta,resno,arr,dep,type,roomno,setrate,haccnt,gstno,rmnum,packages,ref)
		select '0',@no,accnt,sta,resno,arr,dep,type,roomno,setrate,haccnt,gstno,rmnum,packages,ref
		from hmaster
		where (haccnt = @no or cusno = @no or agent = @no or source = @no) and
				accnt not in(select accnt from sync_guest_income where no = @no)
	update sync_guest_income set name=a.name, name2=a.name2 from guest a where sync_guest_income.haccnt=a.no

	-- Sum
	update sync_guest_income set rm=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=sync_guest_income.accnt and a.pccode=b.pccode and b.deptno7='rm'),0)
	update sync_guest_income set fb=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=sync_guest_income.accnt and a.pccode=b.pccode and b.deptno7='fb'),0)
	update sync_guest_income set en=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=sync_guest_income.accnt and a.pccode=b.pccode and b.deptno7='en'),0)
	update sync_guest_income set mt=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=sync_guest_income.accnt and a.pccode=b.pccode and b.deptno7='mt'),0)
	update sync_guest_income set ot=isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt=sync_guest_income.accnt and a.pccode=b.pccode and b.deptno7='ot'),0)
	update sync_guest_income set tl = rm+fb+en+mt+ot

	update sync_guest_income set i_days  = isnull((select sum(a.amount2) from master_income a where a.accnt=sync_guest_income.accnt and a.pccode like '00%'),0)
	update sync_guest_income set i_times = isnull((select sum(a.amount2) from master_income a where a.accnt=sync_guest_income.accnt and a.item='I_TIMES'),0)
	update sync_guest_income set x_times = isnull((select sum(a.amount2) from master_income a where a.accnt=sync_guest_income.accnt and a.item='X_TIMES'),0)
	update sync_guest_income set n_times = isnull((select sum(a.amount2) from master_income a where a.accnt=sync_guest_income.accnt and a.item='N_TIMES'),0)

	return 0
end
;
