if exists ( select * from sysobjects where name = 'p_gl_info_info_analyze' and type ='P')
	drop proc p_gl_info_info_analyze;

create proc p_gl_info_info_analyze
	@pc_id			char(4),
	@modu_id			char(2),
	@begin			datetime,
	@end				datetime,
	@class			varchar(255),
	@mode				char(1)						-- R.每日, W.每周, S.合计
as

declare
	@pos				integer,
	@cclass			char(8),
	@class_set		varchar(255)

delete info_analyze where pc_id = @pc_id and modu_id = @modu_id 
select @class_set = ''
while datalength(rtrim(@class)) > 0
	begin
	select @pos = charindex(';', @class)
	if @pos = 0
		select @cclass = @class, @class = ''
	else
		select @cclass = substring(@class, 1, @pos - 1), @class = substring(@class, @pos + 1, 255)
	select @class_set = @class_set + @cclass + ','
	insert info_analyze select @pc_id, @modu_id, date, class, convert(char(1), datepart(weekday, date) - 1), convert(char(10), date, 111), day
		from yjourrep where date >= @begin and date <= @end and class = @cclass
	end

exec p_gl_info_info_pmsgraph @pc_id, @modu_id, @class_set
return 0
;
