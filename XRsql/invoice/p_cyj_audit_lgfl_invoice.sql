if exists (select * from sysobjects where name = 'p_cyj_audit_lgfl_invoice' and type = 'P')
	drop proc p_cyj_audit_lgfl_invoice;
create proc p_cyj_audit_lgfl_invoice
	@numb			char(7)
as
declare
	@lnumb				char(7),
	@row					int,
	@cby					char(3),
	@changed				datetime,
	@logmark				integer

	// invoice
declare
	@old_numb     		char(7), 
   @old_printtype 	char(10),
	@old_bdate 			datetime,
	@old_gbound   		varchar(255),
	@old_gnumb    		int,
	@old_ubound   		varchar(255),
	@old_unumb    		int,
	@old_bbound   		varchar(255),
	@old_bnumb    		int,
	@old_rbound   		varchar(255),
	@old_rnumb    		int,
	@old_empno    		char(3),
	@old_empno1   		char(3),
	@old_empno2   		char(3),
	@old_empno3   		char(3),
	@old_edate    		datetime,
	@old_sta      		char(1),

	//
	@new_numb     		char(7), 
   @new_printtype 	char(10),
	@new_bdate 			datetime,
	@new_gbound   		varchar(255),
	@new_gnumb    		int,
	@new_ubound   		varchar(255),
	@new_unumb    		int,
	@new_bbound   		varchar(255),
	@new_bnumb    		int,
	@new_rbound   		varchar(255),
	@new_rnumb    		int,
	@new_empno    		char(3),
	@new_empno1   		char(3),
	@new_empno2   		char(3),
	@new_empno3   		char(3),
	@new_edate    		datetime,
	@new_sta          char(1),
	@new_logmark		int

delete lgfl where tbname='invoice' and accnt=@numb

/* invoice 日志 */
if @numb is null
	declare c_invoice cursor for 
		select convert(char(10), numb) from invoice_log group by convert(char(10), numb) having count(1) > 1
else
	declare c_invoice cursor for 
		select convert(char(10), numb) from invoice_log where convert(char(10), numb) = @numb group by convert(char(10), numb) having count(1) > 1
declare c_log_invoice cursor for 
	select convert(char(10), numb), printtype,bdate,gbound,	gnumb,ubound,unumb,bbound,bnumb,rbound,rnumb,
		empno,empno1,empno2,empno3,edate,sta,cby,changed,logmark 
	from invoice_log where convert(char(10), numb) = @lnumb order by logmark
open c_invoice
fetch c_invoice into @lnumb
while @@sqlstatus =0
   begin
	select @row = 0
	open c_log_invoice
	fetch c_log_invoice into @new_numb, @new_printtype,@new_bdate,@new_gbound,@new_gnumb,@new_ubound,@new_unumb,@new_bbound,@new_bnumb,@new_rbound,@new_rnumb,
		@new_empno,@new_empno1,@new_empno2,@new_empno3,@new_edate,@new_sta,@cby,@changed,@logmark 
	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @new_bdate != @old_bdate 
				insert lgfl values ('invoice', 'bdate', '领票日期', @lnumb, '',@logmark, @old_bdate, @new_bdate, @cby, @changed)
			if @new_gbound != @old_gbound 
				insert lgfl values ('invoice', 'gbound', '领票范围', @lnumb, '',@logmark, @old_gbound, @new_gbound, @cby, @changed)
			if @new_bbound != @old_bbound 
				insert lgfl values ('invoice', 'bbound', '废票范围', @lnumb, '', @logmark,@old_bbound, @new_bbound, @cby, @changed)
			if @new_rbound != @old_rbound 
				insert lgfl values ('invoice', 'bbound', '剩票范围', @lnumb, '',@logmark, @old_rbound, @new_rbound, @cby, @changed)
			if @new_empno != @old_empno
				insert lgfl values ('invoice', 'empno', '领票人', @lnumb, '',@logmark, @old_empno, @new_empno, @cby, @changed)
			if @new_empno2 != @old_empno2
				insert lgfl values ('invoice', 'empno2', '领票人', @lnumb, '',@logmark, @old_empno2, @new_empno2, @cby, @changed)
			if @new_sta != @old_sta
				insert lgfl values ('invoice', 'sta', '状态', @lnumb, '',@logmark, @old_sta, @new_sta, @cby, @changed)
			end
		select @old_numb=@new_numb, @old_printtype=@new_printtype,@old_bdate=@new_bdate,
			@old_gbound=@new_gbound,@old_gnumb=@new_gnumb,@old_ubound=@new_ubound,
			@old_unumb=@new_unumb,@old_bbound=@new_bbound,@old_bnumb=@new_bnumb,
			@old_rbound=@new_rbound,@old_rnumb=@new_rnumb,@old_empno=@new_empno,
			@old_empno1=@new_empno1,@old_empno2=@new_empno2,@old_empno3=@new_empno3,
			@old_edate=@new_edate,@old_sta=@new_sta

		fetch c_log_invoice into @new_numb, @new_printtype,@new_bdate,@new_gbound,@new_gnumb,@new_ubound,@new_unumb,@new_bbound,@new_bnumb,@new_rbound,@new_rnumb,
			@new_empno,@new_empno1,@new_empno2,@new_empno3,@new_edate,@new_sta,@cby,@changed,@new_logmark 
		end
	close c_log_invoice
	fetch c_invoice into @lnumb
	end
deallocate cursor c_log_invoice
close c_invoice
deallocate cursor c_invoice

return 
;


