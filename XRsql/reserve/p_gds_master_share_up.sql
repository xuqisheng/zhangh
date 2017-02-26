if exists(select 1 from sysobjects where name = "p_gds_master_share_up")
	drop proc p_gds_master_share_up;
create proc p_gds_master_share_up
	@accnt1		char(10),	-- 需要跟进的帐户
	@accnt2		char(10),	-- 向这个帐户看齐
	@empno		char(10),
	@retmode		char(1),			-- S, R
	@ret        int	output,
   @msg        varchar(60) output
as
----------------------------------------------------------------------------------------------
--		同住客人信息跟进 -> sta, roomno, arr, dep
----------------------------------------------------------------------------------------------
declare		@class1	char(1),			@class2	char(1),
				@sta1		char(1),			@sta2		char(1),
				@type1	char(5),			@type2	char(5),
				@roomno1	char(5),			@roomno2	char(5),
				@arr1		datetime,		@arr2		datetime,
				@dep1		datetime,		@dep2		datetime,
				@qtrate1	money,			@qtrate2	money,
				@rmrate1	money,			@rmrate2	money

select @ret=0, @msg='ok'

begin tran
save 	tran master_share_up

-- Justify accnt1
select @class1=class,@sta1=sta,@arr1=arr,@dep1=dep,@roomno1=roomno,@type1=type,@qtrate1=qtrate,@rmrate1=rmrate
	from master where accnt=@accnt1
if @@rowcount <> 1 
begin
	select @ret=1, @msg='主单不存在'
	goto gout
end
if @class1 <> 'F' or charindex(@sta1,'RI')=0
begin
	select @ret=1, @msg='主单类别或者状态不对'
	goto gout
end

-- Justify accnt2
select @class2=class,@sta2=sta,@arr2=arr,@dep2=dep,@roomno2=roomno,@type2=type,@qtrate2=qtrate,@rmrate2=rmrate
	from master where accnt=@accnt2
if @@rowcount <> 1 
begin
	select @ret=1, @msg='主单不存在'
	goto gout
end
if @class2 <> 'F'
begin
	select @ret=1, @msg='主单类别不对'
	goto gout
end

--
update master set sta=@sta2,arr=@arr2,dep=@dep2,roomno=@roomno2,type=@type2,
		qtrate=@qtrate2,rmrate=@rmrate2,cby=@empno,changed=getdate(),logmark=logmark+1 
	where accnt=@accnt1
if @@rowcount = 1
	exec @ret = p_gds_reserve_chktprm @accnt1,'0','',@empno,'',1,1,@msg output
else
begin
	select @ret=1, @msg='主单更新失败'
	goto gout
end

--
gout:
if @ret <> 0
	rollback tran master_share_up

commit tran 

if @retmode='S'
	select @ret, @msg
return @ret
;
