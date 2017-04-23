drop proc p_hui_guest_birth;
create proc p_hui_guest_birth
	@date		datetime
as

select b.name,a.roomno,char991  =  c.groupno+'/'+c.cusno+c.agent+c.source,a.arr,a.dep from master a,guest b,master_des c 
	where a.class='F' and a.haccnt = b.no and a.accnt=c.accnt and a.sta ='I'  
		and substring(convert(char(12), b.birth, 110), 1, 5)  = substring(convert(char(12), @date, 110), 1, 5)  order by a.oroomno,a.accnt;


return;
