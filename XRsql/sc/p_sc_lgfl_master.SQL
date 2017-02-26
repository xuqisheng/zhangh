-- Column description 
if not exists(select 1 from lgfl_des where columnname = 'sc_rmnum')
	insert lgfl_des values ('sc_rmnum', '房数', 'Rm#', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_arr')
	insert lgfl_des values ('sc_arr', '到日', 'Arr. Date', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_dep')
	insert lgfl_des values ('sc_dep', '离日', 'Dep. Date', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_agent')
	insert lgfl_des values ('sc_agent', '旅行社', 'Agent', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_cusno')
	insert lgfl_des values ('sc_cusno', '协议公司', 'Company', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_source')
	insert lgfl_des values ('sc_source', '订房中心', 'Source', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_channel')
	insert lgfl_des values ('sc_channel', '渠道', 'Channel', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_src')
	insert lgfl_des values ('sc_src', '来源', 'Source', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_market')
	insert lgfl_des values ('sc_market', '市场', 'Market', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_restype')
	insert lgfl_des values ('sc_restype', '预定类型', 'Rresrv. Type', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_gstno')
	insert lgfl_des values ('sc_gstno', '人数', 'Guest#', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_children')
	insert lgfl_des values ('sc_children', '小孩', 'Children#', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_ratecode')
	insert lgfl_des values ('sc_ratecode', '房价码', 'Rate Code', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_packages')
	insert lgfl_des values ('sc_packages', '包价', 'Packages', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_setrate')
	insert lgfl_des values ('sc_setrate', '房价', 'Rate', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_paycode')
	insert lgfl_des values ('sc_paycode', '付款方式', 'Pay Code', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_limit')
	insert lgfl_des values ('sc_limit', '限额', 'Limit', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_srqs')
	insert lgfl_des values ('sc_srqs', '特要', 'Special Requests', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_amenities')
	insert lgfl_des values ('sc_amenities', '客房布置', 'Amenities', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_crsno')
	insert lgfl_des values ('sc_crsno', 'CRS号码', 'CRS#', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_comsg')
	insert lgfl_des values ('sc_comsg', '结帐提示', 'CO MSG', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_saleid')
	insert lgfl_des values ('sc_saleid', '销售员', 'SaleAgent', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_cmscode')
	insert lgfl_des values ('sc_cmscode', '佣金码', 'Comm. Code', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_contact')
	insert lgfl_des values ('sc_contact', '联系人', 'Contact', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_name')
	insert lgfl_des values ('sc_name', '名称', 'Name', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_name2')
	insert lgfl_des values ('sc_name2', '名称2', 'Name2', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_status')
	insert lgfl_des values ('sc_status', '状态', 'Status', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_saleid2')
	insert lgfl_des values ('sc_saleid2', '销售员2', 'SaleAgent2', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_cutoff')
	insert lgfl_des values ('sc_cutoff', 'Cutoff', 'Cutoff', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_follow')
	insert lgfl_des values ('sc_follow', '跟踪日期', 'Follow Date', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_decision')
	insert lgfl_des values ('sc_decision', '决定日期', 'Decision Date', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_porterage')
	insert lgfl_des values ('sc_porterage', '交通', 'Porterage', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_ptgrate')
	insert lgfl_des values ('sc_ptgrate', '交通费', 'Ptg. Rate', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_breakfast')
	insert lgfl_des values ('sc_breakfast', '早餐', 'Breakfast', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_bfrate')
	insert lgfl_des values ('sc_bfrate', '早餐价格', 'Bf. Rate', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_bfdes')
	insert lgfl_des values ('sc_bfdes', '早餐描述', 'Bf. Description', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_c_status')
	insert lgfl_des values ('sc_c_status', '宴会状态', 'C-Status', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_c_attendees')
	insert lgfl_des values ('sc_c_attendees', '人数', 'C-attendees', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_c_guaranteed')
	insert lgfl_des values ('sc_c_guaranteed', '保证', 'C-Guaranteed', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_c_infoboard')
	insert lgfl_des values ('sc_c_infoboard', '告示板', 'Infoboard', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_c_follow')
	insert lgfl_des values ('sc_c_follow', '宴会跟踪日期', 'C-Follow', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_c_decision')
	insert lgfl_des values ('sc_c_decision', '宴会决定日期', 'C-Decision', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_c_function')
	insert lgfl_des values ('sc_c_function', '功能描述', 'Function', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_c_contract')
	insert lgfl_des values ('sc_c_contract', '合约编号', 'Contract', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_c_detailok')
	insert lgfl_des values ('sc_c_detailok', '细节完成', 'Detail OK', 'R'); 
if not exists(select 1 from lgfl_des where columnname = 'sc_c_saleid')
	insert lgfl_des values ('sc_c_saleid', '宴会销售员', 'C-SaleAgent', 'R'); 


--  Procedure 
IF OBJECT_ID('dbo.p_sc_lgfl_master') IS NOT NULL
    DROP PROCEDURE dbo.p_sc_lgfl_master
;
create proc p_sc_lgfl_master
	@no					char(10)
as
-- sc_master日志
declare
	@cno					char(10),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer,
   @old_accnt char(10),   				@new_accnt char(10),
	@old_foact char(10),   				@new_foact char(10),
 	@old_haccnt char(7),   				@new_haccnt char(7),     
	@old_type char(3),     				@new_type char(3),
	@old_otype char(3),    				@new_otype char(3),
	@old_rmnum money,      				@new_rmnum money,
	@old_roomno char(5),	  				@new_roomno char(5),
	@old_oroomno char(5),  				@new_oroomno char(5),
	@old_bdate datetime,	  				@new_bdate datetime,
	@old_sta char(1),	     				@new_sta char(1),
	@old_osta char(1),	  				@new_osta char(1),
	@old_sta_tm char(1),	  				@new_sta_tm char(1),
	@old_tag0 char(1),	  				@new_tag0 char(1),
	@old_arr datetime,	  				@new_arr datetime,
	@old_dep datetime,	  				@new_dep datetime,
	@old_oarr datetime,	  				@new_oarr datetime,
	@old_odep datetime,	  				@new_odep datetime,
	@old_agent char(7),	  				@new_agent char(7),
	@old_cusno char(7),	  				@new_cusno char(7),
	@old_source char(7),	  				@new_source char(7),
	@old_class char(1),	  				@new_class char(1),
	@old_src char(3),	     				@new_src char(3),
	@old_market char(3),	  				@new_market char(3),
	@old_restype char(3),  				@new_restype char(3),
	@old_channel char(3),  				@new_channel char(3),
	@old_gstno money,	     				@new_gstno money,
	@old_children money,	  				@new_children money,
	@old_ratecode char(10),				@new_ratecode char(10),
	@old_packages varchar(30),			@new_packages varchar(30),
	@old_setrate money,					@new_setrate money,
	@old_paycode char(6),				@new_paycode char(6),
	@old_limit money,						@new_limit money,
	@old_credcode varchar(20),			@new_credcode varchar(20),
	@old_credman varchar(20),			@new_credman varchar(20),
	@old_credunit varchar(40),			@new_credunit varchar(40),
	@old_araccnt char(7),				@new_araccnt char(7),
	@old_wherefrom char(6),				@new_wherefrom char(6),
	@old_whereto char(6),				@new_whereto char(6),
	@old_purpose char(3),				@new_purpose char(3),
	@old_arrdate datetime,				@new_arrdate datetime,
	@old_arrinfo varchar(30),			@new_arrinfo varchar(30),
	@old_arrcar char(10),				@new_arrcar char(10),
	@old_arrrate money,					@new_arrrate money,
	@old_depdate datetime,				@new_depdate datetime,
	@old_depinfo varchar(30),			@new_depinfo varchar(30),
	@old_depcar char(10),				@new_depcar char(10),
	@old_deprate money,					@new_deprate money,
	@old_extra varchar(15),				@new_extra varchar(15),
	@old_charge money,					@new_charge money,
	@old_credit money,					@new_credit money,
	@old_accredit  money,				@new_accredit  money,
	@old_lastnumb money,					@new_lastnumb  money,
	@old_lastinumb money,				@new_lastinumb money,
	@old_srqs varchar(30),				@new_srqs varchar(30),
	@old_amenities varchar(30),		@new_amenities varchar(30),
	@old_master char(10),				@new_master char(10),
	@old_saccnt char(10),				@new_saccnt char(10),
	@old_pcrec char(10),					@new_pcrec char(10),
	@old_pcrec_pkg char(10),			@new_pcrec_pkg char(10),
	@old_resno char(10),					@new_resno char(10),
	@old_crsno varchar(20),				@new_crsno varchar(20),
	@old_ref varchar(255),				@new_ref varchar(255),
	@old_comsg varchar(255),			@new_comsg varchar(255),
	@old_saleid varchar(10),			@new_saleid varchar(10),
	@old_cmscode varchar(10),			@new_cmscode varchar(10),
	@old_cardcode varchar(10),			@new_cardcode varchar(10),
	@old_cardno varchar(20),			@new_cardno varchar(20),
	@old_contact varchar(10),			@new_contact varchar(10),
	@old_name varchar(50),				@new_name varchar(50),
	@old_name2 varchar(50),				@new_name2 varchar(50),
	@old_blkcode varchar(20),			@new_blkcode varchar(20),
	@old_status varchar(10),			@new_status varchar(10),
	@old_btype varchar(10),				@new_btype varchar(10),
	@old_bscope char(1),					@new_bscope char(1),
	@old_potential varchar(30),		@new_potential varchar(30),
	@old_saleid2 varchar(10),			@new_saleid2 varchar(10),
	@old_peakrms money,					@new_peakrms money,
	@old_avrate money,					@new_avrate money,
	@old_cutoff datetime,				@new_cutoff datetime,
	@old_follow datetime,				@new_follow datetime,
	@old_decision datetime,				@new_decision datetime,
	@old_rmlistdate datetime,			@new_rmlistdate datetime,
	@old_currency varchar(10),			@new_currency varchar(10),
	@old_tracecode varchar(30),		@new_tracecode varchar(30),
	@old_triggers varchar(30),			@new_triggers varchar(30),
	@old_porterage char(1),				@new_porterage char(1),
	@old_ptgrate money,					@new_ptgrate money,
	@old_breakfast char(1),				@new_breakfast char(1),
	@old_bfrate money,					@new_bfrate money,
	@old_bfdes varchar(30),				@new_bfdes varchar(30),
	@old_c_status varchar(10),			@new_c_status varchar(10),
	@old_c_attendees money,				@new_c_attendees money,
	@old_c_guaranteed char(3),			@new_c_guaranteed char(3),
	@old_c_infoboard varchar(100),	@new_c_infoboard varchar(100),
	@old_c_follow datetime,				@new_c_follow datetime,
	@old_c_decision datetime,			@new_c_decision datetime,
	@old_c_function varchar(40),		@new_c_function varchar(40),
	@old_c_contract varchar(20),		@new_c_contract varchar(20),
	@old_c_detailok varchar(1),		@new_c_detailok varchar(1),
	@old_c_distributed varchar(1),	@new_c_distributed varchar(1),
	@old_c_saleid varchar(10),			@new_c_saleid varchar(10),
	@old_resby varchar(10),				@new_resby varchar(10),
	@old_restime datetime,				@new_restime datetime,
	@old_defby varchar(10),				@new_defby varchar(10),
	@old_deftime datetime,				@new_deftime datetime,
	@old_tfby varchar(10),				@new_tfby varchar(10),
	@old_tftime datetime,				@new_tftime datetime,
	@old_coby varchar(10),				@new_coby varchar(10),
	@old_cotime datetime,				@new_cotime datetime,
	@old_depby varchar(10),				@new_depby varchar(10),
	@old_deptime datetime,				@new_deptime datetime,
	@old_cby varchar(10),				@new_cby varchar(10),
	@old_changed datetime,				@new_changed datetime,
	@old_exp_m1 money,					@new_exp_m1 money,
	@old_exp_m2 money,					@new_exp_m2 money,
	@old_exp_dt1 datetime,				@new_exp_dt1 datetime,
	@old_exp_dt2 datetime,				@new_exp_dt2 datetime,
	@old_exp_s1 varchar(30),			@new_exp_s1 varchar(30),
	@old_exp_s2 varchar(30),			@new_exp_s2 varchar(30),
	@old_exp_s3 varchar(30),			@new_exp_s3 varchar(30)
--
if @no is null
	declare c_master cursor for select distinct accnt from sc_master_log
else
	declare c_master cursor for select distinct accnt from sc_master_log where accnt = @no
--
declare c_log_master cursor for
	select 
		rmnum,arr ,dep ,agent ,cusno ,source ,src ,market ,
		restype ,channel ,gstno ,children ,ratecode ,packages ,setrate ,paycode ,limit,
		srqs ,amenities ,	crsno,comsg ,saleid ,cmscode ,contact ,name ,name2 ,status ,
		saleid2 ,cutoff ,follow ,decision ,	porterage ,ptgrate ,breakfast ,bfrate ,bfdes ,c_status ,c_attendees ,	
		c_guaranteed ,c_infoboard ,c_follow ,c_decision ,c_function ,c_contract ,c_detailok ,
		c_saleid,logmark,cby,changed   
   from sc_master_log where accnt = @cno
	union 
   select 
		rmnum,arr ,dep ,agent ,cusno ,source ,src ,market ,
		restype ,channel ,gstno ,children ,ratecode ,packages ,setrate ,paycode ,limit ,
		srqs ,amenities ,crsno ,comsg ,saleid ,cmscode ,contact ,name ,name2 ,status ,
		saleid2 ,cutoff ,follow ,decision ,	porterage ,ptgrate ,breakfast ,bfrate ,bfdes ,c_status ,c_attendees ,	
		c_guaranteed ,c_infoboard ,c_follow ,c_decision ,c_function ,c_contract ,c_detailok ,
		c_saleid,logmark,cby,changed
   from sc_master where accnt = @cno
	order by logmark
open c_master
fetch c_master into @cno
while @@sqlstatus = 0
   begin
	select @row = 0
	open c_log_master
	fetch c_log_master into @new_rmnum ,@new_arr ,@new_dep ,@new_agent ,@new_cusno ,@new_source ,@new_src ,@new_market ,
	@new_restype ,@new_channel ,@new_gstno ,@new_children ,@new_ratecode ,@new_packages ,@new_setrate ,@new_paycode ,@new_limit ,
   @new_srqs ,@new_amenities ,@new_crsno ,@new_comsg ,@new_saleid ,@new_cmscode ,@new_contact ,@new_name ,@new_name2 ,@new_status ,
   @new_saleid2 ,@new_cutoff ,@new_follow ,@new_decision ,@new_porterage ,@new_ptgrate ,@new_breakfast ,	@new_bfrate ,@new_bfdes ,@new_c_status ,@new_c_attendees ,
   @new_c_guaranteed ,@new_c_infoboard ,@new_c_follow ,@new_c_decision ,@new_c_function ,@new_c_contract ,@new_c_detailok ,
   @new_c_saleid,@logmark,@cby,@changed 
	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @new_rmnum	!=@old_rmnum
            insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_rmnum', @cno, convert(varchar(10),@old_rmnum), convert(varchar(10),@new_rmnum), @cby, @changed)
			if @new_arr	!=@old_arr
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_arr', @cno, convert(char(10), @old_arr, 111) + ' ' + convert(char(10), @old_arr, 108),
				convert(char(10), @new_arr, 111) + ' ' + convert(char(10), @new_arr, 108), @cby, @changed)
			if @new_dep	!=@old_dep
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_dep', @cno, convert(char(10), @old_dep, 111) + ' ' + convert(char(10), @old_dep, 108),
				convert(char(10), @new_dep, 111) + ' ' + convert(char(10), @new_dep, 108), @cby, @changed)
			if @new_agent	!=@old_agent
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_agent', @cno, @old_agent, @new_agent, @cby, @changed)
			if @new_cusno	!=@old_cusno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_cusno', @cno, @old_cusno, @new_cusno, @cby, @changed)
			if @new_source	!=@old_source
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_source', @cno, @old_source, @new_source, @cby, @changed)
			if @new_channel	!=@old_channel
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_channel', @cno, @old_channel, @new_channel, @cby, @changed)
			if @new_src	!=@old_src
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_src', @cno, @old_src, @new_src, @cby, @changed)
			if @new_market	!=@old_market
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_market', @cno, @old_market, @new_market, @cby, @changed)
			if @new_restype	!=@old_restype
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_restype', @cno, @old_restype, @new_restype, @cby, @changed)
			if @new_gstno	!=@old_gstno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_gstno', @cno, convert(varchar(10),@old_gstno), convert(varchar(10),@new_gstno), @cby, @changed)
			if @new_children	!=@old_children
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_children', @cno, convert(varchar(10),@old_children), convert(varchar(10),@new_children), @cby, @changed)
			if @new_ratecode 	!=@old_ratecode 
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_ratecode', @cno, @old_ratecode, @new_ratecode, @cby, @changed)
			if @new_packages	!=@old_packages
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_packages', @cno, @old_packages, @new_packages, @cby, @changed)
			if @new_setrate	!=@old_setrate
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_setrate', @cno, convert(varchar(10),@old_setrate), convert(varchar(10),@new_setrate), @cby, @changed)
			if @new_paycode	!=@old_paycode
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_paycode', @cno, @old_paycode, @new_paycode, @cby, @changed)
			if @new_limit	!=@old_limit
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_limit', @cno, convert(varchar(10),@old_limit), convert(varchar(10),@new_limit), @cby, @changed)
			if @new_srqs	!=@old_srqs
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_srqs', @cno, @old_srqs, @new_srqs, @cby, @changed)
			if @new_amenities	!=@old_amenities
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_amenities', @cno, @old_amenities, @new_amenities, @cby, @changed)
			if @new_crsno	!=@old_crsno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_crsno', @cno, @old_crsno, @new_crsno, @cby, @changed)
			if @new_comsg	!=@old_comsg
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_comsg', @cno, @old_comsg, @new_comsg, @cby, @changed)
			if @new_saleid	!=@old_saleid
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_saleid', @cno, @old_saleid, @new_saleid, @cby, @changed)
			if @new_cmscode	!=@old_cmscode
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_cmscode', @cno, @old_cmscode, @new_cmscode, @cby, @changed)
			if @new_contact	!=@old_contact
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_contact', @cno, @old_contact, @new_contact, @cby, @changed)
			if @new_name	!=@old_name
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_name', @cno, @old_name, @new_name, @cby, @changed)
			if @new_name2	!=@old_name2
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_name2', @cno, @old_name2, @new_name2, @cby, @changed)
			if @new_status	!=@old_status
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_status', @cno, @old_status, @new_status, @cby, @changed)
			if @new_saleid2	!=@old_saleid2
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_saleid2', @cno, @old_saleid2, @new_saleid2, @cby, @changed)
			if @new_cutoff	!=@old_cutoff
 				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_cutoff', @cno, convert(char(10), @old_cutoff, 111) + ' ' + convert(char(10), @old_cutoff, 108),
				convert(char(10), @new_cutoff, 111) + ' ' + convert(char(10), @new_cutoff, 108), @cby, @changed)				
			if @new_follow	!=@old_follow
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_follow', @cno, convert(char(10), @old_follow, 111) + ' ' + convert(char(10), @old_follow, 108),
				convert(char(10), @new_follow, 111) + ' ' + convert(char(10), @new_follow, 108), @cby, @changed)				
			if @new_decision	!=@old_decision
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_decision', @cno, convert(char(10), @old_decision, 111) + ' ' + convert(char(10), @old_decision, 108),
				convert(char(10), @new_decision, 111) + ' ' + convert(char(10), @new_decision, 108), @cby, @changed)				
			if @new_porterage	!=@old_porterage
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_porterage', @cno, @old_porterage, @new_porterage, @cby, @changed)
			if @new_ptgrate	!=@old_ptgrate
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_ptgrate', @cno, convert(varchar(10),@old_ptgrate), convert(varchar(10),@new_ptgrate), @cby, @changed)
			if @new_breakfast	!=@old_breakfast
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_breakfast', @cno, @old_breakfast, @new_breakfast, @cby, @changed)
			if @new_bfrate	!=@old_bfrate
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_bfrate', @cno,  convert(varchar(10),@old_bfrate), convert(varchar(10),@new_bfrate), @cby, @changed)
			if @new_bfdes	!=@old_bfdes
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_bfdes', @cno, @old_bfdes, @new_bfdes, @cby, @changed)
			if @new_c_status	!=@old_c_status
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_c_status', @cno, @old_c_status, @new_c_status, @cby, @changed)
			if @new_c_attendees	!=@old_c_attendees
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_c_attendees', @cno, convert(varchar(10),@old_c_attendees), convert(varchar(10),@new_c_attendees), @cby, @changed)
			if @new_c_guaranteed	!=@old_c_guaranteed
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_c_guaranteed', @cno, convert(varchar(10),@old_c_guaranteed), convert(varchar(10),@new_c_guaranteed), @cby, @changed)
			if @new_c_infoboard	!=@old_c_infoboard
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_c_infoboard', @cno, @old_c_infoboard, @new_c_infoboard, @cby, @changed)
			if @new_c_follow	!=@old_c_follow
            insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_c_follow', @cno, convert(char(10), @old_c_follow, 111) + ' ' + convert(char(10), @old_c_follow, 108),
				convert(char(10), @new_c_follow, 111) + ' ' + convert(char(10), @new_c_follow, 108), @cby, @changed)				
			if @new_c_decision	!=@old_c_decision
            insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_c_decision', @cno, convert(char(10), @old_c_decision, 111) + ' ' + convert(char(10), @old_c_decision, 108),
				convert(char(10), @new_c_decision, 111) + ' ' + convert(char(10), @new_c_decision, 108), @cby, @changed)				
			if @new_c_function	!=@old_c_function
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_c_function', @cno, @old_c_function, @new_c_function, @cby, @changed)
			if @new_c_contract	!=@old_c_contract
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_c_contract', @cno, @old_c_contract, @new_c_contract, @cby, @changed)
			if @new_c_detailok	!=@old_c_detailok
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_c_detailok', @cno, @old_c_detailok, @new_c_detailok, @cby, @changed)
			if @new_c_saleid	!=@old_c_saleid
				insert lgfl(columnname,accnt,old,new,empno,date) values ('sc_c_saleid', @cno, @old_c_saleid, @new_c_saleid, @cby, @changed)
			end
		select   @old_rmnum =@new_rmnum ,@old_arr =@new_arr ,	@old_dep =@new_dep ,	@old_agent =@new_agent ,
					@old_cusno =@new_cusno ,@old_source =@new_source ,@old_src =@new_src ,	@old_market =@new_market ,
					@old_restype =@new_restype ,	@old_channel =@new_channel ,	@old_gstno =@new_gstno ,	@old_children =@new_children ,
					@old_ratecode =@new_ratecode ,	@old_packages =@new_packages ,	@old_setrate =@new_setrate ,	@old_paycode =@new_paycode ,
					@old_limit =@new_limit ,@old_srqs =@new_srqs ,	@old_amenities =@new_amenities ,@old_crsno =@new_crsno ,	@old_comsg =@new_comsg ,
            	@old_saleid =@new_saleid ,	@old_cmscode =@new_cmscode ,@old_contact =@new_contact ,	@old_name =@new_name ,	@old_name2 =@new_name2 ,
					@old_status =@new_status ,@old_saleid2 =@new_saleid2 ,
					@old_cutoff =@new_cutoff ,	@old_follow =@new_follow ,	@old_decision =@new_decision ,
					@old_porterage =@new_porterage ,	@old_ptgrate =@new_ptgrate ,	@old_breakfast =@new_breakfast ,	@old_bfrate =@new_bfrate ,
					@old_bfdes =@new_bfdes ,	@old_c_status =@new_c_status ,	@old_c_attendees =@new_c_attendees ,	@old_c_guaranteed =@new_c_guaranteed ,
					@old_c_infoboard =@new_c_infoboard ,	@old_c_follow =@new_c_follow ,	@old_c_decision =@new_c_decision ,	@old_c_function =@new_c_function ,
					@old_c_contract =@new_c_contract ,	@old_c_detailok =@new_c_detailok ,	
					@old_c_saleid =@new_c_saleid 
			fetch c_log_master into @new_rmnum ,@new_arr ,@new_dep ,@new_agent ,@new_cusno ,@new_source ,@new_src ,@new_market ,
					@new_restype ,@new_channel ,@new_gstno ,@new_children ,@new_ratecode ,@new_packages ,@new_setrate ,@new_paycode ,@new_limit ,
					@new_srqs ,@new_amenities ,@new_crsno ,@new_comsg ,@new_saleid ,@new_cmscode ,@new_contact ,@new_name ,@new_name2 ,@new_status ,
					@new_saleid2 ,@new_cutoff ,@new_follow ,@new_decision ,@new_porterage ,@new_ptgrate ,@new_breakfast ,	@new_bfrate ,@new_bfdes ,@new_c_status ,@new_c_attendees ,
					@new_c_guaranteed ,@new_c_infoboard ,@new_c_follow ,@new_c_decision ,@new_c_function ,@new_c_contract ,@new_c_detailok ,
					@new_c_saleid,@logmark,@cby,@changed 
		end
	close c_log_master
	if @row > 0
		delete sc_master_log where accnt = @cno and logmark < @logmark
	fetch c_master into @cno
	end
deallocate cursor c_log_master
close c_master
deallocate cursor c_master
;


