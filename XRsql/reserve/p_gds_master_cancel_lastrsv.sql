
if exists(select * from sysobjects where name = "p_gds_master_cancel_lastrsv")
   drop proc p_gds_master_cancel_lastrsv
;
create  proc p_gds_master_cancel_lastrsv
   @grpaccnt 				char(10) = '',
	@empno					char(10) = 'FOX',
	@nullwithreturn		char(1) = null   
as

-- ----------------------------------------------------------------------
--
--		取消团体过期预留房  -- 调用 夜审， p_gds_update_group 
--
--------------------------------------------------------------------------
declare
   @ret     int,
   @msg     varchar(70),
   @accnt   char(10),
	@bdate	datetime,
	@arr		datetime,
	@id		int

select @ret=0, @msg ="", @bdate=bdate1 from sysdata
select @grpaccnt = rtrim(isnull(rtrim(@grpaccnt), '%'))

begin tran
save  tran p_gds_master_cancel_lastrsv_s1

declare c_grp cursor for select accnt, arr from master where accnt like @grpaccnt and class in  ('M', 'G') and sta in ('R', 'I', 'N') 
declare c_rsvsrc cursor for select id from rsvsrc where accnt = @accnt and datediff(dd,begin_,@arr)>0

open c_grp 
fetch c_grp into @accnt, @arr  
while @@sqlstatus = 0
begin
	update master set sta = sta where accnt = @accnt

	open c_rsvsrc
	fetch c_rsvsrc into @id
	while @@sqlstatus = 0
	begin
		exec p_gds_reserve_rsv_del @accnt,@id,'R',@empno,@ret output, @msg output
		if @ret<>0 
		begin
			close c_rsvsrc
			close c_grp 
			goto gout 
		end 
		fetch c_rsvsrc into @id
	end
	close c_rsvsrc

	fetch c_grp into @accnt, @arr  
end
close c_grp

gout:
deallocate cursor c_rsvsrc
deallocate cursor c_grp 

if @ret <> 0 
	rollback tran p_gds_master_cancel_lastrsv_s1
commit tran
if @nullwithreturn is null
   select @ret,@msg
else
   select @nullwithreturn = @msg 

return @ret 
;
