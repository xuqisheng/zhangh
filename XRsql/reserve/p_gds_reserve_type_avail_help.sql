if  exists(select * from sysobjects where name = "p_gds_reserve_type_avail_help" and type = "P")
	drop proc p_gds_reserve_type_avail_help;
create proc p_gds_reserve_type_avail_help
	@s_time			datetime,
	@e_time			datetime,
	@langid			int = 0
as
-- ------------------------------------------------------------------------------------
--  房类帮助 - 包含可用数目
--		调用 p_gds_reserve_type_avail  
-- ------------------------------------------------------------------------------------
create table #goutput(
	type		char(5)			not null,
	descript	varchar(30)		not null,
	value		int	default 0	null,
	sequence	int	default 0	null
)

declare	@type			char(5),
			@descript	varchar(30),
			@value		int,
			@sequence	int


-- 客房范围处理 
declare	@empno			char(10),
			@shift			char(1),
			@pc_id			char(4),
			@appid			char(1),
			@ret				int,
			@types			varchar(255),
			@ghall			varchar(255),
			@gtype			varchar(255)

select @types='', @ghall='', @gtype='' 
exec @ret = p_gds_get_login_info 'R', @empno output, @shift output, @pc_id output, @appid output 
if @ret=0 
begin 
	if exists(select 1 from sysoption where catalog='hotel' and item='emp_rm_scope' and value='T') 
	begin 
		select @ghall=halls, @gtype=types from hall_station_user where empno=@empno
		if @@rowcount = 0  
			select @ghall=halls, @gtype=types from hall_station_user a, sys_empno b where a.empno=b.deptno and b.empno=@empno 
	end
	if @ghall = '-' select @ghall = ''
	if @gtype = '-' select @gtype = ''
	if @ghall = '' and @gtype = ''
		select @ghall=halls, @gtype=types from hall_station where pc_id = @pc_id
end

--
create table #type (type char(5)  not null) 
insert #type select distinct type from rmsta where tag='K' and (@ghall='' or charindex(hall,@ghall)>0) and (@gtype='' or charindex(','+rtrim(type)+',',','+@gtype+',')>0) 

-- 
select @type = min(type) from #type 
while @type is not null
begin
	if @langid = 0
		insert #goutput(type,descript,sequence) select type,descript,sequence from typim where type=@type
	else
		insert #goutput(type,descript,sequence) select type,descript1,sequence from typim where type=@type

	exec p_gds_reserve_type_avail @type,@s_time,@e_time,'0','R',@value output
	update #goutput set value=@value where type=@type

	select @type = min(type) from #type where type>@type
end

select type,descript,value from #goutput order by sequence, type

return 0
;

exec p_gds_reserve_type_avail_help '2003.10.20', '2003.10.22';