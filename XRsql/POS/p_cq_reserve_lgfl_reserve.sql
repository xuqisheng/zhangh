drop proc p_cq_reserve_lgfl_reserve;
create proc p_cq_reserve_lgfl_reserve
	@accnt			char(10)
as
declare
	@laccnt				char(10),
	@lguestid			char(7),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer

declare
	@old_tag			char(1),
	@old_date0		datetime,
	@old_shift		char(1),
	@old_pccode		char(3),
	@old_cusno		char(7),
	@old_haccnt		char(7),
	@old_sta			char(1),
	@old_tableno	char(4),
	@old_unit		char(20),
	@old_unitto		char(20),
	@old_name		char(10),
	@old_phone		char(15),
	@old_araccnt	char(7),
	@old_guest		integer,
	@old_tables		integer,
	@old_standent	money,
	@old_stdunit	char(1),
	@old_email		char(20),
	@old_mode		char(3),
	@old_flag		char(20),
	@old_paymth		char(5),
	@old_saleid		char(10),
	@old_remark		varchar(255),
	@old_accnt		char(10),

	@new_tag			char(1),
	@new_date0		datetime,
	@new_shift		char(1),
	@new_pccode		char(3),
	@new_cusno		char(7),
	@new_haccnt		char(7),
	@new_sta			char(1),
	@new_tableno	char(4),
	@new_unit		char(20),
	@new_unitto		char(20),
	@new_name		char(10),
	@new_phone		char(15),
	@new_araccnt	char(7),
	@new_guest		integer,
	@new_tables		integer,
	@new_standent	money,
	@new_stdunit	char(1),
	@new_email		char(20),
	@new_mode		char(3),
	@new_flag		char(20),
	@new_paymth		char(5),
	@new_saleid		char(10),
	@new_remark		varchar(255),
	@new_accnt		char(10)

declare		@pos			int

select @changed = getdate()
if @accnt is null
	declare c_reserve cursor for
		select resno from pos_reserve_log group by resno having count(1) > 1
else
	declare c_reserve cursor for
		select resno from pos_reserve_log where resno = @accnt group by resno having count(1) > 1
declare c_log_reserve cursor for
  SELECT tag,
			date0,
			shift,
			pccode,
			cusno,
			haccnt,
			sta,
			tableno,
			unit,
			unitto,
			name,
			phone,
			araccnt,
			guest,
			tables,
			standent,
			stdunit,
			email,
			mode,
			flag,
			paymth,
			saleid,
			isnull(convert(char(255),remark),''),
			cby,
         logmark,
			accnt
	from pos_reserve_log where resno = @laccnt order by logmark
