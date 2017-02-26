
IF OBJECT_ID('p_gds_upper_string') IS NOT NULL
    DROP PROCEDURE p_gds_upper_string;
create proc p_gds_upper_string
	@str_in			varchar(255),
	@str_out			varchar(255) output 
as
------------------------------------------------------
--	ֱ�� upper �ַ��������ܵ��º������룬����
--	 upper(C�¶�������) = C�¶�������
------------------------------------------------------
declare	@chr		char(1),
			@len		int,
			@pos		int
			
select @len = char_length(@str_in), @pos = 1, @str_out=''
while @pos <= @len 
begin
	select @chr = substring(@str_in, @pos, 1)
	if ascii(@chr)<=128 
		select @chr = upper(@chr)
	if @pos = 1 
		select @str_out = @chr
	else
		select @str_out = @str_out + @chr
	select @pos=@pos+1
end
;
