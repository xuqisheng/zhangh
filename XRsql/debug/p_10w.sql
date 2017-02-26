
if exists(select * from sysobjects where name = "p_10w" and type = "P")
	drop proc p_10w;
create proc  p_10w
as
declare 
	@begin			datetime,
	@num				int

if exists(select 1 from gdsmsg)
begin
	select 'ÇëÏÈÇå¿Õ GDSMSG'
	return 
end 

select @num=0
select @begin=getdate()
while @num<100000
	begin
	insert gdsmsg select "Foxhis Test Data..."
	select @num=@num+1
	end
select convert(char,datediff(ss,@begin,getdate()))+' sec.'

truncate table gdsmsg
;

