drop procedure p_cq_place_use_times;
create procedure p_cq_place_use_times
			@allows		money,
			@used			money,
			@this			money
			
as
declare
			@ii			integer,
			@uu			integer,
			@allow		integer
	

select @allow = @allows - @used
if @allow > 100
	select @allow = 60

create table #times
	(
		t1			integer,
		u1			char(1)
	)

select @ii = 1
select @uu = 1
while @ii <= @allow
	begin
	if @uu <= @this
		insert #times select @ii,'T'
	else
		insert #times select @ii,'F'
	select @uu = @uu + 1
	select @ii = @ii + 1
	end

select u1 from #times order by t1
		
;
