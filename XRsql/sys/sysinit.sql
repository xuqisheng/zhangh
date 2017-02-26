

if exists (select * from sysobjects where name='p_foxhis_sysdata_init' and type='P')
   drop proc p_foxhis_sysdata_init;
create proc p_foxhis_sysdata_init
	@backdays		int = 0 -- 初始化营业日期倒退天数
as
----------------------------------------------
-- init sysdata,gate and accthead 
----------------------------------------------

-- 产生营业日期 (根据需要，初始化的营业日期可以为当天，也可以为前一天)
declare	@today datetime
select @today = convert(datetime,convert(char(10),getdate(),1))

--
if @backdays is null 
	select @backdays = 0
select @today = dateadd(dd, @backdays * -1 ,@today)

--
begin tran
delete sysdata
insert sysdata values
          (	@today,
			@today,
			'T',
			'T',
			dateadd(dd,-1,@today),
			dateadd(dd,-1,@today),
			substring(convert(char(4),datepart(yy,@today)),4,1),
			substring(convert(char(4),(datediff(dd,convert(datetime,convert(char(4),datepart(yy,@today))+"0101"),@today) + 1000)),2,3),
			substring(convert(char(4),(datediff(dd,convert(datetime,convert(char(4),datepart(yy,@today))+"0101"),@today) + 1400)),2,3),
         0,
			0,
			0,
			800000,
			950000,
			6000000,				-- GaoLiang 2006/10/16 以后集团的guest.no < 6000000, 成员酒店的guest.no >= 6000000
			0,
			0,
			0,
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@today)),3,2) + substring(convert(char(3),datepart(mm,@today) + 100),2,2) + substring(convert(char(3),datepart(dd,@today)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@today)),3,2) + substring(convert(char(3),datepart(mm,@today) + 100),2,2) + substring(convert(char(3),datepart(dd,@today)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@today)),3,2) + substring(convert(char(3),datepart(mm,@today) + 100),2,2) + substring(convert(char(3),datepart(dd,@today)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@today)),3,2) + substring(convert(char(3),datepart(mm,@today) + 100),2,2) + substring(convert(char(3),datepart(dd,@today)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@today)),3,2) + substring(convert(char(3),datepart(mm,@today) + 100),2,2) + substring(convert(char(3),datepart(dd,@today)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@today)),3,2) + substring(convert(char(3),datepart(mm,@today) + 100),2,2) + substring(convert(char(3),datepart(dd,@today)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@today)),3,2) + substring(convert(char(3),datepart(mm,@today) + 100),2,2) + substring(convert(char(3),datepart(dd,@today)+100),2,2) + "0001"),
			0,
			0,
			0,
			0,
			0,
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@today)),3,2) + substring(convert(char(3),datepart(mm,@today) + 100),2,2) + substring(convert(char(3),datepart(dd,@today)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@today)),3,2) + substring(convert(char(3),datepart(mm,@today) + 100),2,2) + substring(convert(char(3),datepart(dd,@today)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@today)),3,2) + substring(convert(char(3),datepart(mm,@today) + 100),2,2) + substring(convert(char(3),datepart(dd,@today)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@today)),3,2) + substring(convert(char(3),datepart(mm,@today) + 100),2,2) + substring(convert(char(3),datepart(dd,@today)+100),2,2) + "0001")
		   )
delete gate 
insert gate values ('T','T','T','T','F','F','F','T','T')
delete accthead
insert accthead values (dateadd(day,-1,@today),'FOX','FOXHIS',space(8),space(8),space(8),space(8),
						'F','T','F',3,'F','F','F')

-- Extra id pointer 
update sys_extraid set id = 0 where cat not in ('RATECODE','CMSCODE','STG')

commit tran
return 0
;


if exists (select * from sysobjects where name='p_foxhis_sys_init' and type='P')
   drop proc p_foxhis_sys_init;
create proc p_foxhis_sys_init
   @initmode varchar(10) = 'R'  -- R=report   C=code  A=account_detail Bn=BackDays (default=B0)
as 
----------------------------------------------------------
--	foxhis 系统初始化 -- 包括：前台、餐饮、客房、商务等所有系统
--
--	参数: R-清除报表 C-清除代码 A-清除营业数据
--
-- 一般情况下，调用 p_foxhis_sys_init 'AR'
----------------------------------------------------------

----------------------------------------------------------
-- 强制检查系统参数
----------------------------------------------------------
declare @settime  varchar(30), @setdate  datetime
select @settime =rtrim(substring(value,1,30)) from sysoption where catalog='hotel' and item='check_parms'
if @@rowcount=0 or @settime is null
	select @settime=null
