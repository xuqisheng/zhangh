if exists(select * from sysobjects where type ="U" and name = "night_audit")
   drop table night_audit;

CREATE TABLE night_audit (
	exec_order		integer			not null,
	prgname			char(11)			not null,
	descript			char(40)			not null,
	descript1		char(40)			not null,
	window			char(40)			not null,
	parm				char(50)			default '' not null,
	syntax			varchar(255)	default '' not null,
	hasdone			char(1)			not null,
	starttime		datetime			not null,
	needinst			char(1)			default 'T' not null,
	needzero			char(1)			default 'F' not null
);
INSERT INTO night_audit VALUES (	10, 'nocheckin', '应到未到客人列表', 'Arrivals not yet Checked_In', 'w_gl_audit_guest_list', 'nocheckin', 'select sum(a.rmnum) from master a, sysdata b where a.sta = "R" and datediff(dd, a.arr, b.bdate1) >= 0', 'F', '1-1-2000 0:0:0.000', 'T', 'F');
INSERT INTO night_audit VALUES (	20, 'nocheckout', '应离未离客人列表', 'Departures not yet Checked_Out', 'w_gl_audit_guest_list', 'nocheckout', 'select sum(a.rmnum) from master a, sysdata b where a.sta = "I" and datediff(dd, a.dep, b.bdate1) >= 0', 'F', '1-1-2000 0:0:0.000', 'T', 'F');
INSERT INTO night_audit VALUES (	30, 'cancel', '取消预订客人列表', 'Canceled Reservations', 'w_gl_audit_guest_list', 'cancel', 'select sum(rmnum) from master where sta = "X"', 'F', '1-1-2000 0:0:0.000', 'T', 'F');
INSERT INTO night_audit VALUES (	40, 'message', '尚未传达的宾客留言列表', 'Undelivered_Messages', 'w_gl_audit_undelivered_messages', '', 'select count(1) from message_leaveword where tag < ''2'' and getdate() >= inure and getdate() <= abate', 'F', '1-1-2000 0:0:0.000', 'T', 'F');
INSERT INTO night_audit VALUES (	50, 'phone', '尚未入账的电话列表', '', 'w_gl_audit_phone_check', 'audit', 'select count(1) from phfolio where log_date>=dateadd(dd, -2, getdate()) and log_date<=getdate() and refer like "EMPTY%"', 'F', '1-1-2000 0:0:0.000', 'T', 'F');
INSERT INTO night_audit VALUES (	70, 'rmpost', '房租预审及入账', 'Post Room and Tax', 'w_gl_audit_rmpost', '', '', 'F', '1-1-2000 0:0:0.000', 'T', 'F');
INSERT INTO night_audit VALUES (	80, 'breakfast', '房包餐收入调整', '', 'w_gl_audit_breakfast', '', '', 'F', '1-1-2000 0:0:0.000', 'F', 'F');
INSERT INTO night_audit VALUES (	90, 'runsta', '系统运行状态', 'System Run Status', 'w_gds_runsta', '', 'select count(1) from auth_runsta where status = "R"', 'F', '1-1-2000 0:0:0.000', 'T', 'F');
INSERT INTO night_audit VALUES (	100, 'auditprg', '统计报表及数据更新', 'Statistics and Updates', 'w_gl_audit_auditprg', 'AUDIT', '', 'F', '1-1-2000 0:0:0.000', 'T', 'F')
;
