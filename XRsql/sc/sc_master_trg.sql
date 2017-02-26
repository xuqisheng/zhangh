
-- ------------------------------------------------------------------------
-- sc_master 触发器
--	
-- ------------------------------------------------------------------------

-- ------------------------------------------------------------------------
--		insert 
-- ------------------------------------------------------------------------
if exists(select 1 from sysobjects where name='t_gds_sc_master_insert' and type='TR')
	drop trigger t_gds_sc_master_insert
;
create trigger t_gds_sc_master_insert
   on sc_master
   for insert 
as
declare 		@sta 			char(1),
				@accnt 		char(10),
				@class		char(1),
				@extra		char(30),
				@arr			datetime,
				@dep			datetime,
				@lock			char(1),
				@partpost1	varchar(255),
				@partpost2	varchar(255)

---------------------------------------------------------------------------------
--	Part. 0   特殊校验 - accnt, class 
---------------------------------------------------------------------------------
select @accnt=accnt, @class=class, @sta=sta, @extra=extra from inserted
if rtrim(@accnt) is null
begin
   rollback trigger with raiserror 20000 "账号不能为空HRY_MARK"
	return
end
if substring(@accnt,1,1) <> @class
begin
   rollback trigger with raiserror 20000 "账户号码与账户类型不符HRY_MARK"
	return
end

---------------------------------------------------------------------------------
--	Part. 1   account flag
---------------------------------------------------------------------------------
if not exists(select 1 from subaccnt where accnt=@accnt and type='0' and subaccnt=1) 
begin
	select @lock = substring(@extra, 10, 1) -- 允许记账
	if @lock = '0'
		insert subaccnt select a.roomno, '', a.accnt, 1, '', '', '允许记账费用', '', '2000.1.1', '2030.1.1', a.cby, a.changed, '0', '0', '', '', 1 from inserted a
	else if @lock = '1'
		insert subaccnt(roomno,haccnt,accnt,subaccnt,to_roomno,to_accnt,name,pccodes,starting_time,closing_time,cby,changed,type,tag,paycode,ref,logmark) 
			select a.roomno, '', a.accnt, 1, '', '', '允许记账费用', '*', '2000.1.1', '2030.1.1', a.cby, a.changed, '0', '0', '', '', 1 from inserted a
	else
	begin
		select @partpost1 = isnull((select value from sysoption where catalog='reserve' and item='locksta_part_def'), '10*')
		insert subaccnt(roomno,haccnt,accnt,subaccnt,to_roomno,to_accnt,name,pccodes,starting_time,closing_time,cby,changed,type,tag,paycode,ref,logmark) 
			select a.roomno, '', a.accnt, 1, '', '', '允许记账费用', @partpost1, '2000.1.1', '2030.1.1', a.cby, a.changed, '0', '0', '', '', 1 from inserted a
	end
end 

-- 分账户
if not exists(select 1 from subaccnt where accnt=@accnt and type='5' and subaccnt=1)
begin
	insert subaccnt(roomno,haccnt,accnt,subaccnt,to_roomno,to_accnt,name,pccodes,starting_time,closing_time,cby,changed,type,tag,paycode,ref,logmark) 
		select a.roomno, '', a.accnt, 1, '', '', a.name, '*', '2000.1.1', '2030.1.1', a.cby, a.changed, '5', '0', '', '', 1 from inserted a
end 

// --> block 最后不一定是团体，暂时可以不处理这个 
//-- 团体付费
//-- 团体为成员付费 (just group & meet= 所有费用)
//if not exists(select 1 from subaccnt where accnt=@accnt and type='2' and subaccnt=1)
//begin
//	select @partpost2 = isnull((select value from sysoption where catalog='reserve' and item='grp_post_def'), '')
//	insert subaccnt(roomno,haccnt,accnt,subaccnt,to_roomno,to_accnt,name,pccodes,starting_time,closing_time,cby,changed,type,tag,paycode,ref,logmark) 
//		select a.roomno, '', a.accnt, 1, '', '', '团体为成员付费', @partpost2, '2000.1.1', '2030.1.1', a.cby, a.changed, '2', '0', '', '', 1
//			from inserted a where a.class in ('G', 'M')
//end

