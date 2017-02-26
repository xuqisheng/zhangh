drop proc p_clg_hsk_rmsta_report;
create proc p_clg_hsk_rmsta_report
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

---- 2003.5.3  针对确认预订和贵宾有不同的显示：确认==， 贵宾**
declare
   @brmno     char(5),
	@halls		varchar(30),
	@types		varchar(100)

create table #rmsta_list
(	roomno		char(5)			not null,
	rm_maint		varchar(50)		null  --维修房描述
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

select @halls=isnull(rtrim(halls),'#'), @types=isnull(rtrim(types),'#') from hall_station where pc_id=@pc_id
if @@rowcount=0
	select @halls='#', @types='#'

if @halls='#' and @types='#'
begin
	insert #rmsta_list(roomno) select roomno from rmsta
		where oroomno >= @brmno
			and (@stype='' or charindex(','+rtrim(type)+',', @stype)>0)
			and (@shall='' or charindex(','+rtrim(hall)+',', @shall)>0)
			and (@sflr='' or charindex(','+rtrim(flr)+',', @sflr)>0)
			and (@sfeature='' or feature like @sfeature)
end
else
begin
	if @shall='' and @halls<>'#'
		select @shall = @halls
	if @stype='' and @types<>'#'
		select @stype = @types
	insert #rmsta_list(roomno) select roomno from rmsta
		where oroomno >= @brmno
			and (@stype='' or charindex(','+rtrim(type)+',', @stype)>0)
			and (@shall='' or charindex(','+rtrim(hall)+',', @shall)>0)
			and (@sflr='' or charindex(','+rtrim(flr)+',', @sflr)>0)
			and (@sfeature='' or feature like @sfeature)
end

-- 交叉数据
if @term <> ''
	delete #rmsta_list where roomno not in (select roomno from hsmap_term_end where modu_id=@modu_id and pc_id=@pc_id and cat='4')

--modify by wz
if @langid = 0
	update #rmsta_list set rm_maint = isnull(convert(char(8),a.dbegin,11)+'-->'+convert(char(9),a.dend,11)+b.descript,'')
		from rm_ooo a,basecode b
		where #rmsta_list.roomno = a.roomno and a.status = 'I' -- and datediff(dd,getdate(),a.dend)>=0
			and a.reason = b.code and b.cat = 'rmmaint_reason'
else
	update #rmsta_list set rm_maint = isnull(convert(char(8),a.dbegin,11)+'-->'+convert(char(9),a.dend,11)+b.descript1,'')
		from rm_ooo a,basecode b
		where #rmsta_list.roomno = a.roomno and a.status = 'I'  -- and datediff(dd,getdate(),a.dend)>=0
			and a.reason = b.code and b.cat = 'rmmaint_reason'

update #rmsta_list set rm_maint = '★ ' + rm_maint from rmsta a where #rmsta_list.roomno = a.roomno and a.sta = 'O'
update #rmsta_list set rm_maint = '☆ ' + rm_maint from rmsta a,rm_ooo b where #rmsta_list.roomno = a.roomno and a.roomno = b.roomno and a.sta not in ('O','S') and  b.status = 'I' and b.sta='O'

update #rmsta_list set rm_maint = '◆ ' + rm_maint from rmsta a where #rmsta_list.roomno = a.roomno and a.sta = 'S'
update #rmsta_list set rm_maint = '◇ ' + rm_maint from rmsta a,rm_ooo b where #rmsta_list.roomno = a.roomno and a.roomno = b.roomno and a.sta not in ('O','S') and  b.status = 'I' and b.sta='S'

-- 输出数据
select a.roomno,b.type,b.hall,b.flr,b.ocsta,b.sta,b.tmpsta,substring(a.rm_maint,1,50),substring(b.feature,1,30),substring(b.ref,1,40),c.eccocode
	from #rmsta_list a, rmsta b,rmstamap c where a.roomno = b.roomno and b.ocsta+b.sta=c.code order by b.oroomno -- order by b.sequence,b.roomno


return 0;
