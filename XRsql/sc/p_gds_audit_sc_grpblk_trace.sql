

if exists(select * from sysobjects where name = "p_gds_audit_sc_grpblk_trace")
   drop proc p_gds_audit_sc_grpblk_trace;

create proc p_gds_audit_sc_grpblk_trace
as
--------------------------------------------------------
-- 记录团体占房情况 - 夜审调用 
--------------------------------------------------------

declare
   @bdate      	datetime,
	@grpaccnt		char(10),
	@rmnum			int,
	@gstno			int,
	@rate				money 

select  @bdate = bdate1 from sysdata
delete sc_grpblk_trace where date=@bdate

declare c_block cursor for select accnt from sc_master_till 
open c_block 
fetch c_block into @grpaccnt
while @@sqlstatus = 0
begin
	insert sc_grpblk_trace(date,accnt,foact,sta,c_status,rmnum)
		select @bdate,accnt,foact,sta,c_status,rmnum from sc_master_till where accnt=@grpaccnt
	exec p_gds_sc_rsvblk_cal @grpaccnt, 'T', 'R', @rmnum output, @gstno output, @rate output 	
	update sc_grpblk_trace set rmnum=@rmnum where date=@bdate and accnt=@grpaccnt

	fetch c_block into @grpaccnt
end
close c_block
deallocate cursor c_block 

return ;

//exec p_gds_audit_sc_grpblk_trace;
//select * from sc_grpblk_trace;
