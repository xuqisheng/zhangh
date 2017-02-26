if object_id('p_yjw_rsvsrc_detail_accnt_grp') is not null
drop proc p_yjw_rsvsrc_detail_accnt_grp
;
create procedure p_yjw_rsvsrc_detail_accnt_grp
                   @accnt char(10),
                   @id    int

as
declare
   @begin_  datetime,
	@begin_old datetime,
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
   @rmrate    money,
 	@bdate     datetime,
   @long      int,
   @rmnums    int,
   @roomno    char(5),
   @mode      char(1),
   @quantity  int,
   @typem     char(5),    --master表中的type数据
   @uptype    char(5), 
	@cmode     char(1)     --自动变价模式


--自动变价模式
select @cmode = isnull((select substring(value,1,1) from sysoption where catalog = 'reserve' and item = 'rmrate_autochg_mode'), '0')
if charindex(@cmode, '123') = 0 
   select @cmode='0'


select @rmnums=1,@roomno=null
select @bdate=bdate from sysdata 


select @begin1_=min(date_) from rsvsrc_detail where accnt=@accnt
if @begin1_<@bdate
	select @begin1_=@bdate

select @type=type from rsvsrc_detail where accnt=@accnt and date_=@begin1_ and id=@id
select @typem=type from master where accnt=@accnt
if @type<>@typem 
	delete rsvsrc_detail where accnt=@accnt and date_>=@bdate and id=@id

if exists (select 1 from rsvsrc_detail where accnt=@accnt and mode='M' and date_>=@bdate and id=@id)
	begin  --4
    select @mode='M'
	 select @begin_=begin_,@end_=end_,@long=datediff(dd,begin_,end_),@gstno=gstno,@child=child from rsvsrc where accnt=@accnt and id=@id
	 select @begin1_=min(date_),@end1_=max(date_) from rsvsrc_detail where accnt=@accnt and id=@id
	 if @begin_<@bdate
		 select @begin_=@bdate
	 -- 到日提前
	 if @begin_<@begin1_
		 begin
			select @gstno=gstno,@type=type,@rate=rate,@rmrate=rmrate,@ratecode=ratecode,@package=packages from rsvsrc_detail where accnt=@accnt and date_=@begin1_ and id=@id
			while @begin_<@begin1_
				begin
					insert rsvsrc_detail select accnt,id,@type,roomno,blkmark,blkcode,@begin_,quantity,gstno,child,isnull(rmrate,0),isnull(rate,0),0,0,0,0,0,0,0,0,0,
                                       rtreason,remark,saccnt,master,rateok,arr,dep,ratecode,src,market,packages,srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
														cby,changed,1,mode,'F' from rsvsrc_detail where accnt=@accnt and date_=@begin1_ and id=@id

					exec @ret =p_gds_get_rmrate @begin_,@long,@type,@roomno,@rmnums,@gstno,@ratecode,'','R',@value out,@msg out
					if @ret<>0
						select @value =null

					---判断自动变价
           		if @rmrate<>@value
             	 begin
						  if @cmode='1'
							  update rsvsrc_detail set rmrate=isnull(@value,0),rate=isnull(@value,0) where accnt=@accnt and date_=@begin_ and id=@id
						  else if @cmode='2'
							  update rsvsrc_detail set rmrate=isnull(@value,0),rate=isnull(@rate - @rmrate + isnull(@value,0),0) where accnt=@accnt and date_=@begin_ and id=@id
						  else if @cmode='3'
							  update rsvsrc_detail set rmrate=isnull(@value,0),rate=round(isnull(@rate/@rmrate*isnull(@value,0),0),2) where accnt=@accnt and date_=@begin_ and id=@id and @rmrate<>0
						 else
							update rsvsrc_detail set rate=isnull(@value,0) where accnt=@accnt and date_=@begin_ and  id=@id and rate<>@value  and @rate=@rmrate

                end 
					---2008-6-17

                                                                                                                                                 


					select @begin_=dateadd(day,1,@begin_)
				end
			update rsvsrc_detail  set exp_m=(select isnull(sum(b.amount*b.quantity),0) from fixed_charge b where rsvsrc_detail.accnt=b.accnt and rsvsrc_detail.date_>=b.starting_time and rsvsrc_detail.date_<=b.closing_time) where accnt=@accnt 
		 end
	 -- 到日延后
	 if @begin_>@begin1_ and @begin_<>@bdate
		 begin
			delete rsvsrc_detail from rsvsrc_detail a,master b where a.date_<@begin_ and a.accnt=@accnt and a.id=@id and a.accnt=b.accnt and b.sta<>'I'
		 end

	 -- 离日提前
	 if @end_<@end1_
		 begin
			delete rsvsrc_detail where date_>dateadd(day,-1,@end_) and accnt=@accnt and id=@id
		 end
	 -- 离日延后
	 if @end_>@end1_
		 begin   --3
			select @type=type,@gstno=gstno,@child=child,@rate=rate,@rmrate=rmrate,@ratecode=ratecode,@package=packages from rsvsrc_detail where accnt=@accnt and date_=@end1_ and id=@id
         select @long=datediff(dd,begin_,end_) from rsvsrc where accnt=@accnt and id=@id
			while @end1_<dateadd(day,-1,@end_)
			begin  --2
			  select @end1_=dateadd(day,1,@end1_)
			  insert rsvsrc_detail select accnt,id,@type,roomno,blkmark,blkcode,@end1_,quantity,gstno,child,isnull(rmrate,0),isnull(rate,0),0,0,0,0,0,0,0,0,0,
                                       rtreason,remark,saccnt,master,rateok,arr,dep,ratecode,src,market,packages,srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
														cby,changed,1,mode,'F' from rsvsrc_detail where accnt=@accnt and date_=dateadd(day,-1,@end1_) and id=@id
			  exec @ret =p_gds_get_rmrate @begin_,@long,@type,@roomno,@rmnums,@gstno,@ratecode,'','R',@value out,@msg out
					if @ret<>0
						select @value =null
			---判断自动变价
           if @rmrate<>@value
              begin
                 if @cmode='1'
                    update rsvsrc_detail set rmrate=isnull(@value,0),rate=isnull(@value,0) where accnt=@accnt and date_=@end1_ and id=@id
                 else if @cmode='2'
                    update rsvsrc_detail set rmrate=isnull(@value,0),rate=isnull(@rate - @rmrate + isnull(@value,0),0) where accnt=@accnt and date_=@end1_
                 else if @cmode='3'
                    update rsvsrc_detail set rmrate=isnull(@value,0),rate=round(isnull(@rate/@rmrate*isnull(@value,0),0),2) where accnt=@accnt and date_=@end1_ and id=@id and @rmrate<>0
					  else
							update rsvsrc_detail set rate=isnull(@value,0) where accnt=@accnt and date_=@begin_ and  id=@id and rate<>@value  and @rate=@rmrate
               end 
           ---2008-6-17

                                                                                                                                                
			end  --2
		 end    --3
		update rsvsrc_detail  set exp_m=(select isnull(sum(b.amount*b.quantity),0) from fixed_charge b where rsvsrc_detail.accnt=b.accnt and rsvsrc_detail.date_>=b.starting_time and rsvsrc_detail.date_<=b.closing_time) where accnt=@accnt

  end  --4
