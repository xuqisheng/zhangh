/* 

团体主单预订转登记 

*/

if exists(select * from sysobjects where name = "p_gds_reserve_register_group")
	drop proc p_gds_reserve_register_group
;
create  proc p_gds_reserve_register_group
   @grpaccnt 	char(10),
   @empno    	char(10),
	@retmode		char(1),
	@ret			int	output,
	@msg			varchar(60)	output
as

declare
   @sta     char(1),
   @arr     datetime

begin tran
save  tran p_gds_reserve_register_group

select @ret=0, @msg=''
update master set sta = sta where accnt = @grpaccnt
select @sta = sta,@arr = convert(datetime,convert(char(10),arr,111)) 
	from master where accnt = @grpaccnt and class in ('G', 'M')
if @@rowcount = 0
begin
	select @ret = 1,@msg = "团体主单%1不存在^"+@grpaccnt
	goto gout
end

if charindex(@sta,'I') > 0
   select @ret = 1,@msg = "团体主单%1已经登记^"+@grpaccnt
else if charindex(@sta,'RCG') = 0
   select @ret = 1,@msg = "团体主单%1不是有效预订状态,不能转登记^"+@grpaccnt
else if @arr > convert(datetime,convert(char(10),getdate(),111))
   select @ret = 1,@msg = "未到团体%1的到达日期,请先修改到日^"+@grpaccnt
else if @arr < convert(datetime,convert(char(10),getdate(),111))
   select @ret = 1,@msg = "团体%1的到日已过期,请先修改到日^"+@grpaccnt
if @ret = 0
   update master set sta = 'I',arr = getdate(),logmark=logmark+1,cby=@empno,changed = getdate() where accnt = @grpaccnt

-- End ...
gout:
if @ret <> 0 
	rollback tran p_gds_reserve_register_group
commit tran
if @retmode='S'
	select @ret,@msg
return @ret
;
