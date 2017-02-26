drop proc p_gds_audit_deal_mdata;
create proc p_gds_audit_deal_mdata

as

-- 夜审期间 -- 清理常用的冗余数据
declare	@bdate			datetime,
			@savedays		integer,
			@value			varchar(255),
			@cutdate			datetime,
			@flag				char(10) 

select  @bdate = bdate1 from sysdata

--------------------------------------------------------
-- 协议单位自动‘停用’
--------------------------------------------------------
select @value = rtrim(value) from sysoption where catalog='pubmkt' and item='auto_stop_company'
if @@rowcount=1 and charindex(@value, 'TtYy')>0 
	update guest set sta='O', cby='FOX', changed=getdate(), logmark=logmark+1 
		where class in ('C', 'S', 'A') and dep<getdate() and sta='I'

--------------------------------------------------------
-- 房价码自动‘停用’
--------------------------------------------------------
update rmratecode set halt='T' where end_ is not null and end_ < @bdate and halt='F'

--------------------------------------------------------
-- 临时客户档案删除  -- 需要非常慎重啊。
--------------------------------------------------------
--if not exists(select 1 from sysoption where catalog = 'profile' and item = 'temp_delay')
--	insert sysoption(catalog, item, value) select 'profile', 'temp_delay', '90'
--select @savedays = null
--select  @savedays = convert(integer, value) from sysoption where catalog = 'profile' and item = 'temp_delay'
--select  @savedays = isnull(@savedays, 90)
--delete guest where datediff(day, changed, @bdate) > @savedays and keep='F'
--	and class in ('F', 'M') and no not in (select haccnt from master)

--------------------------------------------------------
-- 客房中心查房信息
--------------------------------------------------------
if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'discrepant_room')
	insert sysoption(catalog, item, value) select 'deal_data', 'discrepant_room', '7'
select @savedays = null
select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'discrepant_room'
select  @savedays = isnull(@savedays, 7)
delete discrepant_room where datediff(day, crttime, @bdate) > @savedays


--------------------------------------------------------
-- Q-Room
--------------------------------------------------------
if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'qroom')
	insert sysoption(catalog, item, value) select 'deal_data', 'qroom', '30'
select @savedays = null
select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'qroom'
select  @savedays = isnull(@savedays, 30)
delete qroom where datediff(day, crttime, @bdate) > @savedays


--------------------------------------------------------
-- hpackage_detail
--------------------------------------------------------
if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'package_detail')
	insert sysoption(catalog, item, value) select 'deal_data', 'package_detail', '40'
select @savedays = null
select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'package_detail'
select  @savedays = isnull(@savedays, 40)
delete hpackage_detail where datediff(day, bdate, @bdate) > @savedays
delete package_detail where datediff(day, bdate, @bdate) > @savedays


--------------------------------------------------------
-- rmpostbucket
--------------------------------------------------------
if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'rmpostbucket')
	insert sysoption(catalog, item, value) select 'deal_data', 'rmpostbucket', '40'
select @savedays = null
select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'rmpostbucket'
select  @savedays = isnull(@savedays, 40)
delete rmpostbucket where datediff(day, rmpostdate, @bdate) > @savedays

--------------------------------------------------------
-- mktsummaryrep_detail
--------------------------------------------------------
if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'mktsummaryrep_detail')
	insert sysoption(catalog, item, value) select 'deal_data', 'mktsummaryrep_detail', '40'
select @savedays = null
select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'mktsummaryrep_detail'
select  @savedays = isnull(@savedays, 40)
delete ymktsummaryrep_detail where datediff(day, date, @bdate) > @savedays

--------------------------------------------------------
-- 查房信息
--------------------------------------------------------
if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'checkroom')
	insert sysoption(catalog, item, value) select 'deal_data', 'checkroom', '10'
select @savedays = null
select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'checkroom'
select  @savedays = isnull(@savedays, 30)
delete checkroom where datediff(day, date1, @bdate) > @savedays


--------------------------------------------------------
-- mail,chat,notify 信息  by ZHJ, 2004/11/15
--------------------------------------------------------
if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'message_x')
	insert sysoption(catalog, item, value) select 'deal_data', 'message_x', '90'
select @savedays = null
select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'message_x'
select  @savedays = isnull(@savedays, 90)
delete message_mail where datediff(day, senddate, @bdate) > @savedays
delete message_mailrecv where id not in(select id from message_mail)
delete message_chat where datediff(day, senddate, @bdate) > @savedays
delete message_notify where datediff(day, msgdate, @bdate) > @savedays

