drop  procedure p_cq_sp_guest_mind;
create procedure p_cq_sp_guest_mind
			
			
as
declare
			@add				integer,
			@month			datetime,
			@bdate			datetime,
			@code				char(2),
			@descript		char(20),
			@number			money
	

create table #mind
(
	month		integer,
	name		char(20),
	number	money
)

select @bdate = bdate1 from sysdata

declare c_mind cursor for 
	select code,descript from basecode where cat = 'mind_type' order by code
open c_mind
fetch c_mind into @code,@descript
while	@@sqlstatus = 0
	begin
	select @month = dateadd(mm,-(datepart(mm,@bdate)-1),@bdate)
	while datediff(yy,@month,@bdate) = 0
		begin
		select @number = isnull(count(1),0) from sp_mind where class = @code and datediff(mm,@month,date0) = 0
		insert #mind select datepart(mm,@month) ,@descript,@number
		select @month = dateadd(mm,1,@month)
		end
	fetch c_mind into @code,@descript
	end
close c_mind
deallocate cursor c_mind

select month,name,number from #mind

;