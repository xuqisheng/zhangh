
create procedure p_init_trace_doc_etc
as	
begin
	-- Trace
   truncate table message_trace
	-- LeaveWord
   truncate table message_leaveword
	-- Handover
   truncate table message_handover
	-- Mail 
   truncate table message_mailrecv
   truncate table message_mail
	-- Chat
   truncate table message_chat
	-- Notify
   truncate table message_notify
	-- Documents
   truncate table doc_readlog
   truncate table doc_detail
	-- Goods
   truncate table goods_av
	-- Meet
   truncate table res_av
   truncate table res_av_h
   truncate table res_av_log

	--------------------------------------------------------------------------------
	--  Goods rent
	--------------------------------------------------------------------------------
	if exists(select 1 from sys_extraid where cat='GAV')
		update sys_extraid set id = 0 where cat='GAV'
	else
		insert into sys_extraid(cat,descript,id) select 'GAV','Goods Rent',0
	--------------------------------------------------------------------------------
	--  resource reserve
	--------------------------------------------------------------------------------
	if exists(select 1 from sys_extraid where cat='RES')
		update sys_extraid set id = 0 where cat='RES'
	else
		insert into sys_extraid(cat,descript,id) select 'RES','Resource Reserve',0
	--------------------------------------------------------------------------------
	--  Meet reserve
	--------------------------------------------------------------------------------
	if exists(select 1 from sys_extraid where cat='MTR')
		update sys_extraid set id = 0 where cat='MTR'
	else
		insert into sys_extraid(cat,descript,id) select 'MTR','Meet Reserve',0
	--------------------------------------------------------------------------------
	--  Meet maintain 
	--------------------------------------------------------------------------------
	if exists(select 1 from sys_extraid where cat='MTO')
		update sys_extraid set id = 0 where cat='MTO'
	else
		insert into sys_extraid(cat,descript,id) select 'MTO','Meet Maintain ',0
	--------------------------------------------------------------------------------
	--  Message chat
	--------------------------------------------------------------------------------
	if exists(select 1 from sys_extraid where cat='MCH')
		update sys_extraid set id = 0 where cat='MCH'
	else
		insert into sys_extraid(cat,descript,id) select 'MCH','Msg Chat',0
	--------------------------------------------------------------------------------
	--  Message mail
	--------------------------------------------------------------------------------
	if exists(select 1 from sys_extraid where cat='MMA')
		update sys_extraid set id = 0 where cat='MMA'
	else
		insert into sys_extraid(cat,descript,id) select 'MMA','Msg Mail',0
	--------------------------------------------------------------------------------
	--  Message handover
	--------------------------------------------------------------------------------
	if exists(select 1 from sys_extraid where cat='MHO')
		update sys_extraid set id = 0 where cat='MHO'
	else
		insert into sys_extraid(cat,descript,id) select 'MHO','Msg handover',0

	--------------------------------------------------------------------------------
	--  Message leaveWord
	--------------------------------------------------------------------------------
	if exists(select 1 from sys_extraid where cat='LWD')
		update sys_extraid set id = 0 where cat='LWD'
	else
		insert into sys_extraid(cat,descript,id) select 'LWD','Msg LeaveWord',0
	--------------------------------------------------------------------------------
	--  Message Trace
	--------------------------------------------------------------------------------
	if exists(select 1 from sys_extraid where cat='TRA')
		update sys_extraid set id = 0 where cat='TRA'
	else
		insert into sys_extraid(cat,descript,id) select 'TRA','Msg Trace',0

end
;
