IF OBJECT_ID('dbo.p_sc_resourcecheck') IS NOT NULL
DROP PROCEDURE dbo.p_sc_resourcecheck
;
create procedure p_sc_resourcecheck
                 @id      varchar(10),
                 @evtresno char(10),
                 @rsid  char(10),
                 @begindate datetime,
                 @enddate   datetime,
                 @quantity  money,
                 @exp       varchar(10),
                 @mode     char = 'A'

as
declare
   @rstype  char(10),
   @count   money,
   @ncount  money,
   @ncount1 money,
   @tempcount money,
   @rsclsid char(10),
   @saleid   varchar(10)

if @exp='1'
   select @count=0
else
   begin

		select @tempcount=0

		select @ncount=quantity from sc_resourcedetails where rsid=@rsid
		select @ncount1=overquan from sc_resourcedetails where rsid=@rsid

		if @ncount1 is null
			select @ncount1=0

		select @ncount=@ncount+@ncount1

		--select @rstype=rsclsid from sc_resourcedetails where rsid=@rsid

		--交叉情况1:已有预定资源的开始时间比新预定的开始时间小，结束时间比新预定的开始时间大,并且预定有效(status='R')
		select  @count =  sum(quantity) from sc_resourcreservation where begindate<@begindate and enddate>@begindate and rsid=@rsid and status='R' and resno<>@evtresno
		if @count is null
			select @count=0
		select  @tempcount=@tempcount+@count

		--交叉情况2:已有预定资源的开始时间比新预定的开始时间大，开始时间比新预定的结束时间小,并且预定有效(status='R')
		select @count =  sum(quantity) from sc_resourcreservation where begindate>@begindate and begindate<@enddate  and rsid=@rsid  and status='R' and resno<>@evtresno
		if @count is null
			select @count=0
		select  @tempcount=@tempcount+@count

		--交叉情况3:已有预定资源的开始时间比新预定的结束时间小,结束时间比新预定的结束时间大,并且预定有效(status='R')
		select @count =  sum(quantity) from sc_resourcreservation where begindate<@enddate and enddate>@enddate and rsid=@rsid  and status='R' and resno<>@evtresno
		if @count is null
			select @count=0
		select  @tempcount=@tempcount+@count

		--交叉情况4:正好重合
		select @count =  sum(quantity) from sc_resourcreservation where begindate=@begindate and enddate=@enddate and rsid=@rsid  and status='R' and resno<>@evtresno
		if @count is null
			select @count=0
		select  @tempcount=@tempcount+@count


		select @count=@ncount - @tempcount - @quantity
      select @rsclsid=rsclsid from sc_resourcedetails where rsid=@rsid
      select @saleid=specialrequire from sc_eventreservation where evtresno=@evtresno
      delete sc_resourceconflict where id=@id
      if @count<0
	      insert sc_resourceconflict values (@id,@evtresno,@rsclsid,@rsid,@begindate,@enddate,@count,@saleid)

   end
   if @mode='A'
	   select @count

;
