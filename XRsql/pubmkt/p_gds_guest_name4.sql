
IF OBJECT_ID('p_gds_guest_name4') IS NOT NULL
    DROP PROCEDURE p_gds_guest_name4;
create proc p_gds_guest_name4
	@no			char(7) -- Null ��ʾ�ؽ����� 
as
------------------------------------------------------------------
-- ���� guest.name4  -- ���ڿ��ٵ�ͨ����������
--	�Ƿ���Ҫ�Զ��ؽ� name3 ? -- �Զ�����ƴ���� 
------------------------------------------------------------------
--
-- һ��������÷���
--		����     ��name/name2=Ӣ����/���� lname/fname=��/��  name3=������
--									name			name2				name3
--						�й����ˣ�Ӣ����		������			����ƴ��
--						ŷ�����ˣ�Ӣ����		������			����ƴ��
--						�ձ����ˣ�Ӣ����		�ձ���			������		-- ��ʱ�ƺ�ȱ��һ������ƴ����

--		��λ/���壺name/name2=Ӣ����/������ name3=��� lname/fname=����
--
------------------------------------------------------------------
--	������� 
--
-- select '�������ɫ��, �ҵ����Ǻ�ɫ��' = upper('������ɫ��, �ҵ����Ǻ�ɫ��') from sysdata
-- select '90' = ascii ('Z'), 'Z' = char(90) from sysdata
-- name, fname, lname, name2, name3 -> name4 
-- �������� asc>128, ֱ�ӷ��� name4, ������ upper, �ٷ��� 
------------------------------------------------------------------
declare 
	@name		   	varchar(50),
	@fname       	varchar(30),
	@lname			varchar(30),
	@name2		   varchar(50),
	@name3		   varchar(50),
	@name4		   varchar(255),
	@nameout			varchar(50)

-- 
select @no = rtrim(ltrim(@no))
if @no is null 
	select @no = '%'

----------------------------------
-- �ؽ�ĳ�������� name4  
----------------------------------
if @no <> '%' 	
begin
	select @name=name,@lname=lname,@fname=fname,@name2=name2,@name3=name3 from guest where no=@no 
	if @@rowcount = 0
		return 

	select @name=rtrim(ltrim(@name)),@fname=rtrim(ltrim(@fname)),@lname=rtrim(ltrim(@lname))
	select @name2=rtrim(ltrim(@name2)),@name3=rtrim(ltrim(@name3))
	select @name4 = ''

	if @name is not null
	begin
		exec p_gds_upper_string @name, @nameout out 
		select @name4 = @name4 + ',' + @nameout
	end	

-- ��\�� һ�㶼�����������ֶ���, ����Ӧ�ÿ���ʡ�� 
--	if @fname is not null
--	begin
--		exec p_gds_upper_string @fname, @nameout out 
--		select @name4 = @name4 + ',' + @nameout
--	end	
--
--	if @lname is not null
--	begin
--		exec p_gds_upper_string @lname, @nameout out 
--		select @name4 = @name4 + ',' + @nameout
--	end	

	if @name2 is not null
	begin
		exec p_gds_upper_string @name2, @nameout out 
		select @name4 = @name4 + ',' + @nameout
	end	

	if @name3 is not null
	begin
		exec p_gds_upper_string @name3, @nameout out 
		select @name4 = @name4 + ',' + @nameout
	end	
	select @name4 = ltrim(stuff(ltrim(@name4),1,1,''))

	-- update 
	update guest set name4=@name4 where no=@no
end
else
----------------------------------
-- �ؽ����е����� name4  
----------------------------------
begin	
	-- test speed 
	declare  @count  int, @ii int, @rows int, @rows_str char(20)  
	select @count = 0, @ii = 0
	delete process_flag where flag='guest_reb'
	insert process_flag(flag,value) values('guest_reb', '0')
	select @rows = count(1) from guest
	select @rows_str = convert(char(20), @rows)
	
	-- Begin
	declare	c_guest cursor for select no,name,lname,fname,name2,name3 from guest
	open c_guest
	fetch c_guest into @no,@name,@lname,@fname,@name2,@name3
	while @@sqlstatus = 0
	begin
		-- test speed��ÿ��� 100 ����¼����ʾһ��  
		select @count = @count + 1, @ii = @ii + 1
		if @ii > 100 
		begin
			update process_flag set value = convert(char(10), @count) + ' : ' + @rows_str where flag='guest_reb'
			select @ii = 0
		end
		
		select @name=rtrim(ltrim(@name)),@fname=rtrim(ltrim(@fname)),@lname=rtrim(ltrim(@lname))
		select @name2=rtrim(ltrim(@name2)),@name3=rtrim(ltrim(@name3))
		select @name4 = ''
	
		if @name is not null
		begin
			exec p_gds_upper_string @name, @nameout out 
			select @name4 = @name4 + ',' + @nameout
		end	
	