open c_reserve
fetch c_reserve into @laccnt
while @@sqlstatus =0
   begin

	select @row = 0
	open c_log_reserve
	fetch c_log_reserve into
		@new_tag,
		@new_date0,
		@new_shift,
		@new_pccode,
		@new_cusno,
		@new_haccnt,
		@new_sta,
		@new_tableno,
		@new_unit,
		@new_unitto,
		@new_name,
		@new_phone,
		@new_araccnt,
		@new_guest,
		@new_tables,
		@new_standent,
		@new_stdunit,
		@new_email,
		@new_mode,
		@new_flag,
		@new_paymth,
		@new_saleid,
		@new_remark,
		@cby,
		@logmark,
		@accnt

	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @new_tag != @old_tag
				insert lgfl values ( 'pr_tag',  @laccnt,@old_tag, @new_tag, @cby, @changed)
			if @new_date0 != @old_date0
				insert lgfl values ('pr_date0', @laccnt,convert(char(10), @old_date0, 111) + ' ' + convert(char(10), @old_date0, 108),
				convert(char(10), @new_date0, 111) + ' ' + convert(char(10), @new_date0, 108), @cby, @changed)
			if @new_shift != @old_shift
				insert lgfl values ('pr_shift',  @laccnt,  @old_shift, @new_shift, @cby, @changed)
			if @new_pccode != @old_pccode
				insert lgfl values ('pr_pccode', @laccnt, @old_pccode, @new_pccode, @cby, @changed)
			if @new_cusno != @old_cusno
				insert lgfl values ('pr_cusno', @laccnt, @old_cusno, @new_cusno, @cby, @changed)
			if @new_haccnt != @old_haccnt
				insert lgfl values ('pr_haccnt', @laccnt, @old_haccnt, @new_haccnt, @cby, @changed)
			if @new_sta != @old_sta
				insert lgfl values ('pr_sta', @laccnt,@old_sta, @new_sta, @cby, @changed)
			if @new_tableno != @old_tableno
				insert lgfl values ('pr_tableno', @laccnt, @old_tableno, @new_tableno, @cby, @changed)
			if @new_unit != @old_unit
				insert lgfl values ('pr_unit', @laccnt,  @old_unit, @new_unit, @cby, @changed)
			if @new_unitto != @old_unitto
				insert lgfl values ('pr_unitto', @laccnt, @old_unitto, @new_unitto, @cby, @changed)

			if @new_name != @old_name
				insert lgfl values ('pr_name', @laccnt,  @old_name, @new_name, @cby, @changed)
			if @new_phone != @old_phone
				insert lgfl values ('pr_phone',  @laccnt,  @old_phone, @new_phone, @cby, @changed)
			if @new_mode != @old_mode
				insert lgfl values ('pr_mode',  @laccnt,  @old_mode, @new_mode, @cby, @changed)
			if @new_guest != @old_guest
				insert lgfl values ('pr_guest', @laccnt, ltrim(convert(char(10), @old_guest)), ltrim(convert(char(10), @new_guest)), @cby, @changed)
			if @new_tables != @old_tables
				insert lgfl values ('pr_tables', @laccnt, ltrim(convert(char(10), @old_tables)), ltrim(convert(char(10), @new_tables)), @cby, @changed)

			if @new_email != @old_email
				insert lgfl values ( 'pr_email',  @laccnt,  @old_email, @new_email, @cby, @changed)
			if @new_flag != @old_flag
				insert lgfl values ('pr_flag', @laccnt, @old_flag, @new_flag, @cby, @changed)
			if @new_saleid != @old_saleid
				insert lgfl values ('pr_saleid', @laccnt,  @old_saleid, @new_saleid, @cby, @changed)
			if @new_remark != @old_remark
				insert lgfl values ( 'pr_remark',  @laccnt, @old_remark, @new_remark, @cby, @changed)
			if @new_accnt != @old_accnt
				insert lgfl values ( 'pr_accnt',  @laccnt, @old_accnt, @new_accnt, @cby, @changed)

			end
		select 	@old_tag = @new_tag,
					@old_date0 = @new_date0,
					@old_shift = @new_shift,
					@old_pccode = @new_pccode,
					@old_cusno = @new_cusno,
					@old_haccnt = @new_haccnt,
					@old_sta = @new_sta,
					@old_tableno = @new_tableno,
					@old_unit = @new_unit,
					@old_unitto = @new_unitto,
					@old_name = @new_name,
					@old_phone = @new_phone,
					@old_araccnt = @new_araccnt,
					@old_guest = @new_guest,
					@old_tables = @new_tables,
					@old_standent = @new_standent,
					@old_stdunit = @new_stdunit,
					@old_email = @new_email,
					@old_mode = @new_mode,
					@old_flag = @new_flag,
					@old_paymth = @new_paymth,
					@old_saleid = @new_saleid,
					@old_remark = @new_remark,
					@old_accnt = @new_accnt

		fetch c_log_reserve into
					@new_tag,
					@new_date0,
					@new_shift,
					@new_pccode,
					@new_cusno,
					@new_haccnt,
					@new_sta,
					@new_tableno,
					@new_unit,
					@new_unitto,
					@new_name,
					@new_phone,
					@new_araccnt,
					@new_guest,
					@new_tables,
					@new_standent,
					@new_stdunit,
					@new_email,
					@new_mode,
					@new_flag,
					@new_paymth,
					@new_saleid,
					@new_remark,
					@cby,
					@logmark,
					@accnt
		end
	close c_log_reserve
	if @row > 0
		delete pos_reserve_log where resno = @laccnt and logmark < @logmark
	fetch c_reserve into @laccnt
	end

deallocate cursor c_log_reserve
close c_reserve
deallocate cursor c_reserve

return

;