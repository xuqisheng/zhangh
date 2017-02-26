-- ------------------------------------------------------------------------------------
--		BOS --- �����������йص� PROC
--
--		p_gds_business_disp_folio			<business> ʵʱ������ʾ 
--		p_gds_busi_fax_fee		�ƷѲ����ص�ַ
--		p_gds_bus_put_fax			���ʹ�������
--		p_hry_bus_put_iddcall
-- ------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------
-- ��������ʵʱ������ʾ����ʱ bos_folio, bos_dish ��ֻ��һ����¼
--	-- �������Ϣ���� bos_dish.ref
-- ------------> �� bosno ��ʽ����
-- --------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_business_disp_folio" and type="P")
   drop proc p_gds_business_disp_folio;
create proc p_gds_business_disp_folio
	@bosno		char(2),
   @bfoliono  	char(10)
as
select a.foliono, b.refer, a.fee_base, a.fee
	   from bos_folio a, bos_dish b
      where a.foliono > @bfoliono 
				and a.sta = 'P'
				and charindex(rtrim(a.pccode),(select a.pccodes from bos_posdef a where a.posno=@bosno))>0 
				and a.foliono=b.foliono
		order by foliono

return 0
;

-- ------------------------------------------------------------------------------------
--	�ƷѲ����ص�ַ
-- ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 'p_gds_busi_fax_fee')
   drop proc p_gds_busi_fax_fee;
create proc p_gds_busi_fax_fee
   @pc_id      char(4) = '1.01',
   @modu_id    char(2) = '05',
   @p_extno    char(8),            -- �ֻ���   
   @phcode     char(15),           -- ������   
   @begin_     datetime,           -- ��ʼʱ��  
   @sndnum     int,                -- ʱ��(��) 
   @returnmode char(1),            -- ����ģʽ 
   @calltype   char(1)   output,   -- ���     
   @address    char(14)  output,   -- ��ַ        
   @fee        money     output,   -- �ܻ���   
   @fee_serve  money     output,   -- �����   
   @fee_dial   money     output,   -- ���ŷ�   
   @msg		   varchar(60) output
as
declare
   @ret        int,
   @phcodelen  int,
   @loopndx    int,
   @phcodearea char(15)

select @ret=0,@msg=""
-- 1. locate the phcode area number 
set rowcount 1
select @phcodelen = datalength(rtrim(@phcode)),@loopndx = 1
while @loopndx <= @phcodelen
   begin
   select @phcodearea = code from phcoden where code = substring(@phcode,1,@loopndx)
   if @@rowcount > 0
      begin 
	   select @loopndx = @loopndx + 1
	   continue
	   end
   else
      begin 
	   if exists (select code from phcoden where code like substring(@phcode,1,@loopndx)+'%')
         begin
		   select @loopndx = @loopndx+1
		   continue
		   end
	   else
         break 
      end 
   end

set rowcount 0
if @phcodearea is null
   begin
   select @ret=0,@msg= "NO CODE",@calltype='0',@address='NO ADDRESS',@fee =0, @fee_serve = 0, @fee_dial =0 
   if @returnmode = 'S'
      select @ret,@msg,@address,@fee,@fee_serve,@fee_dial
   return @ret
   end

-- select @address = address from phcoden where code = @phcodearea

exec @ret = p_hry_phone_calculate_fee
            @pc_id,@modu_id,@p_extno,@phcode,@begin_,@sndnum,'R',
			   @calltype output,@address output,@fee output,
			   @fee_serve output,@fee_dial output,@msg output

if @returnmode = 'S'
   select @ret,@msg,@address,@fee,@fee_serve,@fee_dial
return @ret
;

-- ------------------------------------------------------------------------------------
--	���ʹ�������   
-- ------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bus_put_fax" and type = "P")
   drop proc p_gds_bus_put_fax;