-- ��\�� һ�㶼�����������ֶ���, ����Ӧ�ÿ���ʡ�� 
--		if @fname is not null
--		begin
--			exec p_gds_upper_string @fname, @nameout out 
--			select @name4 = @name4 + ',' + @nameout
--		end	
--	
--		if @lname is not null
--		begin
--			exec p_gds_upper_string @lname, @nameout out 
--			select @name4 = @name4 + ',' + @nameout
--		end	
	
		if @name2 is not null
		begin
			exec p_gds_upper_string @name2, @nameout out 
			select @name4 = @name4 + ',' + @nameout
		end	
	
		if @name3 is not null
		begin
			exec p_gds_upper_string @name3, @nameout out 
			select @name4 = @name4 + ',' + @nameout
		end	
		select @name4 = ltrim(stuff(ltrim(@name4),1,1,''))
	
		-- update 
		update guest set name4=@name4 where no=@no
	
		fetch c_guest into @no,@name,@lname,@fname,@name2,@name3
	end
	close c_guest
	deallocate cursor c_guest

	-- last update
	update process_flag set value = convert(char(10), @count) + ' : ' + @rows_str where flag='guest_reb'
end

return ;



IF OBJECT_ID('p_gds_guest_name4_bu') IS NOT NULL
    DROP PROCEDURE p_gds_guest_name4_bu;
create proc p_gds_guest_name4_bu
as
------------------------------------------------------------------
-- ���� guest.name4  -- ������©���� 
------------------------------------------------------------------
declare 
	@no				char(7),
	@name		   	varchar(50),
	@fname       	varchar(30),
	@lname			varchar(30),
	@name2		   varchar(50),
	@name3		   varchar(50),
	@name4		   varchar(255),
	@nameout			varchar(50)

------------------------------------------------------
-- Begin
------------------------------------------------------
declare	c_guest cursor for select no,name,lname,fname,name2,name3 from guest where name4='' 
open c_guest
fetch c_guest into @no,@name,@lname,@fname,@name2,@name3
while @@sqlstatus = 0
begin
	select @name=rtrim(ltrim(@name)),@fname=rtrim(ltrim(@fname)),@lname=rtrim(ltrim(@lname))
	select @name2=rtrim(ltrim(@name2)),@name3=rtrim(ltrim(@name3))
	select @name4 = ''

	if @name is not null
	begin
		exec p_gds_upper_string @name, @nameout out 
		select @name4 = @name4 + ',' + @nameout
	end	

-- ��\�� һ�㶼�����������ֶ���, ����Ӧ�ÿ���ʡ�� 
--		if @fname is not null
--		begin
--			exec p_gds_upper_string @fname, @nameout out 
--			select @name4 = @name4 + ',' + @nameout
--		end	
--	
--		if @lname is not null
--		begin
--			exec p_gds_upper_string @lname, @nameout out 
--			select @name4 = @name4 + ',' + @nameout
--		end	

	if @name2 is not null
	begin
		exec p_gds_upper_string @name2, @nameout out 
		select @name4 = @name4 + ',' + @nameout
	end	

	if @name3 is not null
	begin
		exec p_gds_upper_string @name3, @nameout out 
		select @name4 = @name4 + ',' + @nameout
	end	
	select @name4 = ltrim(stuff(ltrim(@name4),1,1,''))

	-- update 
	update guest set name4=@name4 where no=@no

	fetch c_guest into @no,@name,@lname,@fname,@name2,@name3
end
close c_guest
deallocate cursor c_guest

return ;