else
begin
	select @setdate=convert(datetime,@settime)
	if @setdate is null 
		select @settime = null
	else if datediff(dd,@settime,getdate()) <> 0 
		select @settime = null
end
if @settime = null 
begin
	select '请预先在维护系统中执行系统参数检查，谢谢！ Please check parameters in maint system first .'
	return 1
end

----------------------------------------------------------
-- 系统特别警告 2005-11 Simon
----------------------------------------------------------
select @settime =rtrim(substring(value,1,30)) from sysoption where catalog='hotel' and item='init_warning'
if @@rowcount=0 
begin
	insert sysoption(catalog,item,value,usermod) values('hotel', 'init_warning', '2000/1/1 10:00:00', 'F') 
	select @settime=null
end
else
begin
	if @settime is not null 
	begin
		select @setdate=convert(datetime,@settime)
		if @setdate is null 
			select @settime = null
		else if abs(datediff(ss,@settime,getdate())) > 5   -- 5 秒之内必须重新执行 
			select @settime = null
	end 
end
if @settime = null 
begin
	-- ---------------------------------------------------------------------------------------
	--	记录执行时间
	-- ---------------------------------------------------------------------------------------
	select @settime = convert(char(10), getdate(), 111)+' '+convert(char(8), getdate(), 8)
	if not exists(select 1 from sysoption where catalog='hotel' and item='init_warning')
		insert sysoption (catalog,item,value) select 'hotel','init_warning',''
	update sysoption set value=@settime where catalog='hotel' and item='init_warning'

	-- 警告
	delete gdsmsg 
	insert gdsmsg select '特别特别提醒: 您即将进行初始化操作,一旦进行,将不可挽回的清除所有数据 !!!'
	insert gdsmsg select '或者, 您是否需要事先做一次备份呢? '
	insert gdsmsg select '还有, 如果您的初始化参数中包含 C --- 部分重要代码也将被清除，比如房价码等。 '
	insert gdsmsg select ''
	insert gdsmsg select '当前操作的数据库 = ' + db_name()
	insert gdsmsg select '系 统 客 户 名称 = ' + value from sysoption where catalog='hotel' and item='name' 
	insert gdsmsg select '' 
	insert gdsmsg select '您确认继续吗？' 
	insert gdsmsg select '' 
	insert gdsmsg select '如果你完全确认，请连续执行该过程，祝您好运 !' 
	insert gdsmsg select '　　★★★　　　★★★'
	insert gdsmsg select '　★★★★★　★★★★★　     不要经常熬夜，知道吗? 家人的幸福依赖您的幸福 ! '
	insert gdsmsg select '　★★★★★★★★★★★'
	insert gdsmsg select '　　★★★★★★★★★         祝你健康、快乐 !!! '
	insert gdsmsg select '　　　★★★★★★★'
	insert gdsmsg select '　　　　★★★★★'
	insert gdsmsg select '　　　　　★★★'
	insert gdsmsg select '　　　　　　★'
	select * from gdsmsg 
	delete gdsmsg 
	return 1
end

--
declare	@backdays	int 
if charindex('B',@initmode) > 0 
begin
	select @backdays = convert(int, substring(@initmode, charindex('B',@initmode)+1, 1))
	if @backdays is null 
		select @backdays = 0 
end
else
	select @backdays = 0 
exec p_foxhis_sysdata_init @backdays
exec p_foxhis_after_licimport

--
declare	@bdate	datetime 
select @bdate = bdate1 from sysdata 

--
truncate table auth_runsta
truncate table auth_runsta_detail
truncate table auth_runsta_hdetail
truncate table action
truncate table audit_date
truncate table fox_apperror 
delete idscan where no not like 'demo%' 

--
truncate table statistic_m
truncate table statistic_y
truncate table statistic_p
truncate table statistic_t
truncate table rmpost_check


if charindex('A',@initmode) > 0 
   begin
   truncate table master
   truncate table master_log
   truncate table master_last
   truncate table master_till
   truncate table hmaster
   truncate table master_income
	truncate table master_del 
	truncate table rsvsrc_detail 
	truncate table rsvsrc_detail_log 
	truncate table ls_master
	truncate table ls_detail

	delete rsvlimit where date < @bdate 

   truncate table master_des
   truncate table master_des_till
   truncate table master_des_last
   truncate table master_remark

	truncate table guest
	truncate table guest_extra
	truncate table guest_log
	truncate table blkmst 

	truncate table guest_del
	truncate table guest_del_flag
	truncate table guest_card
	truncate table guest_date
	truncate table guest_diary
	truncate table guest_cpl
	truncate table guest_income 
	truncate table guest_xfttl 

   truncate table rmsta_log
   truncate table rmsta_last
   truncate table rmsta_till
   truncate table rmstarep
   truncate table rmtmpsta
   truncate table nopart_count  

   truncate table account
   truncate table haccount