---------------------------------------------------------------------------------
--	Part. 2  sc_master_des
---------------------------------------------------------------------------------
if not exists(select 1 from master_des where accnt=@accnt)
begin
	insert master_des(accnt,sta,haccnt,groupno,arr,dep,agent,cusno,source,src,market,restype,channel,
			artag1,artag2,ratecode,rtreason,paycode,wherefrom,whereto,saleid)
		select accnt,sta,haccnt,'',arr,dep,agent,cusno,source,src,market,restype,channel,
			'','',ratecode,'',paycode,wherefrom,whereto,saleid from inserted
end

;

-- ------------------------------------------------------------------------
--		update
-- ------------------------------------------------------------------------
if exists(select 1 from sysobjects where name='t_gds_sc_master_update' and type='TR')
	drop trigger t_gds_sc_master_update
;
create trigger t_gds_sc_master_update
   on sc_master
   for update 
as
declare 	@new_roomno 	char(5),	@old_roomno 	char(5),
        	@new_sta 		char(1),	@old_sta 		char(1),
			@accnt 			char(10), 
			@class			char(1),
			@setrate			money,
			@gstno			int,
			@garr				datetime,
			@ratecode		char(10),
			@market			char(3),
			@src				char(3),
			@packages		varchar(20),
			@srqs				varchar(30),
			@amenities		varchar(30)

select @accnt=accnt, @class=class, @setrate=setrate, @gstno=gstno, @garr=arr, 
		@amenities=amenities, @packages=packages, @market=market, @src=src, @srqs=srqs, @ratecode=ratecode 
	from inserted
if @@rowcount = 0 return 

---------------------------------------------------------------------------------
--	Part. 0   特殊校验
---------------------------------------------------------------------------------
if substring(@accnt,1,1) <> @class
begin
   rollback trigger with raiserror 20000 "账户号码与账户类型不符HRY_MARK"
	return
end

---------------------------------------------------------------------------------
--	Part. 1  Log
---------------------------------------------------------------------------------
if update(logmark)  -- 记录日志
   insert sc_master_log select * from inserted

---------------------------------------------------------------------------------
declare @sta char(1),@extra char(30),@arr datetime,@dep datetime, @ret int, @msg varchar(60)
select @accnt=accnt, @class=class, @sta=sta, @extra=extra, @arr=arr, @dep=dep from inserted
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--	Part. 3  master_des : Just sta column
---------------------------------------------------------------------------------
if update(sta) or update(dep)
begin
	update master_des set sta=@sta, sta_o=@sta, dep=convert(datetime, convert(char(10), @dep, 111)) where accnt=@accnt
	if @sta='X'
		update master_des set sta='CANCELED' where accnt=@accnt
	else if @sta='O'
		update master_des set sta='Checked Out' where accnt=@accnt
	else if @sta='W'
		update master_des set sta='WaitList' where accnt=@accnt
	else if @sta='R'
		update master_des set sta='Expected' where accnt=@accnt
	else if @sta='S'
		update master_des set sta='Suspend' where accnt=@accnt
	else if @sta='N'
		update master_des set sta='No-Show' where accnt=@accnt
	else if @sta='I'
	begin  -- 注意下面的次序
		if datediff(dd,@arr,@dep)=0 and charindex(@class,'FGM')>0
			update master_des set sta='Day Use' where accnt=@accnt
		else if datediff(dd,getdate(),@dep)=0 and charindex(@class,'FGM')>0
			update master_des set sta='Due Out' where accnt=@accnt
		else if substring(@extra,9,1)='1' and charindex(@class,'FGM')>0
			update master_des set sta='Walk In' where accnt=@accnt
		else
			update master_des set sta='Checked In' where accnt=@accnt
	end
