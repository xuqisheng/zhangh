drop proc p_hui_guest_group;
create proc p_hui_guest_group
	@date		datetime,
	@sta		char(1)  --R表示预抵,I表示在住,O表示预离
as

if @sta = 'R'
	begin

	select a.accnt,a.gstno + a.children,b.haccnt,c.country,a.arr,a.dep from master a,master_des b,guest c 
		where a.haccnt=c.no and a.accnt=b.accnt and a.class in ('G','M') and a.sta ='R' and datediff(dd,a.arr,@date)<=0  
			and datediff(dd, @date, a.arr) <= 0	order by a.accnt
	end

else if @sta = 'I'
	begin

	select a.accnt,a.gstno + a.children,b.haccnt,c.country,a.arr,a.dep from master a,master_des b,guest c 
		where a.haccnt=c.no and a.accnt=b.accnt and a.class in ('G','M') and a.sta ='I' order by a.accnt
	end

else if @sta = 'O'
	begin

	select a.accnt,a.gstno + a.children,b.haccnt,c.country,a.arr,a.dep from master a,master_des b,guest c 
		where a.haccnt=c.no and a.accnt=b.accnt and a.class in ('G','M') and a.sta ='I' and datediff(dd, a.dep, getdate())=0  
			order by a.accnt

	end

return;