--   truncate table lalchkou
--   truncate table lallouts
   truncate table gltemp
   truncate table outtemp

	truncate table billno
	truncate table billno_lgfl
	truncate table billno_pcid
	truncate table bill_data 
--	truncate table alchkout
--	truncate table allouts

	truncate table subaccnt
	truncate table hsubaccnt
	truncate table accnt_set

   truncate table account_temp
   truncate table account_folder
   truncate table account_unpaid
	truncate table account_ar
   truncate table fixed_charge

	truncate table package_detail
   truncate table hpackage_detail

   truncate table cms_rec 
	truncate table cms_pay_history 
   truncate table cmb_pool 
   truncate table bursar_out
   truncate table ybursar_out
	truncate table breakfast 
	truncate table breakfast_empno
	truncate table breakfast_ticket 
   truncate table forecast 

   truncate table message_scroll
   truncate table message_handover
   truncate table message_mail
   truncate table message_mailrecv
   truncate table message_chat 
   truncate table message_notify 
	truncate table message_trace
	truncate table message_trace_h 
	truncate table message_leaveword
	truncate table message_leaveword_h 

	truncate table fec_def_log
	update fec_def set logmark=1
	truncate table fec_def_log
	insert fec_def_log select * from fec_def  
	truncate table fec_folio
	truncate table fec_hfolio

	truncate table meet_rmav
	truncate table meet_hrmav
	truncate table meet_rmav_log
	truncate table meet_query1

   truncate table selected_account
   truncate table accnt_set

   truncate table transfer
   truncate table transfer_log
   truncate table accredit
   truncate table checkroom
   truncate table argst
   truncate table argst_log
   truncate table rmpostbucket
   truncate table rmpostpackage
   truncate table rmpostvip
	truncate table rmuserate

	-- some rep 
   truncate table mstbalrep
   truncate table nbrepo
   truncate table ynbrepo 
   truncate table rmrtchangerep
   truncate table yrmrtchangerep
   truncate table arrepo 
   truncate table pmktsummaryrep
   truncate table ymktsummaryrep_detail 
   truncate table rebaterep
   truncate table yrebaterep
	truncate table ymstbalrep
	
	truncate table ydiscount_detail
	truncate table discount_detail
	truncate table ydiscount
	truncate table discount


	truncate table statistic_c
--   truncate table adjdata
--   truncate table yadjdata

   truncate table lgfl
   truncate table events

   truncate table grprate

   truncate table rsvsaccnt
   truncate table rsvsrc
   truncate table rsvsrc_1
   truncate table rsvsrc_2
   truncate table rsvsrc_till
   truncate table rsvsrc_last
   truncate table rsvsrc_log

   truncate table rsvtype
   truncate table rsvroom
   truncate table rsvdtl
   truncate table rsvdtl_segment

   truncate table rsvsrc
   truncate table rsvsaccnt
   truncate table rsvsrc_1
   truncate table rsvsrc_2
   truncate table linksaccnt

   update rmsta set ocsta = 'V',oldsta= 'R',sta = 'R',locked= 'N',futmark='F',changed  =getdate(),tmpsta='',
	                 empno  ='FOX',fcdate  =getdate(),fempno  ='FOX',onumber =0,number =0,accntset = '', logmark = 0
	truncate table rmsta_log
	

	truncate table qroom
	truncate table turnaway
	truncate table turnawayh

	truncate table master_hung
	truncate table master_hhung
	truncate table master_middle
	truncate table master_quick
	
	truncate table alerts
	truncate table alerts_halt
	--配额
	truncate table gzhs_rsv_plan
	truncate table gzhs_rsv_plan_del
	truncate table gzhs_rsv_plan_log

	truncate table sm_send
	truncate table sm_receive
   end


-- bos  
if charindex('A',@initmode) > 0 
   begin
	truncate table bos_folio
	truncate table bos_hfolio
	
	truncate table bos_dish
	truncate table bos_hdish
	
	truncate table bos_account
	truncate table bos_haccount
	truncate table bos_partout
	
	truncate table bos_partfolio
	truncate table bos_tmpdish
	
	truncate table bosjie
	truncate table bosdai
	truncate table bos_jie
	truncate table bos_dai
	
	truncate table ybosjie
	truncate table ybosdai
   end

