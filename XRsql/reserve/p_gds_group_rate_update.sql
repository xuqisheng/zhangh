
/* 
团体房价更新 

-- 其实，团体主单的房价没有多大的意义 !
*/

if exists(select * from sysobjects where name = "p_gds_group_rate_update")
   drop proc p_gds_group_rate_update
;
create proc p_gds_group_rate_update
   @grpaccnt 			char(10),
   @rm_type  			char(5),
   @opmode   			char(3),
   @newrate  			money,
   @empno    			char(10),
   @nullwithreturn 	varchar(60)
as

declare
   @ret      int,
   @msg      char(60),
   @sta      char(1),
   @oldrate  money,
   @maxrate  money

select @ret=0, @msg=""

begin tran
save  tran p_gds_group_rate_update_s1

update master set sta = sta where accnt = @grpaccnt and class in ('G', 'M')
select @sta = sta from master where accnt = @grpaccnt and class in ('G', 'M')
if @@rowcount = 0
   select @ret = 1,@msg ="团体主单%1不存在^"+@grpaccnt
if @ret = 0
   begin
   select @oldrate = rate from grprate where accnt = @grpaccnt and type = @rm_type
   if @@rowcount = 0
	   begin
	   if @opmode = 'ADD'
         begin
		   insert grprate (accnt,type,rate,oldrate,cby,changed)
                values  (@grpaccnt,@rm_type,@newrate,@newrate,@empno,getdate())
		   select @maxrate = isnull(max(rate),0) from grprate where grprate.accnt = @grpaccnt
		   update master set setrate = @maxrate, logmark=logmark + 1
				    where accnt = @grpaccnt and setrate <> @maxrate 
		   end
	   else if @opmode = 'MOD' or @opmode = 'DEL'
  	      select @ret = 1 ,@msg = "团体主单%1房类%2房价未设置或已删除^"+@grpaccnt+"^"+@rm_type
	   end
   else
	   begin
	   if @opmode = 'ADD'
		   select @ret = 1 ,@msg = "团体主单%1房类%2房价已设置^"+@grpaccnt+"^"+@rm_type
	   else if @opmode = 'MOD'
    	   begin
		   update grprate set oldrate = rate where accnt = @grpaccnt and type = @rm_type
		   update grprate set rate = @newrate where accnt = @grpaccnt and type = @rm_type
		   select @maxrate = isnull(max(rate),0) from grprate where grprate.accnt = @grpaccnt
			-- 团体主单
		   update master  set setrate = @maxrate, logmark=logmark+1 
					where accnt = @grpaccnt and setrate <> @maxrate
			-- 成员
		   update master set qtrate=@newrate,setrate = @newrate,logmark=logmark+1
		          where groupno = @grpaccnt and type = @rm_type and setrate = @oldrate
   		end
	   else if @opmode = 'DEL'
		   begin  
		   delete grprate where accnt = @grpaccnt and type = @rm_type
						      and not exists (select accnt from master where groupno = @grpaccnt
											   and type = @rm_type and charindex(sta,'RCGI') > 0 )
		   if @@rowcount = 0
			   select @ret = 1 ,@msg = "房类%1还有有效成员在使用,不允许删除^"+@rm_type
		   else if exists (select accnt from grprate where accnt = @grpaccnt)
			   begin   -- 重新更新团体主单的房价
			   select @maxrate = isnull(max(rate),0) from grprate where grprate.accnt = @grpaccnt
			   update master set setrate = @maxrate, logmark=logmark+1
				              where master.accnt = @grpaccnt and setrate <> @maxrate 
            end 
         end 
	   end
   end

if @ret <> 0
   rollback tran p_gds_group_rate_update_s1
commit tran

if @nullwithreturn is null
   select @ret,@msg
else
   select @nullwithreturn = @msg

return @ret
;
      

