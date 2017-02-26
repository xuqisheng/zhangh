// ------------------------------------------------------------------------------------
//	pos pccode ���
// ------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_pccode_check" and type = "P")
   drop proc p_gds_bos_pccode_check;
create proc    p_gds_bos_pccode_check
   @pccode	   char(5),
   @returnmode char(1),    			//����ģʽ
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
   select @ret = 1,@msg = "ϵͳ�л�δ����Ŀ����%1, ������Է���ϵ!^"+ @pccode 
else if @site0 is null or not exists(select 1 from bos_site where pccode=@pccode and site=@site0)
   select @ret = 1,@msg = "ϵͳ�л�δ����Ŀ����%1��Ӧ�ĵص����, ������Է���ϵ!^"+ @pccode 
else
begin
	if @chgcod is null
		select @ret = 1,@msg = "ϵͳ�л�δ����Ŀ����%1��Ӧ�ķ��ô���, ������Է���ϵ!^"+ @chgcod 
	else
	begin
		select @modu = modu from pccode where pccode = @chgcod
		if @@rowcount = 0
			select @ret = 1,@msg = "ϵͳ�л�δ����ô���%1, ������Է���ϵ!^"+ @chgcod 
		else if @modu is null  -- or @modu <> '06'
			select @ret = 1,@msg = "���ô���%1�������趨���շѷ�Χ,������Է���ϵ!^"+@chgcod
	end
end

if @returnmode = 'S'
	select @ret, @msg
return @ret
;
