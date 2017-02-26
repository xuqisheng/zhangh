drop proc p_gl_lgfl_master
;
create proc p_gl_lgfl_master
	@accnt			char(10)
as
declare
	@laccnt				char(10),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer,
	-- MASTER
	@old_roomno			char(5),					@new_roomno			char(5),
	@old_type			char(5),					@new_type			char(5),--
	@old_cardno			varchar(20),			@new_cardno			varchar(20),--
	@old_up_type		char(5),					@new_up_type		char(5),--
	@old_up_reason		char(3),					@new_up_reason		char(3),--
	@old_sta				char(1),					@new_sta				char(1),
	@old_arr				datetime,				@new_arr				datetime,
	@old_dep				datetime,				@new_dep				datetime,
	@old_haccnt			char(7),					@new_haccnt			char(7),--
	@old_agent			char(7),					@new_agent			char(7),--
	@old_cusno			char(7),					@new_cusno			char(7),--
	@old_source			char(7),					@new_source			char(7),--
	@old_src				char(3),					@new_src				char(3),
	@old_market			char(3),					@new_market			char(3),
	@old_restype		char(3),					@new_restype		char(3),
	@old_channel		char(3),					@new_channel		char(3),--
	@old_rmnum			integer,					@new_rmnum			integer,
	@old_gstno			integer,					@new_gstno			integer,
	@old_children		integer,					@new_children		integer,
	@old_qtrate			money,					@new_qtrate			money,--
	@old_setrate		money,					@new_setrate		money,
	@old_addbed			money,					@new_addbed			money,
	@old_addbed_rate	money,					@new_addbed_rate	money,
	@old_rmreason		char(1),					@new_rmreason		char(1),
	@old_rtreason		char(3),					@new_rtreason		char(3),
	@old_ratecode		char(10),				@new_ratecode		char(10),
	@old_paycode		char(6),					@new_paycode		char(6),
	@old_limit			money,					@new_limit			money,
	@old_srqs			varchar(30),			@new_srqs			varchar(30),
	@old_packages		varchar(50),			@new_packages		varchar(50),--
	@old_fixrate		char(1),					@new_fixrate		char(1),--
	@old_ref				char(255),				@new_ref				char(255),
	@old_credcode		char(20),				@new_credcode		char(20),--
	@old_credman		char(20),				@new_credman		char(20),--
	@old_credunit		char(40),				@new_credunit		char(40),--
	@old_applname		char(20),				@new_applname		char(20),
	@old_applicant		char(30),				@new_applicant		char(30),
	@old_araccnt		char(10),				@new_araccnt		char(10),
	@old_phone			char(16),				@new_phone			char(16),	
	@old_arrinfo		char(30),				@new_arrinfo		char(30),
	@old_arrdate		datetime,				@new_arrdate		datetime,--
	@old_arrcar			char(10),				@new_arrcar			char(10),
	@old_arrrate		money,					@new_arrrate		money,--
	@old_depinfo		char(30),				@new_depinfo		char(30),
	@old_depdate		datetime,				@new_depdate		datetime,--
	@old_depcar			char(10),				@new_depcar			char(10),
	@old_deprate		money,					@new_deprate		money,--
	@old_comsg			varchar(80),			@new_comsg			varchar(80),--
	@old_card			char(7),					@new_card			char(7),--
	@old_saleid			varchar(10),			@new_saleid			varchar(10),--
	@old_amenities		varchar(30),			@new_amenities		varchar(30),--
	@old_resno			varchar(10),			@new_resno			varchar(10),--
	@old_blkcode		varchar(10),			@new_blkcode		varchar(10),--
	@old_pcrec			varchar(10),			@new_pcrec			varchar(10),--
	@old_crsno			varchar(20),			@new_crsno			varchar(20),--
   @old_extra			char(15),				@new_extra			char(15),
	@old_gstname		varchar(50),			@new_gstname		varchar(50),	-- 为了查询方便加入档案对应的客人名 hbb 2004.11.29
	@old_groupno		char(10),				@new_groupno		char(10),		-- 出入团需要记日志 hbb 2004.12.11
	@old_cmscode		char(10),				@new_cmscode		char(10),
	@old_exp_m1			money,					@new_exp_m1			money,
	@old_exp_dt1		datetime,				@new_exp_dt1		datetime,
	@old_fax			varchar(16),				@new_fax			varchar(16)  

