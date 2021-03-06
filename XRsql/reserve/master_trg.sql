if not exists(select 1 from sysoption where catalog='reserve' and item='locksta_part_def')
	insert sysoption(catalog,item,value,remark) 
		VALUES (	'reserve',	'locksta_part_def',	'10*',	'部分允许记账设置的缺省值');

if not exists(select 1 from sysoption where catalog='reserve' and item='grp_post_def')
	insert sysoption(catalog,item,value,remark) 
		VALUES (	'reserve',	'grp_post_def',	'',	'团体付费的缺省值');


-- ------------------------------------------------------------------------
-- master 触发器，关联电话 pms, vod pms
--
-- 针对扩充的 phteleclos, 而且直接插入分机号
--	
--				注意  phonsta 为 空值 !  此时，设为 ‘1’，表示市话  
-- ------------------------------------------------------------------------

-- ------------------------------------------------------------------------
--		insert 
-- ------------------------------------------------------------------------
if exists(select 1 from sysobjects where name='t_gds_master_insert' and type='TR')
	drop trigger t_gds_master_insert
;
create trigger t_gds_master_insert
   on master
   for insert 
as
declare 		@roomno 		char(5),
				@phonesta 	char(1),
				@vodsta 		char(1),
				@sta 			char(1),
				@accnt 		char(10),
				@class		char(1),
				@extra		char(30),
				@arr			datetime,
				@dep			datetime,
				@groupno		char(10),
				@haccnt		char(7),
				@hclass		char(1)

declare		@lock			char(1),
				@partpost1	varchar(255),
				@partpost2	varchar(255),
				@subaccnt_arr		datetime,	-- 分账户有效期
				@subaccnt_dep		datetime

---------------------------------------------------------------------------------
--	Part. 0   特殊校验
---------------------------------------------------------------------------------
select @accnt=accnt, @haccnt=haccnt, @class=class, @sta=sta, @extra=extra, @roomno=roomno, @groupno=groupno from inserted
select @accnt=accnt, @haccnt=haccnt, @class=class, @sta=sta, @extra=extra, @roomno=roomno, @groupno=groupno,
 		@subaccnt_arr = convert(datetime,convert(char(10),arr,111),111),@subaccnt_dep = convert(datetime,convert(char(10),dep,111),111)
	from inserted
select @subaccnt_dep = dateadd(hour,18,@subaccnt_dep)
if @subaccnt_arr is null
	select @subaccnt_arr = '2005.01.01'
if @subaccnt_dep is null
	select @subaccnt_dep = '2010.12.31'

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
if @class='A' or @class='C' 
begin
	select @hclass=class from guest where no=@haccnt
	if (@class='A' and @hclass<>'R') or (@class='C' and @hclass<>'H') 
	begin
		rollback trigger with raiserror 20000 "账户的档案类型不符HRY_MARK"  -- 2003.10.26 消费账、ar账采用专用档案
		return
	end
end


---------------------------------------------------------------------------------
--	Part. 1   account flag
---------------------------------------------------------------------------------
select @lock = substring(@extra, 10, 1) -- 允许记账
if @lock = '0'
	insert subaccnt select a.roomno, '', a.accnt, 1, '', '', '允许记账费用', '', '2000.1.1', '2030.1.1', a.cby, a.changed, '0', '0', '', '', 1
		from inserted a, guest b where a.haccnt = b.no
else if @lock = '1'
	insert subaccnt select a.roomno, '', a.accnt, 1, '', '', '允许记账费用', '*', '2000.1.1', '2030.1.1', a.cby, a.changed, '0', '0', '', '', 1
		from inserted a, guest b where a.haccnt = b.no
else
begin
	select @partpost1 = isnull((select value from sysoption where catalog='reserve' and item='locksta_part_def'), '10*')
	insert subaccnt select a.roomno, '', a.accnt, 1, '', '', '允许记账费用', @partpost1, '2000.1.1', '2030.1.1', a.cby, a.changed, '0', '0', '', '', 1
		from inserted a, guest b where a.haccnt = b.no
