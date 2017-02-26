IF OBJECT_ID('dbo.p_yjw_reserve_rsvsrc_detail') IS NOT NULL
DROP PROCEDURE dbo.p_yjw_reserve_rsvsrc_detail
;
SETUSER 'dbo'
;
-- rsvsrc----->rsvsrc_detail
-- @accnt='' or @accnt is null   扫描整个rsvsrc表对未拆分过的记录拆分到rsvsrc_detail
-- @accnt=accnt                  判断账号为accnt的记录是否拆分过，如果没有，进行拆分
-- 如果对应rsvsrc表中数据已经拆分，则不能对房类、房价码在主单界面下进行修改，只能在明细界面下进行调整，并且也只能
-- 对第一条记录的房类、房价码进行修改
-- 如果房价码
create procedure p_yjw_reserve_rsvsrc_detail
                   @accnt char(10),
                   @mode  char(1),
                   @pc_id char(4),
                   @mdi_id integer 

as
declare
   @begin_  datetime,
   @end_    datetime,
   @begin1_    datetime,
   @end1_    datetime,
   @rate     money,
   @ratecode   char(10),
   @package    varchar(50),
   @ret      int,
   @msg      varchar(255),
   @type     char(5),
   @value    money,
   @gstno    int,
   @child    int,
   @enddate  datetime,
   @fixcharge money,
   @multi     money,
   @adder       money,
   @tag       char(1),
   @p_lau     money,
   @p_bf      money,
   @p_srv     money,
   @p_ot      money,
   @qrate     money,
   @rmrate    money

--删除rsvsrc表中已经没有的记录
delete rsvsrc_detail where accnt not in(select accnt from rsvsrc)
--如果房价码发生变化，应该重新对rsvsrc的相关记录进行拆分？


if @accnt='' or @accnt is null
	begin
     --没有被拆分过的rsvsrc记录进行拆分
      delete rsvsrc_detail where mode=@mode
		declare c_get_accnt cursor for select accnt,begin_,end_,gstno,child,type,ratecode  from rsvsrc where accnt not in(
												 select accnt from rsvsrc_detail) and accnt like 'F%'
		open c_get_accnt
		fetch c_get_accnt into @accnt,@begin_,@end_,@gstno,@child,@type,@ratecode
		while @@sqlstatus=0
         begin
           --房价分拆到离日前一天
           select @end_=dateadd(day,-1,@end_)
           --
			  while @end_>@begin_
                begin
						select @fixcharge=isnull(sum(amount*quantity),0) from fixed_charge where accnt=@accnt and (@begin_>=starting_time and @begin_<=closing_time)
                  insert rsvsrc_detail select  accnt,type,roomno,blkmark,blkcode,@begin_,gstno,child,rmrate,
																rate,0,0,0,0,0,0,0,0,rtreason,remark,saccnt,master,rateok,arr,dep,ratecode,
																src,market,packages,srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
																cby,changed,1,@mode  from rsvsrc where accnt=@accnt
                  select @enddate=dateadd(day,1,@begin_)

						exec @ret=p_yjw_rate_for_dailyrate @type,@begin_,@enddate,@gstno,@ratecode,@value output

						select @tag=calendar from rmratecode where code=@ratecode
                  if @tag='T'
                  	begin
								select @multi=1,@adder=0
								select @multi=a.multi,@adder=a.adder from rmrate_factor a,rmrate_calendar b where datediff(day,b.date,@begin_)=0 and a.code=b.factor

								update rsvsrc_detail set rmrate=@value*@multi+@adder,rate=@value*@multi+@adder,exp_m=isnull(@fixcharge,0) where accnt=@accnt and date_=@begin_
							end
                  else
                     update rsvsrc_detail set rmrate=@value,rate=@value,exp_m=isnull(@fixcharge,0) where accnt=@accnt and date_=@begin_

                  select @package=packages from rsvsrc_detail where accnt=@accnt and date_=@begin_
                  exec @ret=p_yjw_rmratecode_check 'FN',@pc_id,@mdi_id,@begin_, @ratecode,@type, @package,@gstno,@child
                  select @p_srv=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode='005'
              		select @p_bf=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode in ('810','840','870','701')
                  select @p_lau=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode='310'
                  select @p_ot=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode not in('310','810','840','870','701','005') and code<>'QRAT' and code <>'RMRA'
                  select @qrate=isnull(amount,0) from rmratecode_check where pc_id=@pc_id and code='QRAT'
						select @rmrate=isnull(amount,0) from rmratecode_check where pc_id=@pc_id and code='RMRA'
                   
						update rsvsrc_detail set p_srv=@p_srv,p_bf=@p_bf,p_lau=@p_lau,p_ot=@p_ot,qrate=@qrate,rmrate=@rmrate where accnt=@accnt and date_=@begin_                  

                  select @begin_=dateadd(day,1,@begin_)
                 end
           fetch c_get_accnt into @accnt,@begin_,@end_,@gstno,@child,@type,@ratecode
          end
      --已经被拆分过，但到离日有变化的记录进行增删处理

			close c_get_accnt
			deallocate cursor c_get_accnt
   end
