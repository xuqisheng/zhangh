if object_id('p_yjw_rsvsrc_detail_accnt') is not null
drop proc p_yjw_rsvsrc_detail_accnt
;
create procedure p_yjw_rsvsrc_detail_accnt
                   @accnt char(10)

as

-- rsvsrc----->rsvsrc_detail
-- @accnt='' or @accnt is null   ɨ������rsvsrc���δ��ֹ��ļ�¼��ֵ�rsvsrc_detail
-- @accnt=accnt                  �ж��˺�Ϊaccnt�ļ�¼�Ƿ��ֹ������û�У����в��
-- �����Ӧrsvsrc���������Ѿ���֣����ܶԷ��ࡢ�����������������½����޸ģ�ֻ������ϸ�����½��е���������Ҳֻ��
-- �Ե�һ����¼�ķ��ࡢ����������޸�
-- ���������

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
   @quantity  money,
   @long      int,
   @rmnums    int,
   @roomno    char(5),
   @mode      char(1),
   @typem     char(5),    --master���е�type����
   @uptype    char(5),
   @cmode     char(1),     --�Զ����ģʽ
	@zk_rate		money,
   @sta        char(1)

--�Զ����ģʽ 1 �ϸ���ѭЭ��� 2����۽��б�� 3 ���������б��
select @cmode = isnull((select substring(value,1,1) from sysoption where catalog = 'reserve' and item = 'rmrate_autochg_mode'), '0')
if charindex(@cmode, '123') = 0
   select @cmode='0'



select @rmnums=1,@roomno=null
select @bdate=bdate from sysdata

select @begin1_=min(date_) from rsvsrc_detail where accnt=@accnt
if @begin1_<@bdate
	select @begin1_=@bdate

select @type=type from rsvsrc_detail where accnt=@accnt and date_=@begin1_
select @typem=type,@uptype=up_type from master where accnt=@accnt

select @sta=sta from master where accnt=@accnt

if @type<>@typem and ((@uptype='' or @uptype is null) and not exists (select 1 from rsvsrc_detail where accnt=@accnt and mode='M' and date_>=@bdate ))
	delete rsvsrc_detail where accnt=@accnt and date_>=@bdate