end


-- 分账户
insert subaccnt select a.roomno, '', a.accnt, 1, '', '', b.name, '*', '2000.1.1', '2030.1.1', a.cby, a.changed, '5', '0', '', '', 1
	from inserted a, guest b where a.haccnt = b.no

-- 团体付费
select @partpost2 = isnull((select value from sysoption where catalog='reserve' and item='grp_post_def'), '')
-- 团体为成员付费 (just group & meet= 所有费用)
insert subaccnt select a.roomno, '', a.accnt, 1, '', '', '团体为成员付费', @partpost2, '2000.1.1', '2030.1.1', a.cby, a.changed, '2', '0', '', '', 1
	from inserted a, guest b where a.class in ('G', 'M') and a.haccnt = b.no
-- 成员 : 团体付费
insert subaccnt select a.roomno, '', a.accnt, 2, '', a.groupno, '团体付费', b.pccodes, '2000.1.1', '2030.1.1', a.cby, a.changed, '5', '1', '', '', 1
	from inserted a, subaccnt b where a.groupno = b.accnt and b.type = '2'

---------------------------------------------------------------------------------
--	Part. 2  master_des
---------------------------------------------------------------------------------
insert master_des(accnt,sta,haccnt,groupno,arr,dep,agent,cusno,source,src,market,restype,channel,
	artag1,artag2,ratecode,rtreason,paycode,wherefrom,whereto,saleid)
select accnt,sta,haccnt,groupno,arr,dep,agent,cusno,source,src,market,restype,channel,
	artag1,artag2,ratecode,rtreason,paycode,wherefrom,whereto,saleid from inserted

---------------------------------------------------------------------------------
--	Part. 3   宾客入住 ->>> 电话，VOD，。。。查房与报房等
---------------------------------------------------------------------------------
if @sta = 'I' and @class='F'
	begin
	select @phonesta = substring(@extra,6,1),	@vodsta = substring(@extra,7,1)

	--自动打开电话
	exec p_gds_phone_grade @roomno, 'ckin', @phonesta, @accnt
	-- pms building
	exec p_gds_pms_building @roomno, 'sta', '1', @accnt

	-- 报房 - pc_id  From auth_runsta
	declare @pc_id char(4)
	declare @host_id varchar(10)
	select @host_id = host_id()
	select @pc_id = pc_id from auth_runsta where host_id=@host_id and status='R'
--	select @pc_id = min(a.pc_id) from auth_runsta a, inserted b 
--		where a.empno=b.cby and a.status='R' -- and charindex(a.moduno,'01/02')>0
	if @pc_id is null
		select @pc_id=''
	insert checkroom(type, pc_id, roomno, sta, empno1, accnt, date1, refer)
		select "2",  @pc_id, roomno, "0", cby, accnt, getdate(), '直接入住' from inserted

	-- vod 
	declare	@gdate datetime
	select @gdate = getdate()
	exec p_gds_vod_grade @roomno,@vodsta,'1','PMS','PMS','1',@gdate,'R'
	end
;

-- ------------------------------------------------------------------------
--		update
-- ------------------------------------------------------------------------
if exists(select 1 from sysobjects where name='t_gds_master_update' and type='TR')
	drop trigger t_gds_master_update
;
create trigger t_gds_master_update
   on master
   for update 
as
declare 	@new_roomno 	char(5),	@old_roomno 	char(5),
        	@new_sta 		char(1),	@old_sta 		char(1),
        	@new_vodsta 	char(1),	@old_vodsta 	char(1),
        	@new_phonesta 	char(1),	@old_phonesta 	char(1),
			@accnt 			char(10), @opvod			char(1),  -- 是否需要操作vod grade
			@class			char(1),
			@setrate			money,
         @rmrate        money,
			@gstno			int,
			@garr				datetime,
			@ratecode		char(10),
			@market			char(3),
			@src				char(3),
			@packages		varchar(50),
			@srqs				varchar(30),
			@amenities		varchar(30),
			@arr 				datetime,		@old_arr			datetime,
			@dep				datetime,		@old_dep			datetime,
			@diffarr			integer,			@diffdep			integer,
            @bdate              datetime,       @quan               integer


