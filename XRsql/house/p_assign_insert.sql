IF OBJECT_ID('dbo.p_assign_insert') IS NOT NULL
    DROP PROCEDURE dbo.p_assign_insert
;
create proc p_assign_insert
	@roomno	char(5),
	@points	money,
	@attid	varchar(255),
	@empno	char(5),
	@chgtime	datetime,
	@auto		char(1) --自动T拖动F
as
declare
	@hall			char(1),
	@flr			char(3),
	@rmtype		char(5),
	@ocsta		char(1),
	@rmsta		char(1),
	@newsta		char(1),
	@guestname	char(60),
	@vip			char(15),
	@country		char(15),
	@tguestname	char(50),
	@tvip			char(3),
	@tcountry	char(3),
	@tamenities	varchar(80),
	@amen			char(10),
	@amenities	varchar(80),
	@accnt      char(10),   -- 账号 add by hxw

	@no			int,
	@pos			int,
	@id			char(10),
	@attname		char(10),
	@jineng		money,
	@jineng_t	char(2),
	@capable		money,
	@english		int,
	@foreigner	char(1)

/*用窗口的按技能限制替代if @auto='T'
    begin
    if not exists( select 1 from sysoption where catalog='house' and item='task')
        insert into sysoption(catalog,item,value,def,remark,remark1,addby,addtime,usermod,lic,cby,changed)
				select 'house','task','T','T','','','CLG',getdate(),'T','','CLG',getdate()
    if exists( select 1 from sysoption where catalog='house' and item='task' and value='F')
        select @auto='F'
    end
*/
select @jineng=0
-----------
if exists(select 1 from master where roomno=@roomno and sta='I')
    declare c_guest cursor for
	select b.accnt, a.name,a.vip,a.nation from guest a,master b where b.roomno=@roomno and a.no=b.haccnt and b.sta='I'

else
    declare c_guest cursor for
	select b.accnt, a.name,a.vip,a.nation from guest a,master b where b.roomno=@roomno and a.no=b.haccnt and b.sta='R' and datediff(dd,b.arr,getdate())=0

open c_guest
fetch c_guest into @accnt,@tguestname,@tvip,@tcountry
while @@sqlstatus=0
	begin
	if @tvip!='0' and @tvip!=''
		begin
		select @vip = @vip + @tvip
		select @jineng_t=descript from basecode where cat='jineng' and code=@tvip and descript1="宾客"
		if @jineng_t!='' and @jineng_t is not null and @jineng<convert(money,@jineng_t)
			select @jineng=convert(money,@jineng_t)
		end

	if @tcountry!='CN'
		begin
		select @country = @country + @tcountry
		select @foreigner='Y'
		end
	select @vip = @vip + ','
	select @country = @country + ','
	select @guestname = @guestname + @tguestname + ','
	fetch c_guest into @accnt, @tguestname,@tvip,@tcountry
	end
close c_guest
deallocate cursor c_guest

declare c_buzhi cursor for
	select amenities from master
		where roomno=@roomno and amenities<>'' and (convert(char(10),arr)=convert(char(10),@chgtime) or sta='I')
open c_buzhi
fetch c_buzhi into @tamenities
while @@sqlstatus=0
	begin
	select @amenities = @amenities + @tamenities +','
	while @tamenities<>'' and @auto='T'
		begin
		select @pos=charindex(',',@tamenities)
		if @pos>0
			begin
			select @amen = substring(@tamenities,1,@pos - 1)
			select @tamenities = substring(@tamenities,@pos+1,datalength(@tamenities) - @pos)
			end
		else
			begin
			select @amen=@tamenities
			select @tamenities=''
			end
		select @jineng_t=descript from basecode where cat='jineng' and code=@amen and descript1='布置'
		if @jineng_t!='' and @jineng_t is not null and @jineng<convert(money,@jineng_t)
			select @jineng=convert(money,@jineng_t)
		end
	fetch c_buzhi into @tamenities
	end
close c_buzhi
deallocate cursor c_buzhi

if @auto='T'
begin
select @rmtype = type from rmsta where roomno=@roomno
select @jineng_t=descript from basecode where cat='jineng' and code=@rmtype and descript1="房类"
if @jineng_t!='' and @jineng_t is not null and @jineng<convert(money,@jineng_t)
	select @jineng=convert(money,@jineng_t)
end

select @pos=charindex(';',@attid)
while @pos>0
	begin
	select @id=substring(@attid,1,@pos - 1)
	select @attid=substring(@attid,@pos + 1,datalength(@attid) - @pos)
	select @pos=charindex(';',@attid)

	select @attname=name,@english=english,@capable=capability from attendant_info where id=@id

	if @foreigner!='Y' or @english>=2 or @auto='F'
		begin
		if @capable>=@jineng or @auto='F'
			begin
			select @rmtype=type,@hall=hall,@flr=flr,@ocsta=ocsta,@rmsta=sta from rmsta where roomno=@roomno
			select @no=max(no)+1 from task_assignment
			--if @rmsta='D'
			--	select @newsta='R'
			--else
			--	select @newsta=@rmsta

            if @rmsta in ('O','S')
                select @newsta = @rmsta
            else
                begin
                select @newsta=value from sysoption where catalog='house' and item='work_change_sta'
    			if @newsta not in('D','T','I','R')
	       			select @newsta='R'
                end

			if @country=',' or @country=',,' or @country=',,,'
				select @country=''
			if @vip=',' or @vip=',,' or @vip=',,,'
				select @vip=''

			insert into task_assignment(no,rmno,rmtype,lou,floor,guestname,vip,foreigner,rmamenities,rmsta,points,attendantid,attendantname,checked,assigntime,assignman,ocsta,newsta,changetime,changer,accnt)
									values (@no,@roomno,@rmtype,@hall,@flr,@guestname,@vip,@country,@amenities,@rmsta,@points,@id,@attname,'n',@chgtime,@empno,@ocsta,@newsta,@chgtime,@empno,@accnt)
			return
			end
		end
	end

--调试
--exec p_assign_insert @roomno='3031',@points=2,@attid='9;',@empno='1',@chgtime='2006-03-01',@auto='F'
--delete from task_assignment where checked='n'
--select * from task_assignment where checked='n'
;
