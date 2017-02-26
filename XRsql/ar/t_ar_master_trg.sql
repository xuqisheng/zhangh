if exists(select 1 from sysobjects where name='t_ar_master_insert' and type='TR')
	drop trigger t_ar_master_insert
;
create trigger t_ar_master_insert
   on ar_master
   for insert 
as
declare 		@sta 			char(1),
				@accnt 		char(10),
				@class		char(1),
				@extra		char(30),
				@haccnt		char(7),
				@hclass		char(1)

declare		@lock			char(1),
				@partpost1	varchar(255),
				@partpost2	varchar(255)

---------------------------------------------------------------------------------
--	Part. 0   特殊校验
---------------------------------------------------------------------------------
select @accnt=accnt, @haccnt=haccnt, @class=class, @sta=sta, @extra=extra from inserted
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
select @hclass=class from guest where no=@haccnt
if @hclass<>'R'
begin
	rollback trigger with raiserror 20000 "账户的档案类型不符HRY_MARK"  -- 2003.10.26 ar账采用专用档案
	return
end

---------------------------------------------------------------------------------
--	Part. 1   account flag
---------------------------------------------------------------------------------
select @lock = substring(@extra, 10, 1) -- 允许记账
if @lock = '0'
	insert subaccnt select '', '', a.accnt, 1, '', '', '允许记账费用', '', '2000.1.1', '2030.1.1', a.cby, a.changed, '0', '0', '', '', 1
		from inserted a, guest b where a.haccnt = b.no
else if @lock = '1'
	insert subaccnt select '', '', a.accnt, 1, '', '', '允许记账费用', '*', '2000.1.1', '2030.1.1', a.cby, a.changed, '0', '0', '', '', 1
		from inserted a, guest b where a.haccnt = b.no
else
begin
	select @partpost1 = isnull((select value from sysoption where catalog='reserve' and item='locksta_part_def'), '10*')
	insert subaccnt select '', '', a.accnt, 1, '', '', '允许记账费用', @partpost1, '2000.1.1', '2030.1.1', a.cby, a.changed, '0', '0', '', '', 1
		from inserted a, guest b where a.haccnt = b.no
end


-- 分账户
insert subaccnt select '', '', a.accnt, 1, '', '', b.name, '*', '2000.1.1', '2030.1.1', a.cby, a.changed, '5', '0', '', '', 1
	from inserted a, guest b where a.haccnt = b.no

---------------------------------------------------------------------------------
--	Part. 2  ar_master_des
---------------------------------------------------------------------------------
-- insert ar_master_des(accnt,sta,haccnt,groupno,arr,dep,agent,cusno,source,src,market,restype,channel,
-- 	artag1,artag2,ratecode,rtreason,paycode,wherefrom,whereto,saleid)
-- select accnt,sta,haccnt,groupno,arr,dep,agent,cusno,source,src,market,restype,channel,
-- 	artag1,artag2,ratecode,rtreason,paycode,wherefrom,whereto,saleid from inserted

;

-- ------------------------------------------------------------------------
--		update
-- ------------------------------------------------------------------------
if exists(select 1 from sysobjects where name='t_ar_master_update' and type='TR')
	drop trigger t_ar_master_update
;
create trigger t_ar_master_update
   on ar_master
   for update 
as
declare 	@accnt 			char(10),
			@class			char(1),
			@name				varchar(50),
			@haccnt			char(7)

select @accnt=accnt, @class=class from inserted

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
   insert ar_master_log select * from inserted

---------------------------------------------------------------------------------
--	Part. 2  ar_master - haccnt
---------------------------------------------------------------------------------
if update(haccnt)
	begin
	select @haccnt = haccnt from inserted
	if @@rowcount=1 and rtrim(@haccnt) is not null
		begin
		select @name = name from guest where no = @haccnt
		if @@rowcount=1 and rtrim(@haccnt) is not null
			begin
--			update ar_master_des set haccnt=@name, haccnt_o=@haccnt where accnt=@accnt
			update subaccnt set name=@name where accnt=@accnt and subaccnt=1 and type='5'
			end
		end
	end

;
//
//-- ------------------------------------------------------------------------
//--		Delete 
//-- ------------------------------------------------------------------------
//if exists(select 1 from sysobjects where name='t_ar_master_delete' and type='TR')
//	drop trigger t_ar_master_delete
//;
//create trigger t_ar_master_delete
//   on ar_master
//   for delete
//as
//declare 		@accnt 		char(10)
//select @accnt=accnt from deleted
//delete ar_master_des where accnt=@accnt
//return;
//
//if exists(select 1 from sysobjects where name='t_ar_master_till_delete' and type='TR')
//	drop trigger t_ar_master_till_delete
//;
//create trigger t_ar_master_till_delete
//   on ar_master_till
//   for delete
//as
//declare 		@accnt 		char(10)
//select @accnt=accnt from deleted
//delete ar_master_des_till where accnt=@accnt
//return;
//
//if exists(select 1 from sysobjects where name='t_ar_master_last_delete' and type='TR')
//	drop trigger t_ar_master_last_delete
//;
//create trigger t_ar_master_last_delete
//   on ar_master_last
//   for delete
//as
//declare 		@accnt 		char(10)
//select @accnt=accnt from deleted
//delete ar_master_des_last where accnt=@accnt
//return;
//