select @accnt=accnt, @opvod='F', @class=class, @setrate=setrate,@rmrate=rmrate, @gstno=gstno, @garr=arr, @arr=arr, @dep = dep,
		@amenities=amenities, @packages=packages, @market=market, @src=src, @srqs=srqs, @ratecode=ratecode,@new_sta = sta 
	from inserted
select @old_sta = sta from deleted

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
   insert master_log select * from inserted

---------------------------------------------------------------------------------
--	Part. 2  Pms, Phone, CheckRoom ......
---------------------------------------------------------------------------------
if @class='F' and (update(sta) or update(extra) or update(roomno) or update(haccnt))
	begin
	select @new_roomno = roomno,@new_phonesta = substring(extra,6,1),@new_vodsta = substring(extra,7,1) from inserted
	select @old_roomno = roomno,@old_phonesta = substring(extra,6,1),@old_vodsta = substring(extra,7,1) from deleted

	-- 
	if update(roomno) and exists(select 1 from subaccnt where to_accnt = @accnt) 
		update subaccnt set to_roomno=@new_roomno where to_accnt = @accnt

	declare @pc_id char(4), @refer varchar(20)
	declare @host_id varchar(10)
	select @host_id = host_id()
	select @pc_id = pc_id from auth_runsta where host_id=@host_id and status='R'
	--select @pc_id = min(a.pc_id) from auth_runsta a, inserted b 
	--	where a.empno=b.cby and a.status='R' -- and charindex(a.moduno,'01/02')>0
	if @pc_id is null
		select @pc_id=''

	-- 宾客入住
	if @new_sta = 'I' and @old_sta <> 'I'   
		begin
		exec p_gds_phone_grade @new_roomno, 'ckin', @new_phonesta, @accnt
		-- pms building
		exec p_gds_pms_building @new_roomno, 'sta', '1', @accnt

		if @old_sta='S' 
			select @refer='挂帐客人入住'		
		else if @old_sta='O' 
			select @refer='结账补救'
		else if charindex(@old_sta,'RCG')>0
			select @refer='预订入住'
		else
			select @refer='入住'

		if charindex(@old_sta,'SO')=0 select @opvod='T'

		insert checkroom(type, pc_id, roomno, sta, empno1, accnt, date1, refer)
			select "2",  @pc_id, roomno, "0", cby, accnt, getdate(), @refer from inserted
		end

	-- 退房 -
	else if @new_sta <> 'I' and @old_sta = 'I'   
		begin
	--考虑同住关系，如果有同住则不发ckou命令,changed by wz
		if not exists(select 1 from master where class = 'F' and sta = 'I' and roomno = @old_roomno ) 
			begin
			exec p_gds_phone_grade @new_roomno, 'ckou', '0', @accnt
			-- pms building
			exec p_gds_pms_building @new_roomno, 'sta', '0', @accnt
			end
		select @opvod='T',@new_vodsta='0'
		end
		-- 退房的查房由收银员主动操作
	-- 换房        
	else if @new_sta = 'I' and @new_roomno <> @old_roomno
		begin
		if @new_sta = 'I'
			begin
		--考虑同住关系，如果有同住则不发ckou命令
			if not exists(select 1 from master where class = 'F' and sta = 'I' and roomno = @old_roomno ) 
			begin
				exec p_gds_phone_grade @old_roomno, 'ckou', '0', @accnt
				-- pms building
				exec p_gds_pms_building @old_roomno, 'sta', '0', @accnt
			end
			select @refer='换房查房' + @new_roomno		
			insert checkroom(type, pc_id, roomno, sta, empno1, accnt, date1, refer)
				select "1",  @pc_id, roomno, "0", cby, accnt, getdate(), @refer from deleted
			                  
			exec p_gds_phone_grade @new_roomno, 'ckin', @new_phonesta, @accnt
			-- pms building
			exec p_gds_pms_building @new_roomno, 'sta', '1', @accnt
	
			select @refer='换房报房-' + @old_roomno
			insert checkroom(type, pc_id, roomno, sta, empno1, accnt, date1, refer)
				select "2",  @pc_id, roomno, "0", cby, accnt, getdate(), @refer from inserted
	
			select @opvod='T'
			end
		 else if @new_sta = 'R' and @old_roomno<>'' and datediff(dd,@garr,getdate())>=0
			begin
			select @refer='换房报房 R -' + @old_roomno
			insert checkroom(type, pc_id, roomno, sta, empno1, accnt, date1, refer)
				select "2",  @pc_id, roomno, "0", cby, accnt, getdate(), @refer from inserted
			end
		end

	-- 修改 PMS 等级  或者 更改了宾客的档案(需要传入姓名)
	else if @new_sta = 'I' and ( @new_phonesta <> @old_phonesta or update(haccnt))
		exec p_gds_phone_grade @new_roomno, 'grad', @new_phonesta, @accnt

	else if @new_sta = 'I' and @new_vodsta <> @old_vodsta
		begin
		select @opvod='T'
		end

	if @opvod='T'
		begin
		declare	@gdate datetime
		select @gdate = getdate()
	--考虑同住关系，如果有同住则不发关闭命令,changed by wz
		if not exists(select 1 from master where class = 'F' and sta = 'I' and roomno = @old_roomno ) 
		begin
			if @new_roomno<>@old_roomno  --换房,则先关闭原来房间的vod
				exec p_gds_vod_grade @old_roomno,'0','1','PMS','PMS','1',@gdate,'R'
		end 
		exec p_gds_vod_grade @new_roomno,@new_vodsta,'1','PMS','PMS','1',@gdate,'R'
		end
	end

