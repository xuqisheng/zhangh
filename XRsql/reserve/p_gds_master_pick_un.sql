if exists(select 1 from sysobjects where name = "p_gds_master_pick_un")
	drop proc p_gds_master_pick_un;
create proc p_gds_master_pick_un
	@accnt		char(10),
	@empno		char(10),
	@retmode		char(1),			-- S, R
	@ret        int			output,
   @msg        varchar(60) output
as
----------------------------------------------------------------------------------------------
--		取消 分房程序
----------------------------------------------------------------------------------------------
declare		@class	char(1),
				@sta		char(1),
				@roomno	char(1)

select @ret=0, @msg=''

begin tran
save 	tran master_pick

select @class=class, @sta=sta, @roomno=roomno from master where accnt=@accnt
if @@rowcount = 0
begin
	select @ret=1, @msg='账号不存在'
	goto gout
end
if @sta is null or charindex(@sta, 'R')=0
begin
	select @ret=1, @msg='非预订的主单状态'
	goto gout
end
if @class not in ('G', 'M', 'C', 'F') 
begin
	select @ret=1, @msg='非宾客主单'
	goto gout
end
if @roomno = ''
begin
	select @ret=1, @msg='该主单本来就没有房号'
	goto gout
end

update master set roomno='',cby=@empno,changed=getdate()	where accnt=@accnt
if @@rowcount = 0
	select @ret=1, @msg = 'Update Error '
else
begin
	exec @ret = p_gds_reserve_chktprm @accnt,'0','',@empno,'',1,1,@msg output -- ? 
	if @ret = 0
		update master set logmark=logmark+1 where accnt=@accnt
end

--
gout:
if @ret <> 0
	rollback tran master_pick
commit tran
--
if @retmode='S'
	select @ret, @msg
return @ret
;

