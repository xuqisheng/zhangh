-- 似乎没有用了  simon 

IF OBJECT_ID('p_wz_reserve_codes_splits') IS NOT NULL
    DROP PROCEDURE p_wz_reserve_codes_splits
;
//create proc p_wz_reserve_codes_splits
//		@codes		varchar(50),
//		@type			char(20),
//		@des			varchar(100) output,
//		@langid     integer
//as
//declare
//		@pos		 	integer,
//		@tcode		char(5),
//		@tdes			char(20)
//
//select @codes = ltrim(rtrim(@codes))
//select @pos = charindex(',',@codes)
//while @pos > 0
//begin
//	select @tcode = substring(@codes,1,@pos - 1)
//	select @codes = substring(@codes,@pos+1,100)
//	select @codes = ltrim(rtrim(@codes))
//	select @tcode= ltrim(rtrim(@tcode))
//	if @langid = 0
//	begin
//		if @type = 'srqs'
//		begin
//			select @tdes = descript from reqcode where code = @tcode
//		end
//		else if @type = 'amenities'
//			select @tdes = descript from basecode where cat = 'amenities' and code =@tcode
//	end
//	else
//	begin
//		if @type = 'srqs'
//			select @tdes = descript1 from reqcode where code = @tcode
//		else if @type = 'amenities'
//			select @tdes = descript1 from basecode where cat = 'amenities' and code =@tcode
//	end
//	select @des = @des + rtrim(ltrim(@tdes)) + ';'
//	select @pos = charindex(',',@codes)
//end
//
//if @codes <> '' or ltrim(@codes) is not null
//begin
//	if @type = 'srqs'
//		select @tdes = descript1 from reqcode where code = @codes
//	else if @type = 'amenities'
//		select @tdes = descript1 from basecode where cat = 'amenities' and code =@codes
//
//	select @des = @des + rtrim(ltrim(@tdes))
//end
//;
//