end

---------------------------------------------------------------------------------
--	Part. 4  rsvsrc : rate, gstno
---------------------------------------------------------------------------------
if update(setrate) or update(gstno) or update(amenities) or update(market) 
		or update(src) or update(ratecode) or update(srqs) or update(packages) 
	update rsvsrc set rate=@setrate, gstno=@gstno, amenities=@amenities , market=@market, src=@src,
			ratecode=@ratecode, srqs=@srqs, packages=@packages
		where accnt=@accnt  and id=0

---------------------------------------------------------------------------------
--	Part. 5  sc_master - haccnt
---------------------------------------------------------------------------------
if update(haccnt)
begin
	declare	@name	varchar(50), @haccnt char(7)
	declare	@exp_country char(3), @exp_nation char(3), @exp_src char(3), @exp_market char(3), @exp_cusno char(10)
	select @haccnt = haccnt from inserted
	if @@rowcount=1 and rtrim(@haccnt) is not null
	begin
		select @name = name,@exp_country=country,@exp_nation=nation,@exp_src=src,
			@exp_market=market, @exp_cusno=cusno from guest where no = @haccnt
		if @@rowcount=1 and rtrim(@haccnt) is not null
		begin
			update master_des set haccnt=@name, haccnt_o=@haccnt where accnt=@accnt
			update subaccnt set name=@name where accnt=@accnt and subaccnt=1 and type='5'
			update master_des set groupno=@name where groupno_o = @accnt
		end
		-- 
		if exists(select 1 from subaccnt where to_accnt = @accnt) 
			update subaccnt set name=@name where to_accnt = @accnt 
	end
end
---------------------------------------------------------------------------------
--	Part. 6  取消信用
---------------------------------------------------------------------------------
if update(sta)
begin
	if charindex(@new_sta, 'RI')=0 and charindex(@old_sta, 'RI')>0 -- and @accnt not like 'A%'
	begin
		declare	@empno2 char(10), @bdate2 datetime, @shift2 char(1), @logdate2 datetime
		select @empno2=cby, @bdate2=bdate, @shift2='1',@logdate2=changed from inserted 
		if @@rowcount <> 0 
			update accredit set tag='5',empno2=@empno2, bdate2=@bdate2, shift2=@shift2,log_date2=@logdate2
				where accnt=@accnt and tag='0' 
	end
end

;

-- ------------------------------------------------------------------------
--		sc_master/till/last - Delete 
-- ------------------------------------------------------------------------
if exists(select 1 from sysobjects where name='t_gds_sc_master_delete' and type='TR')
	drop trigger t_gds_sc_master_delete
;
create trigger t_gds_sc_master_delete
   on sc_master
   for delete
as
declare 		@accnt 		char(10)
select @accnt=accnt from deleted
if @@rowcount>0 and not exists(select 1 from master where accnt=@accnt)
	delete master_des where accnt=@accnt
return;

if exists(select 1 from sysobjects where name='t_gds_sc_master_till_delete' and type='TR')
	drop trigger t_gds_sc_master_till_delete
;
create trigger t_gds_sc_master_till_delete
   on sc_master_till
   for delete
as
declare 		@accnt 		char(10)
select @accnt=accnt from deleted
if @@rowcount>0 and not exists(select 1 from master_till where accnt=@accnt)
	delete master_des_till where accnt=@accnt
return;

if exists(select 1 from sysobjects where name='t_gds_sc_master_last_delete' and type='TR')
	drop trigger t_gds_sc_master_last_delete
;
create trigger t_gds_sc_master_last_delete
   on sc_master_last
   for delete
as
declare 		@accnt 		char(10)
select @accnt=accnt from deleted
if @@rowcount>0 and not exists(select 1 from master_last where accnt=@accnt)
	delete master_des_last where accnt=@accnt
return;