--------------------------------------------------------
-- trace,leaveword 信息  by ZHJ, 2004/11/15
--------------------------------------------------------
if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'message_x')
	insert sysoption(catalog, item, value) select 'deal_data', 'message_x', '90'
select @savedays = null
select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'message_x'
select  @savedays = isnull(@savedays, 90)
delete message_trace where accnt = '!' and datediff(day, senddate, @bdate) > @savedays
delete message_leaveword where accnt = '!' and datediff(day, senddate, @bdate) > @savedays

delete message_trace_h where id in (select id from message_trace  
		where accnt not in (select accnt from master) and accnt <> '!')
insert message_trace_h 
	select * from message_trace  
		where accnt not in (select accnt from master) and accnt <> '!'
delete from message_trace 
	where accnt not in (select accnt from master)  and accnt <> '!' 

delete message_leaveword_h where id in (select id from message_leaveword  
		where accnt not in (select accnt from master) and accnt <> '!' ) 
                                                                               insert message_leaveword_h 
	select * from message_leaveword  
		where accnt not in (select accnt from master) and accnt <> '!'
delete from message_leaveword 
	where accnt not in (select accnt from master) and accnt <> '!' 

--------------------------------------------------------
-- 客房日志清除
--------------------------------------------------------
declare	@roomno char(5)
declare c_roomno cursor for select roomno from rmsta order by roomno
open c_roomno 
fetch c_roomno into @roomno
while @@sqlstatus = 0
begin
	exec p_gds_lgfl_rmsta @roomno
	fetch c_roomno into @roomno
end
close c_roomno
deallocate cursor c_roomno

--------------------------------------------------------
-- VOD 清除
--------------------------------------------------------
select @savedays = null
select @savedays = convert(int, value) from sysoption where catalog = 'vod' and item = 'src_delay'
select @savedays = isnull(@savedays, 30)
delete vod_src where datediff(dd, log_date, @bdate) > @savedays
delete vod_err where datediff(dd, log_date, @bdate) > @savedays
delete vod_grd_log where datediff(dd, date, @bdate) > @savedays

--------------------------------------------------------
-- datadown 清除
--------------------------------------------------------
select @savedays = 31
delete datadown where datediff(dd, date, @bdate) > @savedays

--------------------------------------------------------
-- 资源记录存储
--------------------------------------------------------
begin tran 
                                                                               insert res_av_h 
	select * from res_av 
		where accnt not in (select accnt from master) 
			and folio not in (select folio from res_av_h)
delete from res_av 
	where accnt not in (select accnt from master) 
		and folio in (select folio from res_av_h)
commit

--------------------------------------------------------
-- 操作日志 lgfl 每个月 1 日处理 
--------------------------------------------------------
if datepart(dd, getdate()) = 1 
begin
	if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'lgfl')
		insert sysoption(catalog, item, value) select 'deal_data', 'lgfl', '60'
	select @savedays = null
	select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'lgfl'
	select  @savedays = isnull(@savedays, 60)

	select @cutdate = min(date) from audit_date 
	while datediff(dd, @cutdate, @bdate) > @savedays
	begin
		delete lgfl where date < @cutdate 
		select @cutdate = dateadd(dd, 30, @cutdate) 
	end
end

--------------------------------------------------------
-- 操作日志 rsvsrc_log 每个月 1 日处理 
--------------------------------------------------------
if datepart(dd, getdate()) = 1 
begin
	if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'rsvsrc_log')
		insert sysoption(catalog, item, value) select 'deal_data', 'rsvsrc_log', '60'
	select @savedays = null
	select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'rsvsrc_log'
	select  @savedays = isnull(@savedays, 60)

	select @cutdate = min(date) from audit_date 
	while datediff(dd, @cutdate, @bdate) > @savedays
	begin
		delete rsvsrc_log where end_ < @cutdate 
		select @cutdate = dateadd(dd, 30, @cutdate) 
	end
end

--------------------------------------------------------
-- 操作日志 ncr 每个月 1 日处理 
--------------------------------------------------------
if datepart(dd, getdate()) = 1 
begin
	if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'ncr')
		insert sysoption(catalog, item, value) select 'deal_data', 'ncr', '60'
	select @savedays = null
	select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'ncr'
	select  @savedays = isnull(@savedays, 60)

	select @cutdate = min(date) from audit_date 
	while datediff(dd, @cutdate, @bdate) > @savedays
	begin
		delete ncr where bdate < @cutdate 
		select @cutdate = dateadd(dd, 30, @cutdate) 
	end