create proc    p_gds_bus_put_fax
   @modu_id	   char(2),
   @pc_id		char(4),
   @shift		char(1),
   @empno		char(10),
   @phcode     char(15),   --����
   @address    char(14),   --��ַ
   @date       datetime,   --��ͨʱ��
   @length     char(8),    --ͨ������
	@paper		int,
   @pfee_paper	money,		--ԭֽ�ŷѷ�
   @pfee_base	money,		--ԭ������
   @pfee_serve	money,		--ԭ�����
   @returnmode char(1),    --����ģʽ
   @msg        varchar(60) output
as
declare
   @pccode		char(5),	
   @chgcod		char(5),
   @site0		char(5),
   @ret	      int,
   @bdate	   datetime,		--Ӫҵ����
   @foliono    char(10),
   @name	      char(24),
   @modu       char(2),
	@refer 		varchar(22),
	@posno		char(2),
	@dinput		datetime,
	@count		int

select @posno = b.posno from bos_station a, bos_posdef b where a.posno=b.posno and a.netaddress=@pc_id and b.modu=@modu_id
if @@rowcount = 0
begin
	select @count = count(1) from bos_posdef where modu=@modu_id and def='T'
	if @count = 1
		select @posno = posno from bos_posdef where modu=@modu_id and def='T'
	else
	begin
		select @ret = 1,@msg = "������������ !"
		if @returnmode = 'S'
			select @ret,@msg
		return @ret
	end
end

if substring(@phcode,1,2) = '00' 
	select @pccode = fax2 from bos_posdef where posno = @posno
else
	select @pccode = fax1 from bos_posdef where posno = @posno

select @ret = 0,@msg="",@dinput=getdate()
select @bdate = bdate1 from sysdata

exec @ret = p_gds_bos_pccode_check @pccode, 'R', @site0 output, @chgcod output, @name output, @msg output
if @ret <> 0
   begin
   if @returnmode = 'S'
	   select @ret,@msg
   return @ret
   end

begin tran
save  tran p_gds_bus_put_fax_s1
exec @ret = p_GetAccnt1 'BUS',@foliono output
if @ret <> 0
   select @msg = "�������ķ�����ˮ�����ɳ���,������Է���ϵ!"
else   
   begin
	select @refer = 'FAX:'+rtrim(@phcode) + '/' + rtrim(@address) + 'Page:' + convert(char(3),@paper)
	insert bos_folio(log_date,bdate,foliono,sta,modu,pccode,name,posno,   
         mode,fee,fee_base,fee_serve,pfee,serve_type,serve_value,
			pfee_base,pfee_serve,refer,empno1,shift1,site0,chgcod)
	values(@dinput,@bdate,@foliono,'M',@modu_id,@pccode,@name,@posno,
         '', @pfee_base+@pfee_serve+@pfee_paper,@pfee_base+@pfee_paper,@pfee_serve,@pfee_base+@pfee_serve+@pfee_paper,'1',@pfee_serve,
			@pfee_base+@pfee_paper,@pfee_serve,@refer,@empno,@shift,@site0,@chgcod)
   if @@rowcount = 0
	   select @ret = 1,@msg = "�����������ʧ��,������Է���ϵ!"
	else
		begin
		insert bos_dish(log_date,id,pccode,code,name,price,number,unit,bdate,foliono,sta,
				fee,fee_base,fee_serve,pfee,pfee_base,pfee_serve,
				serve_type,serve_value,refer,empno1,shift1)
		values(@dinput,1,@pccode, 'FAX','������',@pfee_base+@pfee_paper,1,'��',@bdate,@foliono,'I',
				@pfee_base+@pfee_serve+@pfee_paper,@pfee_base+@pfee_paper,@pfee_serve,@pfee_base+@pfee_serve+@pfee_paper,@pfee_base+@pfee_paper,@pfee_serve,
				'1',@pfee_serve,@refer,@empno,@shift)
		if @@rowcount = 0
			select @ret = 1,@msg = "���� dish error, ������Է���ϵ!"
		end
   end

gds:

if @ret <> 0 
   rollback tran p_gds_bus_put_fax_s1
else
	select @msg = @foliono
