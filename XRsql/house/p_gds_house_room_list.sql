if object_id('p_gds_house_room_list') is not null
	drop proc p_gds_house_room_list;
create proc p_gds_house_room_list
	@modu_id		char(2),
	@pc_id		char(4),
	@term			char(2),
	@shall		varchar(20),
	@sflr			varchar(30),
   @stype    	varchar(255),
   @brm_no		char(5),
	@sfeature	varchar(30),
	@langid		integer
as
----------------------------------------------------------------------------------
--	客房中心 - 房态管理 - 客房列表
----------------------------------------------------------------------------------

---- 2003.5.3  针对确认预订和贵宾有不同的显示：确认==， 贵宾**
declare
   @brmno      char(5),
	@halls		varchar(255),
	@types		varchar(255),
	@ptypes		varchar(255)

-- 假房显示参数
select @ptypes = ','+isnull((select rtrim(value) from sysoption where catalog='hotel' and item='proom_hsk'), '')+','

--
create table #rmsta_list
(	roomno		char(5)			not null,
	rm_maint		varchar(100)		null,  --维修房描述
	discsta		char(1)				null	-- 矛盾房状态 
)

-- 起始房号
if rtrim(@brm_no) is not null
   begin
   select @brmno = min(roomno) from rmsta where roomno >= @brm_no
 if @brmno is null
	  select @brmno = min(oroomno) from rmsta
   else
      select @brmno = oroomno from rmsta where roomno = @brmno
   end
else
   select @brmno = ''

if rtrim(@shall) is null
	select @shall = ''
else
	select @shall = ','+rtrim(@shall)+','
if rtrim(@sflr) is null
	select @sflr = ''
else
	select @sflr = ','+rtrim(@sflr)+','
if rtrim(@stype) is null
	select @stype = ''
else
	select @stype = ','+rtrim(@stype)+','
if rtrim(@sfeature) is null
	select @sfeature = ''

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
	insert #rmsta_list(roomno) select roomno from rmsta
		where oroomno >= @brmno
			and (@stype='' or charindex(','+rtrim(type)+',', ','+@stype+',')>0)
			and (@shall='' or charindex(','+rtrim(hall)+',', ','+@shall+',')>0)
			and (@sflr='' or charindex(','+rtrim(flr)+',', @sflr)>0)
			and (@sfeature='' or feature like @sfeature)
			and (tag<>'P' or (tag='P' and  charindex(','+rtrim(type)+',', @ptypes)>0)) 
end
else
begin
	if @shall='' and @halls<>'#' 
		select @shall = @halls
	if @stype='' and @types<>'#' 
		select @stype = @types
	insert #rmsta_list(roomno) select roomno from rmsta
		where oroomno >= @brmno
			and (@stype='' or charindex(','+rtrim(type)+',', ','+@stype+',')>0)
			and (@shall='' or charindex(','+rtrim(hall)+',', ','+@shall+',')>0)
			and (@sflr='' or charindex(','+rtrim(flr)+',', @sflr)>0)
			and (@sfeature='' or feature like @sfeature)
			and (tag<>'P' or (tag='P' and  charindex(','+rtrim(type)+',', @ptypes)>0)) 
end

-- 交叉数据
if @term <> ''
	delete #rmsta_list where roomno not in (select roomno from hsmap_term_end where modu_id=@modu_id and pc_id=@pc_id and cat='2')

--modify by wz
if @langid = 0 
	update #rmsta_list set rm_maint = isnull(convert(char(10),a.dbegin,11)+'-->'+convert(char(10),a.dend,11)+ '   原因：'+b.descript +'   备注：'+isnull(a.remark,''),'')   
		from rm_ooo a,basecode b 
		where #rmsta_list.roomno = a.roomno and a.status = 'I' -- and datediff(dd,getdate(),a.dend)>=0 
			and a.reason = b.code and b.cat = 'rmmaint_reason'
else
	update #rmsta_list set rm_maint = isnull(convert(char(10),a.dbegin,11)+'-->'+convert(char(10),a.dend,11)+ '   Reason：'+b.descript1 +'   Remark：'+isnull(a.remark,''),'')   
		from rm_ooo a,basecode b 
		where #rmsta_list.roomno = a.roomno and a.status = 'I'  -- and datediff(dd,getdate(),a.dend)>=0 
			and a.reason = b.code and b.cat = 'rmmaint_reason'

update #rmsta_list set rm_maint = '   ★      ' + rm_maint from rmsta a where #rmsta_list.roomno = a.roomno and a.sta = 'O'
update #rmsta_list set rm_maint = '   ☆      ' + rm_maint from rmsta a,rm_ooo b where #rmsta_list.roomno = a.roomno and a.roomno = b.roomno and a.sta not in ('O','S') and  b.status = 'I' and b.sta='O'

update #rmsta_list set rm_maint = '   ◆      ' + rm_maint from rmsta a where #rmsta_list.roomno = a.roomno and a.sta = 'S'
update #rmsta_list set rm_maint = '   ◇      ' + rm_maint from rmsta a,rm_ooo b where #rmsta_list.roomno = a.roomno and a.roomno = b.roomno and a.sta not in ('O','S') and  b.status = 'I' and b.sta='S'

update #rmsta_list set discsta = a.hs_sta from discrepant_room a where #rmsta_list.roomno=a.roomno and a.sta='I' 

-- 输出数据
select a.roomno,b.type,b.hall,b.flr,b.ocsta,b.sta,b.tmpsta,a.rm_maint,b.feature,b.ref,b.ocsta+b.sta, isnull(a.discsta,b.ocsta), b.s1 
	from #rmsta_list a, rmsta b where a.roomno = b.roomno order by b.oroomno -- order by b.sequence,b.roomno


return 0
;
