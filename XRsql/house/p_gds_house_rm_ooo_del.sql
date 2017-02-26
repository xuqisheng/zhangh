
if exists (select 1 from sysobjects where name = 'p_gds_house_rm_ooo_del')
	drop proc p_gds_house_rm_ooo_del
;
create proc p_gds_house_rm_ooo_del
    @sfolio     char(10),
	@gmode		char(1),			--  X-取消, O-解除
	@roomno		char(5),
	@sta			char(1),
	@empno		char(10)
as
-- -----------------------------------------------------------------------
-- 		维护房管理表单  --- 维修单的取消,解除
-- 		不提供恢复维修单
--
-- 				特别注意: 当系统没有该单据的时候,也要将维护房解除!!!
-- -----------------------------------------------------------------------
declare 	@ret	int,
			@msg	varchar(60),
            @begin  datetime,
            @end    datetime

select @ret = 0, @msg = 'OK!'

begin tran
save tran p_gds_house_rm_ooo_del1

if not exists ( select 1 from rmsta where roomno = @roomno)
begin
	select @ret=1,@msg='房号不存在'
	goto gds
end
if @gmode='O' and charindex(@sta, 'R,D,I,T') <= 0
begin
	select @ret=1,@msg='维护房解除状态错误 ! --- %1^' + @sta
	goto gds
end
if charindex(@gmode, 'X,O') <= 0
begin
	select @ret=1,@msg='维护房处理状态错误 ! --- %1^' + @gmode
	goto gds
end

if @gmode = 'O' or (@gmode = 'X' and not exists(select 1 from rmsta where sta in ('O','S')))--取消状态（当前还有维修）不影响rmsta
    exec @ret = p_gds_update_room_status @roomno, 'l', @sta, null, null, @empno, 'R', @msg output
    if @ret <> 0
    	goto gds

if exists ( select 1 from rm_ooo where roomno = @roomno and status = 'I')
begin  --  该单据
   	--select @msg = folio from rm_ooo where roomno=@roomno and status = 'I'

	--  解除,取消 对应的工号不一样 !
	if @gmode = 'X'
		update rm_ooo set status=@gmode, empno4=@empno, date4=getdate(), logmark = logmark + 1
			where roomno=@roomno and status = 'I' and  folio=@sfolio
	else
		update rm_ooo set status=@gmode, empno3=@empno, date3=getdate(), logmark = logmark + 1
			where roomno=@roomno and status = 'I' and folio=@sfolio

	if @@error <> 0
		select @ret = 1, @msg = '数据更新失败 !'
   else
      begin
      select @begin=min(dbegin) from rm_ooo where roomno=@roomno and status='I'
      if @begin<>'' and @begin is not null
        	begin
         select @end=dend,@sta=sta from rm_ooo where roomno=@roomno and status='I' and dbegin=@begin
         exec p_gds_update_room_status @roomno, 'L', @sta, @begin, @end, @empno, 'R', @msg output
         end
      end
end

gds:
if @ret <> 0
	rollback tran p_gds_house_rm_ooo_del1
commit tran

select @ret, @msg
return @ret
;