---------------------------------------------------------------------------------
declare @sta char(1),@extra char(30), @ret int, @msg varchar(60)
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
if (update(setrate) or update(gstno) or update(amenities) or update(market) or update(src) 
		or update(ratecode) or update(srqs) or update(packages) or update(rmrate) ) and @class='F'
	update rsvsrc set rate=@setrate, rmrate=@rmrate,gstno=@gstno, amenities=@amenities , market=@market, src=@src,
			ratecode=@ratecode, srqs=@srqs, packages=@packages
		where accnt=@accnt and id=0

---------------------------------------------------------------------------------
--	Part. 5  master - haccnt
---------------------------------------------------------------------------------
if update(haccnt)
begin
	declare	@name	varchar(50), @haccnt char(7), @oldname varchar(50), @exp_s1  char(10)
	declare	@exp_country char(3), @exp_nation char(3), @exp_src char(3), @exp_market char(3), @exp_cusno char(10)
	select @oldname = a.name from guest a,deleted b where a.no=b.haccnt
	select @haccnt = haccnt, @exp_s1 = exp_s1 from inserted
	if @@rowcount=1 and rtrim(@haccnt) is not null
	begin
		select @name = name,@exp_country=country,@exp_nation=nation,@exp_src=src,
			@exp_market=market, @exp_cusno=cusno from guest where no = @haccnt
		if @@rowcount=1 and rtrim(@haccnt) is not null
		begin
			update master_des set haccnt=@name, haccnt_o=@haccnt where accnt=@accnt
			update subaccnt set name=@name where accnt=@accnt and subaccnt=1 and type='5'
			if @class in ('G', 'M')
			begin
				update master_des set groupno=@name where groupno_o = @accnt
				update guest set name=@name, country=@exp_country, src=@exp_src, market=@exp_market,
					nation=@exp_nation, cusno=@exp_cusno where no=@exp_s1
			end
		end
		--
		if exists(select 1 from subaccnt where to_accnt = @accnt)
			update subaccnt set name=@name where to_accnt = @accnt
		--
		if exists(select 1 from master where accnt = @accnt and class='F' and osta='I' and sta='I')
      	insert into lgfl select 'r_haccnt', 'rm:'+roomno, @accnt+'-'+@oldname+'#', @accnt+'-'+@name+'#', cby, getdate(),'' from inserted
	end
