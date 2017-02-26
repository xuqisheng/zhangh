drop  proc    p_hry_bus_put_iddcall;
create proc    p_hry_bus_put_iddcall
   @modu_id	   char(2),
   @pc_id		char(4),
   @shift		char(1),
   @empno		char(10),
	@phone		char(8),
   @pccode		char(5),
   @phcode     char(15),
   @address    char(14),
   @date       datetime,
   @length     char(8),
   @pfee_base	money,
   @pfee_serve	money,
   @refer		char(18),
   @returnmode char(1),
   @msg        varchar(60) output
as

select  @pfee_base = round(@pfee_base,2)
select  @pfee_serve=	round(@pfee_serve,2)

declare
   @ret	      int,
   @site0    	char(5),
   @chgcod    	char(5),
   @bdate	   datetime,
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
   select @msg = "商务中心费用流水号生成出错,请与电脑房联系!"
else
   begin
	select @ref1 = substring(@phone+space(8),1,6) + substring(@phcode+space(16),1,14) + @length
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
	   select @ret = 1,@msg = "插入 folio error, 请与电脑房联系!"
	else
		begin
		insert bos_dish(log_date,id,pccode,code,name,price,number,unit,bdate,foliono,sta,
				fee,fee_base,fee_serve,pfee,pfee_base,pfee_serve,serve_type,serve_value,
				refer,empno1,shift1)
		values(@dinput,1,@pccode, 'PHN','商务自动电话',@pfee_base,1,'次',@bdate,@foliono,'I',
				@pfee_base+@pfee_serve,@pfee_base,@pfee_serve,@pfee_base+@pfee_serve,@pfee_base,@pfee_serve,'1',@pfee_serve,
				@ref2,@empno,@shift)
		if @@rowcount = 0
			select @ret = 1,@msg = "插入 dish error, 请与电脑房联系!"
		end
   end
if @ret <> 0
   rollback tran p_hry_bus_put_iddcall_s1
commit tran

if @returnmode = 'S'
   select @ret,@msg
return @ret
;