-- vip  
if charindex('A',@initmode) > 0 
   begin
	truncate table vipcard
	truncate table vipcard_log
	truncate table vippoint
	truncate table hvippoint 
	truncate table vippack_set 
	truncate table datadown 
	truncate table vipcard_pool 
	truncate table vipcocar 
	truncate table vipcard_tranlog 
   end


-- pos  
exec p_pos_sys_init @initmode
truncate table pdeptrep
truncate table pdeptrep1
truncate table pdeptrep2
truncate table pdeptrep
truncate table pos_detail_jie_link 
--truncate table pos_rep
--truncate table pos_yrep
truncate table x_pos_entrep
truncate table x_pos_yentrep

-- spo 
exec p_spo_sys_init @initmode

-- phone  
if charindex('A',@initmode) > 0 
   begin
   truncate table phfolio
   truncate table phinumber
   truncate table phspclis
   truncate table phempty_deal
	truncate table foliosrc      --  华为
	truncate table phteleclos
	truncate table phn_dept_sumrep 

   end

if charindex('C',@initmode) > 0 
   begin
   truncate table phdeptdef
   truncate table phdeptdex
   truncate table phdepthis
   truncate table phdeptroom
   truncate table phhisdeptroom
   truncate table phextroom
   end
-- reserve and account 
if charindex('C',@initmode) > 0 
   begin
   truncate table rmratedef
	truncate table rmratedef_sslink
	truncate table rmrate_strategy
	truncate table rmrate_strategy_log
   truncate table rmratecode
   truncate table rmratecode_link
	truncate table rmrate_calendar 
	truncate table rate_query_item 
	truncate table rmratecode_ava
	truncate table cmscode
	truncate table cmscode_link
	truncate table cms_defitem
	delete from rmratecode_info where code <> ''
	update sys_extraid set id = 0 where cat in ('RATECODE','CMSCODE')
   end
-- shop init 
if charindex('A',@initmode) > 0 
   begin
   truncate table bos_kcmenu
   truncate table bos_kcdish
   truncate table bos_store
   truncate table bos_hstore
	end

-- Other 
truncate table gs_rec
truncate table doorcard_req

if charindex('C',@initmode) > 0 
   begin
   truncate table bos_provider
	--truncate table hrs_set
	truncate table attendant_info
	delete from basecode where cat ='jifen' or cat='jineng'
	end

-- report init 
if charindex('R',@initmode) > 0 
   begin
   exec p_foxhis_audit_maininit
   end

-- for new ar 
truncate table ar_account
truncate table har_account
truncate table ar_master
truncate table har_master
truncate table ar_master_till
truncate table ar_master_last
truncate table ar_master_log
truncate table ar_aging
truncate table ar_audit
truncate table ar_detail
truncate table har_detail
truncate table ar_creditcard
truncate table ar_apply
truncate table ar_compress 

-- 简易发票管理 
truncate table invoice_opdtl 
truncate table invoice_op

-- house init 
exec p_gds_house_init

-- VOD init 
exec p_gds_vod_init

-- Invoice init 
exec p_cyj_invoice_init

--
exec p_init_trace_doc_etc

--
exec p_foxhis_sc_init

--
delete herror_msg

-- 关于启用何种 ar 的影响
declare	@lic1 varchar(255), @lic2 varchar(255)
select @lic1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
if charindex(',oar,', @lic1)>0 or charindex(',oar,', @lic2)>0 
	update pccode set deptno3='', deptno6='' where pccode>='9' and deptno2='TOR'
else
	update pccode set deptno3='', deptno6='99' where pccode>='9' and deptno2='TOR'

-- 
update sysoption set value='' where catalog='gds' and item='debug'

-- 自动生成快登档案 
declare	@hno char(7) 
exec p_GetAccnt1 'HIS',@hno output
insert guest(no,class,name,fname,lname,name2,name3,name4,
	nation,country,crtby,crttime,cby,changed,keep,remark,belong)
select @hno,'F','*Quick Checkin*','*Quick Checkin*','*Quick Checkin*','*Quick Checkin*','*Quick Checkin*','*Quick Checkin*',
	'CN','CN','FOX',getdate(), 'FOX',getdate(),'T','System Profile for Quick Register, Can not be deleted.','1'
if exists(select 1 from sysoption where catalog='reserve' and item='default_guestid')
	update sysoption set value=@hno where catalog='reserve' and item='default_guestid'
else
	insert sysoption(catalog,item,value,def,remark,remark1,addby,addtime) 
		values('reserve', '', @hno, @hno, '缺省快登档案号', 'Default Profile No for Quick Register', 'FOX', getdate())

-- 
select '初始化完成!' from sysdata

return 0
;


