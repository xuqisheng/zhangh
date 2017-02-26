if exists (select 1 from sysobjects where name = 'p_gds_house_map_create')
	drop proc p_gds_house_map_create
;
create proc  p_gds_house_map_create 
	@pc_id			char(4),
	@modu_id			char(2),
	@type				char(5) = '#####',  --  房类
	@hall				varchar(20) = '#',	
	@flr				char(3) = '###',	
	@sep				char(1) = 'F',
	@accnt			char(7) = ''
as
--------------------------------------------------------------------------------
--		X5 客房部房态表 - 2  --  速度很关键
--
--		对每一种状态都要定义一个基本色,然后加以变化
-- 	这里如果用光标,速度很慢 !!!
--
--------------------------------------------------------------------------------
declare 	
			@ocsta	char(1),
			@sta		char(1),
			@tmpsta	char(1),
			@f4		char(1),
			@f3		char(1),
			@f2		char(1),
			@f1		char(1),
			@accntset	varchar(70)
declare 
			@roomno	char(5),
			@base		char(1),
			@day		int,
			@needbu	char(1),		-- 需要补吗 ?
			@halls	varchar(30),
			@types	varchar(100),
			@ptypes		varchar(255)	-- 假房显示房类 

-- 假房显示参数
select @ptypes = ','+isnull((select rtrim(value) from sysoption where catalog='hotel' and item='proom_map'), '')+','

-- 
if substring(@accnt,1,1)='B' 
	begin
	select @needbu = 'T'
	select @accnt = rtrim(substring(@accnt,2,6))
	end
else
	select @needbu = 'F'
select @day = isnull(convert(int, @accnt), 0)
select @roomno='', @base=''

delete hsmap where pc_id=@pc_id and modu_id=@modu_id
delete hsmap_des where pc_id=@pc_id and modu_id=@modu_id

-- 插入基本数据 -- 同时也代表基本的一类情况 - 注意是否有站点控制 
select @halls='', @types='' 
-- 客房范围处理 
declare	@empno			char(10),
			@shift			char(1),
			@pcid				char(4),
			@appid			char(1),
			@ret				int
exec @ret = p_gds_get_login_info 'R', @empno output, @shift output, @pcid output, @appid output 
if @ret=0 
begin 
	if exists(select 1 from sysoption where catalog='hotel' and item='emp_rm_scope' and value='T') 
	begin 
		select @halls=halls, @types=types from hall_station_user where empno=@empno
		if @@rowcount = 0  
			select @halls=halls, @types=types from hall_station_user a, sys_empno b where a.empno=b.deptno and b.empno=@empno 
	end
	if @halls = '-' select @halls = ''
	if @types = '-' select @types = ''
	if @halls = '' and @types = ''
		select @halls=halls, @types=types from hall_station where pc_id = @pcid
end
if @halls='' 
	select @halls='#'
if @types='' 
	select @types='#'

if @halls='#' and @types='#' 
begin
	insert hsmap select @pc_id, @modu_id, a.roomno, a.oroomno, a.flr,'F','0', '', '', '','',0,0,0,0,0,0,0,0,0,0,0 
		from rmsta a, hsmap_term_end b 
		where b.modu_id=@modu_id and b.pc_id=@pc_id and a.roomno=b.roomno and b.cat='1'
			and (@type='#####' or @type=a.type) 
			and (@hall ='#' or charindex(a.hall,@hall)>0) 
			and (@flr='###' or a.flr=@flr)
			and (a.tag<>'P' or (a.tag='P' and  charindex(','+rtrim(a.type)+',', @ptypes)>0)) 
end 
else
begin
	if @hall='#' and @halls<>'#' 
		select @hall = @halls
	if @types<>'#' 
		select @types=','+@types+',' 
	insert hsmap select @pc_id, @modu_id, a.roomno, a.oroomno, a.flr,'F','0', '', '', '','',0,0,0,0,0,0,0,0,0,0,0 
		from rmsta a, hsmap_term_end b 
		where b.modu_id=@modu_id and b.pc_id=@pc_id and a.roomno=b.roomno and b.cat='1'
			and ((@type='#####' and (@types='#' or charindex(','+rtrim(a.type)+',',@types)>0)) or @type=a.type) 
			and (@hall ='#' or charindex(a.hall,@hall)>0) 
			and (@flr='###' or a.flr=@flr)
			and (a.tag<>'P' or (a.tag='P' and  charindex(','+rtrim(a.type)+',', @ptypes)>0)) 
end 

