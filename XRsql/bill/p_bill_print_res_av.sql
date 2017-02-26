
if exists(select * from sysobjects where name = "p_bill_print_res_av" and type = "P")
	drop proc p_bill_print_res_av;

create proc  p_bill_print_res_av
	@folio			char(10) 
as
begin 
	declare 
		@accnt			char(10),
		@name				varchar(60) 
	
	if exists(select * from res_av where folio = @folio)
	begin
		select @accnt = accnt from res_av where folio = @folio
		select @name = name from master a, guest b where a.haccnt=b.no and a.accnt=@accnt
		select a.folio, a.accnt,  a.sta, a.resid,b.name,  a.qty, a.stime, a.etime,a.sfield,   
				a.summary,  a.worker,a.amount,a.flag,a.date, a.resby,a.resbyname,a.reserved,   
				b.sortid, b.chkmode,@name  
		from res_av a, res_plu b  
		where ( a.resid = b.resid ) and ( a.folio = @folio ) 
	
	end
	else
	begin 
		select @accnt = accnt from res_av_h where folio = @folio
		select @name = name from master a, guest b where a.haccnt=b.no and a.accnt=@accnt
	
		select a.folio, a.accnt,  a.sta, a.resid,b.name,  a.qty, a.stime, a.etime,a.sfield,   
				a.summary,  a.worker,a.amount,a.flag,a.date, a.resby,a.resbyname,a.reserved,   
				b.sortid, b.chkmode,@name  
		from res_av_h a, res_plu b  
		where ( a.resid = b.resid ) and ( a.folio = @folio ) 
	
	end
end
;



