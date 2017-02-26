if exists (select 1 from sysobjects where name = 'p_sync_guest_list_crs' and type = 'P')
   drop procedure p_sync_guest_list_crs
; 
--------------------------------------------------------------------------------
-- 需要同步的客人列表CRS
--------------------------------------------------------------------------------
create procedure p_sync_guest_list_crs
as	
begin 
	declare @no	 varchar(7)
	declare
		@cno					char(7),
		@row					integer,
		@cby					char(10),
		@changed				datetime,
		@logmark				integer,
		@old_sta				char(1),					@new_sta				char(1),
		@old_sno				varchar(15),			@new_sno				varchar(15),   
		@old_cno				varchar(20),			@new_cno				varchar(20),   
	
		@old_name			varchar(50),			@new_name			varchar(50),
		@old_lname			varchar(30),			@new_lname			varchar(30),
		@old_fname			varchar(30),			@new_fname			varchar(30),   
		@old_name2			varchar(50),			@new_name2			varchar(50),   
		@old_name3			varchar(50),			@new_name3			varchar(50),   
	
		@old_type			char(1),					@new_type			char(1),   
		@old_grade			char(1),					@new_grade			char(1),   
		@old_latency		char(1),					@new_latency		char(1),   
		@old_country		char(1),					@new_country		char(1),   
	
		@old_class1			char(3),					@new_class1			char(3),   
		@old_class2			char(3),					@new_class2			char(3),   
		@old_class3			char(3),					@new_class3			char(3),   
		@old_class4			char(3),					@new_class4			char(3),   
		@old_src				char(3),					@new_src				char(3),   
		@old_market			char(3),					@new_market			char(3),
		@old_vip				char(1),					@new_vip				char(1),
		@old_keep			char(1),					@new_keep			char(1),   
		@old_belong			varchar(15),			@new_belong			varchar(15),   
	
		@old_sex				char(1),					@new_sex				char(1),
		@old_lang			char(1),					@new_lang			char(1),   
		@old_title			char(3),					@new_title			char(3),   
		@old_salutation	varchar(60),			@new_salutation	varchar(60),   
	
		@old_birth			datetime,				@new_birth			datetime,
		@old_city	char(6),					@new_city	char(6),
		@old_race			char(2),					@new_race			char(2),
		@old_religion		char(2),					@new_religion		char(2),   
		@old_occupation	char(2),					@new_occupation	char(2),
		@old_nation			char(3),					@new_nation			char(3),
	
		@old_idcls			char(3),					@new_idcls			char(3),
		@old_ident			char(18),				@new_ident			char(18),
		@old_cusno			char(7),					@new_cusno			char(7),
		@old_unit			varchar(60),			@new_unit			varchar(60),
	
		@old_street		varchar(100),			@new_street		varchar(100),
		@old_street1		varchar(100),			@new_street1		varchar(100),   
		@old_zip				char(6),					@new_zip				char(6),   
		@old_mobile		varchar(20),			@new_mobile		varchar(20),   
		@old_phone			varchar(20),			@new_phone			varchar(20),   
		@old_fax				varchar(20),			@new_fax				varchar(20),   
		@old_wetsite		varchar(20),			@new_wetsite		varchar(20),   
		@old_email			varchar(20),			@new_email			varchar(20),   
	
		@old_visaid			char(3),					@new_visaid			char(3),
		@old_idend		datetime,				@new_idend		datetime,
		@old_visaend		datetime,				@new_visaend		datetime,
		@old_visano			varchar(20),			@new_visano			varchar(20),   
		@old_visaunit		char(4),					@new_visaunit		char(4),   
		@old_rjplace		char(3),					@new_rjplace		char(3),
		@old_rjdate			datetime,				@new_rjdate			datetime,
	
		@old_srqs			varchar(30),			@new_srqs			varchar(30),
		@old_feature		varchar(30),			@new_feature		varchar(30),   
		@old_rmpref			varchar(20),			@new_rmpref			varchar(20),   
		@old_interest		varchar(30),			@new_interest		varchar(30),   
	
		@old_lawman			varchar(16),			@new_lawman			varchar(16),
		@old_regno			varchar(20),			@new_regno			varchar(20),
		@old_bank			varchar(50),			@new_bank			varchar(50),   
		@old_bankno			varchar(20),			@new_bankno			varchar(20),   
		@old_taxno			varchar(20),			@new_taxno			varchar(20),   
		@old_liason			varchar(30),			@new_liason			varchar(30),   
		@old_liason1		varchar(30),			@new_liason1		varchar(30), 
		@old_extrainf		varchar(30),			@new_extrainf		varchar(30),   
		@old_refer1			varchar(250),			@new_refer1			varchar(250),   
		@old_refer2			varchar(250),			@new_refer2			varchar(250),   
		@old_refer3			varchar(250),			@new_refer3			varchar(250),   
		@old_comment		varchar(100),			@new_comment		varchar(100),   
		@old_override		char(1),					@new_override		char(1),   
	
		@old_arr				datetime,				@new_arr				datetime,
		@old_dep				datetime,				@new_dep				datetime,   
		@old_code1			char(10),				@new_code1			char(10),
		@old_code2			char(3),					@new_code2			char(3),   
		@old_code3			char(3),					@new_code3			char(3),   
		@old_code4			char(3),					@new_code4			char(3),   
		@old_code5			char(3),					@new_code5			char(3),   
		@old_saleid			char(12),				@new_saleid			char(12),   
		@old_araccnt1		char(7),					@new_araccnt1		char(7),
		@old_araccnt2		char(7),					@new_araccnt2		char(7),
		@old_master			char(7),					@new_master			char(7)

	create table #lgfl
	(
		columnname				char(15)					null,
		accnt						char(10)					null,
		old						varchar(60)				null,
		new						varchar(60)				null,
		empno						char(10)					null,
		date						datetime					null 
	)

	create table #lst
	(
		no				char(20)								not null,	-- 卡号	
		hno 			char(7)								not null,
		name		   varchar(50)	 						not null,	-- 姓名: 本名 
		op			   int 				default 0 		not null 
	)
	-- 把guest_sync转化成最后的纪录,即logmark最大
	update guest_sync set logmark = b.logmark + 1
		from guest_sync a,guest b 
		where a.no = b.no 
	-- 比较guest和guest_sync创建变化日志用于查对
	declare c_guest cursor for select distinct no from guest_sync 
	declare c_log_guest cursor for 
		select name, lname, sex, birth, occupation, sta, idcls, ident, nation, code1, city, visaid, idend, rjdate, rjplace, unit, cusno, 
			street, vip, lawman, race, regno, market, visaend, arr, araccnt1, srqs, cby, changed, logmark, 
			sno, cno, fname, name2, name3, type, grade, latency, country, class1, class2, class3, class4, src, keep, belong,
			lang, title, salutation, religion, street1, zip, mobile, phone, fax, wetsite, email, visano, visaunit,
			feature, rmpref, interest, bank, bankno, taxno, liason, liason1, extrainf, refer1, refer2, refer3, comment, override,
			dep, code1, code2, code3, code4, code5, saleid
			from guest_sync where no = @cno
		union select name, lname, sex, birth, occupation, sta, idcls, ident, nation, code1, city, visaid, idend, rjdate, rjplace, unit, cusno, 
			street, vip, lawman, race, regno, market, visaend, arr, araccnt1, srqs, cby, changed, logmark, 
			sno, cno, fname, name2, name3, type, grade, latency, country, class1, class2, class3, class4, src, keep, belong,
			lang, title, salutation, religion, street1, zip, mobile, phone, fax, wetsite, email, visano, visaunit,
			feature, rmpref, interest, bank, bankno, taxno, liason, liason1, extrainf, refer1, refer2, refer3, comment, override,
			dep, code1, code2, code3, code4, code5, saleid
			from guest where no = @cno
		order by logmark
	open c_guest
	fetch c_guest into @cno
	while @@sqlstatus = 0
	begin
		select @row = 0
		open c_log_guest
		fetch c_log_guest into @new_name, @new_lname, @new_sex, @new_birth, @new_occupation, @new_sta, 
			@new_idcls, @new_ident, @new_nation, @new_code1, @new_city, @new_visaid, @new_idend, @new_rjdate, @new_rjplace, @new_unit, @new_cusno, 
			@new_street, @new_vip, @new_lawman, @new_race, @new_regno, @new_market, @new_visaend, @new_arr, @new_araccnt1, @new_srqs, @cby, @changed, @logmark,
			@new_sno, @new_cno, @new_fname, @new_name2, @new_name3, @new_type, @new_grade, @new_latency, @new_country, @new_class1, @new_class2, @new_class3, @new_class4, @new_src, @new_keep, @new_belong,
			@new_lang, @new_title, @new_salutation, @new_religion, @new_street1, @new_zip, @new_mobile, @new_phone, @new_fax, @new_wetsite, @new_email, @new_visano, @new_visaunit,
			@new_feature, @new_rmpref, @new_interest, @new_bank, @new_bankno, @new_taxno, @new_liason, @new_liason1, @new_extrainf, @new_refer1, @new_refer2, @new_refer3, @new_comment, @new_override,
			@new_dep, @new_code1, @new_code2, @new_code3, @new_code4, @new_code5, @new_saleid
		while @@sqlstatus =0
			begin
			select @row = @row + 1
			if @row > 1
				begin
				if @new_name != @old_name
					insert #lgfl values ('g_name', @cno, @old_name, @new_name, @cby, @changed)
				if @new_lname != @old_lname
					insert #lgfl values ('g_lname', @cno, @old_lname, @new_lname, @cby, @changed)
				if @new_sex != @old_sex
					insert #lgfl values ('g_sex', @cno, @old_sex, @new_sex, @cby, @changed)
				if @new_birth != @old_birth
					insert #lgfl values ('g_birth', @cno, convert(char(10), @old_birth, 111) + ' ' + convert(char(10), @old_birth, 108), 
					convert(char(10), @new_birth, 111) + ' ' + convert(char(10), @new_birth, 108), @cby, @changed)
				if @new_occupation != @old_occupation
					insert #lgfl values ('g_occupation', @cno, @old_occupation, @new_occupation, @cby, @changed)
				if @new_sta != @old_sta
					insert #lgfl values ('g_sta', @cno, @old_sta, @new_sta, @cby, @changed)
				if @new_idcls != @old_idcls
					insert #lgfl values ('g_idcls', @cno, @old_idcls, @new_idcls, @cby, @changed)
				if @new_ident != @old_ident
					insert #lgfl values ('g_ident', @cno, @old_ident, @new_ident, @cby, @changed)
				if @new_arr != @old_arr
					insert #lgfl values ('g_arr', @cno, convert(char(10), @old_arr, 111) + ' ' + convert(char(10), @old_arr, 108), 
					convert(char(10), @new_arr, 111) + ' ' + convert(char(10), @new_arr, 108), @cby, @changed)
				if @new_nation != @old_nation
					insert #lgfl values ('g_nation', @cno, @old_nation, @new_nation, @cby, @changed)
				if @new_vip != @old_vip
					insert #lgfl values ('g_vip', @cno, @old_vip, @new_vip, @cby, @changed)
				if @new_lawman != @old_lawman
					insert #lgfl values ('g_lawman', @cno, @old_lawman, @new_lawman, @cby, @changed)
				if @new_race != @old_race
					insert #lgfl values ('g_race', @cno, @old_race, @new_race, @cby, @changed)
				if @new_regno != @old_regno
					insert #lgfl values ('g_regno', @cno, @old_regno, @new_regno, @cby, @changed)
				if @new_street != @old_street
					insert #lgfl values ('g_street', @cno, @old_street, @new_street, @cby, @changed)
				if @new_city != @old_city
					insert #lgfl values ('g_city', @cno, @old_city, @new_city, @cby, @changed)
				if @new_visaid != @old_visaid
					insert #lgfl values ('g_visaid', @cno, @old_visaid, @new_visaid, @cby, @changed)
				if @new_idend != @old_idend
					insert #lgfl values ('g_idend', @cno, convert(char(10), @old_idend, 111) + ' ' + convert(char(10), @old_idend, 108), 
					convert(char(10), @new_idend, 111) + ' ' + convert(char(10), @new_idend, 108), @cby, @changed)
				if @new_visaend != @old_visaend
					insert #lgfl values ('g_visaend', @cno, convert(char(10), @old_visaend, 111) + ' ' + convert(char(10), @old_visaend, 108), 
					convert(char(10), @new_visaend, 111) + ' ' + convert(char(10), @new_visaend, 108), @cby, @changed)
				if @new_rjdate != @old_rjdate
					insert #lgfl values ('g_rjdate', @cno, convert(char(10), @old_rjdate, 111) + ' ' + convert(char(10), @old_rjdate, 108), 
					convert(char(10), @new_rjdate, 111) + ' ' + convert(char(10), @new_rjdate, 108), @cby, @changed)
				if @new_rjplace != @old_rjplace
					insert #lgfl values ('g_rjplace', @cno, @old_rjplace, @new_rjplace, @cby, @changed)
				if @new_unit != @old_unit
					insert #lgfl values ('g_unit', @cno, @old_unit, @new_unit, @cby, @changed)
				if @new_cusno != @old_cusno
					insert #lgfl values ('g_cusno', @cno, @old_cusno, @new_cusno, @cby, @changed)
				if @new_araccnt1 != @old_araccnt1
					insert #lgfl values ('g_araccnt1', @cno, @old_araccnt1, @new_araccnt1, @cby, @changed)
				if @new_srqs != @old_srqs
					insert #lgfl values ('g_srqs', @cno, @old_srqs, @new_srqs, @cby, @changed)
				if @new_sno != @old_sno
					insert #lgfl values ('g_sno', @cno, @old_sno, @new_sno, @cby, @changed)
				if @new_cno != @old_cno
					insert #lgfl values ('g_cno', @cno, @old_cno, @new_cno, @cby, @changed)
				if @new_fname != @old_fname
					insert #lgfl values ('g_fname', @cno, @old_fname, @new_fname, @cby, @changed)
				if @new_name2 != @old_name2
					insert #lgfl values ('g_name2', @cno, @old_name2, @new_name2, @cby, @changed)
				if @new_name3 != @old_name3
					insert #lgfl values ('g_name3', @cno, @old_name3, @new_name3, @cby, @changed)
				if @new_type != @old_type
					insert #lgfl values ('g_type', @cno, @old_type, @new_type, @cby, @changed)
				if @new_grade != @old_grade
					insert #lgfl values ('g_grade', @cno, @old_grade, @new_grade, @cby, @changed)
				if @new_latency != @old_latency
					insert #lgfl values ('g_latency', @cno, @old_latency,@new_latency, @cby, @changed)
				if @new_country != @old_country
					insert #lgfl values ('g_country', @cno, @old_country, @new_country, @cby, @changed)
				if @new_class1 != @old_class1
					insert #lgfl values ('g_class1', @cno, @old_class1, @new_class1, @cby, @changed)
				if @new_class2 != @old_class2
					insert #lgfl values ('g_class2', @cno, @old_class2, @new_class2, @cby, @changed)
				if @new_class3 != @old_class3
					insert #lgfl values ('g_class3', @cno, @old_class3, @new_class3, @cby, @changed)
				if @new_class4 != @old_class4
					insert #lgfl values ('g_class4', @cno, @old_class4, @new_class4, @cby, @changed)
				if @new_src != @old_src
					insert #lgfl values ('g_src', @cno, @old_src, @new_src, @cby, @changed)
				if @new_keep != @old_keep
					insert #lgfl values ('g_keep', @cno, @old_keep, @new_keep, @cby, @changed)
				if @new_belong != @old_belong
					insert #lgfl values ('g_belong', @cno, @old_belong, @new_belong, @cby, @changed)
				if @new_lang != @old_lang
					insert #lgfl values ('g_lang', @cno, @old_lang, @new_lang, @cby, @changed)
				if @new_title != @old_title
					insert #lgfl values ('g_title', @cno, @old_title, @new_title, @cby, @changed)
				if @new_salutation != @old_salutation
					insert #lgfl values ('g_salutation', @cno, @old_salutation, @new_salutation, @cby, @changed)
				if @new_religion != @old_religion
					insert #lgfl values ('g_religion', @cno, @old_religion, @new_religion, @cby, @changed)
				if @new_street1 != @old_street1
					insert #lgfl values ('g_street1', @cno, @old_street1, @new_street1, @cby, @changed)
				if @new_zip != @old_zip
					insert #lgfl values ('g_zip', @cno, @old_zip, @new_zip, @cby, @changed)
				if @new_mobile != @old_mobile
					insert #lgfl values ('g_mobile', @cno, @old_mobile, @new_mobile, @cby, @changed)
				if @new_phone != @old_phone
					insert #lgfl values ('g_phone', @cno, @old_phone, @new_phone, @cby, @changed)
				if @new_fax != @old_fax
					insert #lgfl values ('g_fax', @cno, @old_fax, @new_fax, @cby, @changed)
				if @new_wetsite != @old_wetsite
					insert #lgfl values ('g_wetsite', @cno, @old_wetsite, @new_wetsite, @cby, @changed)
				if @new_email != @old_email
					insert #lgfl values ('g_email', @cno, @old_email, @new_email, @cby, @changed)
				if @new_visano != @old_visano
					insert #lgfl values ('g_visano', @cno, @old_visano, @new_visano, @cby, @changed)
				if @new_visaunit != @old_visaunit
					insert #lgfl values ('g_visaunit', @cno, @old_visaunit, @new_visaunit, @cby, @changed)
				if @new_feature != @old_feature
					insert #lgfl values ('g_feature', @cno, @old_feature, @new_feature, @cby, @changed)
				if @new_rmpref != @old_rmpref
					insert #lgfl values ('g_rmpref', @cno, @old_rmpref, @new_rmpref, @cby, @changed)
				if @new_interest != @old_interest
					insert #lgfl values ('g_interest', @cno, @old_interest, @new_interest, @cby, @changed)
				if @new_bank != @old_bank
					insert #lgfl values ('g_bank', @cno, @old_bank, @new_bank, @cby, @changed)
				if @new_bankno != @old_bankno
					insert #lgfl values ('g_bankno', @cno, @old_bankno, @new_bankno, @cby, @changed)
				if @new_taxno != @old_taxno
					insert #lgfl values ('g_taxno', @cno, @old_taxno, @new_taxno, @cby, @changed)
				if @new_liason != @old_liason
					insert #lgfl values ('g_liason', @cno, @old_liason, @new_liason, @cby, @changed)
				if @new_liason1 != @old_liason1
					insert #lgfl values ('g_liason1', @cno, @old_liason1, @new_liason1, @cby, @changed)
				if @new_extrainf != @old_extrainf
					insert #lgfl values ('g_extrainf', @cno, @old_extrainf, @new_extrainf, @cby, @changed)
				if @new_refer1 != @old_refer1
					insert #lgfl values ('g_refer1', @cno, @old_refer1, @new_refer1, @cby, @changed)
				if @new_refer2 != @old_refer2
					insert #lgfl values ('g_refer2', @cno, @old_refer2, @new_refer2, @cby, @changed)
				if @new_refer3 != @old_refer3
					insert #lgfl values ('g_refer3', @cno, @old_refer3, @new_refer3, @cby, @changed)
				if @new_comment != @old_comment
					insert #lgfl values ('g_comment', @cno, @old_comment, @new_comment, @cby, @changed)
				if @new_override != @old_override
					insert #lgfl values ('g_override', @cno, @old_override, @new_override, @cby, @changed)
				if @new_dep != @old_dep
					insert #lgfl values ('g_dep', @cno, convert(char(10), @old_dep, 111) + ' ' + convert(char(10), @old_dep, 108), 
					convert(char(10), @new_dep, 111) + ' ' + convert(char(10), @new_dep, 108), @cby, @changed)
				if @new_code1 != @old_code1
					insert #lgfl values ('g_code1', @cno, @old_code1, @new_code1, @cby, @changed)
				if @new_code2 != @old_code2
					insert #lgfl values ('g_code2', @cno, @old_code2, @new_code2, @cby, @changed)
				if @new_code3 != @old_code3
					insert #lgfl values ('g_code3', @cno, @old_code3, @new_code3, @cby, @changed)
				if @new_code4 != @old_code4
					insert #lgfl values ('g_code4', @cno, @old_code4, @new_code4, @cby, @changed)
				if @new_code5 != @old_code5
					insert #lgfl values ('g_code5', @cno, @old_code5, @new_code5, @cby, @changed)
				if @new_saleid != @old_saleid
					insert #lgfl values ('g_saleid', @cno, @old_saleid,@new_saleid, @cby, @changed)
				end
			select @old_name = @new_name, @old_lname = @new_lname, @old_sex = @new_sex, @old_birth = @new_birth, 
				@old_occupation = @new_occupation, @old_sta = @new_sta, @old_idcls = @new_idcls, @old_ident = @new_ident, 
				@old_nation = @new_nation, @old_code1 = @new_code1, @old_city = @new_city, @old_visaid = @new_visaid, 
				@old_idend = @new_idend, @old_rjdate = @new_rjdate, @old_rjplace = @new_rjplace, 
				@old_cusno = @new_cusno, @old_unit = @new_unit, @old_araccnt1 = @new_araccnt1, @old_srqs = @new_srqs, 
				@old_street = @new_street, @old_vip = @new_vip, @old_lawman = @new_lawman, @old_race = @new_race, 
				@old_regno = @new_regno, @old_market = @new_market, @old_visaend = @new_visaend, @old_arr = @new_arr,
				@old_sno = @new_sno, @old_cno = @new_cno, @old_fname = @new_fname, @old_name2 = @new_name2, @old_name3 = @new_name3, 
				@old_type = @new_type, @old_grade = @new_grade, @old_latency = @new_latency, @old_country = @new_country, 
				@old_class1 = @new_class1, @old_class2 = @new_class2, @old_class3 = @new_class3, @old_class4 = @new_class4,
				@old_src = @new_src, @old_keep = @new_keep, @old_belong = @new_belong, @old_lang = @new_lang, @old_title = @new_title,
				@old_salutation = @new_salutation, @old_religion = @new_religion, @old_street1 = @new_street1, @old_zip = @new_zip,
				@old_mobile = @new_mobile, @old_phone = @new_phone, @old_fax = @new_fax, @old_wetsite = @new_wetsite, @old_email = @new_email,
				@old_visano = @new_visano, @old_visaunit = @new_visaunit, @old_feature = @new_feature,
				@old_rmpref = @new_rmpref, @old_interest = @new_interest, @old_bank = @new_bank, @old_bankno = @new_bankno,
				@old_taxno = @new_taxno, @old_liason = @new_liason, @old_liason1 = @new_liason1, @old_extrainf =@new_extrainf,
				@old_refer1 = @new_refer1, @old_refer2 = @new_refer2, @old_refer3 = @new_refer3, @old_comment = @new_comment, @old_override = @new_override,
				@old_dep = @new_dep, @old_code1 = @new_code1, @old_code2 = @new_code2, @old_code3 = @new_code3,
				@old_code4 = @new_code4, @old_code5 = @new_code5, @old_saleid = @new_saleid
			fetch c_log_guest into @new_name, @new_lname, @new_sex, @new_birth, @new_occupation, @new_sta, 
				@new_idcls, @new_ident, @new_nation, @new_code1, @new_city, @new_visaid, @new_idend, @new_rjdate, @new_rjplace, @new_unit, @new_cusno, 
				@new_street, @new_vip, @new_lawman, @new_race, @new_regno, @new_market, @new_visaend, @new_arr, @new_araccnt1, @new_srqs, @cby, @changed, @logmark,
				@new_sno, @new_cno, @new_fname, @new_name2, @new_name3, @new_type, @new_grade, @new_latency, @new_country, @new_class1, @new_class2, @new_class3, @new_class4, @new_src, @new_keep, @new_belong,
				@new_lang, @new_title, @new_salutation, @new_religion, @new_street1, @new_zip, @new_mobile, @new_phone, @new_fax, @new_wetsite, @new_email, @new_visano, @new_visaunit,
				@new_feature, @new_rmpref, @new_interest, @new_bank, @new_bankno, @new_taxno, @new_liason, @new_liason1, @new_extrainf, @new_refer1, @new_refer2, @new_refer3, @new_comment, @new_override,
				@new_dep, @new_code1, @new_code2, @new_code3, @new_code4, @new_code5, @new_saleid
			end
		close c_log_guest
		fetch c_guest into @cno
	end
	deallocate cursor c_log_guest
	close c_guest
	deallocate cursor c_guest


	
	insert into #lst (no,hno,name)
		select b.no,b.hno,a.name from guest_sync a, vipcard b where b.hno = a.no   
	
	select c.op,c.hno,c.name,c.no,b.descript, a.old, a.new, a.empno, a.date 
		from #lgfl a, lgfl_des b,#lst c
		where a.accnt= c.hno and a.columnname = b.columnname 
	order by a.date, a.columnname
	
end
;

exec p_sync_guest_list_crs;
