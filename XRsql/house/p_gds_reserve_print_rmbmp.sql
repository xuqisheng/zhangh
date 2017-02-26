------------------------------------------------------------------------------
--	按照楼层的，方格房态表
--		
--		print_rmbmp_new
--		p_gds_reserve_print_rmbmp
--		p_gds_reserve_print_rmbmp1
------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "print_rmbmp_new" and type = 'U')
   drop table print_rmbmp_new;
create table print_rmbmp_new
(
   pc_id      char(4),
   modu_id    char(2),
   oflr       char(3),
   flr        char(3),
   vc         int  default 0 not null,
   vd         int  default 0 not null,
   occ        int  default 0 not null,
   hu         int  default 0 not null,
   ooo        int  default 0 not null,
   oos        int  default 0 not null,
   ttl        int  default 0 not null
)
exec sp_primarykey print_rmbmp_new,pc_id,modu_id,flr
create unique index index1 on print_rmbmp_new(pc_id,modu_id,flr)
;


drop proc   p_gds_reserve_print_rmbmp
;
create  proc  p_gds_reserve_print_rmbmp
   @pc_id   char(4),
   @modu_id char(2),
   @hall    varchar(20), --add
   @flr_     varchar(60),
   @auto    char(1) --add, print as you see
as

declare
   @roomno   char(5),
   @oroomno  char(5),
   @flr      char(3),
   @oflr     char(3),
   @nopart   char(2),
   @nocnt    int,
   @ocsta    char(1),
   @sta 		char(1),
   @eccosta  char(3),
	@ptypes		varchar(255)

-- 假房显示参数
select @ptypes = ','+isnull((select rtrim(value) from sysoption where catalog='hotel' and item='proom_map'), '')+','

declare 	@wghall		varchar(30),
			@wgtype		varchar(100)
--select @wghall=rtrim(halls), @wgtype=(types) from hall_station where pc_id=@pc_id
--if @@rowcount = 1
--	begin
--	if @wghall is null
--		select @wghall = '%'
--	if @wgtype is null
--		select @wgtype = '%'
--	end
--else
	select @wghall='%', @wgtype='%'
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
		select @wghall=halls, @wgtype=types from hall_station_user where empno=@empno
		if @@rowcount = 0  
			select @wghall=halls, @wgtype=types from hall_station_user a, sys_empno b where a.empno=b.deptno and b.empno=@empno 
	end
	if @wghall = '-' select @wghall = ''
	if @wgtype = '-' select @wgtype = ''
	if @wghall = '' and @wgtype = ''
		select @wghall=halls, @wgtype=types from hall_station where pc_id = @pcid
end
if @wghall='' 
	select @wghall='%'
if @wgtype='' 
	select @wgtype='%'

create table #tmp(roomno char(5))
if @auto='T'
    begin
    insert into #tmp select a.roomno from hsmap_term_end a,hsmap b where a.pc_id = @pc_id and a.modu_id = @modu_id and b.pc_id = @pc_id and b.modu_id = @modu_id and a.roomno=b.roomno
    insert into #tmp select a.roomno from hsmap_term_end a,hsmap_new b where a.pc_id = @pc_id and a.modu_id = @modu_id and b.pc_id = @pc_id and b.modu_id = @modu_id and a.roomno=b.roomno
    end
else
    insert into #tmp select roomno from rmsta where (@wghall='%' or charindex(hall,@wghall)>0) and (@wgtype='%' or charindex(type,@wgtype)>0)
         and (rtrim(@flr_) is null or charindex(rtrim(flr),@flr_)>0) and (rtrim(@hall) is null or charindex(rtrim(hall),@hall)>0)
			and (tag='K' or (tag='P' and  charindex(','+rtrim(type)+',', @ptypes)>0))
	
delete nopart_count where pc_id = @pc_id and modu_id = @modu_id
delete print_rmbmp_new  where pc_id = @pc_id and modu_id = @modu_id

declare c_rmsta cursor for select a.roomno,a.oroomno,a.flr from rmsta a, #tmp b where a.roomno=b.roomno
	order by roomno
open  c_rmsta
fetch c_rmsta into @roomno,@oroomno,@flr
while @@sqlstatus = 0
   begin
   select @nopart = right(right(space(5)+rtrim(@roomno),5),2)
   --select @flr    = substring(right(space(5)+rtrim(@roomno),5),1,3)
   --select @oflr   = substring(right(space(5)+rtrim(@oroomno),5),1,3)
	--rmsta没有oflr字段，排序还是参照房态图，按实际flr排
	select @oflr=@flr
   if not exists ( select 1 from nopart_count where pc_id = @pc_id and modu_id = @modu_id and no = @nopart)
      insert nopart_count (pc_id,modu_id,no) values (@pc_id,@modu_id,@nopart)
   if not exists ( select 1 from print_rmbmp_new where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr)
      insert print_rmbmp_new (pc_id,modu_id,oflr,flr) values(@pc_id,@modu_id,@oflr,@flr)
   fetch c_rmsta into @roomno,@oroomno,@flr
   end
close c_rmsta
deallocate cursor c_rmsta


declare c_rmsta1 cursor for select a.roomno,a.oroomno,a.ocsta,a.sta,a.flr from rmsta a,#tmp b where a.roomno=b.roomno
		order by oroomno
