IF OBJECT_ID('p_billno_restore') IS NOT NULL
    DROP PROCEDURE p_billno_restore
;
create procedure p_billno_restore
as
declare  @billno   		char(10) ,
			@pccode   char(5),
			@bdate   datetime,
			@log_date datetime,
			@empno	char(10),
			@shift	char(1),
			@accnt	char(10)

-- 找回丢失的 billno . 目前不支持针对新AR 的情况 
-- by clg 2007.11 

create table #billno (billno char(10) null)
insert into #billno select distinct billno from haccount where billno not in(select billno from billno)

declare c_billno cursor for select billno from #billno
open c_billno
fetch c_billno into @billno
while @@sqlstatus=0
begin
	if substring(@billno,1,1)='B'
	begin
		select @log_date=max(log_date) from haccount where billno=@billno
		select @pccode=max(pccode) from haccount where billno=@billno and log_date=@log_date
		if @pccode>'9'
		begin
			select @accnt=accnt,@empno=empno,@shift=shift,@bdate=bdate
				 from haccount where billno=@billno and log_date=@log_date and pccode=@pccode
			insert  billno select @billno,  @accnt, @bdate,@empno, @shift,@log_date,'', '',null
		end
		else
		begin
			select @accnt=accnt,@bdate=bdate
				 from haccount where billno=@billno and log_date=@log_date
			insert billno select @billno,  @accnt, @bdate,'FOX', '1',@log_date,'', '',null
		end
	end
	else if substring(@billno,1,1)='C'
	begin
		select @accnt=accnt,@empno=empno,@shift=shift,@bdate=bdate,@log_date=log_date
			from haccount where crradjt='CO' and billno=@billno
		insert billno select @billno,  @accnt, @bdate,@empno, @shift,@log_date,'', '',null
	end
	else if substring(@billno,1,1)='T'
	begin
		select @accnt=accnt,@empno=empno,@shift=shift,@bdate=bdate,@log_date=log_date
			from haccount where tofrom='TO' and billno=@billno
		insert billno select @billno,  @accnt, @bdate,@empno, @shift,@log_date,'', '',null
	end

	fetch c_billno into @billno
end
close c_billno
deallocate cursor c_billno
select * from #billno order by billno
;
