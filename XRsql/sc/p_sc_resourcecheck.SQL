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

		--�������1:����Ԥ����Դ�Ŀ�ʼʱ�����Ԥ���Ŀ�ʼʱ��С������ʱ�����Ԥ���Ŀ�ʼʱ���,����Ԥ����Ч(status='R')
		select  @count =  sum(quantity) from sc_resourcreservation where begindate<@begindate and enddate>@begindate and rsid=@rsid and status='R' and resno<>@evtresno
		if @count is null
			select @count=0
		select  @tempcount=@tempcount+@count

		--�������2:����Ԥ����Դ�Ŀ�ʼʱ�����Ԥ���Ŀ�ʼʱ��󣬿�ʼʱ�����Ԥ���Ľ���ʱ��С,����Ԥ����Ч(status='R')
		select @count =  sum(quantity) from sc_resourcreservation where begindate>@begindate and begindate<@enddate  and rsid=@rsid  and status='R' and resno<>@evtresno
		if @count is null
			select @count=0
		select  @tempcount=@tempcount+@count

		--�������3:����Ԥ����Դ�Ŀ�ʼʱ�����Ԥ���Ľ���ʱ��С,����ʱ�����Ԥ���Ľ���ʱ���,����Ԥ����Ч(status='R')
		select @count =  sum(quantity) from sc_resourcreservation where begindate<@enddate and enddate>@enddate and rsid=@rsid  and status='R' and resno<>@evtresno
		if @count is null
			select @count=0
		select  @tempcount=@tempcount+@count

		--�������4:�����غ�
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