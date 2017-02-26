drop proc p_xym_zero_rate_rooms;
create proc p_xym_zero_rate_rooms
  @fmroom   char(5),
  @lsroom   char(5)

as
-- ------------------------------------------------------------------------
-- 系统维护程序之 #special
--
-- 维护单个账号
-- ------------------------------------------------------------------------

declare	
   @accnt      char(10),
   @roomno     char(5),
   @toroom     char(5),
   @name       varchar(150),
   @toname     varchar(50),
   @toaccnt    char(10),
   @subname    varchar(50),
   @ref        varchar(255) 

create table #zero
   (
   accnt    char(10) not null,
   roomno   char(5),
   name     varchar(50) not null,
   gstno    integer,
   ratecode char(10),
   blkcode  char(10),
   market   char(3),
   arr      datetime,
   dep      datetime,
   balance  money,
   type     char(5),
   comp     char(1),
   cag      varchar(150),
   paycode  char(6),
   taxtype  char(10),
   comments char(10),
   comsg    varchar(255)
   )
if @fmroom is null
   select @fmroom='0'
if @lsroom is null
   select @lsroom='9999'
insert #zero select a.accnt,a.roomno,b.name,a.gstno,a.ratecode,a.blkcode,a.market,a.arr,a.dep,a.credit - a.charge,a.type,'',c.cusno+'/'+c.agent+'/'+c.source,a.paycode,'','',a.ref
  from master a,guest b,master_des c where a.haccnt=b.no and a.accnt=c.accnt and a.setrate = 0 and a.class in ('F')
  and a.sta in ('I') and (a.roomno>=@fmroom or ''=@fmroom) and (a.roomno<=@lsroom or ''=@lsroom) order by a.roomno,a.accnt
//update #zero set comsg = 'Comments:     '+comsg where rtrim(comsg)<>''
declare c_zero cursor for select a.accnt,a.name,rtrim(b.to_roomno),rtrim(b.to_accnt),rtrim(b.name) from #zero a,subaccnt b where a.accnt = b.accnt and b.subaccnt<>1 and b.type='5' order by a.accnt
open  c_zero
fetch c_zero into @accnt,@name,@roomno,@toaccnt,@subname
while @@sqlstatus = 0
	begin
     if rtrim(@toaccnt) is not null or rtrim(@toaccnt) <> ''
       begin
         select @toname = b.name from master a,guest b where a.haccnt=b.no and a.accnt = @toaccnt
         select @ref = rtrim(comsg) from #zero where accnt = @accnt 
         if @ref is null
            update #zero set comsg = 'Routed to ' + @toname + ':' + @toroom where accnt = @accnt
         else
            update #zero set comsg = comsg + '' +  char(13) + 'Routed to ' + @toname + ':' + @toroom where accnt = @accnt
       end  
     else
       update #zero set comsg = comsg + '' +  char(13) + 'Routed to ' + @subname + ':' + @toroom where accnt = @accnt
     select @toaccnt = '',@accnt = '',@roomno='',@subname='',@toname='',@toroom=''
	fetch c_zero into @accnt,@name,@roomno,@toaccnt,@subname
	end
close c_zero
deallocate cursor c_zero

update #zero set comp = 'Y' where market = 'N'
update #zero set comments='Comments:' where (rtrim(comsg)<>'' or rtrim(comsg) is not null)

select    roomno,
   name,
   gstno,
   ratecode,
   blkcode,
   market,
   arr,
   dep,
   balance,
   type,
   comp,
   cag,
   paycode,
   taxtype,
   comments,
   substring(rtrim(comsg),1,datalength(comsg)) from #zero

;
exec p_xym_zero_rate_rooms '','';