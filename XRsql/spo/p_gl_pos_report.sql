drop procedure p_gl_pos_report;
create proc p_gl_pos_report
as

declare
	@duringaudit		char(1),			              
	@bdate				datetime,		            
	@bfdate				datetime,		            
	@isfstday			char(1) ,
	@isyfstday			char(1) ,
	      
	@pccode				char(2),			          
	@tag				   char(1),			            
	@shift			   char(1),			            
	@tables				integer,			        
	@guest				integer,			        
   @charge				money				            

select @duringaudit = audit from gate
if @duringaudit = 'T'
   select @bdate = bdate from sysdata
else
   select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
                                                                                          
                    
                               
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
                        
if @isfstday = 'T'
   truncate table pos_report
begin  tran     
update pos_report set
	tablesm1 = tablesm1 - tablesd1, guestsm1 = guestsm1 - guestsd1, amountm1 = amountm1 - amountd1, 
	tablesm2 = tablesm2 - tablesd2, guestsm2 = guestsm2 - guestsd2, amountm2 = amountm2 - amountd2, 
	tablesm3 = tablesm3 - tablesd3, guestsm3 = guestsm3 - guestsd3, amountm3 = amountm3 - amountd3, 
	tablesm4 = tablesm4 - tablesd4, guestsm4 = guestsm4 - guestsd4, amountm4 = amountm4 - amountd4
	where date = @bdate
update pos_report set
	tablesd1 = 0, guestsd1 = 0, amountd1 = 0, 
	tablesd2 = 0, guestsd2 = 0, amountd2 = 0, 
	tablesd3 = 0, guestsd3 = 0, amountd3 = 0, 
	tablesd4 = 0, guestsd4 = 0, amountd4 = 0
commit tran
                                                        
                                                        
                                                        
declare c_menu cursor for select pccode, tag, shift, tables, guest, amount from pos_tmenu where paid = '1'
		union select pccode, tag, shift, tables, guest, amount from sp_tmenu where paid = '1'
open c_menu
fetch c_menu into @pccode, @tag, @shift, @tables, @guest, @charge
while @@sqlstatus = 0
	begin
	if not exists(select 1 from pos_report where pccode = @pccode and tag = @tag)
		insert pos_report (date, pccode, tag) select @bfdate, @pccode, @tag
	if @shift = '1'
		update pos_report set 
			tablesd1 = tablesd1 + @tables, guestsd1 = guestsd1 + @guest, amountd1 = amountd1 + @charge
			where pccode = @pccode and tag = @tag
	else if @shift = '2'
		update pos_report set 
			tablesd2 = tablesd2 + @tables, guestsd2 = guestsd2 + @guest, amountd2 = amountd2 + @charge
			where pccode = @pccode and tag = @tag
	else if @shift = '3'
		update pos_report set 
			tablesd3 = tablesd3 + @tables, guestsd3 = guestsd3 + @guest, amountd3 = amountd3 + @charge
			where pccode = @pccode and tag = @tag
	else
		update pos_report set 
			tablesd4 = tablesd4 + @tables, guestsd4 = guestsd4 + @guest, amountd4 = amountd4 + @charge
			where pccode = @pccode and tag = @tag
	fetch c_menu into @pccode, @tag, @shift, @tables, @guest, @charge
   end
close c_menu
deallocate cursor c_menu
begin tran
update pos_report set 
	tablesm1 = tablesm1 + tablesd1, guestsm1 = guestsm1 + guestsd1, amountm1 = amountm1 + amountd1, 
	tablesm2 = tablesm2 + tablesd2, guestsm2 = guestsm2 + guestsd2, amountm2 = amountm2 + amountd2, 
	tablesm3 = tablesm3 + tablesd3, guestsm3 = guestsm3 + guestsd3, amountm3 = amountm3 + amountd3, 
	tablesm4 = tablesm4 + tablesd4, guestsm4 = guestsm4 + guestsd4, amountm4 = amountm4 + amountd4, 
	date = @bdate
delete pos_yreport where date = @bdate
insert pos_yreport select * from pos_report
commit tran
return 0

;