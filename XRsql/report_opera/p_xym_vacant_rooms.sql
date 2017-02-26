drop proc p_xym_vacant_rooms;
create proc p_xym_vacant_rooms
   @type    char(5)
as
-- ------------------------------------------------------------------------
-- 系统维护程序之 #special
--
-- 维护单个账号
-- ------------------------------------------------------------------------

declare	
   @accnt      char(10),
   @roomno     char(5),
   @name       varchar(50),
   @arr        datetime,
   @dep        datetime,
   @gstno      money,
   @chld       money,
   @sta        char(1),
   @status     char(10),
   @saccnt     char(10),
   @saccnt1    char(10),
   @class      char(1),
   @extra      char(10) 

create table #vacant
   (
   roomno   char(5),
   type     char(5),
   fstatus  char(5),
   status   char(5),
   locked   char(1),
   name     varchar(100),
   arr      datetime  null,
   dep      datetime  null,
   sta      char(10) null,
   adlts    money,
   chld     money,
   nextbk   datetime  null   
   )
if rtrim(@type) is null or rtrim(@type)='' 
   insert #vacant select roomno,type,'VAC',sta,locked,'',null,null,null,0,0,null from rmsta where ocsta='V' order by roomno
else 
   insert #vacant select roomno,type,'VAC',sta,locked,'',null,null,null,0,0,null from rmsta where ocsta='V' and type = @type order by roomno
update #vacant set status = 'OO' where status = 'O' and locked = 'L'
update #vacant set status = 'OS' where status = 'S' and locked = 'L'
update #vacant set status = 'CL' where status = 'R'
update #vacant set status = 'DI' where status = 'D'
update #vacant set status = 'IS' where status = 'I'
declare c_vacant1 cursor for select a.accnt,b.name,a.arr,a.dep,a.sta,a.gstno,a.children,a.saccnt,a.class,a.extra 
   from master a,guest b where a.roomno=@roomno 
   and a.haccnt = b.no and a.sta in ('R') and a.class  = 'F' order by a.saccnt,a.dep,a.accnt
declare c_vacant cursor for select roomno from #vacant order by roomno
open  c_vacant
fetch c_vacant into @roomno
while @@sqlstatus = 0
	begin

     open  c_vacant1
     fetch c_vacant1 into @accnt,@name,@arr,@dep,@sta,@gstno,@chld,@saccnt,@class,@extra
     while @@sqlstatus = 0
	     begin
          if datediff(dd,@arr,getdate())=0
            begin 
              update #vacant set arr = @arr,dep = @dep,adlts = adlts + @gstno,chld = chld + @chld where roomno = @roomno
              if  @class='F' and substring(@extra,9,1)='1'
                 update #vacant set sta = 'Walk In' where roomno = @roomno
              else if @class in ('F','G','M') and datediff(dd,@dep,getdate())=0
                 update #vacant set sta = 'Due Out' where roomno = @roomno
              else if @class in ('F','G','M') and datediff(dd,@arr,getdate())=0
                 update #vacant set sta = 'Due In' where roomno = @roomno
              else if @class in ('F','G','M') and datediff(dd,@dep,getdate())=0 and datediff(dd,@arr,getdate())=0
                 update #vacant set sta = 'Day Use' where roomno = @roomno
              else if @class in ('F','G','M')
                 update #vacant set sta = 'Check In' where roomno = @roomno
              if @saccnt1 = @saccnt
                 update #vacant set name = name + ',' + @name where roomno = @roomno
              else
                 update #vacant set name = @name where roomno = @roomno
            end 
          else
              update #vacant set nextbk = @arr where roomno = @roomno
          select @saccnt1 = @saccnt
	     fetch c_vacant1 into @accnt,@name,@arr,@dep,@sta,@gstno,@chld,@saccnt,@class,@extra
	     end
     close c_vacant1

	fetch c_vacant into @roomno
	end
close c_vacant

deallocate cursor c_vacant
deallocate cursor c_vacant1
select roomno,type,fstatus,status,name,arr,dep,sta,adlts,chld,nextbk from #vacant order by roomno

;
exec p_xym_vacant_rooms '';