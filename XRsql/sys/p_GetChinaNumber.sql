create proc p_GetChinaNumber
	@i	int,
	@s	char(2) out,
	@lower	char(1) = "F"
as

select @i = @i % 10

if @lower != "T"
begin
	if @i = 0
		select @s = "零"
	if @i = 1
		select @s = "壹"
	if @i = 2
		select @s = "贰"
	if @i = 3
		select @s = "叁"
	if @i = 4
		select @s = "肆"
	if @i = 5
		select @s = "伍"
	if @i = 6
		select @s = "陆"
	if @i = 7
		select @s = "柒"
	if @i = 8
		select @s = "捌"
	if @i = 9
		select @s = "玖"
end
else
begin
	if @i = 0
		select @s = "另"
	if @i = 1
		select @s = "一"
	if @i = 2
		select @s = "二"
	if @i = 3
		select @s = "三"
	if @i = 4
		select @s = "四"
	if @i = 5
		select @s = "五"
	if @i = 6
		select @s = "六"
	if @i = 7
		select @s = "七"
	if @i = 8
		select @s = "八"
	if @i = 9
		select @s = "九"
end
return  0;