if exists (select 1 from rsvsrc_detail where accnt=@accnt and mode='M' and date_>=@bdate )
	begin  --4
    select @mode='M'
	 select @begin_=begin_,@end_=end_,@long=datediff(dd,begin_,end_),@gstno=gstno,@child=child from rsvsrc where accnt=@accnt
	 select @begin1_=min(date_),@end1_=max(date_) from rsvsrc_detail where accnt=@accnt
	 if @begin_<@bdate
		 select @begin_=@bdate
	 -- ������ǰ
	 if @begin_<@begin1_
		 begin
			select @gstno=gstno,@type=type,@rate=rate,@rmrate=rmrate,@ratecode=ratecode,@package=packages from rsvsrc_detail where accnt=@accnt and date_=@begin1_
			while @begin_<@begin1_
				begin
					insert rsvsrc_detail select  accnt,id,type,roomno,blkmark,blkcode,@begin_,quantity,gstno,child,isnull(rmrate,0),
														  isnull(@rate,isnull(rate,0)),0,0,0,0,0,0,0,0,0,rtreason,remark,saccnt,master,rateok,arr,dep,isnull(@ratecode,ratecode),
														  src,market,isnull(@package,packages),srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
														  cby,changed,1,@mode,'F' from rsvsrc where accnt=@accnt
					exec @ret =p_gds_get_rmrate @begin_,@long,@type,@roomno,@rmnums,@gstno,@ratecode,'','R',@value out,@msg out
					if @ret<>0
						select @value =null
				---�ж��Զ����
           	if @rmrate<>@value and @value is not null and @rate<>0 --���ȡ��������,rsvsrc_detail�ļ۸񲻱�
              begin
                  update rsvsrc_detail set rmrate=isnull(@value,0) where accnt=@accnt and date_=@begin_
                 if @cmode='1'
                    update rsvsrc_detail set rate=isnull(@value,0) where accnt=@accnt and date_=@begin_ and @rate<>0
                 else if @cmode='2'
						  begin
						  select @zk_rate = isnull(@rate - @rmrate + isnull(@value,0),0)
						  if @zk_rate < 0 select @zk_rate = 0
                    update rsvsrc_detail set rate=@zk_rate where accnt=@accnt and date_=@begin_ and @rate<>0
						  end
                    --update rsvsrc_detail set rmrate=isnull(@value,0),rate=isnull(@rate - @rmrate + isnull(@value,0),0) where accnt=@accnt and date_=@begin_
                 else if @cmode='3'
                    update rsvsrc_detail set rate=round(isnull(@rate/@rmrate*isnull(@value,0),0),2) where accnt=@accnt and date_=@begin_ and @rate<>0 and @rmrate<>0
					  else
						update rsvsrc_detail set rate=isnull(@value,0) where accnt=@accnt and date_=@begin_ and rate<>@value and @rate=@rmrate
               end
				---2008-6-17
 					select @begin_=dateadd(day,1,@begin_)
				end
			update rsvsrc_detail  set exp_m=(select isnull(sum(b.amount*b.quantity),0) from fixed_charge b where rsvsrc_detail.accnt=b.accnt and rsvsrc_detail.date_>=b.starting_time and rsvsrc_detail.date_<=b.closing_time) where accnt=@accnt
		 end
	 -- �����Ӻ�
	 if @begin_>@begin1_ and @begin_<>@bdate
		 begin
         delete  rsvsrc_detail  from rsvsrc_detail a,master b where a.date_<@begin_ and a.accnt=@accnt and a.accnt=b.accnt and b.sta<>'I'
		 end
    -- ������ǰ
	 if @end_<=@end1_
		 begin
 			delete rsvsrc_detail where date_>dateadd(day,-1,@end_) and accnt=@accnt
		 end
	 -- �����Ӻ�
	 if @end_>@end1_
		 begin   --3
			select @type=type,@gstno=gstno,@child=child,@rate=rate,@rmrate=rmrate,@ratecode=ratecode,@package=packages from rsvsrc_detail where accnt=@accnt and date_=@end1_
         select @long=datediff(dd,begin_,end_) from rsvsrc where accnt=@accnt
			while @end1_<dateadd(day,-1,@end_)
			begin  --2
			  select @end1_=dateadd(day,1,@end1_)

           insert rsvsrc_detail select accnt,id,@type,roomno,blkmark,blkcode,@end1_,quantity,gstno,child,isnull(rmrate,0),isnull(rate,0),0,0,0,0,0,0,0,0,0,
                                       rtreason,remark,saccnt,master,rateok,arr,dep,ratecode,src,market,packages,srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
														cby,changed,1,mode,'F' from rsvsrc_detail where accnt=@accnt and date_=dateadd(day,-1,@end1_)

			  exec @ret =p_gds_get_rmrate @begin_,@long,@type,@roomno,@rmnums,@gstno,@ratecode,'','R',@value out,@msg out
					if @ret<>0
						select @value =null
				---�ж��Զ����
           if @rmrate<>@value and @value is not null and @rate<>0
              begin
                 update rsvsrc_detail set rmrate=isnull(@value,0) where accnt=@accnt and date_=@end1_
                 if @cmode='1'
                    update rsvsrc_detail set rate=isnull(@value,0) where accnt=@accnt and date_=@end1_ and @rate<>0
                 else if @cmode='2'
						  begin
						  select @zk_rate = isnull(@rate - @rmrate + isnull(@value,0),0)
						  if @zk_rate < 0 select @zk_rate = 0
                    update rsvsrc_detail set rate=@zk_rate where accnt=@accnt and date_=@end1_ and @rate<>0
						  end
                 else if @cmode='3'
                    update rsvsrc_detail set rate=round(isnull(@rate/@rmrate*isnull(@value,0),0),2) where accnt=@accnt and date_=@end1_ and @rate<>0 and @rmrate<>0
						else
						update rsvsrc_detail set rate=isnull(@value,0) where accnt=@accnt and date_=@begin_ and rate<>@value  and @rate=@rmrate
               end
           ---2008-6-17


			end  --2
		 end    --3
		update rsvsrc_detail  set exp_m=(select isnull(sum(b.amount*b.quantity),0) from fixed_charge b where rsvsrc_detail.accnt=b.accnt and rsvsrc_detail.date_>=b.starting_time and rsvsrc_detail.date_<=b.closing_time) where accnt=@accnt
        if @uptype<>'' and @uptype is not null
           update   rsvsrc_detail set rsvsrc_detail.type=a.type,rsvsrc_detail.roomno=a.roomno,rsvsrc_detail.rtreason=a.rtreason from master a where rsvsrc_detail.accnt=a.accnt and rsvsrc_detail.date_>=@bdate
		if @sta='I'	
			update master set setrate=a.rate from rsvsrc_detail a where master.accnt=a.accnt and a.date_=@bdate and master.accnt=@accnt
      else
			update master set setrate=a.rate from rsvsrc_detail a where master.accnt=a.accnt and a.date_=@begin_ and master.accnt=@accnt
  end  --4
else
	begin
