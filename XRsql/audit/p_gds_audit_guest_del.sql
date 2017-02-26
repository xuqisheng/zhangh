if exists(select * from sysobjects where name = "p_gds_audit_guest_del")
	drop proc p_gds_audit_guest_del;
create proc p_gds_audit_guest_del
	@empno			char(10)='FOX' 
as
----------------------------------------------------------------------------------
--  夜审处理：客户档案删除 依据 guest_del_flag 
----------------------------------------------------------------------------------
declare		@parms		varchar(255),
				@bdate		datetime,
				@delay		int,
				@no			char(7),
				@msg			varchar(60) 

if rtrim(@empno) is null
	select @empno = 'FOX' 

-- parms
select @parms=null, @bdate=bdate1 from sysdata 
select @parms=rtrim(value) from sysoption where catalog='profile' and item='temp_delay'   -- 将要删除的档案临时保存天数 
select @delay=convert(int, @parms)
if @delay is null or @delay<=0 
	return 0  

--
exec p_gds_guest_del_check 'audit', @empno 

-- deal 
declare c_audit_guest_del cursor for select no from guest_del_flag where datediff(dd, crttime, @bdate)>@delay 
open c_audit_guest_del
fetch c_audit_guest_del into @no
while  @@sqlstatus = 0
begin
	exec p_gds_guest_delete @no, @empno,'R', @msg output 	
	fetch c_audit_guest_del into @no 
end
close c_audit_guest_del
deallocate cursor c_audit_guest_del

;
