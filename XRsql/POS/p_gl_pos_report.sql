drop proc p_gl_pos_report;
create proc p_gl_pos_report
as
---------------------------------------------------------------------------------
--
--	综合收银营业情况统计表, auditprg
-- 根据 pos_tmenu 的tag,tag1,tag2,tag3,source,market 统计，累计台数，人数，消费额
---------------------------------------------------------------------------------
declare
	@duringaudit		char(1),
	@bdate				datetime,
	@bfdate				datetime,
	@isfstday			char(1) ,
	@isyfstday			char(1) ,

	@pccode				char(3),
	@tag				   char(1),
	@tag1				   char(1),
	@tag2				   char(1),
	@tag3				   char(1),
	@source			   char(3),
	@market			   char(3),
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
	tablesm4 = tablesm4 - tablesd4, guestsm4 = guestsm4 - guestsd4, amountm4 = amountm4 - amountd4,
	tablesm5 = tablesm5 - tablesd5, guestsm5 = guestsm5 - guestsd5, amountm5 = amountm5 - amountd5,
	tablesm6 = tablesm6 - tablesd6, guestsm6 = guestsm6 - guestsd6, amountm6 = amountm6 - amountd6
	where date = @bdate
update pos_report set
	tablesd1 = 0, guestsd1 = 0, amountd1 = 0,
	tablesd2 = 0, guestsd2 = 0, amountd2 = 0,
	tablesd3 = 0, guestsd3 = 0, amountd3 = 0,
	tablesd4	= 0, guestsd4 = 0, amountd4 = 0,
	tablesd5	= 0, guestsd5 = 0, amountd5 = 0,
	tablesd6	= 0, guestsd6 = 0, amountd6 = 0
commit tran


