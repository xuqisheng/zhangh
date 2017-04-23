drop proc p_hui_guest_vip;
create proc p_hui_guest_vip
	@date		datetime,
	@sta		char(1)  --R表示预抵,I表示在住,O表示预离
as

if @sta = 'R'
	begin
	select b.haccnt,char901  =  b.groupno+'/'+b.cusno+b.agent+b.source,c.roomno,c.arr,c.dep 
		from master a,master_des b,rsvsrc c,guest d where d.vip in('V1','V2','V3') and a.haccnt=d.no 
			and c.accnt=a.accnt and a.accnt=b.accnt and  a.sta='R' and datediff(dd,c.arr, @date)<=0 and datediff(dd, @date, c.arr) <= 0
				 order by a.oroomno,a.accnt
	end

else if @sta = 'I'
	begin
	select b.haccnt,char901  =  b.groupno+'/'+b.cusno+b.agent+b.source,a.roomno,a.arr,a.dep 
		from master a,master_des b,guest d where d.vip in('V1','V2','V3') and a.haccnt=d.no 
			and a.accnt=b.accnt and a.sta='I'
				 order by a.oroomno,a.accnt
	end

else if @sta = 'O'
	begin
	select b.haccnt,char901  =  b.groupno+'/'+b.cusno+b.agent+b.source,a.roomno,a.arr,a.dep 
		from master a,master_des b,guest d where a.class='F' and a.groupno = '' and d.vip in('V1','V2','V3') and a.haccnt=d.no
			and a.accnt=b.accnt and a.sta ='I' and datediff(dd, a.dep, getdate())=0
				 order by a.oroomno,a.accnt
	end


return;
