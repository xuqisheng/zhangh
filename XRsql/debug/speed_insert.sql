
// 测试 dbms 数据插入的速度   hp370 -> 100000 = 12m 


if exists ( select * from sysobjects where name = 'p_a1' and type ='P')
	drop proc p_a1;
create proc p_a1
as

declare
	@count			integer

select getdate()
truncate table gdsmsg
select @count = 1
while @count < 100000
	begin
	insert gdsmsg select convert(char(20), getdate(),111)
	select @count = @count + 1
	end
select getdate()
return;


exec p_a1;
