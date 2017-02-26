-----------------------------------------------------------
if  exists(select * from sysobjects where name = "p_gds_master_single_arrdep" and type = "P")
	drop proc p_gds_master_single_arrdep
;
create proc  p_gds_master_single_arrdep
   @accnt    char(10),
   @nroomno		char(5),
   @narr     datetime,
   @ndep     datetime,
   @empno    char(10),
   @request  char(1),		-- 换房理由 
   @nullwithreturn    varchar(60) output
as
-----------------------------------------------------------
--	主要修改：房号、到日、离日
-- 运用的地方：房态表拖动
-----------------------------------------------------------

declare
   @ret     int,
   @msg     varchar(60),
   @sta  	char(1),
   @roomno  char(5),
   @type  	char(5),
   @ntype  char(5),
   @arr  	datetime,
   @dep		datetime,
   @today  	datetime,
   @nrequest char(1),
	@qtrate	money,
	@rmrate	money,
	@setrate	money,
	@discount	money,
	@discount1	money,
	@long			int,
	@rmnums		int,
	@gstno		int,
	@groupno		char(10),
	@ratecode	char(10),
	@rate			money

begin tran
save  tran p_gds_master_single_arrdep_s1

select @nrequest = '0'
select @ret = 0,@msg = "",@today=getdate()

if @ret = 0
	begin
	if rtrim(@nroomno) is null and @narr is null and @ndep is null 
		select @ret = 1,@msg = "请设置正确的参数"
	end

if @ret = 0
   begin
   select @sta=sta, @type=type, @roomno=roomno, @arr=arr, @dep=dep, @gstno=gstno, @rmnums=rmnum, @groupno=groupno, @ratecode=ratecode,
		@qtrate=qtrate, @rmrate=rmrate, @setrate=setrate, @discount=discount, @discount1=discount1
			from master where accnt = @accnt
   if @@rowcount=0 or @sta is null
      select @ret = 1,@msg = "主单%1不存在^"+@accnt
   if charindex(@sta,'OED') > 0
	  select @ret = 1,@msg = "主单已结帐,不允许更改"
   end

if @ret = 0
	begin
	if (rtrim(@nroomno) is null or @nroomno=@roomno)
		and (@narr is null or datediff(dd, @arr, @narr)=0)
		and (@ndep is null or datediff(dd, @dep, @ndep)=0)
		select @ret = 1,@msg = "请设置正确的参数"
	end

if @ret = 0 
   begin
	if @narr is not null and datediff(dd, @arr, @narr)<>0 -- 到日
		begin
		if @sta = 'I' 
			select @ret = 1,@msg = "主单已登记,其到日不能修改"
		else if charindex(@sta,'RCG') > 0
			begin
			if datediff(dd, @today, @narr)<0 
			  select @ret = 1,@msg = "主单的到日不能早于今天"
			end
		end
	else
		select @narr = @arr

	if @ret = 0
		begin
		if @ndep is not null and datediff(dd, @dep, @ndep)<>0   -- 离日
			begin
			if datediff(dd,@ndep,@today) > 0
			  select @ret = 1,@msg = "主单%1的离日不能早于今天^"+@accnt
			else if datediff(dd,@ndep,@narr) > 0
			  select @ret = 1,@msg = "主单%1的离日不能早于到日^"+@accnt
			end
		else
			select @ndep = @dep
		end
   end

if @ret = 0
	begin
	if rtrim(@nroomno) is null  
		select @nroomno = @roomno, @ntype=@type
	else if @nroomno = @roomno
		select @ntype=@type
	else if @nroomno <> @roomno
		begin
		select @type=type from rmsta where roomno=@roomno
		select @ntype=type, @qtrate=rate from rmsta where roomno=@nroomno
		if @type<>@ntype
			begin
			exec p_gds_get_rmrate @narr, @long, @ntype, @nroomno, @rmnums, @gstno, @groupno, @ratecode, 'R', @rate output, @msg output
			select @rmrate=@rate
			if @setrate <> 0 
				select @setrate = @rmrate, @discount=0,  @discount1=0
			end
		end
	end

if @ret = 0
   begin
   update master set sta = sta where accnt = @accnt
	if @sta='I' and @roomno<>@nroomno and @roomno>='0' and @nroomno>='0' 
		update master set arr = @narr,dep = @ndep,type=@ntype,roomno=@nroomno,qtrate=@qtrate, rmreason=@request,  
			rmrate=@rmrate,setrate=@setrate, discount=@discount, discount1=@discount1 where accnt = @accnt 
	else
		update master set arr = @narr,dep = @ndep,type=@ntype,roomno=@nroomno,qtrate=@qtrate, 
			rmrate=@rmrate,setrate=@setrate, discount=@discount, discount1=@discount1 where accnt = @accnt 
   exec @ret = p_gds_reserve_chktprm @accnt,@request,'',@empno,'',1,1,@msg out
   update master set logmark=logmark+1,cby=@empno,changed = getdate() where accnt = @accnt
   end

if @ret <> 0
   rollback tran p_gds_master_single_arrdep_s1
commit tran

if @nullwithreturn  is null
   select @ret,@msg
else
   select @nullwithreturn = @msg
return @ret
;
