
if exists (select * from sysobjects where name ='p_gds_string_multi_replace' and type ='P')
	drop proc p_gds_string_multi_replace;
create proc p_gds_string_multi_replace
	@input				varchar(255), 
	@flag_begin			varchar(255), 
	@flag_end			varchar(255), 
	@output				varchar(255) output 
as
------------------------------------------------------------------ 
-- Ìæ»»×Ö·û´ÜÖÐµÄ±êÊ¶×Ö·û£»È«Ìæ»»  
------------------------------------------------------------------ 
declare
	@pos					int,
	@len					int  


select @len=char_length(@flag_begin)

select @pos=charindex(@flag_begin, @input)
while @pos > 0
begin
	select @input=stuff(@input, @pos, @len, @flag_end) 
	select @pos=charindex(@flag_begin, @input)
end 	
select @output = @input 
;
