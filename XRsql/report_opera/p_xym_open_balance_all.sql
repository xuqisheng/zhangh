drop proc p_xym_open_balance_all;
create proc p_xym_open_balance_all
  @s_time   datetime,
  @e_time   datetime

as
-- ------------------------------------------------------------------------
-- 系统维护程序之 #special
--
-- 维护单个账号
-- ------------------------------------------------------------------------

declare	
   @accnt      char(10),
   @accnt1     char(10),
   @roomno     char(5),
   @toroom     char(5),
   @name       varchar(150),
   @toname     varchar(50),
   @toaccnt    char(10),
   @subname    varchar(50),
   @ref        varchar(255),
   @pccodes    varchar(255),
   @pccode     char(5), 
   @extras     money,
   @amount     money,
   @quantity   money

create table #balance
   (
   accnt    char(10) not null,
   roomno   char(5),
   name     varchar(50),
   blkcode  char(10),
   insrtuctions  varchar(100),
   arr      datetime,
   dep      datetime,
   prs      int,
   fix_charge  money,
   extras      money,
   credit      money,
   balance     money,
   amount      money,
   billing     char(5)
   )
insert #balance select a.accnt,a.roomno,b.name,a.blkcode,'',a.arr,a.dep,a.gstno,0,0,0,a.charge - a.credit,a.setrate,''
  from master a,guest b where a.haccnt=b.no and a.class in ('F') and a.sta = 'I'
  order by a.roomno,a.accnt 
update #balance set fix_charge = (select isnull(sum(charge),0) from account where #balance.accnt = account.accnt and account.pccode in (select pccode from pccode where jierep='010'))
//update #balance set amount = (select isnull(sum(charge),0) from account where #balance.accnt = account.accnt and account.pccode in (select pccode from pccode where jierep='010'))
update #balance set extras = (select isnull(sum(charge),0) from account where #balance.accnt = account.accnt and account.pccode not in (select pccode from pccode where jierep='010'))
update #balance set credit = (select isnull(sum(credit),0) from account where #balance.accnt = account.accnt)

declare c_balance cursor for select a.accnt,a.name,rtrim(b.to_roomno),rtrim(b.to_accnt),rtrim(b.name),b.pccodes from #balance a,subaccnt b where a.accnt = b.accnt and b.subaccnt<>1 and b.type='5' order by a.accnt
open  c_balance
fetch c_balance into @accnt,@name,@roomno,@toaccnt,@subname,@pccodes
while @@sqlstatus = 0
	begin
     if rtrim(@toaccnt) is not null or rtrim(@toaccnt) <> ''
       begin
         select @toname = b.name from master a,guest b where a.haccnt=b.no and a.accnt = @toaccnt
         select @ref = rtrim(insrtuctions) from #balance where accnt = @accnt 
         if @ref is null
            update #balance set insrtuctions = 'Routed to ' + @toname + ':' + @toroom + ':'+@pccodes where accnt = @accnt
         else
            update #balance set insrtuctions = insrtuctions + '' +  char(13) + 'Routed to ' + @toname + ':' + @toroom + ':'+@pccodes where accnt = @accnt
       end  
     else
       update #balance set insrtuctions = insrtuctions + '' +  char(13) + 'Routed to ' + @subname + ':' + @toroom + ':'+@pccodes where accnt = @accnt

	fetch c_balance into @accnt,@name,@roomno,@toaccnt,@subname,@pccodes
	end
close c_balance
deallocate cursor c_balance

declare c_fix cursor for select a.accnt,a.pccode,a.amount,a.quantity from fixed_charge a,#balance b where a.accnt = b.accnt order by a.accnt
open  c_fix
fetch c_fix into @accnt,@pccode,@amount,@quantity
while @@sqlstatus = 0
	begin
       select @amount = (select isnull(sum(charge),0) from account where pccode = @pccode and accnt = @accnt)
       update #balance set fix_charge = fix_charge + @amount where accnt = @accnt 
       update #balance set extras = extras - @amount where accnt = @accnt        
	fetch c_fix into @accnt,@pccode,@amount,@quantity
	end
close c_fix
deallocate cursor c_fix


select    roomno  ,
   name,
   blkcode,
   insrtuctions,
   arr,
   dep,
   prs,
   fix_charge,
   extras,
   credit,
   balance,
   amount,
   billing from #balance

;
exec p_xym_open_balance_all '2006/08/01','2006/09/11';