end

--------------------------------------------------------
-- 操作日志 phfolio 每个月 1 日处理 
--------------------------------------------------------
if datepart(dd, getdate()) = 1 
begin
	if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'phfolio')
		insert sysoption(catalog, item, value) select 'deal_data', 'phfolio', '400'
	select @savedays = null
	select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'phfolio'
	select  @savedays = isnull(@savedays, 400)

	select @cutdate = min(date) from audit_date 
	while datediff(dd, @cutdate, @bdate) > @savedays
	begin
		delete phfolio where date < @cutdate 
		select @cutdate = dateadd(dd, 30, @cutdate) 
	end
end

--------------------------------------------------------
-- 操作日志 pos_menu 每个月 1 日处理 
--------------------------------------------------------
--if datepart(dd, getdate()) = 1 
--begin
--	if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'pos_menu')
--		insert sysoption(catalog, item, value) select 'deal_data', 'pos_menu', '400'
--	select @savedays = null
--	select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'pos_menu'
--	select  @savedays = isnull(@savedays, 400)
--
--	-- 是否需要保留协议单位的呢 ？ 还是协议单位的业绩要另外保留？ -simon 
--	select @cutdate = min(date) from audit_date 
--	while datediff(dd, @cutdate, @bdate) > @savedays
--	begin
--		select @flag = substring(convert(char(4),datepart(yy,@cutdate)),3,2) + substring(convert(char(3),datepart(mm,@cutdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@cutdate)+100),2,2)
--		delete pos_hmenu where menu < @flag 
--		delete pos_hdish where menu < @flag 
--		delete pos_hpay  where menu < @flag 
--		select @cutdate = dateadd(dd, 30, @cutdate) 
--	end
--end

--------------------------------------------------------
-- 操作日志 rm_ooo_log 每个月 1 日处理 
--------------------------------------------------------
if datepart(dd, getdate()) = 1 
begin
	if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'rm_ooo_log')
		insert sysoption(catalog, item, value) select 'deal_data', 'rm_ooo_log', '100'
	select @savedays = null
	select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'rm_ooo_log'
	select  @savedays = isnull(@savedays, 100)

	select @cutdate = min(date) from audit_date 
	while datediff(dd, @cutdate, @bdate) > @savedays
	begin
		delete rm_ooo_log where dend < @cutdate 
		select @cutdate = dateadd(dd, 30, @cutdate) 
	end
end

--------------------------------------------------------
-- 操作日志 doorcard_req 每个周 1 日处理 
--------------------------------------------------------
if datepart(weekday, getdate()) = 2 
begin
	if not exists(select 1 from sysoption where catalog = 'deal_data' and item = 'doorcard_req')
		insert sysoption(catalog, item, value) select 'deal_data', 'doorcard_req', '14'
	select @savedays = null
	select  @savedays = convert(integer, value) from sysoption where catalog = 'deal_data' and item = 'doorcard_req'
	select  @savedays = isnull(@savedays, 14)
	select @cutdate = dateadd(dd, @savedays * -1, @bdate) 
	delete doorcard_req where date < @cutdate 
end

--------------------------------------------------------
-- 短信历史数据清除
--------------------------------------------------------
exec p_zlf_sm_delhis

--------------------------------------------------------
-- rsvsrc_detail 操作日志 每天 删除1个月前已退房的日志
--------------------------------------------------------

delete rsvsrc_detail where accnt not in(select accnt from master) and datediff(day,dep,@bdate)> 30

--------------------------------------------------------
-- idscan 扫描结果信息 每天 删除7天以前未 匹配信息以及已经匹配但不在master表的纪录  add by xjg 090813
--------------------------------------------------------
	delete  idscan 
   WHERE (( idscan.haccnt = '' AND datediff(dd,idscan.date1,dateadd(dd, -7, @bdate) )>0 )  
			or (idscan.haccnt<>'' and not exists(select 1 from master where idscan.haccnt=haccnt ) AND datediff(dd,idscan.date2,dateadd(dd, -7, @bdate) )>0 ) )



-----

return 0
/* ### DEFNCOPY: END OF DEFINITION */
;