--     delete rsvsrc_detail where accnt=@accnt and date_>=@bdate
	  --delete rsvsrc_detail where accnt=@accnt and date_>=@bdate and accnt in (select accnt from master where sta in ('I','R')) -- modi by zk 2008-11-19
	  delete rsvsrc_detail from master a where a.accnt = rsvsrc_detail.accnt and rsvsrc_detail.accnt=@accnt and a.sta in ('I','R') and datediff(dd,rsvsrc_detail.date_,@bdate)<=0
	  delete rsvsrc_detail from master a where a.accnt = rsvsrc_detail.accnt and rsvsrc_detail.accnt=@accnt and a.sta not in ('I','R')
							and datediff(dd,rsvsrc_detail.date_,a.dep) < 0
     select @mode='A'
	  select @begin_=begin_,@end_=end_,@long=datediff(dd,begin_,end_),@gstno=gstno,@child=child,@ratecode=ratecode,@type=type,@rmrate=rmrate,@rate=rate  from rsvsrc where accnt=@accnt
    
	  select @begin_old=@begin_ 

	  if @begin_<@bdate
          begin 
				
				select @begin_= @bdate
			 end
             
      select @begin1_=@begin_
		--�Ƿ�Ϊ������
      select @uptype=up_type from master where accnt=@accnt
		if @uptype<>'' and @uptype is not null
        select @type=@uptype
     -- ���յ�������

     if @begin_=@end_ and @begin_old=@begin_ 
         begin
				
				insert rsvsrc_detail select  accnt,id,type,roomno,blkmark,blkcode,@begin_,quantity,gstno,child,isnull(rmrate,0),
														isnull(rate,0),0,0,0,0,0,0,0,0,0,rtreason,remark,saccnt,master,rateok,arr,dep,ratecode,
														src,market,packages,srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
														cby,changed,1,@mode,'F' from rsvsrc where accnt=@accnt


			   exec @ret =p_gds_get_rmrate @begin_,@long,@type,null,@rmnums,@gstno,@ratecode,'','R',@value out,@msg out
				if @ret<>0
					select @value =null

				update rsvsrc_detail set rmrate=isnull(@value,0),rate=isnull(@value,0) where accnt=@accnt  and date_=@begin_ and rmrate<>@value
			 end

--���� ��
			  --update rsvsrc_detail  set exp_m=(select isnull(sum(b.amount*b.quantity),0) from fixed_charge b where rsvsrc_detail.accnt=b.accnt and rsvsrc_detail.date_>=b.starting_time and rsvsrc_detail.date_<=b.closing_time) where accnt=@accnt
--���� ��

		while @end_>@begin_
			 begin

				insert rsvsrc_detail select  accnt,id,type,roomno,blkmark,blkcode,@begin_,quantity,gstno,child,isnull(rmrate,0),
														isnull(rate,0),0,0,0,0,0,0,0,0,0,rtreason,remark,saccnt,master,rateok,arr,dep,ratecode,
														src,market,packages,srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
														cby,changed,1,@mode,'F' from rsvsrc where accnt=@accnt
			  exec @ret =p_gds_get_rmrate @begin_,@long,@type,null,@rmnums,@gstno,@ratecode,'','R',@value out,@msg out

					if @ret<>0
						select @value =null
           ---�ж��Զ����
           if @rmrate<>@value and @value is not null
              begin
		            update rsvsrc_detail set rmrate=isnull(@value,0)where accnt=@accnt and date_=@begin_
                 if @cmode='1'
                    update rsvsrc_detail set rate=isnull(@value,0) where accnt=@accnt and date_=@begin_ and @rate<>0
                 else if @cmode='2'
						  begin
						  select @zk_rate = isnull(@rate - @rmrate + isnull(@value,0),0)
						  if @zk_rate < 0 select @zk_rate = 0
                    update rsvsrc_detail set rate=@zk_rate where accnt=@accnt and date_=@begin_  and @rate<>0
						  end
                    --update rsvsrc_detail set rmrate=isnull(@value,0),rate=isnull(@rate - @rmrate + isnull(@value,0),0) where accnt=@accnt and date_=@begin_
                 else if @cmode='3'
                    update rsvsrc_detail set rate=round(isnull(@rate/@rmrate*isnull(@value,0),0),2) where accnt=@accnt and date_=@begin_ and @rate<>0  and @rmrate<>0
					  else
						update rsvsrc_detail set rate=isnull(@value,0) where accnt=@accnt and date_=@begin_ and rate<>@value  and @rate=@rmrate
               end
           ---2008-6-17
				select @begin_=dateadd(day,1,@begin_)
			 end
           update master set setrate=a.rate from rsvsrc_detail a where master.accnt=a.accnt and a.date_=@begin1_ and master.accnt=@accnt
			  update rsvsrc_detail  set exp_m=(select isnull(sum(b.amount*b.quantity),0) from fixed_charge b where rsvsrc_detail.accnt=b.accnt and rsvsrc_detail.date_>=b.starting_time and rsvsrc_detail.date_<=b.closing_time) where accnt=@accnt
	end
;