--	-- 干净的空房
--	update hsmap set base = '0' from rmsta a 
--		where hsmap.roomno=a.roomno and a.ocsta='V' and a.sta='R'
--				and hsmap.pc_id=@pc_id and hsmap.modu_id=@modu_id
-- 脏的空房
update hsmap set base = '1' from rmsta a 
	where hsmap.roomno=a.roomno and a.ocsta='V' and a.sta not in ('R','I')
			and hsmap.pc_id=@pc_id and hsmap.modu_id=@modu_id
-- 住房 oc
update hsmap set base = '2' from rmsta a, master b 
	where hsmap.roomno=a.roomno and a.roomno = b.roomno and a.ocsta='O' and b.sta='I' and b.class<>'Z' and a.sta in ('R','I')
		and hsmap.pc_id=@pc_id and hsmap.modu_id=@modu_id
-- 住房 od
update hsmap set base = '3' from rmsta a, master b 
	where hsmap.roomno=a.roomno and a.roomno = b.roomno and a.ocsta='O' and b.sta='I' and b.class<>'Z' and a.sta not in ('R','I')
		and hsmap.pc_id=@pc_id and hsmap.modu_id=@modu_id
-- 其他房间 - M,B,...
update hsmap set base = '4' from rmsta a 
	where hsmap.roomno=a.roomno and a.ocsta='V' and a.sta not in ('D','R','I','T')
			and hsmap.pc_id=@pc_id and hsmap.modu_id=@modu_id
-- 自用房
update hsmap set base = '5' from rmsta a, master b, mktcode c 
	where hsmap.roomno=a.roomno and a.roomno = b.roomno and a.ocsta='O' and b.sta='I' and b.market=c.code and c.flag='HSE'
		and hsmap.pc_id=@pc_id and hsmap.modu_id=@modu_id

-- 临时态
update hsmap set ad1 = '1' from rmsta 
	where hsmap.roomno=rmsta.roomno and (rtrim(rmsta.tmpsta) is not null) 
		and hsmap.pc_id=@pc_id and hsmap.modu_id=@modu_id
-- 将来
update hsmap set ad2 = '1' from rmsta a, master b 
	where hsmap.roomno=a.roomno and a.roomno = b.roomno and charindex(b.sta,'RCG')>0 
		and datediff(dd,getdate(),b.arr)<=@day
		and hsmap.pc_id=@pc_id and hsmap.modu_id=@modu_id
-- 将走
update hsmap set ad3 = '1' from rmsta a, master b 
		where hsmap.roomno=a.roomno and a.roomno = b.roomno and b.sta='I' and datediff(dd,getdate(),b.dep)<=0
		and hsmap.pc_id=@pc_id and hsmap.modu_id=@modu_id

insert hsmap_des select @pc_id, @modu_id, 'CL', 'DI', 'OC', 'OD', 'OO', 'HU', '', '', 'TP','EA', 'ED'

update hsmap set num0 = 1 where base = '0' and modu_id=@modu_id and pc_id=@pc_id
update hsmap set num1 = 1 where base = '1' and modu_id=@modu_id and pc_id=@pc_id
update hsmap set num2 = 1 where base = '2' and modu_id=@modu_id and pc_id=@pc_id
update hsmap set num3 = 1 where base = '3' and modu_id=@modu_id and pc_id=@pc_id
update hsmap set num4 = 1 where base = '4' and modu_id=@modu_id and pc_id=@pc_id
update hsmap set num5 = 1 where base = '5' and modu_id=@modu_id and pc_id=@pc_id
update hsmap set num6 = 1 where base = '6' and modu_id=@modu_id and pc_id=@pc_id
update hsmap set num7 = 1 where base = '7' and modu_id=@modu_id and pc_id=@pc_id
update hsmap set adn1 = 1 where ad1  = '1' and modu_id=@modu_id and pc_id=@pc_id
update hsmap set adn2 = 1 where ad2  = '1' and modu_id=@modu_id and pc_id=@pc_id
update hsmap set adn3 = 1 where ad3  = '1' and modu_id=@modu_id and pc_id=@pc_id

if @sep = 'T'  -- 补虚拟房号
begin
	if @needbu='T'
		exec p_gds_house_map_bu @modu_id, @pc_id
	insert hsmap select @pc_id, @modu_id, oroomno, oroomno, flr, 'T', '0', '', '', '','',0,0,0,0,0,0,0,0,0,0,0 
		from hsmap_bu where modu_id=@modu_id and pc_id=@pc_id
end

select roomno, base, bu, ad1, ad2, ad3, box,num0,num1,num2,num3,num4,num5,num6,num7,adn1, adn2 , adn3 
	from hsmap where pc_id=@pc_id and modu_id=@modu_id 
			order by flr,roomno 

return 0
;