end
---------------------------------------------------------------------------------
--	Part. 6  取消信用 -- 转移到 CHKTPRM 处理 
---------------------------------------------------------------------------------
--if update(sta)
--begin
--	if charindex(@new_sta, 'IRS')=0 and charindex(@old_sta, 'IRS')>0 -- and @accnt not like 'A%'
--	begin
--		declare	@empno2 char(10), @bdate2 datetime, @shift2 char(1), @logdate2 datetime
--		select @empno2=cby, @bdate2=bdate, @shift2='1',@logdate2=changed from inserted 
--		if @@rowcount <> 0 
--			update accredit set tag='5',empno2=@empno2, bdate2=@bdate2, shift2=@shift2,log_date2=@logdate2
--				where accnt=@accnt and tag='0' 
--	end
--end

---------------------------------------------------------------------------------------------------------------
--	Part. 7 分账户有效期 hbb 2005.12.09   目前只处理用户定义的分账户(tag=2)及系统自动生成的可修改的分账户(tag='1')
---------------------------------------------------------------------------------------------------------------
if (update(dep) or update(arr)) and exists(select 1 from subaccnt where accnt = @accnt)
begin
	select @arr = arr		, @dep 	  = dep 	from inserted
	select @old_arr = arr, @old_dep = dep 	from deleted

	select @diffarr = datediff(day,@old_arr,@arr),@diffdep = datediff(day,@old_dep,@dep)	

	if update(arr)
		update subaccnt set starting_time = dateadd(day,@diffarr,starting_time) 
			where datediff(day,@old_arr,starting_time) = 0 and accnt = @accnt and tag like '[12]%'

	if update(dep)
		update subaccnt set closing_time = dateadd(day,@diffdep,closing_time) 
			where datediff(day,@old_dep,closing_time)  = 0 and accnt = @accnt and tag like '[12]%'
end

---------------------------------------------------------------------------------
--	Part. 8 SC 状态更新
---------------------------------------------------------------------------------
if update(sta)
begin
	update sc_master set sta=@sta, osta=@sta where accnt=@accnt
	if @sta='X'
		update sc_master set status='CAN' where accnt=@accnt
	else if @sta='N'
		update sc_master set status='NS' where accnt=@accnt
	else if @sta='I'
		update sc_master set status='ACT' where accnt=@accnt
end

---------------------------------------------------------------------------------
--	Part. 8 master rmnum update---update rsvsrc_detail的quantity
---------------------------------------------------------------------------------
if update(rmnum)
begin
    select @bdate=bdate from sysdata
    select @quan=rmnum from inserted
    update rsvsrc_detail set quantity=@quan where accnt=@accnt and date_>=@bdate and mode='M'
end
;

-- ------------------------------------------------------------------------
--		Delete 
-- ------------------------------------------------------------------------
if exists(select 1 from sysobjects where name='t_gds_master_delete' and type='TR')
	drop trigger t_gds_master_delete
;
create trigger t_gds_master_delete
   on master
   for delete
as
declare 		@accnt 		char(10)
select @accnt=accnt from deleted
delete master_des where accnt=@accnt
return;

if exists(select 1 from sysobjects where name='t_gds_master_till_delete' and type='TR')
	drop trigger t_gds_master_till_delete
;
create trigger t_gds_master_till_delete
   on master_till
   for delete
as
declare 		@accnt 		char(10)
select @accnt=accnt from deleted
delete master_des_till where accnt=@accnt
return;

if exists(select 1 from sysobjects where name='t_gds_master_last_delete' and type='TR')
	drop trigger t_gds_master_last_delete
;
create trigger t_gds_master_last_delete
   on master_last
   for delete
as
declare 		@accnt 		char(10)
select @accnt=accnt from deleted
delete master_des_last where accnt=@accnt
return;
