IF OBJECT_ID('dbo.p_clg_vacant_rooms') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_vacant_rooms
;
create proc p_clg_vacant_rooms
	@shall	char(20),
    @sflr   char(50),
	@stype	char(100),
	@brmno	char(5),
	@trmno	char(5),
	@sta		char(1),
	@days		int
as
declare
	@roomno	char(5),
	@accnt char(10),
	@bdate	datetime
create table #rmsta_list
(	roomno		char(5)			not null,
	name			char(50) null,
	arr			datetime null,
	dep			datetime null,
	status		char(10) null,
	adlts			int null,
	child			int null,
	block			datetime null  --next blocked
)

if @sta='A' or @sta='V'
insert #rmsta_list(roomno) select roomno from rmsta
	where (@brmno='' or roomno >= @brmno) and (@trmno='' or roomno <=@trmno)
		and (@stype='' or charindex(','+rtrim(type)+',', @stype)>0)
		and (@shall='' or charindex(','+rtrim(hall)+',', @shall)>0)
        and (@sflr='' or charindex(','+rtrim(flr)+',', @sflr)>0)
		and datediff(dd,changed,getdate())>=@days
		and ocsta = 'V' and tag='K'
if @sta='A' or @sta='O'
insert #rmsta_list(roomno) select roomno from rmsta
	where (@brmno='' or roomno >= @brmno) and (@trmno='' or roomno <=@trmno)
		and (@stype='' or charindex(','+rtrim(type)+',', @stype)>0)
		and (@shall='' or charindex(','+rtrim(hall)+',', @shall)>0)
        and (@sflr='' or charindex(','+rtrim(flr)+',', @sflr)>0)
		and ocsta = 'O' and tag='K'
--新增预定也会导致rmsta修改
if @sta = 'V'
    begin
    declare c_rmcur cursor for select roomno from rmsta
        where (@brmno='' or roomno >= @brmno) and (@trmno='' or roomno <=@trmno)
		and (@stype='' or charindex(','+rtrim(type)+',', @stype)>0)
		and (@shall='' or charindex(','+rtrim(hall)+',', @shall)>0)
        and (@sflr='' or charindex(','+rtrim(flr)+',', @sflr)>0)
		and datediff(dd,changed,getdate())<@days
		and ocsta = 'V' and tag='K'
    open c_rmcur
    fetch c_rmcur into @roomno
    while @@sqlstatus=0
        begin
        if not exists(select 1 from hmaster where roomno=@roomno and sta='O' and datediff(dd,dep,getdate())<@days) and not exists(select 1 from master where roomno=@roomno and (sta='O' or sta='S') and datediff(dd,dep,getdate())<@days)
            insert into #rmsta_list(roomno) select @roomno
        fetch c_rmcur into @roomno
        end
    close c_rmcur
    deallocate cursor c_rmcur
    end

select @bdate=bdate from sysdata

declare c_rmno cursor for select roomno from rmsta
open c_rmno
fetch c_rmno into @roomno
while @@sqlstatus=0
	begin
	if exists(select 1 from master where roomno=@roomno and sta='I')
		begin
		select @accnt=accnt from master where roomno=@roomno and sta='I'
		update #rmsta_list set arr=a.arr,dep=a.dep,name=a.haccnt,status=a.sta,adlts=b.gstno,child=b.children from master_des a,master b where #rmsta_list.roomno=@roomno and a.accnt=@accnt and a.accnt=b.accnt
		end
	else if exists(select 1 from master where roomno=@roomno and sta='R' and datediff(dd,arr,@bdate)=0)
		begin
		select @accnt=accnt from master where roomno=@roomno and sta='R' and datediff(dd,arr,@bdate)=0
		update #rmsta_list set arr=a.arr,dep=a.dep,name=a.haccnt,status=a.sta,adlts=b.gstno,child=b.children from master_des a,master b where #rmsta_list.roomno=@roomno and a.accnt=@accnt and a.accnt=b.accnt
		end

	select @accnt=''
	select @accnt=accnt from master where roomno=@roomno and sta='R' and datediff(dd,arr,@bdate)<0
	if rtrim(@accnt) is not null
		update #rmsta_list set block=a.arr from master a where #rmsta_list.roomno=@roomno and a.accnt=@accnt
	fetch c_rmno into @roomno
	end
close c_rmno
deallocate cursor c_rmno

select b.roomno,b.type,c.eccocode,a.name,a.arr,a.dep,a.status,a.adlts,a.child,a.block from #rmsta_list a,rmsta b,rmstamap c
	 where a.roomno=b.roomno and b.ocsta+b.sta=c.code order by b.roomno
;