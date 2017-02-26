//p_gds_reserve_daily_info
drop proc p_xym_userlog_transfers;
create proc p_xym_userlog_transfers
	@date 			datetime,
   @empno         char(10)
as
-- ------------------------------------------------------------------------------------
--  暂时只对本日的和上日的转帐日志进行统计，考虑到速度
-- ------------------------------------------------------------------------------------
declare
  @accnt    char(10),
  @accntof  char(10),
  @logdate  datetime,
  @number   integer,
  @roomno   char(5),
  @roomno1  char(5),
  @name     varchar(50),
  @name1    varchar(50),
  @pccode   char(5),
  @charge   money,
  @credit   money,
  @empno1   char(10),
  @ref1     varchar(255),
  @ref2     char(20)

create table #transfers
(
accnt     char(10),
number    integer,
date1     datetime,
date2     datetime,
roomno    char(5),
name      varchar(50),
pccode    char(5),
descript1 varchar(50),
revenue   money,
credit    money,
cashier   char(10),
empno     char(20),
ref       varchar(255)
)
if rtrim(@empno) is null or rtrim(@empno)=''   
  declare c_transfers cursor for select a.accnt,b.number,b.log_date,a.roomno,c.name,b.pccode,b.charge,b.credit,b.roomno,b.empno,b.ref1,b.ref2,b.accntof
    from master a,account b,guest c where a.accnt = b.accnt and a.haccnt = c.no  and datediff(dd,@date,b.log_date)=0 
    and b.tofrom ='FM' order by a.roomno,a.accnt
else
  declare c_transfers cursor for select a.accnt,b.number,b.log_date,a.roomno,c.name,b.pccode,b.charge,b.credit,b.roomno,b.empno,b.ref1,b.ref2,b.accntof
    from master a,account b,guest c where a.accnt = b.accnt and a.haccnt = c.no and datediff(dd,@date,b.log_date)=0 
    and b.tofrom ='FM' and b.empno = @empno order by a.roomno,a.accnt

open  c_transfers
fetch c_transfers into @accnt,@number,@logdate,@roomno,@name,@pccode,@charge,@credit,@roomno1,@empno1,@ref1,@ref2,@accntof
while @@sqlstatus = 0
	begin
      insert #transfers select @accnt,@number,@logdate,@logdate,@roomno,@name,@pccode,'',@charge,@credit,@empno1,'',''
      select @name1 = a.name from guest a,master b where b.accnt = @accntof and a.no = b.haccnt
      update #transfers set ref = '#'+@roomno1 +' : '+ @ref2 + ' ['+@ref1+'] '+@name1+' #'+@roomno1 + '=>'+@name+' #'+@roomno
          where accnt = @accnt and pccode = @pccode and number = @number
	fetch c_transfers into @accnt,@number,@logdate,@roomno,@name,@pccode,@charge,@credit,@roomno1,@empno1,@ref1,@ref2,@accntof
	end
close c_transfers
deallocate cursor c_transfers

update #transfers set descript1 = (select descript1 from pccode where #transfers.pccode = pccode.pccode)

update #transfers set empno = (select name from sys_empno where #transfers.cashier = sys_empno.empno)

select date1,date2,roomno,name,pccode,descript1,revenue,credit,cashier,empno,ref from #transfers order by roomno,accnt

return 0;

exec p_xym_userlog_transfers '2006/09/19','FOX';