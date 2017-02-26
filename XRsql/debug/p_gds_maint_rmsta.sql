if exists(select * from sysobjects where name='p_gds_maint_rmsta' and type ='P')
   drop proc p_gds_maint_rmsta;
create proc p_gds_maint_rmsta
as
-- ------------------------------------------------------------------------
-- 系统维护程序之一: 	维护 rmsta 
--
--				依据 master, rm_ooo
--
--				是否干净，临时态这里不维护了。
-- ------------------------------------------------------------------------
declare	@accnt		char(10),
			@count		int,
			@roomno		char(5),
			@sta			char(1),
			@dbegin		datetime,
			@dend			datetime,
			@ret			int,
			@msg			varchar(60),
			@empno		char(10)

create table #goutput (msg			varchar(100)		null)

-- Init 
update rmsta set ocsta='V', locked='N', number=0, onumber=0, accntset=''
update rmsta set sta='D' where sta not in ('R', 'I', 'T')

-- 根据 master 维护 rmsta
declare c_roomno cursor for select roomno from rmsta
open c_roomno
fetch c_roomno into @roomno
while @@sqlstatus = 0
begin
	select @accnt = ''
	select @accnt = isnull((select min(accnt) from master where roomno=@roomno and sta='I' and class in ('F', 'G', 'M', 'C') and accnt>@accnt),'')
	while @accnt<>'' 
	begin
		update rmsta set ocsta='O', number=number+1,onumber=onumber+1,accntset=accntset+@accnt+'#' where roomno=@roomno
		select @accnt = isnull((select min(accnt) from master where roomno=@roomno and sta='I' and class in ('F', 'G', 'M', 'C') and accnt>@accnt),'')
	end

	fetch c_roomno into @roomno
end
close c_roomno
deallocate cursor c_roomno
update rmsta set accntset=ltrim(rtrim(accntset)) where accntset<>''

-- 根据 rm_ooo 维护 rmsta
declare c_ooo cursor for select roomno, sta, dbegin,dend,empno1 from rm_ooo where status='I' order by roomno
open c_ooo
fetch c_ooo into @roomno,@sta,@dbegin,@dend,@empno
while @@sqlstatus = 0
begin
	if @dbegin<getdate()
		select @dbegin = getdate()
	if @dend<getdate()
		select @dend = getdate()
	exec @ret = p_gds_update_room_status @roomno, 'L', @sta, @dbegin, @dend, @empno, 'R', @msg output
	if @ret <> 0
		insert #goutput select 'OO ERROR: ' + @roomno + ' ' + @msg

	fetch c_ooo into @roomno,@sta,@dbegin,@dend,@empno
end
close c_ooo
deallocate cursor c_ooo

-- Output
if exists(select 1 from #goutput)
	select * from #goutput
return 0
;


-- exec p_gds_maint_rmsta;


