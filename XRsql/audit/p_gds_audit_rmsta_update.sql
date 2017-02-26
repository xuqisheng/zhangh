
IF OBJECT_ID('p_gds_audit_rmsta_update') IS NOT NULL
    DROP PROCEDURE p_gds_audit_rmsta_update
;
create proc p_gds_audit_rmsta_update
	@empno	char(10)
as

declare
   @ret      int,
   @begin	 datetime,
   @end	    datetime,
   @msg      varchar(60),
	@roomno	 char(5)


select @ret=0, @msg='',@begin = getdate(), @end = dateadd(dd, 1, getdate())

-- 只能在夜审的时候执行              
if not exists(select 1 from gate where audit = 'T')
	return 0

-- Dealing with ...
declare c_roomno cursor for 
	select distinct roomno from master 
		where sta='I' and class='F' and roomno<>'' 
			order by roomno
open c_roomno
fetch c_roomno into @roomno 
while @@sqlstatus = 0
	begin
	exec @ret = p_gds_update_room_status @roomno,' ','D',@begin,@end,@empno,'R',@msg output

	fetch c_roomno into @roomno 
	end
close c_roomno
deallocate cursor c_roomno

return 0
;
