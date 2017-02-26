if exists(select 1 from sysobjects where name = "p_gds_reserve_master_tran")
	drop proc p_gds_reserve_master_tran;
create  proc p_gds_reserve_master_tran
	@accnt   	char(10),
   @grpno  		char(10),	-- 有团号表示入团,否则表示出团
   @empno   	char(10)
as
----------------------------------------------------------------------------------------------
--		散客,成员 转化程序
--
--			注意: 房价, 日期
----------------------------------------------------------------------------------------------
declare
   @ret      	int,
   @msg      	varchar(60),
   @sta   		char(1),
	@nrequest	char(1),
   @grpsta   	char(1),
	@class		char(1),
	@roomno		char(5),
	@arr			datetime,
	@dep			datetime,
	@grparr		datetime,
	@grpdep		datetime,
	@setrate		money,
	@type			char(5),
	@subaccnt 	int,
	@count		int,
	@ogrpno		char(10)

begin tran
save  tran p_gds_reserve_master_tran_s1

select @nrequest = '0',@ret = 0,@msg=''
select @sta = sta, @class=class, @setrate=setrate, @type=type, @ogrpno=groupno, @arr=arr, @dep=dep  
	from master where accnt = @accnt and charindex(sta, 'RCGIS') > 0
if @@error<>0 or @@rowcount = 0
begin
	select @ret = 1,@msg = "当前客人不存在或非有效状态"
	goto gout
end
if @class<>'F' 
begin
	select @ret=1, @msg = "非宾客账户"
	goto gout
end

-- Begin ...
if rtrim(@grpno) is not null  -- 入团
begin
	select @grpsta = sta, @grparr=arr, @grpdep=dep from master 
		where accnt = @grpno and class in ('G', 'M') and charindex(sta, 'RCGI') > 0
	if @@error <> 0 or @@rowcount = 0
		select @ret = 1,@msg = "当前团体不存在或非有效状态"
--	else if exists(select 1 from master where accnt = @accnt and groupno <> '')
--			select @ret = 1,@msg = "当前宾客已经是某团体成员, 请先转化为散客"
	else if exists(select 1 from master where accnt = @accnt and groupno = @grpno)
		select @ret = 1,@msg = "当前宾客已经是该团体成员"
	else if @grpsta<>'I' and @sta='I'
		select @ret = 1,@msg = "团体主单尚未登记"
	else if exists(select 1 from master where accnt = @accnt and rmnum > 1)
		or (select count(1) from rsvsrc where accnt=@accnt)>1
		select @ret = 1,@msg = "当前宾客有多间订房，不能进行该项操作 !"
	else if datediff(dd,@grpdep,@dep)>0 or (@grpsta='R' and datediff(dd,@grparr,@arr)<0) 
		select @ret = 1,@msg = "宾客抵离日期必须包含于团体抵离日期"
	if @ret<>0 goto gout

	update master set groupno=@grpno,rmrate=@setrate,setrate=@setrate,cby=@empno,changed=getdate(),logmark=logmark+1 where accnt=@accnt
	if @@rowcount=0
		select @ret = 1,@msg = "转化失败"
	else 
	begin
		-- 维护团体房价  grprate
		if not exists(select 1 from grprate where accnt=@grpno and type=@type)
			insert grprate(accnt,type,rate,oldrate,cby,changed)
				values(@grpno,@type,@setrate,@setrate,@empno,getdate())
		-- 维护分帐号  -- 团体付费  subaccnt
		if not exists(select 1 from subaccnt where accnt=@accnt and to_accnt=@grpno and type='5')
		begin
			select @subaccnt=isnull((select max(subaccnt) from subaccnt where accnt=@accnt and type='5')+1,2)
			insert subaccnt select a.roomno, '', a.accnt, @subaccnt, '', a.groupno, '团体付费', b.pccodes, '2000.1.1', '2030.1.1', a.cby, a.changed, '5', '0', '', '', 1
				from master a, subaccnt b where a.groupno = b.accnt and b.type = '2' and a.accnt=@accnt
		end

		-- 去掉原来的团体信息
		if @ogrpno <> ''
		begin
			select @count = count(1) from subaccnt where accnt=@accnt and to_accnt=@ogrpno and type='5'
			if @count = 1   -- 只有一个分账户
			begin
				select @subaccnt = subaccnt from subaccnt where accnt=@accnt and to_accnt=@ogrpno and type='5'
				if exists(select 1 from account where accnt=@accnt and subaccnt=@subaccnt)
					update subaccnt set pccodes='.', tag='2' where accnt=@accnt and to_accnt=@ogrpno and type='5'
				else
				begin
					delete subaccnt where accnt=@accnt and to_accnt=@ogrpno and type='5'
				end
			end
			else
			begin
				update subaccnt set pccodes='.', tag='2' where accnt=@accnt and to_accnt=@ogrpno and type='5'
			end
			
		end
	end
end
else								-- 出团
begin
	select @grpno=groupno from master where accnt=@accnt
	if @grpno=''
		select @ret = 1,@msg = "该主单本是散客, 不需要出团 !"
	else
	begin
		update master set groupno='', cby=@empno, changed=getdate(),logmark=logmark+1 where accnt=@accnt
		if @@rowcount=0
			select @ret = 1,@msg = "转化失败"
		else  -- 团体付费分账户(自动清除，或者 封锁项目)
		begin
			select @count = count(1) from subaccnt where accnt=@accnt and to_accnt=@grpno and type='5'
			if @count = 1   -- 只有一个分账户
			begin
				select @subaccnt = subaccnt from subaccnt where accnt=@accnt and to_accnt=@grpno and type='5'
				if exists(select 1 from account where accnt=@accnt and subaccnt=@subaccnt)
					update subaccnt set pccodes='.', tag='2' where accnt=@accnt and to_accnt=@grpno and type='5'
				else
				begin
					delete subaccnt where accnt=@accnt and to_accnt=@grpno and type='5'
				end
			end
			else
			begin
				update subaccnt set pccodes='.', tag='2' where accnt=@accnt and to_accnt=@grpno and type='5'
			end
		end
	end
end

if @ret=0   -- 维护团体主单
	exec @ret = p_gds_maintain_group @grpno, @empno, 1, @msg output

-- End ...
gout:
if @ret <> 0
   rollback tran p_gds_reserve_master_tran_s1
commit tran

exec p_gds_master_des_maint @accnt   -- master_des  不放入事务了

select @ret,@msg

return @ret
;
