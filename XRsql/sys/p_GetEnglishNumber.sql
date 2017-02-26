if object_id("p_GetEnglishNumber") is not null
drop proc p_GetEnglishNumber;
create proc p_GetEnglishNumber
	@i	int,
	@s	char(5) out

as

select @i = @i % 10

	if @i = 0
		select @s = "Other"
	if @i = 1
		select @s = "One"
	if @i = 2
		select @s = "Two"
	if @i = 3
		select @s = "Three"
	if @i = 4
		select @s = "Four"
	if @i = 5
		select @s = "Five"
	if @i = 6
		select @s = "Six"
	if @i = 7
		select @s = "Seven"
	if @i = 8
		select @s = "Eight"
	if @i = 9
		select @s = "Nine"
return  0;