update pos_tmenu set tag = 'Z' where tag  = '' or tag is null
update pos_tmenu set tag1 = 'Z' where tag1 = '' or tag is null
update pos_tmenu set tag2 = 'Z' where tag2 = '' or tag is null
update pos_tmenu set tag3 = 'Z' where tag2 = '' or tag is null
update pos_tmenu set source = 'Z' where source = '' or tag is null
update pos_tmenu set market = 'Z' where market = '' or tag is null
declare c_menu cursor for select pccode, tag,tag1,tag2,tag3,source,market,shift, tables, guest, amount from pos_tmenu where sta = '3'
open c_menu
fetch c_menu into @pccode, @tag, @tag1, @tag2, @tag3, @source,@market, @shift, @tables, @guest, @charge
while @@sqlstatus = 0
	begin
	if not exists(select 1 from pos_report where pccode = @pccode and class='tag' and code = @tag)
		insert pos_report select @bfdate, @pccode, 'tag', @tag,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	if not exists(select 1 from pos_report where pccode = @pccode and class='tag1' and code = @tag1)
		insert pos_report select @bfdate, @pccode, 'tag1', @tag1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	if not exists(select 1 from pos_report where pccode = @pccode and class='tag2' and code = @tag2)
		insert pos_report select @bfdate, @pccode, 'tag2', @tag2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	if not exists(select 1 from pos_report where pccode = @pccode and class='tag3' and code = @tag3)
		insert pos_report select @bfdate, @pccode, 'tag3', @tag3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	if not exists(select 1 from pos_report where pccode = @pccode and class='source' and code = @source)
		insert pos_report select @bfdate, @pccode, 'source', @source,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	if not exists(select 1 from pos_report where pccode = @pccode and class='market' and code = @market)
		insert pos_report select @bfdate, @pccode, 'market', @market,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	if @shift = '1'
		begin
		update pos_report set
			tablesd1 = tablesd1 + @tables, guestsd1 = guestsd1 + @guest, amountd1 = amountd1 + @charge
			where pccode = @pccode and class='tag' and code = @tag
		update pos_report set
			tablesd1 = tablesd1 + @tables, guestsd1 = guestsd1 + @guest, amountd1 = amountd1 + @charge
			where pccode = @pccode and class='tag1' and code = @tag1
		update pos_report set
			tablesd1 = tablesd1 + @tables, guestsd1 = guestsd1 + @guest, amountd1 = amountd1 + @charge
			where pccode = @pccode and class='tag2' and code = @tag2
		update pos_report set
			tablesd1 = tablesd1 + @tables, guestsd1 = guestsd1 + @guest, amountd1 = amountd1 + @charge
			where pccode = @pccode and class='tag3' and code = @tag3
		update pos_report set
			tablesd1 = tablesd1 + @tables, guestsd1 = guestsd1 + @guest, amountd1 = amountd1 + @charge
			where pccode = @pccode and class='source' and code = @source
		update pos_report set
			tablesd1 = tablesd1 + @tables, guestsd1 = guestsd1 + @guest, amountd1 = amountd1 + @charge
			where pccode = @pccode and class='market' and code = @market
		end
	else if @shift = '2'
		begin
		update pos_report set
			tablesd2 = tablesd2 + @tables, guestsd2 = guestsd2 + @guest, amountd2 = amountd2 + @charge
			where pccode = @pccode and class='tag' and code = @tag
		update pos_report set
			tablesd2 = tablesd2 + @tables, guestsd2 = guestsd2 + @guest, amountd2 = amountd2 + @charge
			where pccode = @pccode and class='tag1' and code = @tag1
		update pos_report set
			tablesd2 = tablesd2 + @tables, guestsd2 = guestsd2 + @guest, amountd2 = amountd2 + @charge
			where pccode = @pccode and class='tag2' and code = @tag2
		update pos_report set
			tablesd2 = tablesd2 + @tables, guestsd2 = guestsd2 + @guest, amountd2 = amountd2 + @charge
			where pccode = @pccode and class='tag3' and code = @tag3
		update pos_report set
			tablesd2 = tablesd2 + @tables, guestsd2 = guestsd2 + @guest, amountd2 = amountd2 + @charge
			where pccode = @pccode and class='source' and code = @source
		update pos_report set
			tablesd2 = tablesd2 + @tables, guestsd2 = guestsd2 + @guest, amountd2 = amountd2 + @charge
			where pccode = @pccode and class='market' and code = @market
		end
	else if @shift = '3'
		begin
		update pos_report set
			tablesd3 = tablesd3 + @tables, guestsd3 = guestsd3 + @guest, amountd3 = amountd3 + @charge
			where pccode = @pccode and class='tag' and code = @tag
		update pos_report set
			tablesd3 = tablesd3 + @tables, guestsd3 = guestsd3 + @guest, amountd3 = amountd3 + @charge
			where pccode = @pccode and class='tag1' and code = @tag1
		update pos_report set
			tablesd3 = tablesd3 + @tables, guestsd3 = guestsd3 + @guest, amountd3 = amountd3 + @charge
			where pccode = @pccode and class='tag2' and code = @tag2
		update pos_report set
			tablesd3 = tablesd3 + @tables, guestsd3 = guestsd3 + @guest, amountd3 = amountd3 + @charge
			where pccode = @pccode and class='tag3' and code = @tag3
		update pos_report set
			tablesd3 = tablesd3 + @tables, guestsd3 = guestsd3 + @guest, amountd3 = amountd3 + @charge
			where pccode = @pccode and class='source' and code = @source
		update pos_report set
			tablesd3 = tablesd3 + @tables, guestsd3 = guestsd3 + @guest, amountd3 = amountd3 + @charge
			where pccode = @pccode and class='market' and code = @market
		end
	else if @shift = '4'
		begin
		update pos_report set
			tablesd4 = tablesd4 + @tables, guestsd4 = guestsd4 + @guest, amountd4 = amountd4 + @charge
			where pccode = @pccode and class='tag' and code = @tag
		update pos_report set
			tablesd4 = tablesd4 + @tables, guestsd4 = guestsd4 + @guest, amountd4 = amountd4 + @charge
			where pccode = @pccode and class='tag1' and code = @tag1
		update pos_report set
			tablesd4 = tablesd4 + @tables, guestsd4 = guestsd4 + @guest, amountd4 = amountd4 + @charge
			where pccode = @pccode and class='tag2' and code = @tag2
		update pos_report set
			tablesd4 = tablesd4 + @tables, guestsd4 = guestsd4 + @guest, amountd4 = amountd4 + @charge
			where pccode = @pccode and class='tag3' and code = @tag3
		update pos_report set
			tablesd4 = tablesd4 + @tables, guestsd4 = guestsd4 + @guest, amountd4 = amountd4 + @charge
			where pccode = @pccode and class='source' and code = @source
		update pos_report set
			tablesd4 = tablesd4 + @tables, guestsd4 = guestsd4 + @guest, amountd4 = amountd4 + @charge
			where pccode = @pccode and class='market' and code = @market
		end
	else if @shift = '5'
		begin
		update pos_report set
			tablesd5 = tablesd5 + @tables, guestsd5 = guestsd5 + @guest, amountd5 = amountd5 + @charge
			where pccode = @pccode and class='tag' and code = @tag
		update pos_report set
			tablesd5 = tablesd5 + @tables, guestsd5 = guestsd5 + @guest, amountd5 = amountd5 + @charge
			where pccode = @pccode and class='tag1' and code = @tag1
		update pos_report set
			tablesd5 = tablesd5 + @tables, guestsd5 = guestsd5 + @guest, amountd5 = amountd5 + @charge
			where pccode = @pccode and class='tag2' and code = @tag2
		update pos_report set
			tablesd5 = tablesd5 + @tables, guestsd5 = guestsd5 + @guest, amountd5 = amountd5 + @charge
			where pccode = @pccode and class='tag3' and code = @tag3
		update pos_report set
			tablesd5 = tablesd5 + @tables, guestsd5 = guestsd5 + @guest, amountd5 = amountd5 + @charge
			where pccode = @pccode and class='source' and code = @source
		update pos_report set
			tablesd5 = tablesd5 + @tables, guestsd5 = guestsd5 + @guest, amountd5 = amountd5 + @charge
			where pccode = @pccode and class='market' and code = @market
		end
	else
		begin
		update pos_report set
			tablesd6 = tablesd6 + @tables, guestsd6 = guestsd6 + @guest, amountd6 = amountd6 + @charge
			where pccode = @pccode and class='tag' and code = @tag
		update pos_report set
			tablesd6 = tablesd6 + @tables, guestsd6 = guestsd6 + @guest, amountd6 = amountd6 + @charge
			where pccode = @pccode and class='tag1' and code = @tag1
		update pos_report set
			tablesd6 = tablesd6 + @tables, guestsd6 = guestsd6 + @guest, amountd6 = amountd6 + @charge
			where pccode = @pccode and class='tag2' and code = @tag2
		update pos_report set
			tablesd6 = tablesd6 + @tables, guestsd6 = guestsd6 + @guest, amountd6 = amountd6 + @charge
			where pccode = @pccode and class='tag3' and code = @tag3
		update pos_report set
			tablesd6 = tablesd6 + @tables, guestsd6 = guestsd6 + @guest, amountd6 = amountd6 + @charge
			where pccode = @pccode and class='source' and code = @source
		update pos_report set
			tablesd6 = tablesd6 + @tables, guestsd6 = guestsd6 + @guest, amountd6 = amountd6 + @charge
			where pccode = @pccode and class='market' and code = @market
		end
	fetch c_menu into @pccode, @tag, @tag1, @tag2, @tag3, @source,@market, @shift, @tables, @guest, @charge
   end
close c_menu
deallocate cursor c_menu
begin tran
update pos_report set
	tablesm1 = tablesm1 + tablesd1, guestsm1 = guestsm1 + guestsd1,amountm1 = amountm1 + amountd1,
	tablesm2 = tablesm2 + tablesd2, guestsm2 = guestsm2 + guestsd2, amountm2 = amountm2 + amountd2,
	tablesm3 = tablesm3 + tablesd3, guestsm3 = guestsm3 + guestsd3, amountm3 = amountm3 + amountd3,
	tablesm4 = tablesm4 + tablesd4, guestsm4 = guestsm4 + guestsd4, amountm4 = amountm4 + amountd4,
	tablesm5 = tablesm5 + tablesd5, guestsm5 = guestsm5 + guestsd5, amountm5 = amountm5 + amountd5,
	tablesm6 = tablesm6 + tablesd6, guestsm6 = guestsm6 + guestsd6, amountm6 = amountm6 + amountd6,
	date = @bdate
delete pos_yreport where date = @bdate
insert pos_yreport select * from pos_report
commit tran
return 0 
;