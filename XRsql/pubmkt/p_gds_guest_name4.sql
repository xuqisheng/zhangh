
IF OBJECT_ID('p_gds_guest_name4') IS NOT NULL
    DROP PROCEDURE p_gds_guest_name4;
create proc p_gds_guest_name4
	@no			char(7) -- Null 表示重建所有 
as
------------------------------------------------------------------
-- 建立 guest.name4  -- 用于快速的通用姓名检索
--	是否需要自动重建 name3 ? -- 自动增加拼音名 
------------------------------------------------------------------
--
-- 一般的姓名用法：
--		客人     ：name/name2=英文名/本名 lname/fname=姓/名  name3=辅助名
--									name			name2				name3
--						中国客人：英文名		中文名			中文拼音
--						欧美客人：英文名		中文名			中文拼音
--						日本客人：英文名		日本名			中文名		-- 此时似乎缺少一个中文拼音名

--		单位/团体：name/name2=英文名/中文名 name3=简称 lname/fname=不用
--
------------------------------------------------------------------
--	测试情况 
--
-- select '大洪是兰色的, 我的涯是喉色的' = upper('大海是兰色的, 我的心是红色的') from sysdata
-- select '90' = ascii ('Z'), 'Z' = char(90) from sysdata
-- name, fname, lname, name2, name3 -> name4 
-- 处理方法： asc>128, 直接放入 name4, 否则先 upper, 再放入 
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
-- 重建某个档案的 name4  
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

-- 姓\名 一般都包含到姓名字段了, 这里应该可以省略 
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
-- 重建所有档案的 name4  
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
		-- test speed：每完成 100 条记录，标示一下  
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
	
-- 姓\名 一般都包含到姓名字段了, 这里应该可以省略 
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
-- 建立 guest.name4  -- 补充遗漏部分 
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

-- 姓\名 一般都包含到姓名字段了, 这里应该可以省略 
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

