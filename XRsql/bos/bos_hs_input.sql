-------------------------------------------------------------------------
--		客房中心 快速入账 -------  两种方式
--
--			bos_trans
--			p_gds_bos_quick_input_new	--- 前台收银进行
--			p_gds_bos_quick_input		--- 房态表上进行
--
-------------------------------------------------------------------------


-------------------------------------------------------------------------
--	客房中心 快速入账 -----------	基于明细账的方式
-------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_quick_input_new" and type = "P")
   drop proc p_gds_bos_quick_input_new;
create proc     p_gds_bos_quick_input_new
   @modu_id  char(2),
   @pc_id    char(4),
   @foliono  char(10),
   @sfoliono char(10),
   @site     char(5),
   @pccode   char(5),
   @mode   	 char(1),
	@reason	 char(3),
   @empno    char(10),
	@shift	 char(1),
   @accnt    char(17),    			-- 转帐帐号 <+ 分账号 + 客人号> 
   @returnmode  char(1) = 'S'    -- 返回模式 
as

declare 
	@roomno			char(5),
	@paycode			char(5),
	@fee			 	money,
	@ret			 	int,
	@msg			 	varchar(60)

-- -- 目前的系统还没有全部实现此功能 - gds 2001/08
--declare 
--	@subact			varchar(3),
--	@guestid			varchar(7)
--select @subact=substring(@accnt,8,3), @guestid=substring(@accnt,11,7)

select @fee=0, @ret=0, @msg=''
select @accnt=substring(@accnt,1,10)

begin tran
save tran sss

exec @ret = p_gds_bos_input_dish @modu_id,@pc_id,@foliono output,@sfoliono,@site,@pccode,
   @mode,@reason,@empno,@shift,'R'
if @ret <> 0
	begin
	select @msg = 'Input dish error -- ' + @foliono
	goto gout
	end

update bos_folio set checkout=@pc_id where foliono = @foliono 	-- mark
select @fee = fee from bos_folio where foliono = @foliono

-- 付款
select @roomno = isnull((select roomno from  master where accnt=@accnt), '')
if substring(@accnt,1,1)='A' 
	select @paycode='TOR'
else
	select @paycode='TOA'
select @paycode=pccode from pccode where deptno2 = @paycode
exec @ret = p_gds_bos_input_credit @modu_id, @pc_id, @shift, @empno, @paycode, '', @fee, @accnt, @roomno, '','',0,'R'
if @ret <> 0 
	begin
	select @msg = 'Input credit error !'
	goto gout
	end

-- 结账
exec @ret = p_gds_bos_settlement @modu_id, @pc_id, 'R', '', @msg output 
--if @ret <> 0 
--	select @msg = '可能不允许签单 !'
--	select @msg = 'Settlement error !'

-- 出口
gout:
if @ret <> 0 
	rollback tran sss
else
	select @msg = @foliono
commit tran
if @returnmode = 'S' 
	select @ret, @msg
return  @ret
;


-------------------------------------------------------------------------
--	客房中心 快速入账 ------- 基于费用码的方式
-------------------------------------------------------------------------
if exists(select * from sysobjects where name = "bos_trans" and type = "U")
   drop table bos_trans;
create table  bos_trans
(
	modu_id			char(2)				not null,
	pc_id				char(4)				not null,
	pccode			char(5)				not null,
	mode			 	char(3)				null,
   pfee_base	 	money	default 0 	not null,
   serve_type	 	char	default '0'	not null,
   serve_value	 	money	default 0 	not null,
   tax_type	 		char	default '0'	not null,
   tax_value	 	money	default 0 	not null,
   disc_type	 	char	default '0'	not null,
   disc_value	 	money	default 0 	not null,
	reason			char(3)				null
)
exec sp_primarykey bos_trans, modu_id, pc_id, pccode
create unique index index1 on bos_trans(modu_id, pc_id, pccode)
;


if exists(select * from sysobjects where name = "p_gds_bos_quick_input" and type = "P")
   drop proc p_gds_bos_quick_input;
create proc     p_gds_bos_quick_input
   @modu_id	    char(2),
   @pc_id		 char(4),
   @posno	 	 char(2),	 
   @shift		 char(1),
   @empno		 char(10),
   @accnt       char(10),    	--转帐帐号
   @room        char(5),    	--转帐房号
   @returnmode  char(1) = 'S'	--返回模式
as

declare 
   @foliono	    char(10),   --流水号
   @pccode		 char(5),	 --费用码
   @mode		 	 char(3),	
	@paycode		 char(5), 
   @pfee_base	 money,		--原基本费
   @serve_type	 char(1),	--服务费定义
   @serve_value money,		
   @tax_type	 char(1),	--附加费定义
   @tax_value   money,		
   @disc_type	 char(1),	--折扣定义
   @disc_value  money,		
	@reason		 char(3),		--优惠原因
	@ret			 int,
	@msg			 varchar(60),
	@fee			 money

select @fee=0, @ret=0, @msg=''

if not exists(select 1 from bos_trans where modu_id = @modu_id and pc_id = @pc_id)
	begin
	select @ret = 1, @msg = '没有需要入账的项目 !'
	if @returnmode = 'S' 
		select @ret, @msg
	return @ret
	end

begin tran
save tran sss

-- 每做一个单据，自动 mark
declare c_folio cursor for 
	select pccode,mode,pfee_base,serve_type,serve_value,tax_type,tax_value,disc_type,disc_value,reason
		from bos_trans where modu_id = @modu_id and pc_id=@pc_id order by pccode
open c_folio 
fetch c_folio into @pccode,@mode,@pfee_base,@serve_type,@serve_value,@tax_type,@tax_value,@disc_type,@disc_value,@reason
while @@sqlstatus = 0
	begin
	exec @ret = p_gds_bos_input_charge_etc @modu_id, @pc_id, @shift, @empno,
	   '', @pccode, @posno,	@room, @mode,'M', 
		@pfee_base, @serve_type, @serve_value, @tax_type, @tax_value,
		@disc_type, @disc_value, @reason, '', 'A', null, null, null, null, 'R', @msg output
	if @ret <> 0 
		goto gout
   update bos_folio set checkout=@pc_id where foliono = @msg  		-- mark
	select @fee = @fee + fee from bos_folio where foliono = @msg  	-- sum fee
	fetch c_folio into @pccode,@mode,@pfee_base,@serve_type,@serve_value,@tax_type,@tax_value,@disc_type,@disc_value,@reason
	end
close c_folio
deallocate cursor c_folio

-- 付款
if substring(@accnt,1,1)='A' 
	select @paycode='TOR'
else
	select @paycode='TOA'
select @paycode=pccode from pccode where deptno2 = @paycode
exec @ret = p_gds_bos_input_credit @modu_id, @pc_id, @shift, @empno, @paycode, '', @fee, @accnt, @room, '', '', 0, 'R'
if @ret <> 0 
	goto gout

-- 结账
exec @ret = p_gds_bos_settlement @modu_id, @pc_id, 'R'

gout:
if @ret <> 0 
	rollback tran sss
delete bos_trans where modu_id = @modu_id and pc_id = @pc_id
commit tran

if @returnmode = 'S' 
	select @ret, @msg
return  @ret
;
