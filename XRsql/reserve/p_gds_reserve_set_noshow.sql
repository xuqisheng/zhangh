
/* No Show */

if exists(select * from sysobjects where name = "p_gds_reserve_set_noshow")
   drop proc p_gds_reserve_set_noshow
;
create  proc p_gds_reserve_set_noshow
   @empno    char(10),
	@accnt	 char(10),
   @retmode  char(1),
   @ret      int,
   @msg      varchar(70)

as

---- 可以针对某一个账号进行；

declare
	@sta     		char(1),
	@maccnt   		char(7),
	@today   		datetime,
	@arr     		datetime

select @ret=0, @msg ="", @today=convert(datetime,convert(char(10),getdate(),111))
select @accnt = isnull(rtrim(@accnt),'')

if datepart(hour,getdate()) < 18 and @accnt=''
begin
	select @ret=1,@msg='请在18点以后做此功能'
	if @retmode ='S'
		select @ret,@msg
	return @ret
end

declare c_set_noshow cursor for
		  select accnt from master 
			where class='F' and groupno='' and charindex(sta,'RCG') > 0  and datediff(day,@today,arr) <= 0
				and (@accnt='' or accnt=@accnt)
        order by accnt
open  c_set_noshow
fetch c_set_noshow into @maccnt
while @@sqlstatus = 0
begin
	begin tran		-- 每取消一个账号作为一个事务
	save  tran p_hry_reserve_set_nowshow_s1

	update master set sta = sta where accnt = @maccnt
	select @sta = sta,@arr=arr from master where accnt = @maccnt
	if charindex(@sta,'RCG') > 0 and datediff(day,@today,@arr) <= 0
	begin
		update master set sta = 'N' where accnt = @maccnt
		exec @ret = p_gds_reserve_chktprm @maccnt,'0','',@empno,'',1,0,@msg out
		if @ret = 0
		  update master set logmark=logmark+1,cby=@empno,changed = getdate() where accnt = @maccnt
	end

	if @ret <> 0
	  rollback tran p_hry_reserve_set_nowshow_s1
	commit tran

	select @ret=0,@msg=''
	fetch c_set_noshow into @maccnt
end
close  c_set_noshow
deallocate cursor c_set_noshow

if @retmode ='S'
   select @ret,@msg
return @ret
;
