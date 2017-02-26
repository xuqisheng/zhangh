
DELETE FROM toolbar WHERE appid = 'Z'
DELETE FROM toolbar_cat WHERE appid = 'Z'
;

INSERT INTO toolbar_cat VALUES (	'reserve',	'预订',	'Reservation',	'Z',	'01',	'res',	'T',	10)
INSERT INTO toolbar_cat VALUES (	'other',	'其他',	'Other',	'Z',	'10',	'flower',	'T',	100)
INSERT INTO toolbar_cat VALUES (	'exit',	'退出',	'Exit',	'Z',	'',	'exit',	'T',	800)

INSERT INTO toolbar VALUES (	'Z',	'reserve',	'loginmember',	'登陆成员',	'Login member',	'action',	'',	'',	'',	'F',	10);
INSERT INTO toolbar VALUES (	'Z',	'reserve',	'guestlist',	'预订列表',	'Resrv. List',	'sheet',	'',	'w_gds_master_list_res_cen',	'ZZ',	'F',	20);
INSERT INTO toolbar VALUES (	'Z',	'reserve',	'guests',	'客户档案',	'Profiles',	'sheet',	'',	'w_gds_guest_list',	'',	'F',	 30);
INSERT INTO toolbar VALUES (	'Z',	'other',	'external',	'外部程序',	'External',	'response',	'',	'w_gds_extraprg',	'',	'F',	10);
INSERT INTO toolbar VALUES (	'Z',	'other',	'calc',	'计算器',	'Calculation',	'response',	'',	'w_gds_calculator',	'',	'F',	20);
INSERT INTO toolbar VALUES (	'Z',	'other',	'runsta',	'运行状态',	'Station Status',	'response',	'',	'w_gds_runsta',	'',	'F',	40);
INSERT INTO toolbar VALUES (	'Z',	'other',	'mail',	'职员消息',	'Mail',	'response',	'',	'w_trace_master',	'',	'F',	50);
;

-- 切换到成员时用
DELETE FROM toolbar WHERE appid = 'Y'
DELETE FROM toolbar_cat WHERE appid = 'Y'
;
INSERT INTO toolbar_cat  VALUES ( 'reserve', '预订', 'Reservation', 'Y', '01', 'res', 'T', 10 ) 
INSERT INTO toolbar_cat  VALUES ( 'info', '信息查询', 'Information', 'Y', '09', 'query', 'T', 90 ) 
INSERT INTO toolbar_cat  VALUES ( 'return_crs', '返回', 'Return', 'Y', '', 'exit', 'T', 800 ) 

INSERT INTO toolbar  VALUES ( 'Y', 'info', 'rmsta', '客房可用与占用', 'Rooms Available and Occupation', 'response', '', 'w_gds_type_detail_avail_cen', '', 'F', 10 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'info', 'rmlst', '客房列表', 'Room List', 'sheet', '', 'w_gds_reserve_rmsta_list_cen', '', 'F', 80 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'info', 'autorep', '报表专家', 'Report Expert', 'sheet', '', 'w_gds_auto_report', '', 'F', 80 ) 

INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'newres', '新建预订', 'New Reservation', 'response', '', 'w_gds_master', 'AFITR', 'F', 10 ) 
//INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'rmqry', '房价查询', 'Room Query', 'action', '', '', '', 'F', 15 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'guestlist', '预订列表', 'Resrv. List', 'sheet', '', 'w_gds_master_list_res', '', 'F', 20 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'guests', '客户档案', 'Profiles', 'sheet', '', 'w_gds_guest_list', '', 'F', 35 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'rmsta', '客房可用与占用', 'Rooms Available and Occupation', 'response', '', 'w_gds_type_detail_avail', '', 'F', 40 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'rmlst', '客房列表', 'Room List', 'sheet', '', 'w_gds_reserve_rmsta_list', '', 'F', 50 ) 
INSERT INTO toolbar  VALUES (	'Y', 'reserve', 'events',	'活动事务',	'Events',	'response',	'',	'w_gds_events_list_member',	'',	'F',	80);
INSERT INTO toolbar  VALUES (	'Y', 'reserve', 'infomation',	'公共信息',	'Public Informatins',	'sheet',	'',	'w_gl_information',	'',	'F',	81);
INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'calc', '计算器', 'Calculation', 'response', '', 'w_gds_calculator', '', 'F', 90 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'printer', '设置打印机', 'Printer Setup', 'system', '', '', '', 'F', 91 ) 
;