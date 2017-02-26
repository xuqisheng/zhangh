
if exists(select * from sysobjects where name = "p_gds_reserve_oneroom_table" and type = 'P')
	drop proc p_gds_reserve_oneroom_table
;
create proc p_gds_reserve_oneroom_table
   @rm_no		char(5),
   @bdate		datetime,
   @days			int
as

create table #oneroom
(
	date			datetime null,
    numstr		char(3)  null
)

if not exists(select 1 from rmsta where roomno = @rm_no)
   begin
   select 1 from #oneroom
   return 100
   end
if @days < 0 or @days is null
   begin
   select 1 from #oneroom
   return 101
   end

declare	@cdate		datetime,
			@quantity	int,
			@numstr		char(3),
        	@tmpstr     char(3)

select 	@bdate = isnull(@bdate,getdate())
select  	@cdate = @bdate

select 	@quantity = datepart(dw, @bdate) - 1
while @quantity > 0
   begin
   insert #oneroom values(NULL, NULL)
   select @quantity = @quantity - 1
   end

while datediff(day, @bdate, @cdate) < @days
   begin
   select 	@quantity = isnull(max(quantity),0) from rsvroom where roomno = @rm_no
                                 and begin_ <= @cdate and end_ > @cdate
   if @quantity = 0
	   select @numstr = "---"
   else if	@quantity > 999 or @quantity < 0
      select @numstr = "***"
   else if	@quantity > 99
	  select @numstr = convert(char(3), @quantity)
   else if	@quantity > 9
	  select @numstr = "" + convert(char(2), @quantity)
   else
	  select @numstr = "" + convert(char(1), @quantity) + ""
   if @numstr = "---"
	  begin
	  select @tmpstr = ' '+futsta+' ' from rmsta where roomno = @rm_no
			 and locked = 'L' and futbegin <= @cdate and (futend > @cdate or futend is null)
	  if @@rowcount > 0
         select @numstr=@tmpstr
 	  end
   insert #oneroom values(@cdate, @numstr)
   select @cdate = dateadd(day, 1, @cdate)
   end

select * from #oneroom

return	0
;
