//----------------------------------------------------------------------
//  bos_kcmenu    ----->      bos_store
//  帐单入帐、冲帐、补救 
//----------------------------------------------------------------------
if exists (select 1 from sysobjects where name ='p_wz_bos_kc_folio_input')
	drop proc p_wz_bos_kc_folio_input ;
create proc p_wz_bos_kc_folio_input 
	@modu_id 		char(2),
	@pc_id			char(4),
	@mode				char(2),		//IN-入帐	OU-冲帐    BJ-补救
	@folio			char(10),
	@empno			char(10),
	@msg				varchar(60) output,
	@returnmode		char(1)  = 'S'  
as
declare 	@flag		char(2),
			@pccode	char(3),
			@sta		char(1),
			@site0	varchar(5),
			@site1	varchar(5),
			@code		char(8),
			@number	money,
			@price	money,
			@blow		money,
			@amount 	money,
			@amount1	money,
			@profit 	money,
			@bdate 	datetime,
			@bdate0 	datetime,
			@ret	 	int,
			@pc_id0	char(4),
			@id		char(6)
//init
select @ret = 0,@msg ='OK!'
select @bdate =bdate1 from sysdata 

begin tran
save tran p_wz_bos_kc_folio_input_s1

if not exists (select 1 from bos_kcmenu where folio = @folio ) or not exists (select 1 from bos_kcdish where folio = @folio)
	select @ret = 1 , @msg ='该帐号不存在，或单据不存在	！---' + @folio

if @ret = 0 and @mode = 'IN'
begin
	if not exists (select 1 from bos_kcmenu where folio = @folio and sta ='I')
		select @ret = 1, @msg ='此帐号：'+@folio+ '非有效状态！'
	select @pc_id0 = pc_id from bos_kcmenu where folio = @folio 
	if @pc_id0 is not null and @pc_id <> @pc_id0
		select @ret = 1, @msg ='此单据：'+@folio+' 正在被其他站点：'+@pc_id0+'修改中。'
end 

if @ret = 0 and @mode <> 'IN'
	if not exists(select 1 from bos_kcmenu where folio = @folio and sta ='O')
		select @ret = 1 ,@msg = '此单据：'+@folio+'非入帐状态！'

if @mode = 'OU'
	select @ret =1,@msg='不能进行冲账 ! ---- 入账错误请输入相反的单据进行处理。'
else if @mode ='BJ'
	select @ret =1,@msg='暂时不提供补救功能，请用冲账 !'
else if @mode <> 'IN'
	select @ret =1,@msg='未知帐务处理标志：'+@mode

if @ret = 0
	exec @ret = p_gds_bos_detail @modu_id,@pc_id,@folio,'','',@msg output

if @ret = 0
begin
	if @mode ='IN'
	begin
	update bos_kcmenu set bdate = @bdate,sta = 'O', pc_id = null ,cby = @empno ,cdate = @bdate ,logmark = logmark + 1 where folio = @folio 
	if @@error <> 0
		select @ret = 1,@msg ='更新失败！---------' +@folio
	end 
end 

if @ret <> 0
	rollback tran p_wz_bos_kc_folio_input_s1
commit tran

if @returnmode = 'S'
  	select @ret,@msg

return @ret ;

