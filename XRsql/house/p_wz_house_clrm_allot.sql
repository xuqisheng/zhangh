//====================================================================
// Database Administration - 2.2.SYT SQL Server 4.x.foxhis6.dbo
// Reason: 
//--------------------------------------------------------------------
// Modified By: wz		Date: 2003.08.12
//--------------------------------------------------------------------
//实现客房中心清洁工作量的分配
//====================================================================
if exists (select 1 from sysobjects where name = 'p_wz_house_clrm_allot')
	drop proc p_wz_house_clrm_allot;
create proc p_wz_house_clrm_allot
		@empno			char(3),
		@person			integer,
		@mode				char(1)	
as
declare
		@roomno 			char(5),
		@ocsta			char(1),
		@sta				char(1),
		@temp 			varchar(2),
		@status			varchar(2),
		@value_all		integer,
		@rule				integer,
		@ptmp				integer,
		@tmp1				integer,
		@tmp2				integer

if @mode = 'T'	
begin
	delete attendant_allot
	insert attendant_allot(hall,flr,roomno,status,people)
			select hall,flr,roomno,ocsta+sta,people from rmsta order by convert(integer,roomno)
--到rmsta 里提取房间状态
//	declare c_cur cursor for select roomno,ocsta,sta from rmsta order by roomno
//	open c_cur
//	fetch c_cur into @roomno,@ocsta,@sta
//	while @@sqlstatus = 0
//	begin
//		select @temp = status from attendant_allot where roomno= @roomno	
//		select @status = @ocsta + @sta
//		if @temp <> @status
//			update attendant_allot set status = @status where roomno = @roomno
//		fetch c_cur into @roomno,@ocsta,@sta
//	end
//	close c_cur
//	deallocate cursor c_cur
--
	update attendant_allot set status = 'VC' where status = 'VR'

--
	update attendant_allot set credits = isnull(b.value,0) from gs_item b
			where attendant_allot.status = b.descript
	
	select @value_all = sum(credits) from attendant_allot
	select @rule = @value_all/@person
--
	update attendant_allot set people = isnull(b.people,0),empno = @empno,cdate = getdate() from rmsta b
		where attendant_allot.roomno = b.roomno

	update attendant_allot set vip = b.vip from guest b,master d
		where attendant_allot.roomno = d.roomno and d.haccnt = b.no 

--根据算法规则来分配要清洁的房间
	select @ptmp = 1,@tmp2 = 0
	declare c_rmsta cursor for select roomno,credits from attendant_allot order by convert(integer,roomno)
	open c_rmsta
	fetch c_rmsta into @roomno,@tmp1
	
	while	@ptmp < = @person and @@sqlstatus = 0
	begin
		while @tmp2 < @rule and @@sqlstatus= 0
		begin
			update attendant_allot set attendant = @ptmp where roomno = @roomno
			select @tmp2 = @tmp2 + @tmp1 
			fetch c_rmsta into @roomno,@tmp1
		end
		select @ptmp = @ptmp + 1, @tmp2 = 0
	end
	close c_rmsta
	deallocate cursor c_rmsta
	
end

select attendant,hall,flr,roomno,status,people,vip,credits from attendant_allot	order by convert(integer,attendant),convert(integer,roomno)
return 0;
