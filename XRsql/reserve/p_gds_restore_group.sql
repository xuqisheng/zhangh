if exists(select * from sysobjects where name = "p_gds_restore_group")
   drop proc p_gds_restore_group
;
create  proc p_gds_restore_group
   @grpaccnt char(10),
   @narr     datetime,       -- 恢复后团体主单新的到日
   @ndep     datetime,       -- 恢复后团体主单新的离日
   @empno    char(10),
	@retmode		char(1),
	@ret			int	output,
	@msg			varchar(60) output
as
-- 团体/会议  预订恢复

declare
   @sta     char(1)

select @ret=0, @msg=''

begin tran
save  tran p_gds_restore_group_s1

update master set sta = sta where accnt = @grpaccnt
select @sta = sta from master where accnt = @grpaccnt and class in ('G', 'M')
if @@rowcount = 0
begin
   select @ret = 1,@msg = "团体主单%1不存在^"+@grpaccnt
	goto gout
end

if charindex(@sta,'I') > 0
   select @ret = 1,@msg = "团体主单%1已经登记,不需恢复^"+@grpaccnt
else if charindex(@sta,'RCG') > 0
   select @ret = 1,@msg = "团体主单%1已经是有效预订状态,不需恢复^"+@grpaccnt
else if charindex(@sta,'XNL') = 0
   select @ret = 1,@msg = "团体主单%1并非取消预订团体,不能恢复^"+@grpaccnt
if @ret = 0
begin
   update master set sta = 'R',arr = @narr,dep=@ndep,logmark=logmark+1,cby=@empno,changed = getdate() where accnt = @grpaccnt

	-- 如果有原来取消的预留资源，暂时不考虑自动追回 
	-- rsvsrc_cxl 

end 

gout:
if @ret <> 0
	rollback tran p_gds_restore_group_s1
commit tran
if @retmode='S'
	select @ret,@msg
return @ret
;
