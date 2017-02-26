
drop  proc p_cyj_bar_audit_exec;
create proc p_cyj_bar_audit_exec
	@ret			integer		output,
	@msg			char(80)		output
as
--------------------------------------------------------------------------------
--
--每日结转，没有月结概念
--
--------------------------------------------------------------------------------
declare	
	@bdate		datetime,
	@truedate	datetime,
	@count	int


select @bdate = bdate1 from sysdata				--餐饮系统时间

select @truedate = convert(datetime,convert(char(10),truedate,111)) from pos_st_sysdata			--吧台系统时间,取消时间

-- 当天吧台已经结转，通过系统日期一致性来判断是否已结转
if @bdate = @truedate
	return

select @count = count(1) from pos_sale
insert pos_hsale select * from pos_sale								--如果失败该怎么处理，pos_sale中第二天又马上会有新数据
if @@rowcount <> @count
begin 
	select @msg = '当天销售数据转入历史失败，请检查！'
	return
end
else
	delete from pos_sale

begin tran 
save  tran t_bar_audit
select @ret = 0, @msg = ''

exec p_fhb_docu_dayturn @pc_id='0.00',@vdate=@truedate,@ret=@ret out,@msg=@msg out

if @ret <> 1
	rollback tran         --结转操作回滚，第二天做手工结转

commit tran



select @ret =0,@msg =''
return @ret
;
