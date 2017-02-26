IF OBJECT_ID('p_wz_rmsta_bu') IS NOT NULL
    DROP PROCEDURE p_wz_rmsta_bu
;
create proc p_wz_rmsta_bu
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
		@tmp2				integer,
		@today			datetime

select @today = getdate()

if @mode = 'T'
begin
	--
	if not exists(select 1 from attendant_allot)
		insert attendant_allot(cdate,hall,flr,roomno,status)
				select @today,hall,flr,roomno,ocsta+sta from rmsta

	--到rmsta 里提取房间状态
	declare c_cur cursor for select roomno,ocsta,sta from rmsta order by roomno
	open c_cur
	fetch c_cur into @roomno,@ocsta,@sta
	while @@sqlstatus = 0
	begin
		select @temp = status from attendant_allot where roomno = @roomno
		select @status = @ocsta + @sta
		if @temp <> @status
			update attendant_allot set status = @status where roomno = @roomno

		fetch c_cur into @roomno,@ocsta,@sta
	end
	close c_cur
	deallocate cursor c_cur

--
	 update attendant_allot set credits = isnull(b.value,0) from gs_item b
			where attendant_allot.status = b.descript
	select @value_all = isnull((select sum(credits) from attendant_allot),0)
	if @person<>0
		select @rule = @value_all/@person
	else
		select @rule = 0


	--根据算法规则来分配要清洁的房间
	select @ptmp = 1,@tmp2 = 0
	declare c_rmsta cursor for select roomno,credits from attendant_allot order by roomno
	open c_rmsta
	fetch c_rmsta into @roomno,@tmp1
	while	@ptmp < = @person and @@sqlstatus = 0
	begin
		while @tmp2 < @rule and @@sqlstatus = 0
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

select attendant,isnull(sum(credits),0) from attendant_allot group by attendant

return 0
;
