if exists (select * from sysobjects where name ='p_gl_audit_mntrmetc' and type ='P')
	drop proc p_gl_audit_mntrmetc
;
create proc p_gl_audit_mntrmetc
	@empno	char(10),
	@ret		integer		out,
	@msg		varchar(70)	out
as
-------------------------------------
-- 夜核房态处理
-------------------------------------
declare
	@bdate 		datetime,
	@roomno		char(5),
	@osno			char(10),
	@sta			char(1),
   @dbegin     datetime,
   @dend       datetime

select @ret = 0, @msg = ''
select @bdate = bdate1  from sysdata

-- lock
update rmsta set oldsta = sta

-- 自动设置 维修房
update rmsta set sta = futsta, empno = @empno, changed = getdate(), logmark = logmark + 1
	where ocsta = 'V' and locked = 'L' and datediff(dd,futbegin,@bdate)>=0 and datediff(dd,futend,@bdate)<0

---------------------------------------------------
-- 解除 维修房 (需要对维修单处理) 到期自动解除
---------------------------------------------------
-- 原来的做法
--update rm_ooo set status='O', empno3=@empno, date3 = getdate(), logmark = logmark + 1
--	where status = 'I'
--		and roomno in (select roomno from rmsta where ocsta = 'V' and locked='L' and convert(datetime, convert(char(10), futend, 111)) = @bdate)
--update rmsta set sta = 'D', empno = @empno, changed = getdate(), locked='N', fempno = @empno, fcdate = getdate(), logmark = logmark + 1
--	where ocsta = 'V' and locked='L' and convert(datetime, convert(char(10), futend, 111)) = @bdate

--- 新的做法 from X50204
declare c_oocls cursor for select roomno, osno, sta from rmsta
	where ocsta = 'V' and locked='L' and datediff(dd, futend, @bdate)>=0
open c_oocls
fetch c_oocls into @roomno, @osno, @sta
while @@sqlstatus = 0
	begin
    --@osno是空的，要重新取
    select @osno=b.folio from rmsta a,rm_ooo b where a.roomno=@roomno and a.roomno=b.roomno and a.futbegin=b.dbegin and b.status='I'
	if @sta in ('O', 'S')
		update rmsta set sta = 'D', empno = @empno, changed = getdate(), locked='N', fempno = @empno, fcdate = getdate(), logmark = logmark + 1
			where roomno=@roomno
	if rtrim(@osno) is not null
		update rm_ooo set status='O', empno3=@empno, date3 = getdate(), logmark = logmark + 1
			where folio=@osno and status = 'I'
--	else -- 兼顾 osno 没有填入的情况
--		update rm_ooo set status='O', empno3=@empno, date3 = getdate(), logmark = logmark + 1
--			where roomno=@roomno and status = 'I'
   --解除了之后还要继续处理未来维修
   select @dbegin=min(dbegin) from rm_ooo where status='I' and roomno=@roomno
   if @dbegin<>'' and @dbegin is not null
    	begin
      select @dend=dend,@sta=sta from rm_ooo where status='I' and roomno=@roomno and dbegin=@dbegin
      exec p_gds_update_room_status @roomno, 'L', @sta, @dbegin, @dend, @empno, 'R', @msg output
      end
	fetch c_oocls into @roomno, @osno, @sta
	end
close c_oocls
deallocate cursor c_oocls

---------------------------------------------------
-- 过期自动取消
---------------------------------------------------
declare c_oocxl cursor for select folio, roomno, sta from rm_ooo where status='I' and datediff(dd, dend, @bdate)>=0
open c_oocxl
fetch c_oocxl into @osno, @roomno, @sta
while @@sqlstatus = 0
	begin
	if exists(select 1 from rmsta where roomno=@roomno and sta=@sta and locked='L') --  and osno=@osno)
	begin
		update rmsta set sta = 'D', empno = @empno, changed = getdate(), locked='N', fempno = @empno, fcdate = getdate(), logmark = logmark + 1
			where roomno=@roomno
		update rm_ooo set status='O', empno3=@empno, date3 = getdate(), logmark = logmark + 1
			where folio=@osno and status = 'I'
	end
	else
	begin
		update rmsta set empno = @empno, changed = getdate(), locked='N', fempno = @empno, fcdate = getdate(), logmark = logmark + 1
			where roomno=@roomno
		update rm_ooo set status='X', empno4=@empno, date4 = getdate(), logmark = logmark + 1
			where folio=@osno and status = 'I'
	end

	--解除了之后还要继续处理未来维修
	select @dbegin=min(dbegin) from rm_ooo where status='I' and roomno=@roomno
	if @dbegin<>'' and @dbegin is not null
		begin
		select @dend=dend,@sta=sta from rm_ooo where status='I' and roomno=@roomno and dbegin=@dbegin
		exec p_gds_update_room_status @roomno, 'L', @sta, @dbegin, @dend, @empno, 'R', @msg output
		end
	
	fetch c_oocxl into @osno, @roomno, @sta
	end
close c_oocxl
deallocate cursor c_oocxl

return @ret
;