if not exists(select 1 from master_log where accnt=@accnt)
	return

-- 
delete lgfl where accnt = @accnt and columnname like 'm[_]%' and columnname <>'m_mrfj' and columnname<>'m_cancelrmres'

-- MASTER日志 
if @accnt is null
	declare c_master cursor for 
		select accnt from master_log group by accnt having count(1) > 1
else
	declare c_master cursor for 
		select accnt from master_log where accnt = @accnt group by accnt having count(1) >= 1
declare c_log_master cursor for 
	select roomno, sta, arr, dep, src, restype, gstno, rmnum,setrate, qtrate, rmreason, rtreason,
		ratecode, paycode, limit, srqs, ref, applname, applicant, market, children, addbed, addbed_rate, 
		araccnt, phone, arrinfo, depinfo, cby, changed, logmark, 
		up_type, up_reason, haccnt, agent, cusno, source, channel, extra,packages, fixrate, credcode, credman, credunit, 
		arrdate, depdate, comsg, card, saleid, amenities, resno, blkcode, pcrec, crsno,groupno,type,cardno,arrcar,arrrate,depcar,deprate ,cmscode
		,exp_m1,exp_dt1,fax 
	from master_log where accnt = @laccnt order by logmark
open c_master
fetch c_master into @laccnt
while @@sqlstatus =0
   begin
	select @row = 0
	open c_log_master
	fetch c_log_master into @new_roomno, @new_sta, @new_arr, @new_dep, @new_src, @new_restype, 
		@new_gstno, @new_rmnum, @new_setrate, @new_qtrate, @new_rmreason, @new_rtreason, @new_ratecode, 
		@new_paycode, @new_limit, @new_srqs, @new_ref, @new_applname, @new_applicant, 
		@new_market, @new_children, @new_addbed, @new_addbed_rate, 
		@new_araccnt, @new_phone, @new_arrinfo, @new_depinfo, @cby, @changed, @logmark,
		@new_up_type, @new_up_reason, @new_haccnt, @new_agent, @new_cusno, @new_source, @new_channel,@new_extra, @new_packages, @new_fixrate, @new_credcode, @new_credman, @new_credunit,
		@new_arrdate, @new_depdate, @new_comsg, @new_card, @new_saleid, @new_amenities, @new_resno, @new_blkcode, @new_pcrec, @new_crsno, @new_groupno,@new_type,@new_cardno,
		@new_arrcar,@new_arrrate,@new_depcar,@new_deprate,@new_cmscode,@new_exp_m1,@new_exp_dt1,@new_fax 
	while @@sqlstatus =0
		begin
		if @logmark = 1
			insert lgfl(columnname,accnt,old,new,empno,date) values ('m_reservation', @laccnt, '', @laccnt, @cby, @changed)
		select @row = @row + 1
		if @row > 1
			begin
			if @new_roomno != @old_roomno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_roomno', @laccnt, @old_roomno, @new_roomno, @cby, @changed)
			if @new_sta != @old_sta and not(@old_sta = 'O' and @new_sta = 'D')
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_sta', @laccnt, @old_sta, @new_sta, @cby, @changed)
			if @new_arr != @old_arr
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_arr', @laccnt, convert(char(10), @old_arr, 111) + ' ' + convert(char(10), @old_arr,108), 
				convert(char(10), @new_arr, 111) + ' ' + convert(char(10), @new_arr, 108), @cby, @changed)
			if @new_dep != @old_dep
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_dep', @laccnt, convert(char(10), @old_dep, 111) + ' ' + convert(char(10), @old_dep, 108), 
				convert(char(10), @new_dep, 111) + ' ' + convert(char(10), @new_dep, 108), @cby, @changed)
			if @new_src != @old_src
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_src', @laccnt, @old_src, @new_src, @cby, @changed)
			if @new_restype != @old_restype
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_restype', @laccnt, @old_restype, @new_restype, @cby, @changed)
			if @new_gstno != @old_gstno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_gstno', @laccnt, ltrim(convert(char(10), @old_gstno)), ltrim(convert(char(10), @new_gstno)), @cby, @changed)
			if @new_rmnum != @old_rmnum
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_rmnum', @laccnt, ltrim(convert(char(10), @old_rmnum)), ltrim(convert(char(10), @new_rmnum)), @cby, @changed)
			if @new_setrate != @old_setrate
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_setrate', @laccnt, ltrim(convert(char(20), @old_setrate)), ltrim(convert(char(20), @new_setrate)), @cby, @changed)
			if @new_qtrate != @old_qtrate
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_qtrate', @laccnt, ltrim(convert(char(20), @old_qtrate)), ltrim(convert(char(20), @new_qtrate)), @cby, @changed)
			if @new_rmreason != @old_rmreason
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_rmreason', @laccnt, @old_rmreason, @new_rmreason, @cby, @changed)
			if @new_rtreason != @old_rtreason
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_rtreason', @laccnt, @old_rtreason, @new_rtreason, @cby, @changed)
			if @new_ratecode != @old_ratecode
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_ratecode', @laccnt, @old_ratecode, @new_ratecode, @cby, @changed)
--			if @new_paycode != @old_paycode
--				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_paycode', @laccnt, @old_paycode, @new_paycode, @cby, @changed)
--			if @new_limit != @old_limit
--				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_limit', @laccnt, ltrim(convert(char(20), @old_limit)), ltrim(convert(char(20), @new_limit)), @cby, @changed)
			if @new_srqs != @old_srqs
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_srqs', @laccnt, @old_srqs, @new_srqs, @cby, @changed)
			if @new_ref != @old_ref
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_ref', @laccnt, @old_ref, @new_ref, @cby, @changed)
			if @new_applname != @old_applname
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_applname', @laccnt, @old_applname, @new_applname, @cby, @changed)
			if @new_applicant != @old_applicant
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_applicant', @laccnt, @old_applicant, @new_applicant, @cby, @changed)
			if @new_araccnt != @old_araccnt
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_araccnt', @laccnt, @old_araccnt, @new_araccnt, @cby, @changed)
			if @new_phone != @old_phone
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_phone', @laccnt, @old_phone, @new_phone, @cby, @changed)
			if @new_arrinfo != @old_arrinfo
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_arrinfo', @laccnt, @old_arrinfo, @new_arrinfo, @cby, @changed)
			if @new_depinfo != @old_depinfo
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_depinfo', @laccnt, @old_depinfo, @new_depinfo, @cby, @changed)

			if @new_arrcar != @old_arrcar
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_arrcar', @laccnt, @old_arrcar, @new_arrcar, @cby, @changed)
			if @new_arrrate != @old_arrrate
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_arrrate', @laccnt, ltrim(convert(char(20), @old_arrrate)), ltrim(convert(char(20), @new_arrrate)), @cby, @changed)
			if @new_depcar != @old_depcar
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_depcar', @laccnt, @old_depcar, @new_depcar, @cby, @changed)
			if @new_deprate != @old_deprate
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_deprate', @laccnt, ltrim(convert(char(20), @old_deprate)), ltrim(convert(char(20), @new_deprate)), @cby, @changed)

			if @new_market != @old_market
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_market', @laccnt, @old_market, @new_market, @cby, @changed)
			if @new_children != @old_children
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_children', @laccnt, ltrim(convert(char(10), @old_children)), ltrim(convert(char(10), @new_children)), @cby, @changed)
			if @new_addbed != @old_addbed
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_addbed', @laccnt, ltrim(convert(char(10), @old_addbed)), ltrim(convert(char(10), @new_addbed)), @cby, @changed)
			if @new_addbed_rate != @old_addbed_rate
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_addbed_rate', @laccnt, ltrim(convert(char(20), @old_addbed_rate)), ltrim(convert(char(20), @new_addbed_rate)), @cby, @changed)
			if @new_up_type != @old_up_type
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_up_type', @laccnt, @old_up_type, @new_up_type, @cby, @changed)
			if @new_type != @old_type
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_type', @laccnt, @old_type, @new_type, @cby, @changed)
			if @new_cardno != @old_cardno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_cardno', @laccnt, @old_cardno, @new_cardno, @cby, @changed)
			if @new_up_reason != @old_up_reason
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_up_reason', @laccnt, @old_up_reason, @new_up_reason, @cby, @changed)

			if @new_haccnt != @old_haccnt -- 为了查询方便加入档案对应的客人名 hbb 2004.11.29				
				begin
					select @old_gstname = rtrim(name) from guest where no = @old_haccnt
					select @new_gstname = rtrim(name) from guest where no = @new_haccnt
					insert lgfl(columnname,accnt,old,new,empno,date) values ('m_haccnt', @laccnt, @old_haccnt + isnull('[' + @old_gstname + ']',''), 
						@new_haccnt + isnull('[' + @new_gstname + ']',''), @cby, @changed)
				end

			if @new_agent != @old_agent
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_agent', @laccnt, @old_agent, @new_agent, @cby, @changed)
			if @new_cusno != @old_cusno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_cusno', @laccnt, @old_cusno, @new_cusno, @cby, @changed)
			if @new_source != @old_source
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_source', @laccnt, @old_source, @new_source, @cby, @changed)
			if @new_channel != @old_channel
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_channel', @laccnt, @old_channel, @new_channel, @cby, @changed)
			if @new_packages != @old_packages
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_packages', @laccnt, @old_packages, @new_packages, @cby, @changed)
			if @new_fixrate != @old_fixrate
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_fixrate', @laccnt, @old_fixrate, @new_fixrate, @cby, @changed)
--			if @new_credcode != @old_credcode
--				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_credcode', @laccnt, @old_credcode, @new_credcode, @cby, @changed)
			if @new_credman != @old_credman
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_credman', @laccnt, @old_credman, @new_credman, @cby, @changed)
			if @new_credunit != @old_credunit
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_credunit', @laccnt, @old_credunit, @new_credunit, @cby, @changed)
 			if @new_comsg != @old_comsg
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_comsg', @laccnt, @old_comsg, @new_comsg, @cby, @changed)
			if @new_card != @old_card
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_card', @laccnt, @old_card, @new_card, @cby, @changed)
			if @new_saleid != @old_saleid
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_saleid', @laccnt, @old_saleid, @new_saleid, @cby, @changed)
			if @new_amenities != @old_amenities
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_amenities', @laccnt, @old_amenities, @new_amenities, @cby, @changed)
			if @new_resno != @old_resno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_resno', @laccnt, @old_resno, @new_resno, @cby, @changed)
			if @new_blkcode != @old_blkcode
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_blkcode', @laccnt, @old_blkcode, @new_blkcode, @cby, @changed)
			if @new_pcrec != @old_pcrec
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_pcrec', @laccnt, @old_pcrec, @new_pcrec, @cby, @changed)
			if substring(@new_extra,1,1) != substring(@old_extra,1,1)
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_extra_1', @laccnt, substring(@old_extra,1,1), substring(@new_extra,1,1), @cby, @changed)
			if substring(@new_extra,4,1) != substring(@old_extra,4,1)
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_extra_4', @laccnt, substring(@old_extra,4,1), substring(@new_extra,4,1), @cby, @changed)
			if substring(@new_extra,5,1) != substring(@old_extra,5,1)
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_extra_5', @laccnt, substring(@old_extra,5,1), substring(@new_extra,5,1), @cby, @changed)
			if substring(@new_extra,6,1) != substring(@old_extra,6,1)
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_extra_6', @laccnt, substring(@old_extra,6,1), substring(@new_extra,6,1), @cby, @changed)
			if substring(@new_extra,7,1) != substring(@old_extra,7,1)
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_extra_7', @laccnt, substring(@old_extra,7,1), substring(@new_extra,7,1), @cby, @changed)
			if substring(@new_extra,8,1) != substring(@old_extra,8,1)
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_extra_8', @laccnt, substring(@old_extra,8,1), substring(@new_extra,8,1), @cby, @changed)
			if substring(@new_extra,12,1) != substring(@old_extra,12,1)
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_extra_12', @laccnt, substring(@old_extra,12,1), substring(@new_extra,12,1), @cby, @changed)
			if @new_crsno != @old_crsno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_crsno', @laccnt, @old_crsno, @new_crsno, @cby, @changed)
			if @new_arrdate != @old_arrdate
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_arrdate', @laccnt, rtrim(convert(char(20), @old_arrdate, 111)) + ' ' + convert(char(20), @old_arrdate, 108), 
				rtrim(convert(char(20), @new_arrdate, 111)) + ' ' + rtrim(convert(char(20), @new_arrdate, 108)), @cby, @changed)
			if @new_depdate != @old_depdate
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_depdate', @laccnt, rtrim(convert(char(20), @old_depdate, 111)) + ' ' + convert(char(20), @old_depdate, 108), 
				rtrim(convert(char(20), @new_depdate, 111)) + ' ' + rtrim(convert(char(20), @new_depdate, 108)), @cby, @changed)
			-- 出入团需要记日志 hbb 2004.12.11
			if @new_groupno != @old_groupno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_groupno',@laccnt,@old_groupno,@new_groupno,@cby,@changed)
			if @old_cmscode!=@new_cmscode
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_cmscode',@laccnt,@old_cmscode,@new_cmscode,@cby,@changed)
			if @old_exp_m1!=@new_exp_m1
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_expm1',@laccnt,@old_exp_m1,@new_exp_m1,@cby,@changed)
			if @old_exp_dt1!=@new_exp_dt1
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_expdt1',@laccnt,convert(char(20), @old_exp_dt1, 111),convert(char(20), @new_exp_dt1, 111),@cby,@changed)
			if @old_fax!=@new_fax
				insert lgfl(columnname,accnt,old,new,empno,date) values ('m_fax',@laccnt,@old_fax,@new_fax,@cby,@changed)
			end
		select @old_roomno = @new_roomno, @old_sta = @new_sta, @old_arr = @new_arr, @old_dep = @new_dep, 
			@old_src = @new_src, @old_restype = @new_restype, @old_gstno = @new_gstno, @old_rmnum = @new_rmnum, @old_setrate = @new_setrate, 
			@old_qtrate = @new_qtrate, @old_rmreason = @new_rmreason, @old_rtreason = @new_rtreason, 
			@old_ratecode = @new_ratecode, @old_paycode = @new_paycode, @old_limit = @new_limit, 
			@old_srqs = @new_srqs, @old_ref = @new_ref, @old_applname = @new_applname, @old_applicant = @new_applicant, 
			@old_market = @new_market, @old_children = @new_children, @old_addbed = @new_addbed, @old_addbed_rate = @new_addbed_rate, 
			@old_araccnt = @new_araccnt, @old_phone = @new_phone, @old_arrinfo = @new_arrinfo, @old_depinfo = @new_depinfo,
			@old_up_type = @new_up_type, @old_up_reason = @new_up_reason, @old_haccnt = @new_haccnt, @old_agent = @new_agent, 
			@old_cusno = @new_cusno, @old_source = @new_source, @old_channel = @new_channel, @old_extra =@new_extra,
			@old_packages = @new_packages, @old_fixrate = @new_fixrate, @old_credcode = @new_credcode, @old_credman = @new_credman,
			@old_credunit = @new_credunit, @old_arrdate = @new_arrdate, @old_arrdate = @new_arrdate, @old_depdate = @new_depdate,
			@old_comsg = @new_comsg, @old_card = @new_card, @old_saleid = @new_saleid, @old_amenities = @new_amenities, @old_resno = @new_resno, @old_blkcode = @new_blkcode, @old_pcrec = @new_pcrec, @old_crsno = @new_crsno,
			@old_groupno = @new_groupno,@old_type = @new_type,@old_cardno = @new_cardno,@old_exp_m1 = @new_exp_m1,@old_exp_dt1 = @new_exp_dt1,
			@old_fax=@new_fax
		select @old_arrcar=@new_arrcar,@old_arrrate=@new_arrrate,@old_depcar=@new_depcar,@old_deprate=@new_deprate  ,@old_cmscode=@new_cmscode
		fetch c_log_master into @new_roomno, @new_sta, @new_arr, @new_dep, @new_src, @new_restype, 
			@new_gstno, @new_rmnum, @new_setrate, @new_qtrate, @new_rmreason, @new_rtreason, @new_ratecode, 
			@new_paycode, @new_limit, @new_srqs, @new_ref, @new_applname, @new_applicant, 
			@new_market, @new_children, @new_addbed, @new_addbed_rate, 
			@new_araccnt, @new_phone, @new_arrinfo, @new_depinfo, @cby, @changed, @logmark,
			@new_up_type, @new_up_reason, @new_haccnt, @new_agent, @new_cusno, @new_source, @new_channel,@new_extra, @new_packages, @new_fixrate, @new_credcode, @new_credman, @new_credunit,
			@new_arrdate, @new_depdate, @new_comsg, @new_card, @new_saleid, @new_amenities, @new_resno, @new_blkcode, @new_pcrec, @new_crsno,
			@new_groupno,@new_type,@new_cardno,@new_arrcar,@new_arrrate,@new_depcar,@new_deprate ,@new_cmscode,@new_exp_m1,@new_exp_dt1,@new_fax 
		end
	close c_log_master
	fetch c_master into @laccnt
	end
deallocate cursor c_log_master
close c_master
deallocate cursor c_master
;