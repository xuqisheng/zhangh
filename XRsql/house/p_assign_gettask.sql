IF OBJECT_ID('dbo.p_assign_gettask') IS NOT NULL
    DROP PROCEDURE dbo.p_assign_gettask
;
create proc p_assign_gettask
as
declare
	@roomno	char(5),
	@pos1		int,
	@hall		char(1),
	@flr		char(3),
	@rmtype	char(5),
	@ocsta	char(1),
	@rmsta	char(1),
	@vip		char(15),
	@country	char(15),
	@tvip		char(3),
	@tcountry	char(3),
	@amenities	varchar(80),
	@amen		char(10),
	@today	datetime,

	@point	char(4),
	@points	money,
	@totalpoints	money,
	@tpoint	char(4),
	@catalog	char(5),
    @accntset varchar(70),
	@accnt	char(10)


create table #temp_assign(
roomno	char(5),
hall		char(1),
flr		char(3),
rmtype	char(5),
ocsta		char(1),
rmsta		char(1),
credits	money,
vip		char(15),
country	char(15),
totalpoints	money,
eccosta	char(3))

select @today=bdate from sysdata
select @totalpoints=0
----------------------20061201
declare @o_sta char(10),@v_sta char(10),@arg char(20),@position int
select @arg=beizhu from task_assignment where rmno='where'
select @position = charindex('V' , @arg)
if @position > 0
    begin
    select @v_sta = substring(@arg, @position + 1, datalength(@arg) - @position)
    select @arg = substring(@arg,1,@position -1)
    end
else
    select @position = datalength(@arg) + 1
if substring(@arg,1,1)='O'
    select @o_sta = substring(@arg,2,@position -2)
declare c_roomno cursor for
    select a.roomno from rmsta a where ((a.ocsta='O' and charindex(a.sta,@o_sta)>0) or (a.ocsta='V' and charindex(a.sta,@v_sta)>0))
    and not exists(select 1 from task_assignment b where a.roomno=b.rmno and b.checked='n') order by a.oroomno


declare c_buzhi cursor for
   	select amenities from master
   	where roomno=@roomno and amenities<>'' and (sta='I' or convert(char(10),arr)=convert(char(10),@today))
--declare c_roomno cursor for
--	select roomno from task_rooms
open c_roomno
fetch c_roomno into @roomno
--按房号提取住客信息，计算打扫积分
while @roomno!='' and @@sqlstatus=0
begin
select @roomno=roomno,@hall=hall,@flr=flr,@rmtype=type,@ocsta=ocsta,@rmsta=sta,@accntset=accntset
from rmsta
where roomno=@roomno

select @vip='',@country=''

while charindex('#',@accntset)>0 and @ocsta='O'
	begin
	select @accnt=substring(@accntset,1,charindex('#',@accntset)-1)
	select @accntset=substring(@accntset,charindex('#',@accntset)+1,datalength(@accntset))
	select @tvip=a.vip,@tcountry=a.nation from guest a,master b where a.no=b.haccnt and b.accnt=@accnt
	if @tvip!='0' and @tvip!=''
		select @vip ='★'--表示贵宾
	if @tcountry!='CN'
		select @country ='★'--表示外宾
    end

--积分：只要basecode表中有设置积分的项目，都累计
select @points=0
select @catalog='jifen'
select @point=descript from basecode --房态的积分
	where cat=@catalog and substring(code,1,2)=(@ocsta+@rmsta) and descript1='房态'
if @point!='' and not @point is null
	begin
	select @points=convert(float,@point)
	select @point=''
	end

if not exists( select 1 from sysoption where catalog='house' and item='credit')
    insert into sysoption(catalog,item,value,def,remark,remark1,addby,addtime,usermod,lic,cby,changed)
		select 'house','credit','T','T','','','CLG',@today,'T','','CLG',@today

if not exists( select 1 from sysoption where catalog='house' and item='credit' and value='F' )
    begin

    select @point=descript from basecode --房类的积分
    	where cat=@catalog and code=@rmtype and descript1='房类'
    if @point!='' and not @point is null
    	begin
    	select @points = @points + convert(float,@point)
    	select @point=''
    	end

    select @point='0'--布置
    open c_buzhi
    fetch c_buzhi into @amenities
    while @@sqlstatus=0
    	begin
    	while @amenities<>''
    		begin
    		select @pos1=charindex(',',@amenities)
	   	    if @pos1>0
	   		     begin
			     select @amen = substring(@amenities,1,@pos1 - 1)
			     select @amenities = substring(@amenities,@pos1+1,datalength(@amenities) - @pos1)
			     end
	       	else
		      	 begin
			     select @amen=@amenities
		         select @amenities=''
			     end
	       	select @tpoint=descript from basecode where cat=@catalog and code=@amen and descript1='布置'
		    if @tpoint!='' and @tpoint is not null
			     begin
			     select @points = @points + convert(float,@tpoint,1)
			     select @tpoint=''
			     end
	       	end
	    fetch c_buzhi into @amenities
	    end
    close c_buzhi

    if @country!=''--外宾的积分,外宾没有分类
	   begin
	   select @point=descript from basecode
	       	where cat=@catalog and code='外宾' and descript1='宾客'
    	if @point!='' and not @point is null
	       	begin
		    select @points = @points + convert(float,@point)
		    select @point=''
		    end
    	end

    if @vip!=''--贵宾等级的积分
	   begin
	   select @point='0'
	   select @accntset=accntset from rmsta where roomno=@roomno
       while charindex('#',@accntset)>0 and @ocsta='O'
        	begin
        	select @accnt=substring(@accntset,1,charindex('#',@accntset)-1)
        	select @accntset=substring(@accntset,charindex('#',@accntset)+1,datalength(@accntset))
        	select @tvip=a.vip from guest a,master b where a.no=b.haccnt and b.accnt=@accnt
   		    if @tvip!='0' and @tvip!=''
			     select @tpoint=descript from basecode
				    where cat=@catalog and code=@tvip and descript1='宾客'
    		if @tpoint!='' and not @tpoint is null and convert(float,@tpoint,1)>convert(float,@point)
	       		begin
		      	select @point=@tpoint
			    select @tpoint=''
			    end
	       	end
    	if @point<>'0'
	       	select @points = @points + convert(float,@point)
    	end
    end
select @totalpoints = @totalpoints + @points
insert #temp_assign values(@roomno,@hall,@flr,@rmtype,@ocsta,@rmsta,@points,@vip,@country,@totalpoints,'')

fetch c_roomno into @roomno
end
close c_roomno

deallocate cursor c_roomno
deallocate cursor c_buzhi

update #temp_assign set eccosta = b.eccocode from rmstamap b where #temp_assign.ocsta+#temp_assign.rmsta=b.code
update #temp_assign set eccosta='ED' from master a
	where a.sta='I' and a.roomno=#temp_assign.roomno and datediff(dd,a.dep,getdate())>=0

select * from #temp_assign
;