commit tran     

if @returnmode = 'S'
   select @ret,@msg

return @ret
;

-- --------------------------------------------------------------------------
-- �绰��������(��IDDCALL����) 
-- --------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_hry_bus_put_iddcall" and type = "P")
   drop proc p_hry_bus_put_iddcall;

create proc    p_hry_bus_put_iddcall
   @modu_id	   char(2),
   @pc_id		char(4),
   @shift		char(1),
   @empno		char(10),
	@phone		char(8),    --�ֻ� - gds
   @pccode		char(5),		--������
   @phcode     char(15),   --����
   @address    char(14),   --��ַ
   @date       datetime,   --��ͨʱ��
   @length     char(8),    --ͨ������
   @pfee_base	money,		--ԭ������
   @pfee_serve	money,		--ԭ�����
   @refer		char(18),	--��ע
   @returnmode char(1),    --����ģʽ
   @msg        varchar(60) output
as
declare
   @ret	      int,
   @site0    	char(5),
   @chgcod    	char(5),
   @bdate	   datetime,		--Ӫҵ����
   @foliono    char(10),
   @name	      char(8),
   @modu       char(2),
	@posno		char(2),
	@dinput		datetime,
	@ref1			varchar(40),
	@ref2			varchar(80)

select @ret = 0, @msg="", @dinput = getdate()
select @bdate = bdate1 from sysdata

exec @ret = p_gds_bos_pccode_check @pccode, 'R', @site0 output, @chgcod output, @name output, @msg output
if @ret <> 0
   begin
   if @returnmode = 'S'
	   select @ret,@msg
   return @ret
   end

begin tran
save  tran p_hry_bus_put_iddcall_s1
exec @ret = p_GetAccnt1 'BUS',@foliono output
if @ret <> 0
   select @msg = "�������ķ�����ˮ�����ɳ���,������Է���ϵ!"
else   
   begin
	select @ref1 = substring(@phone+space(8),1,9) + substring(@phcode+space(16),1,16) + @length + ' ' + @address
	select @ref2 = substring(@phone+space(8),1,9) + convert(char(11), @date,111) + convert(char(9), @date,8)
	select @ref2 = @ref2 + ' ' + substring(@phcode+space(16),1,16) + @length + ' ' + @address
	select @posno = posno from bos_extno where code = @phone

	insert bos_folio(log_date,bdate,foliono,sta,modu,pccode,name,posno,   
         mode,fee,fee_base,fee_serve,pfee,serve_type,serve_value,
			pfee_base,pfee_serve,refer,empno1,shift1,site0,chgcod)
	values(@dinput,@bdate,@foliono,'P',@modu_id,@pccode,@name,@posno,
         '', @pfee_base+@pfee_serve,@pfee_base,@pfee_serve,@pfee_base+@pfee_serve,'1',@pfee_serve,
			@pfee_base,@pfee_serve,@ref1,@empno,@shift,@site0,@chgcod)
   if @@rowcount = 0
	   select @ret = 1,@msg = "���� folio error, ������Է���ϵ!"
	else
		begin
		insert bos_dish(log_date,id,pccode,code,name,price,number,unit,bdate,foliono,sta,
				fee,fee_base,fee_serve,pfee,pfee_base,pfee_serve,serve_type,serve_value,
				refer,empno1,shift1)
		values(@dinput,1,@pccode, 'PHN','�����Զ��绰',@pfee_base,1,'��',@bdate,@foliono,'I',
				@pfee_base+@pfee_serve,@pfee_base,@pfee_serve,@pfee_base+@pfee_serve,@pfee_base,@pfee_serve,'1',@pfee_serve,
				@ref2,@empno,@shift)
		if @@rowcount = 0
			select @ret = 1,@msg = "���� dish error, ������Է���ϵ!"
		end
   end
if @ret <> 0 
   rollback tran p_hry_bus_put_iddcall_s1
commit tran     

if @returnmode = 'S'
   select @ret,@msg
return @ret
;