else
   begin
		if substring(@accnt,1,1)<>'F'
			begin
				select @ret=1,@msg="非有效的散客或成员账户!"
				goto gout
			end
     	if exists (select 1 from rsvsrc_detail where accnt=@accnt and mode='M')
			begin
          select @begin_=begin_,@end_=end_,@gstno=gstno,@child=child from rsvsrc where accnt=@accnt
        	 select @begin1_=min(date_),@end1_=max(date_) from rsvsrc_detail where accnt=@accnt
        	 -- 到日提前
          if @begin_<@begin1_
             begin
               select @gstno=gstno,@type=type,@rate=rate,@ratecode=ratecode,@package=packages from rsvsrc_detail where accnt=@accnt and date_=@begin1_
               while @begin_<@begin1_
                  begin
                     select @fixcharge=isnull(sum(amount*quantity),0) from fixed_charge where accnt=@accnt and (@begin_>=starting_time and @begin_<=closing_time)
	                  insert rsvsrc_detail select  accnt,type,roomno,blkmark,blkcode,@begin_,gstno,child,rmrate,
			   												  isnull(@rate,rate),0,0,0,0,0,0,0,0,rtreason,remark,saccnt,master,rateok,arr,dep,isnull(@ratecode,ratecode),
																  src,market,isnull(@package,packages),srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
																  cby,changed,1,@mode from rsvsrc where accnt=@accnt

							select @enddate=dateadd(day,1,@begin_)

							exec @ret=p_yjw_rate_for_dailyrate @type,@begin_,@enddate,@gstno,@ratecode,@value output


						select @tag=calendar from rmratecode where code=@ratecode
                  if @tag='T'
                  	begin
								select @multi=1,@adder=0
								select @multi=a.multi,@adder=a.adder from rmrate_factor a,rmrate_calendar b where datediff(day,b.date,@begin_)=0 and a.code=b.factor

								update rsvsrc_detail set rmrate=@value*@multi+@adder,rate=@value*@multi+@adder,exp_m=isnull(@fixcharge,0) where accnt=@accnt and date_=@begin_
							end
                  else
                     update rsvsrc_detail set rmrate=@value,rate=@value,exp_m=isnull(@fixcharge,0) where accnt=@accnt and date_=@begin_

						select @package=packages from rsvsrc_detail where accnt=@accnt and date_=@begin_
                  exec @ret=p_yjw_rmratecode_check 'FN',@pc_id,@mdi_id,@begin_, @ratecode,@type, @package,@gstno,@child
                  select @p_srv=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode='005'
              		select @p_bf=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode in ('810','840','870','701')
                  select @p_lau=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode='310'
                  select @p_ot=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode not in('310','810','840','870','701','005') and code<>'QRAT' and code <>'RMRA'
                  select @qrate=isnull(amount,0) from rmratecode_check where pc_id=@pc_id and code='QRAT'
                  select @rmrate=isnull(amount,0) from rmratecode_check where pc_id=@pc_id and code='RMRA'
                   
						update rsvsrc_detail set p_srv=@p_srv,p_bf=@p_bf,p_lau=@p_lau,p_ot=@p_ot,qrate=@qrate,rmrate=@rmrate where accnt=@accnt and date_=@begin_                  

 							select @begin_=dateadd(day,1,@begin_)
                  end
             end
          -- 到日延后
			 if @begin_>@begin1_
             begin
               delete rsvsrc_detail where date_<@begin_ and accnt=@accnt
             end

			 -- 离日提前
          if @end_<@end1_
             begin
               delete rsvsrc_detail where date_>dateadd(day,-1,@end_) and accnt=@accnt
             end
          -- 离日延后
          if @end_>@end1_
             begin
					select @type=type,@gstno=gstno,@child=child,@rate=rate,@ratecode=ratecode,@package=packages from rsvsrc_detail where accnt=@accnt and date_=@end1_
               while @end1_<dateadd(day,-1,@end_)
               begin
                 select @end1_=dateadd(day,1,@end1_)
					  select @fixcharge=isnull(sum(amount*quantity),0) from fixed_charge where accnt=@accnt and (@end1_>=starting_time and @end1_<=closing_time)
                 insert rsvsrc_detail select  accnt,type,roomno,blkmark,blkcode,@end1_,gstno,child,rmrate,
																isnull(@rate,rate),0,0,0,0,0,0,0,0,rtreason,remark,saccnt,master,rateok,arr,dep,isnull(@ratecode,ratecode),
																src,market,isnull(@package,packages),srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
																cby,changed,1,@mode from rsvsrc where accnt=@accnt

					  select @enddate=dateadd(day,1,@end1_)

					  	exec @ret=p_yjw_rate_for_dailyrate @type,@end1_,@enddate,@gstno,@ratecode,@value output

						select @tag=calendar from rmratecode where code=@ratecode
                  if @tag='T'
                  	begin
								select @multi=1,@adder=0
								select @multi=a.multi,@adder=a.adder from rmrate_factor a,rmrate_calendar b where datediff(day,b.date,@begin_)=0 and a.code=b.factor

								update rsvsrc_detail set rmrate=@value*@multi+@adder,rate=@value*@multi+@adder,exp_m=isnull(@fixcharge,0) where accnt=@accnt and date_=@begin_
							end
                  else
                     update rsvsrc_detail set rmrate=@value,rate=@value,exp_m=isnull(@fixcharge,0) where accnt=@accnt and date_=@begin_

                  select @package=packages from rsvsrc_detail where accnt=@accnt and date_=@begin_
                  exec @ret=p_yjw_rmratecode_check 'FN',@pc_id,@mdi_id,@begin_, @ratecode,@type, @package,@gstno,@child
                  select @p_srv=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode='005'
              		select @p_bf=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode in ('810','840','870','701')
                  select @p_lau=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode='310'
                  select @p_ot=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode not in('310','810','840','870','701','005') and code<>'QRAT' and code <>'RMRA'
                  select @qrate=isnull(amount,0) from rmratecode_check where pc_id=@pc_id and code='QRAT'
                  select @rmrate=isnull(amount,0) from rmratecode_check where pc_id=@pc_id and code='RMRA'
                   
						update rsvsrc_detail set p_srv=@p_srv,p_bf=@p_bf,p_lau=@p_lau,p_ot=@p_ot,qrate=@qrate,rmrate=@rmrate where accnt=@accnt and date_=@begin_                  
               end
             end
				update rsvsrc_detail  set exp_m=(select isnull(sum(b.amount*b.quantity),0) from fixed_charge b where rsvsrc_detail.accnt=b.accnt and rsvsrc_detail.date_>=b.starting_time and rsvsrc_detail.date_<=b.closing_time)

        end
   else
      begin
        delete rsvsrc_detail where accnt=@accnt
        select @begin_=begin_,@end_=end_,@gstno=gstno,@child=child,@ratecode=ratecode,@type=type  from rsvsrc where accnt=@accnt
        	while @end_>@begin_
                begin
						select @fixcharge=isnull(sum(amount*quantity),0) from fixed_charge where accnt=@accnt and (@begin_>=starting_time and @begin_<=closing_time)
                  insert rsvsrc_detail select  accnt,type,roomno,blkmark,blkcode,@begin_,gstno,child,rmrate,
																rate,0,0,0,0,0,0,0,0,rtreason,remark,saccnt,master,rateok,arr,dep,ratecode,
																src,market,packages,srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
																cby,changed,1,@mode from rsvsrc where accnt=@accnt
                 	select @enddate=dateadd(day,1,@begin_)

					  	exec @ret=p_yjw_rate_for_dailyrate @type,@begin_,@enddate,@gstno,@ratecode,@value output

						select @tag=calendar from rmratecode where code=@ratecode
                  if @tag='T'
                  	begin
								select @multi=1,@adder=0
								select @multi=a.multi,@adder=a.adder from rmrate_factor a,rmrate_calendar b where datediff(day,b.date,@begin_)=0 and a.code=b.factor

								update rsvsrc_detail set rmrate=@value*@multi+@adder,rate=@value*@multi+@adder,exp_m=isnull(@fixcharge,0) where accnt=@accnt and date_=@begin_
							end
                  else
                     update rsvsrc_detail set rmrate=@value,rate=@value,exp_m=isnull(@fixcharge,0) where accnt=@accnt and date_=@begin_
                 
						select @package=packages from rsvsrc_detail where accnt=@accnt and date_=@begin_
                  exec @ret=p_yjw_rmratecode_check 'FN',@pc_id,@mdi_id,@begin_, @ratecode,@type, @package,@gstno,@child
                  select @p_srv=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode='005'
              		select @p_bf=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode in ('810','840','870','701')
                  select @p_lau=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode='310'
                  select @p_ot=isnull(sum(amount),0) from rmratecode_check where pc_id=@pc_id and pccode not in('310','810','840','870','701','005') and code<>'QRAT' and code <>'RMRA'
                  select @qrate=isnull(amount,0) from rmratecode_check where pc_id=@pc_id and code='QRAT'
                  select @rmrate=isnull(amount,0) from rmratecode_check where pc_id=@pc_id and code='RMRA'
                   
						update rsvsrc_detail set p_srv=@p_srv,p_bf=@p_bf,p_lau=@p_lau,p_ot=@p_ot,qrate=@qrate,rmrate=@rmrate where accnt=@accnt and date_=@begin_                  

                  select @begin_=dateadd(day,1,@begin_)
                 end
      end
	end

update rsvsrc_detail  set discount=b.discount ,discount1=b.discount1 from master b where rsvsrc_detail.accnt=b.accnt and rsvsrc_detail.rate=b.setrate and rsvsrc_detail.accnt=@accnt

gout:
--  select @ret,@msg
  return @ret
;

