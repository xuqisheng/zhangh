if exists (select 1 from sysobjects where name = 'p_sync_guest_list_today' and type = 'P')
   drop procedure p_sync_guest_list_today
; 
--------------------------------------------------------------------------------
-- 今天需要同步的客人列表 
--------------------------------------------------------------------------------
create procedure p_sync_guest_list_today
as	
begin 
	declare @no	 varchar(7)

	create table #lst
	(
		no				char(20)								not null,	-- 卡号	
		hno 			char(7)								not null,
		name		   varchar(50)	 						not null,	-- 姓名: 本名 
		op			   int 				default 0 		not null 
	)
	
	insert into #lst (no,hno,name)
		select b.no,b.hno,a.name from guest a, vipcard b where b.hno = a.no and datediff(day,a.changed,getdate()) = 0

	declare c1 cursor for
		select hno from #lst
	open c1
	fetch c1 into @no  
	while @@sqlstatus = 0 
	begin
		execute p_gl_lgfl_guest @no
		fetch c1 into @no 
	end
	close c1
	deallocate cursor c1
	
	select c.op,c.hno,c.name,c.no,b.descript, a.old, a.new, a.empno, a.date 
		from lgfl a, lgfl_des b,#lst c
		where a.accnt= c.hno and a.columnname = b.columnname 
	order by a.date, a.columnname
	
end
;

exec p_sync_guest_list_today;
