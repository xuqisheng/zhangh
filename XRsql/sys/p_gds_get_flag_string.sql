
if exists (select * from sysobjects where name ='p_gds_get_flag_string' and type ='P')
	drop proc p_gds_get_flag_string;
create proc p_gds_get_flag_string
	@input				varchar(255), 
	@flag_begin			varchar(255), 
	@flag_end			varchar(255), 
	@output				varchar(255) output 
as
------------------------------------------------------------------ 
-- 提取字符串中间的标志包含内容 
------------------------------------------------------------------ 
declare
	@pos					int,
	@len					int  

select @pos=charindex(@flag_begin, @input), @len=char_length(@flag_begin), @output='' 
if @pos > 0
begin
	select @input=substring(@input, @pos + @len, 255) 
	select @pos=charindex(@flag_end, @input)
	if @pos > 0 
		select @output=substring(@input, 1, @pos - 1) 
end 	
;
