if exists (select * from sysobjects where name = 'p_gl_lgfl_ar_master' and type = 'P')
	drop proc p_gl_lgfl_ar_master;
create proc p_gl_lgfl_ar_master
	@accnt			char(10)
as
declare
	@laccnt				char(10),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer,
	-- AR_MASTER
	@old_sta				char(1),					@new_sta				char(1),
	@old_arr				datetime,				@new_arr				datetime,
	@old_dep				datetime,				@new_dep				datetime,
	@old_haccnt			char(7),					@new_haccnt			char(7),--
	@old_artag1			char(5),					@new_artag1			char(5),
	@old_artag2			char(5),					@new_artag2			char(5),
	@old_address1		char(60),				@new_address1		char(60),
	@old_address2		char(60),				@new_address2		char(60),
	@old_address3		char(60),				@new_address3		char(60),
	@old_address4		char(60),				@new_address4		char(60),
	@old_paycode		char(6),					@new_paycode		char(6),
	@old_cycle			char(5),					@new_cycle			char(5),--
	@old_limit			money,					@new_limit			money,
	@old_srqs			varchar(30),			@new_srqs			varchar(30),
	@old_ref				char(100),				@new_ref				char(100),
	@old_credcode		char(20),				@new_credcode		char(20),--
	@old_credman		char(20),				@new_credman		char(20),--
	@old_credunit		char(40),				@new_credunit		char(40),--
	@old_applname		char(20),				@new_applname		char(20),
	@old_applicant		char(30),				@new_applicant		char(30),
	@old_phone			char(16),				@new_phone			char(16),	
	@old_fax				char(16),				@new_fax				char(16),
	@old_email			char(30),				@new_email			char(30),
	@old_saleid			varchar(10),			@new_saleid			varchar(10),--
   @old_extra			char(15),				@new_extra			char(15),
	@old_gstname		varchar(50),			@new_gstname		varchar(50)	-- 为了查询方便加入档案对应的客人名 hbb 2004.11.29

if not exists(select 1 from ar_master_log where accnt=@accnt)
	return

-- 
delete lgfl where accnt = @accnt and columnname like 'ar[_]%'

-- MASTER日志 
if @accnt is null
	declare c_ar_master cursor for 
		select accnt from ar_master_log group by accnt having count(1) > 1
else
	declare c_ar_master cursor for 
		select accnt from ar_master_log where accnt = @accnt group by accnt having count(1) > 1
declare c_log_ar_master cursor for 
	select sta, arr, dep, artag1, artag2, address1, address2,
		address3, address4, paycode, limit, srqs, ref, applname, applicant, 
		fax, phone, email, cby, changed, logmark, 
		cycle, haccnt, extra, credcode, credman, credunit, saleid
	from ar_master_log where accnt = @laccnt order by logmark
