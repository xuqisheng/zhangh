// ------------------------------------------------------------------------
//		Î¬»¤master_des
// ------------------------------------------------------------------------ 
if exists (select 1 from sysobjects where name = 'p_crs_master_des_maint'  and type = 'P')
	drop procedure p_crs_master_des_maint;

create  procedure p_crs_master_des_maint  
as
begin 
	declare @accnt varchar(10)	
	
	declare c_3 cursor for 
		select accnt from master_hotel where datediff(day,lastdate,getdate())<=0
	open c_3
	fetch c_3 into @accnt
	while @@sqlstatus = 0 
	begin
		execute p_gds_master_des_maint @accnt
		fetch c_3 into @accnt
	end 
	close c_3
	deallocate cursor c_3
end
;

exec p_crs_master_des_maint
;
