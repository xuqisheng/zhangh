
if object_id("p_gds_pinyin") is not null
   drop proc p_gds_pinyin
;
create  proc p_gds_pinyin
	@input			varchar(255),
	@mode				char(2) = '0',	-- 0=首位字符，1=全部拼音 11=全部大写 10=首字母大写 
	@retmode			char(1) = 'S',
	@output			varchar(255)	out
as

declare	
	@firstchar	varchar(2),
	@pinyin		varchar(6),
	@count		int,
	@len			int

select @output='', @count=0, @input=ltrim(rtrim(@input))
if @input is not null
	select @len = char_length(@input)
else
	select @len = 0

while @len > 0
begin
	select @firstchar = substring(@input,1,1), @len = @len - 1
	select @input = substring(@input,2,@len)

	if ascii(@firstchar) < 128
	begin
		if upper(@firstchar) like "[0-9A-Z]%"
		begin
			select @output=@output+space(@count)+upper(@firstchar)
			select @count = 0
		end
		else
			select @count = @count + 1
	end
	else
	begin
		select @firstchar = @firstchar + substring(@input,1,1), @len = @len - 1
		select @input = substring(@input,2,@len)
		
		if charindex(@firstchar, "（）［］｛｝－—") = 0
		begin
			select @pinyin = rtrim(pinyin) from pinyin where ascii = @firstchar
			if @@rowcount = 1
			begin
				if @mode = '0'
					select @output = @output + substring(@pinyin,1,1)
				else if @mode = '11'
					select @output = @output + ' ' + upper(@pinyin)
				else if @mode = '10'
					select @output = @output + ' ' + upper(substring(@pinyin,1,1)) + lower(substring(@pinyin,2,5))
				else
					select @output = @output + substring(@pinyin,1,1)
			end
		end
	end
end

select @output = rtrim(ltrim(@output)) 
if @output is null
	select @output='?' 

if @retmode = 'S'
	select @output 
return 0
;

exec p_gds_pinyin  '郭迪胜', '10', 'S', ''; 
