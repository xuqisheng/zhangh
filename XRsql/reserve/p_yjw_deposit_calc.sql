if exists(select 1 from sysobjects where name='p_yjw_deposit_calc' and type='P')
drop proc p_yjw_deposit_calc
;
create proc p_yjw_deposit_calc
                  @accnt 	char(10),
                  @pc_id   char(4),
                  @link 	char(1),--是否包括联房
                  @share	char(1) --是否包含同住
as
declare 
  @balance  money,
  @p_bf       money,
  @p_srv      money, 
  @p_lau      money,
  @p_cms      money,
  @p_oth      money,
  @pcrec      char(10),
  @master	  char(10),
  @bdate  	  datetime,
  @date		  datetime,
  @arr		  datetime,
  @dep		  datetime

create table #tmp
 ( 
	date_	 	datetime,
   rmrate   money,	--门市价
   rate     money,	--定价
	trate  	money,   --实际房费
	fixcharge money,	--固定支出
   p_bf   	money,
 	p_srv	 	money,
 	p_lau	 	money,
	p_cms	 	money,
 	p_oth	 	money,
   charge   money,
   credit   money,
	balance 	money,
   pkg      varchar(255),
   tag      char(1), --标志位'T'已经发生的,'F'预测的

 	
)
create table #accnt
(
	accnt char(10)
)

select @bdate=bdate from sysdata


--一个人
if @link<>'T' and @share<>'T'
  begin
	  select @arr=begin_,@dep=end_ from rsvsrc where accnt=@accnt
  	  if @arr>@bdate
        begin
				exec p_yjw_reserve_rsvsrc_calc @accnt,@pc_id,1
            while @dep>@arr
                begin
                  select @balance=balance from #tmp where datediff(dd,date_,dateadd(dd,-1,@arr))=-1
                	if @balance is null 
                     select @balance=isnull(trate,0)+isnull(exp_m,0) from rsvsrc_detail where accnt=@accnt and datediff(dd,date_,@arr)=0
                  else
                     select @balance=@balance+isnull(trate,0)+isnull(exp_m,0) from rsvsrc_detail where accnt=@accnt and datediff(dd,date_,@arr)=0
                 	insert #tmp select @arr,rmrate,rate,trate,exp_m,p_bf,p_srv,p_lau,p_cms,p_ot,isnull(trate,0)+isnull(exp_m,0),0,@balance,packages,'F' from rsvsrc_detail where accnt=@accnt and datediff(day,date_,@arr)=0
                  select @arr=dateadd(dd,1,@arr)
                end
         end
     if @arr<=@bdate
    		begin
				insert #tmp select dateadd(dd,-1,@bdate),0,0,0,0,0,0,0,0,0,charge,credit,charge - credit,packages,'T' from master where accnt=@accnt
            exec p_yjw_reserve_rsvsrc_calc @accnt,@pc_id,1
//            select @arr=dateadd(dd,1,@bdate)
				  select @arr=@bdate
            while @dep>@arr
                begin
                  select @balance=balance from #tmp where date_=dateadd(dd,-1,@arr)
                	if @balance is null 
                     select @balance=isnull(trate,0)+isnull(exp_m,0) from rsvsrc_detail where date_=@arr and accnt=@accnt
                  else
                     select @balance=@balance+isnull(trate,0)+isnull(exp_m,0) from rsvsrc_detail where date_=@arr and accnt=@accnt
                	insert #tmp select @arr,rmrate,rate,trate,exp_m,p_bf,p_srv,p_lau,p_cms,p_ot,trate+exp_m,0,@balance,packages,'F' from rsvsrc_detail where accnt=@accnt and date_=@arr
                  select @arr=dateadd(dd,1,@arr)
                end
         end 
   end 
else
	begin
	--只有联房
	 if @link='T' and @share='F' 
		 begin
			select  @pcrec =pcrec from master where accnt=@accnt and pcrec<>'' and pcrec is not null
         if @pcrec='' or @pcrec is null
				insert #accnt select @accnt
         else 
 				insert #accnt select accnt from master where pcrec=@pcrec

		 end
	 else if @link='F' and @share='T' --只有同住
		 begin
			 select  @master =master from master where accnt=@accnt
			 insert #accnt select accnt from master where master=@master
		 end 
	 else if @link='T' and @share='T' --既有同住又有共享
		 begin
			 select  @master =master from master where accnt=@accnt
			insert #accnt select accnt from master where master=@master
			select  @pcrec =pcrec from master where accnt=@accnt
			if @pcrec='' or @pcrec is null
            begin
					if not exists(select accnt from #accnt where accnt=@accnt)
							insert #accnt select @accnt 
            end
         else 
 				insert #accnt select accnt from master where pcrec=@pcrec and accnt not in(select accnt from #accnt)
		 end

      select @arr=min(begin_),@dep=max(end_) from rsvsrc where accnt in(select accnt from #accnt)
		exec p_yjw_reserve_rsvsrc_calc '',@pc_id,1
		if @arr>@bdate
        begin
           while @dep>@arr
                begin
                  select @balance=balance from #tmp where datediff(dd,date_,dateadd(dd,-1,@arr))=-1
                	if @balance is null 
                     select @balance=sum(isnull(trate,0))+sum(isnull(exp_m,0)) from rsvsrc_detail where accnt in(select accnt from #accnt) and datediff(dd,date_,@arr)=0
                  else
                     select @balance=@balance+sum(isnull(trate,0))+sum(isnull(exp_m,0)) from rsvsrc_detail where accnt in(select accnt from #accnt) and datediff(dd,date_,@arr)=0
                 	insert #tmp select @arr,sum(rmrate),sum(rate),sum(trate),sum(exp_m),sum(p_bf),sum(p_srv),sum(p_lau),sum(p_cms),sum(p_ot),sum(trate)+sum(exp_m),0,@balance,'','F' from rsvsrc_detail where accnt in(select accnt from #accnt) and datediff(day,date_,@arr)=0
                  select @arr=dateadd(dd,1,@arr)
                end
         end
     if @arr<=@bdate
    		begin
				insert #tmp select @bdate,0,0,0,0,0,0,0,0,0,sum(charge),sum(credit),sum(charge - credit),'','T' from master where accnt in(select accnt from #accnt)
//            select @arr=dateadd(dd,1,@bdate)
 				  select @arr=@bdate
            while @dep>@arr
                begin
                  select @balance=balance from #tmp where date_=dateadd(dd,-1,@arr)
                	if @balance is null 
                     select @balance=sum(isnull(trate,0))+sum(isnull(exp_m,0)) from rsvsrc_detail where date_=@arr and accnt in(select accnt from #accnt)
                  else
                     select @balance=@balance+sum(isnull(trate,0))+sum(isnull(exp_m,0)) from rsvsrc_detail where date_=@arr and accnt in(select accnt from #accnt)
                	insert #tmp select @arr,sum(rmrate),sum(rate),sum(trate),sum(exp_m),sum(p_bf),sum(p_srv),sum(p_lau),sum(p_cms),sum(p_ot),sum(trate)+sum(exp_m),0,@balance,'','F' from rsvsrc_detail where accnt in(select accnt from #accnt) and date_=@arr
                  select @arr=dateadd(dd,1,@arr)
                end
         end 
    end 
select * from #tmp

;      
 			 
          
            



   
   