
if exists(select 1 from sysobjects where name = 'p_wz_rmsta_input')
		drop proc p_wz_rmsta_input;
create proc p_wz_rmsta_input
		@empno			char(10),
		@person			integer,
		@mode				char(1)	-- �Ƿ��������� 
as
--====================================================================
-- �˴洢���̹���rmsta���ű�ÿ����һ�δӱ������һ�η���״̬��attendant_allot
-- ���Ҷ�̬�������Ա����������ƽ������Ĺ���
--====================================================================
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
	delete attendant_allot
	insert attendant_allot(cdate,hall,flr,roomno,status,people)
			select @today,hall,flr,roomno,ocsta+sta,people 
				from rmsta order by convert(integer,roomno)
		
--��rmsta ����ȡ����״̬
--	declare c_cur cursor for select roomno,ocsta,sta from rmsta order by convert(integer,roomno)
--	open c_cur
--	fetch c_cur into @roomno,@ocsta,@sta
--	while @@sqlstatus = 0
--	begin
--		select @temp = status from attendant_allot where roomno = @roomno	
--		select @status = @ocsta + @sta
--		if @temp <> @status
--			update attendant_allot set status = @status where roomno = @roomno
--		fetch c_cur into @roomno,@ocsta,@sta
--	end
--	close c_cur
--	deallocate cursor c_cur

--
	update attendant_allot set status = 'OC' where status = 'OR'
	update attendant_allot set status = 'VC' where status = 'VR'

--	
	update attendant_allot set people = isnull(b.people,0),empno = @empno 
		from rmsta b where attendant_allot.roomno = b.roomno

	update attendant_allot set vip = b.vip 
		from guest b,master d where attendant_allot.roomno = d.roomno and d.haccnt = b.no 

--
	update attendant_allot set credits = isnull(b.value,0) 
		from gs_item b	where attendant_allot.status = b.descript
	
	select @value_all = sum(credits) from attendant_allot
	if @person <> 0
		select @rule = @value_all/@person

--�����㷨����������Ҫ���ķ���
	select @ptmp = 1,@tmp2 = 0
	declare c_rmsta cursor for select roomno,credits from attendant_allot order by convert(integer,roomno)
	open c_rmsta
	fetch c_rmsta into @roomno,@tmp1
	
	while	@ptmp <= @person and @@sqlstatus = 0
	begin
		while @tmp2 <= @rule
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

select attendant,hall,flr,roomno,status,people,vip,credits 
	from attendant_allot	
	order by convert(integer,attendant), convert(integer,roomno)

return 0 ; 
