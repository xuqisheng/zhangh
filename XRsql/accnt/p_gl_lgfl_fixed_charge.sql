//delete lgfl_des where columnname like 'fc_%';
//insert lgfl_des(columnname,descript,descript1,tag) values('fc_new', '新建固定支出', 'New FixedCharge', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('fc_delete', '删除固定支出', 'Delete FixedCharge', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('fc_pccode', '营业项目', 'Department', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('fc_argcode', '账单编码', 'Arrangement', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('fc_amount', '金额', 'Amount', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('fc_quantity', '数量', 'Quantity', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('fc_starting', '起始日期', 'From', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('fc_closing', '截止日期', 'To', 'R');
//
if exists (select * from sysobjects where name = 'p_gl_lgfl_fixed_charge' and type = 'P')
	drop proc p_gl_lgfl_fixed_charge;
create proc p_gl_lgfl_fixed_charge
	@operation			char(1) = 'S'
as
/* fixed_charge日志 */
declare
	@accnt				char(10),
	@number				integer,
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer,
	@old_pccode			char(5),					@new_pccode			char(5),
	@old_argcode		char(3),					@new_argcode		char(3),
	@old_amount			money,					@new_amount			money,
	@old_quantity		money,					@new_quantity		money,
	@old_starting		datetime,				@new_starting		datetime,
	@old_closing		datetime,				@new_closing		datetime

//
declare c_fixed_charge cursor for select distinct accnt, number from fixed_charge_log
//
declare c_log_fixed_charge cursor for
	select pccode, argcode, amount, quantity, starting_time, closing_time, cby, changed, logmark
		from fixed_charge_log where accnt = @accnt and number = @number
	union select pccode, argcode, amount, quantity, starting_time, closing_time, cby, changed, logmark
		from fixed_charge where accnt = @accnt and number = @number
	order by logmark
open c_fixed_charge
fetch c_fixed_charge into @accnt, @number
while @@sqlstatus = 0
   begin
	select @row = 0
	open c_log_fixed_charge
	fetch c_log_fixed_charge into @new_pccode,@new_argcode,@new_amount,@new_quantity,@new_starting,@new_closing,@cby,@changed,@logmark
	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @new_pccode != @old_pccode
				insert lgfl values ('fc_pccode  ' + convert(char(4), @number), @accnt, @old_pccode, @new_pccode, @cby, @changed)
			if @new_argcode != @old_argcode
				insert lgfl values ('fc_argcode ' + convert(char(4), @number), @accnt, @old_argcode, @new_argcode, @cby, @changed)
			if @new_amount != @old_amount
				insert lgfl values ('fc_amount  ' + convert(char(4), @number), @accnt, convert(char(10),@old_amount), convert(char(10),@new_amount), @cby, @changed)
			if @new_quantity != @old_quantity
				insert lgfl values ('fc_quantity' + convert(char(4), @number), @accnt, convert(char(10),@old_quantity), convert(char(10),@new_quantity), @cby, @changed)
			if @new_starting != @old_starting
				insert lgfl values ('fc_starting' + convert(char(4), @number), @accnt, convert(char(10),@old_starting,111), convert(char(10),@new_starting,111), @cby, @changed)
			if @new_closing != @old_closing
				insert lgfl values ('fc_closing ' + convert(char(4), @number), @accnt, convert(char(10),@old_closing,111), convert(char(10),@new_closing,111), @cby, @changed)
			end
		select @old_pccode = @new_pccode, @old_argcode = @new_argcode, 
			@old_amount = @new_amount, @old_quantity = @new_quantity, 
			@old_starting = @new_starting, @old_closing = @new_closing

		fetch c_log_fixed_charge into @new_pccode,@new_argcode,@new_amount,@new_quantity,@new_starting,@new_closing,@cby,@changed,@logmark
		end
	close c_log_fixed_charge
	if @row > 0
		delete fixed_charge_log where accnt=@accnt and number=@number and logmark < @logmark
	fetch c_fixed_charge into @accnt, @number
	end
deallocate cursor c_log_fixed_charge
close c_fixed_charge
deallocate cursor c_fixed_charge
//
if @operation = 'S'
	select 0, ''
;
