if object_id('p_yjw_audit_changerate') is not null
drop proc p_yjw_audit_changerate
;
create procedure p_yjw_audit_changerate
          @pc_id  char(4),
          @mdi_id int,
			 @empno  char(10)
as
declare
   @accnt      char(10),
   @bdate      datetime,
   @bdate1     datetime,
	@rate       money,    ------第二天的房价
   @rmrate     money,
   @src        char(3),
   @mkt        char(3),
   @packages   char(50),
   @ratecode   char(10),
   @type       char(5),
   @dis		   decimal,
   @dis1			decimal,
   @reason     char(3),
   @count     integer


--自动变价处理
select @bdate = bdate, @bdate1 = bdate1 from sysdata
--自动对散客或成员进行拆分
exec p_yjw_reserve_rsvsrc_calc '',@pc_id,@mdi_id
--

declare c_master cursor for select accnt from master where accnt like 'F%' order by accnt
open c_master
fetch c_master into @accnt
while (@@sqlstatus=0)
  begin
    select @count=count(1) from rsvsrc_detail where accnt=@accnt and date_=dateadd(day,1,@bdate)
		 if @count>0 
			 begin
				 select @rmrate=rmrate,@rate=rate,@src=src,@mkt=market,@packages=packages,@ratecode=ratecode,@type=type,@dis=discount,@dis1=discount1,@reason=rtreason from rsvsrc_detail where accnt=@accnt and date_=dateadd(day,1,@bdate)
				 if @rate is not null
					 begin
						 update master set rmrate=@rmrate,setrate=@rate,src=@src,market=@mkt,packages=@packages,ratecode=@ratecode,type=@type, 
												discount=@dis,discount1=@dis1,rtreason=@reason,cby=@empno,changed=getdate(),logmark=logmark+1 where accnt=@accnt
					end
		 	end
    fetch c_master into @accnt
  end
close c_master
deallocate cursor c_master

---
;