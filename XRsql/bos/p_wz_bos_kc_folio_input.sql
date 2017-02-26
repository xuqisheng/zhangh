//----------------------------------------------------------------------
//  bos_kcmenu    ----->      bos_store
//  �ʵ����ʡ����ʡ����� 
//----------------------------------------------------------------------
if exists (select 1 from sysobjects where name ='p_wz_bos_kc_folio_input')
	drop proc p_wz_bos_kc_folio_input ;
create proc p_wz_bos_kc_folio_input 
	@modu_id 		char(2),
	@pc_id			char(4),
	@mode				char(2),		//IN-����	OU-����    BJ-����
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
	select @ret = 1 , @msg ='���ʺŲ����ڣ��򵥾ݲ�����	��---' + @folio

if @ret = 0 and @mode = 'IN'
begin
	if not exists (select 1 from bos_kcmenu where folio = @folio and sta ='I')
		select @ret = 1, @msg ='���ʺţ�'+@folio+ '����Ч״̬��'
	select @pc_id0 = pc_id from bos_kcmenu where folio = @folio 
	if @pc_id0 is not null and @pc_id <> @pc_id0
		select @ret = 1, @msg ='�˵��ݣ�'+@folio+' ���ڱ�����վ�㣺'+@pc_id0+'�޸��С�'
end 

if @ret = 0 and @mode <> 'IN'
	if not exists(select 1 from bos_kcmenu where folio = @folio and sta ='O')
		select @ret = 1 ,@msg = '�˵��ݣ�'+@folio+'������״̬��'

if @mode = 'OU'
	select @ret =1,@msg='���ܽ��г��� ! ---- ���˴����������෴�ĵ��ݽ��д���'
else if @mode ='BJ'
	select @ret =1,@msg='��ʱ���ṩ���ȹ��ܣ����ó��� !'
else if @mode <> 'IN'
	select @ret =1,@msg='δ֪�������־��'+@mode

if @ret = 0
	exec @ret = p_gds_bos_detail @modu_id,@pc_id,@folio,'','',@msg output

if @ret = 0
begin
	if @mode ='IN'
	begin
	update bos_kcmenu set bdate = @bdate,sta = 'O', pc_id = null ,cby = @empno ,cdate = @bdate ,logmark = logmark + 1 where folio = @folio 
	if @@error <> 0
		select @ret = 1,@msg ='����ʧ�ܣ�---------' +@folio
	end 
end 

if @ret <> 0
	rollback tran p_wz_bos_kc_folio_input_s1
commit tran

if @returnmode = 'S'
  	select @ret,@msg

return @ret ;