else
	begin
                                                                                                                                                                                                                                                                                                                                                                                     
 --	delete rsvsrc_detail where (( accnt=@accnt and id=@id  and date_>=@bdate ) or accnt not in(select accnt from master)) and accnt in (select accnt from master where sta in ('I','R'))
    delete rsvsrc_detail where ( accnt=@accnt and id=@id  and date_>=@bdate )
	select @mode='A'
	select @begin_=begin_,@end_=end_,@long=datediff(dd,begin_,end_),@gstno=gstno,@child=child,@ratecode=ratecode,@type=type,@rmrate=rmrate,@rate=rate  from rsvsrc where accnt=@accnt and id=@id
select @begin_old=@begin_ 	
if @begin_<@bdate
	  begin
		 
		 select @begin_= @bdate
	  end
		  
	--是否为升级房
      select @uptype=up_type from master where accnt=@accnt
		if @uptype<>'' and @uptype is not null
        select @type=@uptype
	-- 本日到本日离
	if @begin_=@end_ and @begin_=@begin_old
		begin
			insert rsvsrc_detail select  accnt,id,type,roomno,blkmark,blkcode,@begin_,quantity,gstno,child,isnull(rmrate,0),
													isnull(rate,0),0,0,0,0,0,0,0,0,0,rtreason,remark,saccnt,master,rateok,arr,dep,ratecode,
													src,market,packages,srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
													cby,changed,1,@mode,'F' from rsvsrc where accnt=@accnt and id=@id
			exec @ret =p_gds_get_rmrate @begin_,@long,@type,null,@rmnums,@gstno,@ratecode,'','R',@value out,@msg out
				if @ret<>0
					select @value =null
	
			update rsvsrc_detail set rmrate=isnull(@value,0),rate=isnull(@value,0) where accnt=@accnt and date_=@begin_ and id=@id and rmrate<>@value
		 end
		  update rsvsrc_detail  set exp_m=(select isnull(sum(b.amount*b.quantity),0) from fixed_charge b where rsvsrc_detail.accnt=b.accnt and rsvsrc_detail.date_>=b.starting_time and rsvsrc_detail.date_<=b.closing_time) where accnt=@accnt 
	
	while @end_>@begin_
		 begin
			insert rsvsrc_detail select  accnt,id,type,roomno,blkmark,blkcode,@begin_,quantity,gstno,child,isnull(rmrate,0),
													isnull(rate,0),0,0,0,0,0,0,0,0,0,rtreason,remark,saccnt,master,rateok,arr,dep,ratecode,
													src,market,packages,srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
													cby,changed,1,@mode,'F' from rsvsrc where accnt=@accnt and id=@id
		  exec @ret =p_gds_get_rmrate @begin_,@long,@type,null,@rmnums,@gstno,@ratecode,'','R',@value out,@msg out
				if @ret<>0
					select @value =null

		 ---判断自动变价
           if @rmrate<>@value
              begin
                 if @cmode='1'
                    update rsvsrc_detail set rmrate=isnull(@value,0),rate=isnull(@value,0) where accnt=@accnt and date_=@begin_  and id=@id
                 else if @cmode='2'
                    update rsvsrc_detail set rmrate=isnull(@value,0),rate=isnull(@rate - @rmrate + isnull(@value,0),0) where accnt=@accnt and date_=@begin_  and id=@id
                 else if @cmode='3'
                    update rsvsrc_detail set rmrate=isnull(@value,0),rate=round(isnull(@rate/@rmrate*isnull(@value,0),0),2) where accnt=@accnt and date_=@begin_  and id=@id and @rmrate<>0
					 else
							update rsvsrc_detail set rate=isnull(@value,0) where accnt=@accnt and date_=@begin_ and  id=@id and rate<>@value  and @rate=@rmrate
               end 
         ---2008-6-17
	
                                                                                                                                                
			select @begin_=dateadd(day,1,@begin_)
		 end
		  update rsvsrc_detail  set exp_m=(select isnull(sum(b.amount*b.quantity),0) from fixed_charge b where rsvsrc_detail.accnt=b.accnt and rsvsrc_detail.date_>=b.starting_time and rsvsrc_detail.date_<=b.closing_time) where accnt=@accnt 
	end
;