drop proc p_cq_reserve_rmsta_list_print;
create  proc p_cq_reserve_rmsta_list_print
	@hall		 char(1),
	@rm_no	 char(5),
	@brm_no	 char(5),
	@type		 char(3),
	@ocsta	 char(1),
	@sta		 char(1),
	@bdate	 datetime,
	@bed	 	 int
as
declare
	@feature	 varchar(50),
	@alldays	 int,
	@row_num	 int,
   @page		 int

select @feature = '%',@alldays = 10,@row_num = 1000,@page = 1
-- Define output table
create table #rmsta_list
(
	roomno	char(5)		not null,
   oroomno  char(5)     not null,
	type		char(3)		default '' null,
	state		char(2)		default '' null,
	people   int	      default 0 null,
	bedno		int	      default 0 null,
	rate		money		   default 0 null,
	trate		money		   default 0 null,  		-- Used in scjj hotel
	hall     char(1)     default '' null,
	flr      char(2)     default '' null,
	f5       char(2)     default '' null,
	numstr	char(60)		default '' null,
	n_flag	char(1)		default '' null,     -- flag for pageup / pagedown  - old version
	ref	  varchar(50)   default '' null,
	feature	  varchar(50)   default '' null
)
create unique index #rmsta_list on #rmsta_list(oroomno)

-- None data output request
if	@alldays < 0 or @row_num <= 0
begin
	select * from #rmsta_list
	return 1
end

declare	@tmproomno	char(5),
		@cdate		datetime,
		@quantity	int,
		@numstr		varchar(60),
		@locked     char(1),
		@futsta     char(1),
		@futbegin   datetime,
		@futend     datetime,
		@rm_type    char(3),
		@state      char(2),
		@people     int,
      @bedno      int,
      @rate       money,
      @rm_hall         char(1),
      @flr         char(2),
      @f5         char(2),
		@mycount    int,
		@fstroomno  char(5),
		@brmno      char(5),
		@oroomno    char(5)

-- brm_no
if rtrim(@brm_no) is not null
   begin
   select @brmno = min(roomno) from rmsta where roomno >= @brm_no
   if @brmno is null
	  select @brmno = min(oroomno) from rmsta
   else
      select @brmno = oroomno from rmsta where roomno = @brmno
   end
else
   select @brmno = ''

select 	@bdate = isnull(@bdate,getdate()), @mycount=0
select 	@alldays = 20 where @alldays > 20 or @alldays is null   -- Max data length = 20
if rtrim(@feature) is null
	select @feature = '%'

-- Begin dealing ......
declare	c_rmsta_list cursor for
	select	roomno,oroomno,type, ocsta + sta, people, bedno, rate,hall,flr,tmpsta,locked,futsta,futbegin,futend
	from 	rmsta
	where roomno like rtrim(@rm_no)+'%' and
			oroomno >= @brmno             and
			(hall=@hall or rtrim(@hall) is null) and
			type   like rtrim(@type) +'%' and
			ocsta  like rtrim(@ocsta)+'%' and
			sta    like rtrim(@sta)+'%' and
			feature   like @feature and
			(@bed is null or bedno = @bed or @bed = 0)
    order by oroomno
open 	c_rmsta_list
fetch   c_rmsta_list into @tmproomno,@oroomno,@rm_type,@state,@people,@bedno,@rate,@rm_hall,@flr,@f5,@locked,@futsta,@futbegin,@futend
if @@sqlstatus = 0
   select @fstroomno = @tmproomno
while 	@@sqlstatus = 0 and @mycount < @row_num
begin
	select @numstr = NULL,@cdate = @bdate,@mycount = @mycount + 1

	while	datediff(day, @bdate, @cdate) < @alldays
	begin
		select @quantity = isnull(sum(quantity), 0) from rsvdtl
			 where roomno = @tmproomno and begin_ <= @cdate and end_ > @cdate
		if	@quantity = 0  -- 没有预留
		begin
			if @locked <> 'L'
				select @numstr = @numstr + "/ -"
			else if (@futend is null or @futend > @cdate ) and @cdate >= @futbegin  -- 维修
				select @numstr = @numstr + "/ "+@futsta
			else
				select @numstr = @numstr + "/ -"
		end
		else
			if	@quantity > 99 or @quantity < 0
				select @numstr = @numstr + "/" + "**"   -- 占用过多
			else
			begin
				if	@quantity > 9
					select @numstr = @numstr + "/" + convert(char(2), @quantity)
				else
					select @numstr = @numstr + "/ " + convert(char(1), @quantity)
			end
		select @cdate = dateadd(day, 1, @cdate)
	end

	insert #rmsta_list
		select @tmproomno,@oroomno,@rm_type,@state,@people,@bedno,@rate,@rate,
				@rm_hall,@flr,@f5,isnull(@numstr,""),'F','',''

	fetch   c_rmsta_list into @tmproomno,@oroomno,@rm_type,@state,@people,@bedno,@rate,@rm_hall,@flr,@f5,@locked,@futsta,@futbegin,@futend
end

if	@@sqlstatus = 0
	update #rmsta_list set n_flag = 'T' where roomno = @fstroomno

close c_rmsta_list
deallocate cursor c_rmsta_list

update #rmsta_list set ref=a.ref,feature=a.feature from rmsta a where a.roomno=#rmsta_list.roomno

-- Output
select roomno,type,state,people,bedno,rate,trate,hall,flr,f5,numstr,n_flag,ref,feature
       from #rmsta_list order by oroomno
return 0

;