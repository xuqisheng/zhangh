
if exists(select * from sysobjects where name = "p_gds_sc_no_booking")
	drop proc p_gds_sc_no_booking
;
create proc p_gds_sc_no_booking
	@no					char(10)
as
--------------------------------------------------------------------------------------
--	某个档案的预定信息 列表
--------------------------------------------------------------------------------------
select accnt, name, name2, arr,dep,rmnum,gstno,status, c_status, saleid, c_saleid,resby 
	from sc_master 
	where haccnt = @no 
		or cusno = @no 
		or agent = @no 
		or source = @no 
		or contact = @no 
	order by arr 

return;