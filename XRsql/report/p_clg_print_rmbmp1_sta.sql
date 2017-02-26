IF OBJECT_ID('dbo.p_clg_print_rmbmp1_sta') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_print_rmbmp1_sta
;
create  proc  p_clg_print_rmbmp1_sta
	@pc_id	char(4),
   @hall    varchar(20),
	@flr_		char(3),
   @osta 	char(3),
   @auto    char(1)
as
declare	@roomno   char(5),
   @ptypes		varchar(255),
   @ocsta    char(1),
   @sta 		char(1),
   @eccosta  char(3)

-- 假房显示参数
select @ptypes = ','+isnull((select rtrim(value) from sysoption where catalog='hotel' and item='proom_map'), '')+','

declare 	@wghall		varchar(30),
			@wgtype		varchar(100)
select @wghall='%', @wgtype='%'
create table #tmp(roomno char(5))
if @auto='T'
    begin
    insert into #tmp select a.roomno from hsmap_term_end a,hsmap b where a.pc_id = @pc_id and a.modu_id = '01' and b.pc_id = @pc_id and b.modu_id = '01' and a.roomno=b.roomno
    insert into #tmp select a.roomno from hsmap_term_end a,hsmap_new b where a.pc_id = @pc_id and a.modu_id = '01' and b.pc_id = @pc_id and b.modu_id = '01' and a.roomno=b.roomno
    end
else
    insert into #tmp select roomno from rmsta
create table #map
(
	roomno		char(5),
	ocsta			char(1),
	sta			char(1),
	refer			varchar(20)
)

declare c_rmsta cursor for select a.roomno,a.ocsta,a.sta
	from rmsta a,#tmp b
	where (@wghall='%' or charindex(a.hall,@wghall)>0) and (@wgtype='%' or charindex(a.type,@wgtype)>0)
         and (rtrim(@flr_) is null or charindex(rtrim(a.flr),@flr_)>0) and (rtrim(@hall) is null or charindex(rtrim(a.hall),@hall)>0)
			and (a.tag='K' or (a.tag='P' and  charindex(','+rtrim(a.type)+',', @ptypes)>0)) and a.roomno=b.roomno
	order by roomno
open  c_rmsta
fetch c_rmsta into @roomno,@ocsta,@sta
while @@sqlstatus = 0
   begin
	if exists ( select 1 from rmstamap where code = @ocsta+@sta and eccocode = @osta)
      insert #map select @roomno, @ocsta, @sta, ''
   fetch c_rmsta into @roomno,@ocsta,@sta
   end
close c_rmsta
deallocate cursor c_rmsta

update #map set refer = 'OCC' where ocsta = 'O'
update #map set refer = 'OCC|OO' where ocsta ='O' and (sta = 'O' or sta = 'S')
update #map set refer = 'OO' where ocsta <> 'O' and sta = 'O'
update #map set refer = 'OS' where ocsta <> 'O' and sta = 'S'
update #map set refer = 'DI'  where ocsta = 'V' and sta ='D'
update #map set refer = 'CL'  where ocsta = 'V' and sta ='R'

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