open c_ar_master
fetch c_ar_master into @laccnt
while @@sqlstatus =0
   begin
	select @row = 0
	open c_log_ar_master
	fetch c_log_ar_master into @new_sta, @new_arr, @new_dep, @new_artag1, @new_artag2, 
		@new_address1, @new_address2, @new_address3, @new_address4, 
		@new_paycode, @new_limit, @new_srqs, @new_ref, @new_applname, @new_applicant, 
		@new_fax, @new_phone, @new_email, @cby, @changed, @logmark,
		@new_cycle, @new_haccnt, @new_extra, @new_credcode, @new_credman, @new_credunit, @new_saleid
	while @@sqlstatus =0
		begin
		if @logmark = 1
			insert lgfl values ('ar_reservation', @laccnt, '', @laccnt, @cby, @changed)
		select @row = @row + 1
		if @row > 1
			begin
			if @new_sta != @old_sta and not(@old_sta = 'O' and @new_sta = 'D')
				insert lgfl values ('ar_sta', @laccnt, @old_sta, @new_sta, @cby, @changed)
			if @new_arr != @old_arr
				insert lgfl values ('ar_arr', @laccnt, convert(char(10), @old_arr, 111) + ' ' + convert(char(10), @old_arr,108), 
				convert(char(10), @new_arr, 111) + ' ' + convert(char(10), @new_arr, 108), @cby, @changed)
			if @new_dep != @old_dep
				insert lgfl values ('ar_dep', @laccnt, convert(char(10), @old_dep, 111) + ' ' + convert(char(10), @old_dep, 108), 
				convert(char(10), @new_dep, 111) + ' ' + convert(char(10), @new_dep, 108), @cby, @changed)
			if @new_artag1 != @old_artag1
				insert lgfl values ('ar_artag1', @laccnt, @old_artag1, @new_artag1, @cby, @changed)
			if @new_artag2 != @old_artag2
				insert lgfl values ('ar_artag2', @laccnt, @old_artag2, @new_artag2, @cby, @changed)
			if @new_address1 != @old_address1
				insert lgfl values ('ar_address1', @laccnt, @old_address1, @new_address1, @cby, @changed)
			if @new_address2 != @old_address2
				insert lgfl values ('ar_address2', @laccnt, @old_address2, @new_address2, @cby, @changed)
			if @new_address3 != @old_address3
				insert lgfl values ('ar_address3', @laccnt, @old_address3, @new_address3, @cby, @changed)
			if @new_address4 != @old_address4
				insert lgfl values ('ar_address4', @laccnt, @old_address4, @new_address4, @cby, @changed)
			if @new_paycode != @old_paycode
				insert lgfl values ('ar_paycode', @laccnt, @old_paycode, @new_paycode, @cby, @changed)
			if @new_limit != @old_limit
				insert lgfl values ('ar_limit', @laccnt, ltrim(convert(char(10), @old_limit)), ltrim(convert(char(10), @new_limit)), @cby, @changed)
			if @new_srqs != @old_srqs
				insert lgfl values ('ar_srqs', @laccnt, @old_srqs, @new_srqs, @cby, @changed)
			if @new_ref != @old_ref
				insert lgfl values ('ar_ref', @laccnt, @old_ref, @new_ref, @cby, @changed)
			if @new_applname != @old_applname
				insert lgfl values ('ar_applname', @laccnt, @old_applname, @new_applname, @cby, @changed)
			if @new_applicant != @old_applicant
				insert lgfl values ('ar_applicant', @laccnt, @old_applicant, @new_applicant, @cby, @changed)
			if @new_fax != @old_fax
				insert lgfl values ('ar_fax', @laccnt, @old_fax, @new_fax, @cby, @changed)
			if @new_phone != @old_phone
				insert lgfl values ('ar_phone', @laccnt, @old_phone, @new_phone, @cby, @changed)
			if @new_email != @old_email
				insert lgfl values ('ar_email', @laccnt, @old_email, @new_email, @cby, @changed)
			if @new_cycle != @old_cycle
				insert lgfl values ('ar_cycle', @laccnt, @old_cycle, @new_cycle, @cby, @changed)

			if @new_haccnt != @old_haccnt -- 为了查询方便加入档案对应的客人名 hbb 2004.11.29				
				begin
					select @old_gstname = rtrim(name) from guest where no = @old_haccnt
					select @new_gstname = rtrim(name) from guest where no = @new_haccnt
					insert lgfl values ('ar_haccnt', @laccnt, @old_haccnt + isnull('[' + @old_gstname + ']',''), 
						@new_haccnt + isnull('[' + @new_gstname + ']',''), @cby, @changed)
				end

			if @new_credcode != @old_credcode
				insert lgfl values ('ar_credcode', @laccnt, @old_credcode, @new_credcode, @cby, @changed)
			if @new_credman != @old_credman
				insert lgfl values ('ar_credman', @laccnt, @old_credman, @new_credman, @cby, @changed)
			if @new_credunit != @old_credunit
				insert lgfl values ('ar_credunit', @laccnt, @old_credunit, @new_credunit, @cby, @changed)
			if @new_saleid != @old_saleid
				insert lgfl values ('ar_saleid', @laccnt, @old_saleid, @new_saleid, @cby, @changed)
			if substring(@new_extra,1,1) != substring(@old_extra,1,1)
				insert lgfl values ('ar_extra_1', @laccnt, substring(@old_extra,1,1), substring(@new_extra,1,1), @cby, @changed)
			if substring(@new_extra,4,1) != substring(@old_extra,4,1)
				insert lgfl values ('ar_extra_4', @laccnt, substring(@old_extra,4,1), substring(@new_extra,4,1), @cby, @changed)
			if substring(@new_extra,5,1) != substring(@old_extra,5,1)
				insert lgfl values ('ar_extra_5', @laccnt, substring(@old_extra,5,1), substring(@new_extra,5,1), @cby, @changed)
			if substring(@new_extra,6,1) != substring(@old_extra,6,1)
				insert lgfl values ('ar_extra_6', @laccnt, substring(@old_extra,6,1), substring(@new_extra,6,1), @cby, @changed)
			if substring(@new_extra,7,1) != substring(@old_extra,7,1)
				insert lgfl values ('ar_extra_7', @laccnt, substring(@old_extra,7,1), substring(@new_extra,7,1), @cby, @changed)
			if substring(@new_extra,8,1) != substring(@old_extra,8,1)
				insert lgfl values ('ar_extra_8', @laccnt, substring(@old_extra,8,1), substring(@new_extra,8,1), @cby, @changed)
			if substring(@new_extra,12,1) != substring(@old_extra,12,1)
				insert lgfl values ('ar_extra_12', @laccnt, substring(@old_extra,12,1), substring(@new_extra,12,1), @cby, @changed)
			end
		select @old_sta = @new_sta, @old_arr = @new_arr, @old_dep = @new_dep, @old_artag1 = @new_artag1, @old_artag2 = @new_artag2, 
			@old_address1 = @new_address1, @old_address2 = @new_address2, @old_address3 = @new_address3, @old_address4 = @new_address4,
			@old_paycode = @new_paycode, @old_limit = @new_limit, @old_srqs = @new_srqs, @old_ref = @new_ref, @old_applname = @new_applname,
			@old_applicant = @new_applicant, @old_fax = @new_fax, @old_phone = @new_phone, @old_email = @new_email, 
			@old_cycle = @new_cycle, @old_haccnt = @new_haccnt, @old_extra =@new_extra,
			@old_credcode = @new_credcode, @old_credman = @new_credman, @old_credunit = @new_credunit, @old_saleid = @new_saleid
		fetch c_log_ar_master into @new_sta, @new_arr, @new_dep, @new_artag1, @new_artag2, 
			@new_address1, @new_address2, @new_address3, @new_address4, 
			@new_paycode, @new_limit, @new_srqs, @new_ref, @new_applname, @new_applicant, 
			@new_fax, @new_phone, @new_email, @cby, @changed, @logmark,
			@new_cycle, @new_haccnt, @new_extra, @new_credcode, @new_credman, @new_credunit, @new_saleid
		end
	close c_log_ar_master
	fetch c_ar_master into @laccnt
	end
deallocate cursor c_log_ar_master
close c_ar_master
deallocate cursor c_ar_master
;