open c_rmsta1
fetch c_rmsta1 into @roomno,@oroomno,@ocsta,@sta,@flr
while @@sqlstatus = 0
   begin
   select @nopart = right(right(space(5)+rtrim(@roomno),5),2)
   --select @flr    = substring(right(space(5)+rtrim(@roomno),5),1,3)
   --select @oflr   = substring(right(space(5)+rtrim(@oroomno),5),1,3)
	select @oflr=@flr
   select @nocnt  = nocnt from nopart_count where pc_id = @pc_id and modu_id = @modu_id and no = @nopart

   if @ocsta = 'V' and (@sta = 'R' or @sta='I')
      update print_rmbmp_new set vc = vc + 1    where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @ocsta = 'V' and @sta = 'D'
      update print_rmbmp_new set vd = vd + 1    where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
	else if exists (select 1 from master a, mktcode b where a.sta = 'I' and a.market = b.code and b.flag='HSE' and a.roomno = @roomno)
      update print_rmbmp_new set hu = hu + 1    where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @sta = 'O'
      update print_rmbmp_new set ooo = ooo + 1  where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @sta = 'S'
      update print_rmbmp_new set oos = oos + 1  where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @ocsta = 'O'
      update print_rmbmp_new set occ = occ + 1  where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr

   fetch c_rmsta1 into @roomno,@oroomno,@ocsta,@sta,@flr
   end
close c_rmsta1
deallocate cursor c_rmsta1

update print_rmbmp_new set ttl = vc+vd+occ+hu+ooo+oos where pc_id = @pc_id and modu_id = @modu_id

select oflr,flr,vc,vd,occ,hu,ooo,oos,ttl from print_rmbmp_new where pc_id = @pc_id and modu_id = @modu_id order by oflr
return 0
;

if object_id('p_gds_reserve_print_rmbmp1') is not null
drop proc p_gds_reserve_print_rmbmp1
;
create  proc  p_gds_reserve_print_rmbmp1
    @pc_id  char(4),
    @modu_id char(2),
    @hall varchar(20),
   @oflr  char(3),
   @auto    char(1)
as
declare	@ptypes		varchar(255)

-- 假房显示参数
select @ptypes = ','+isnull((select rtrim(value) from sysoption where catalog='hotel' and item='proom_map'), '')+','
declare 	@wghall		varchar(30),
			@wgtype		varchar(100)
select @wghall='%', @wgtype='%'
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
		select @wghall=halls, @wgtype=types from hall_station_user where empno=@empno
		if @@rowcount = 0  
			select @wghall=halls, @wgtype=types from hall_station_user a, sys_empno b where a.empno=b.deptno and b.empno=@empno 
	end
	if @wghall = '-' select @wghall = ''
	if @wgtype = '-' select @wgtype = ''
	if @wghall = '' and @wgtype = ''
		select @wghall=halls, @wgtype=types from hall_station where pc_id = @pcid
end
if @wghall='' 
	select @wghall='%'
if @wgtype='' 
	select @wgtype='%'

create table #tmp(roomno char(5))
if @auto='T'
    begin
    insert into #tmp select a.roomno from hsmap_term_end a,hsmap b where a.pc_id = @pc_id and a.modu_id = @modu_id and b.pc_id = @pc_id and b.modu_id = @modu_id and a.roomno=b.roomno and b.flr=rtrim(@oflr)
    insert into #tmp select a.roomno from hsmap_term_end a,hsmap_new b where a.pc_id = @pc_id and a.modu_id = @modu_id and b.pc_id = @pc_id and b.modu_id = @modu_id and a.roomno=b.roomno and b.flr=rtrim(@oflr)
    end
else
    insert into #tmp select roomno from rmsta where (@wghall='%' or charindex(hall,@wghall)>0) and (@wgtype='%' or charindex(type,@wgtype)>0)
         and flr=rtrim(@oflr) and (rtrim(@hall) is null or charindex(hall,rtrim(@hall))>0)
			and (tag='K' or (tag='P' and  charindex(','+rtrim(type)+',', @ptypes)>0))

create table #map
(
	roomno		char(5),
	ocsta			char(1),
	sta			char(1),
	refer			varchar(20)
)

insert #map select a.roomno, a.ocsta, a.sta, ''
	from rmsta a, #tmp b		where a.roomno=b.roomno
			
update #map set refer = 'OCC' where ocsta = 'O'
update #map set refer = 'OCC|OO' where ocsta ='O' and (sta = 'O' or sta = 'S')
update #map set refer = 'OO' where ocsta <> 'O' and sta = 'O'
update #map set refer = 'OS' where ocsta <> 'O' and sta = 'S'
update #map set refer = 'DI'  where ocsta = 'V' and sta ='D'
update #map set refer = 'CL'  where ocsta = 'V' and sta in ('R','I')

update #map set refer=refer+'→' from master a
	where a.sta='I' and a.roomno=#map.roomno and datediff(dd,a.dep,getdate())>=0

update #map set refer=refer+'←' from master a
	where charindex(a.sta,'RCG')>0 and a.roomno=#map.roomno and datediff(dd,a.arr,getdate())>=0

update #map set refer=refer+'★' from master a, guest b
	where charindex(a.sta,'IRCG')>0 and a.roomno=#map.roomno and datediff(dd,a.arr,getdate())>=0 and a.haccnt=b.no and b.vip>'0'

update #map set refer=refer+'※' from master a
	where charindex(a.sta,'I')>0 and a.roomno=#map.roomno and a.market='LON'

update #map set refer=refer+'◎' from master a, guest b
	where charindex(a.sta,'IRCG')>0 and a.roomno=#map.roomno and datediff(dd,a.arr,getdate())>=0 and a.haccnt=b.no and b.i_times>0


select roomno, refer from #map order by roomno

return 0
;