// ------------------------------------------------------------------------------------
//	pos pccode 监测
// ------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_pccode_check" and type = "P")
   drop proc p_gds_bos_pccode_check;
create proc    p_gds_bos_pccode_check
   @pccode	   char(5),
   @returnmode char(1),    			//返回模式
   @site0		char(5)			output,	
   @chgcod		char(5)			output,
   @descript	varchar(24)		output,
   @msg        varchar(60) 	output
as
declare
   @ret	      int,
	@modu			char(2)

select @ret = 0
select @descript=descript, @site0=rtrim(site0), @chgcod=rtrim(chgcod) from bos_pccode where pccode = @pccode
if @@rowcount = 0
   select @ret = 1,@msg = "系统中还未设项目代码%1, 请与电脑房联系!^"+ @pccode 
else if @site0 is null or not exists(select 1 from bos_site where pccode=@pccode and site=@site0)
   select @ret = 1,@msg = "系统中还未设项目代码%1对应的地点代码, 请与电脑房联系!^"+ @pccode 
else
begin
	if @chgcod is null
		select @ret = 1,@msg = "系统中还未设项目代码%1对应的费用代码, 请与电脑房联系!^"+ @chgcod 
	else
	begin
		select @modu = modu from pccode where pccode = @chgcod
		if @@rowcount = 0
			select @ret = 1,@msg = "系统中还未设费用代码%1, 请与电脑房联系!^"+ @chgcod 
		else if @modu is null  -- or @modu <> '06'
			select @ret = 1,@msg = "费用代码%1不属于设定的收费范围,请与电脑房联系!^"+@chgcod
	end
end

if @returnmode = 'S'
	select @ret, @msg
return @ret
;
