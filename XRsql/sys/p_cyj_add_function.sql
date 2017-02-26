
/*-------------------------------------------------------------------------------------------------------*/
// 增加系统功能类和功能
/*-------------------------------------------------------------------------------------------------------*/

if exists(select 1 from sysobjects where name = 'p_cyj_add_function' and type = 'P')
	drop proc p_cyj_add_function;
create proc p_cyj_add_function
	@type				char(1),        -- S: 增加类别，其他增加功能
	@funcsort		char(2),			
	@fun_des  		char(30),
	@descript  		char(30),
	@descript1  	char(30)
as

declare
			@funccode		char(4),
			@tmp				char(4)
if @type = 'S'
	insert into basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) select 'function_class', @funcsort, @descript, @descript1,'F','F',0,'', 'F'
else
	begin
		if exists(select 1 from sys_function where fun_des = @fun_des)       -- 已经存在
			return 
		select @funccode = max(code) from sys_function where class = @funcsort
		if @funccode  = '' or @funccode is null
			select @funccode = @funcsort + '00'
		else
			begin
			select @tmp = ltrim('00'+convert(char(2), convert(int,substring(@funccode, 3, 2)) + 1))
			select @tmp = substring(@tmp, datalength(@tmp) - 1, 2)
			select @funccode = substring(@funccode, 1, 2) +  @tmp
			end
		insert into sys_function(code,class,descript,descript1,fun_des) select @funccode, @funcsort, @descript, @descript1,@fun_des
	end;
