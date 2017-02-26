-- appid define
DELETE FROM appid WHERE code ='Z'
;
INSERT INTO appid VALUES (	'Z',	'', '集团预订',	'Group Booking',	' ',	'xrcenter')
;
-- 系统功能
DELETE FROM sys_function WHERE code = '0399'
;
INSERT INTO sys_function(code,class,descript,descript1,fun_des) VALUES ('0399','03','集团预订',	'Group Booking','appid!Z')
;
-- 工具栏
DELETE FROM toolbar_cat WHERE appid  = 'Z'
;
INSERT INTO toolbar_cat ( code, descript, descript1, appid, moduno, pic, show, sequence ) VALUES ( 'exit', '退出', 'Exit', 'Z', 'ZS', 'exit', 'T', 800 ) 
INSERT INTO toolbar_cat ( code, descript, descript1, appid, moduno, pic, show, sequence ) VALUES ( 'other', '其他', 'Other', 'Z', 'Z', 'flower', 'T', 100 ) 
INSERT INTO toolbar_cat ( code, descript, descript1, appid, moduno, pic, show, sequence ) VALUES ( 'reserve', '预订', 'Reservation', 'Z', 'ZY', 'res', 'T', 10 ) 
INSERT INTO toolbar_cat ( code, descript, descript1, appid, moduno, pic, show, sequence ) VALUES ( 'return_crs', '返回', 'Return', 'Z', 'YS', 'exit', 'T', 800 ) 
;
DELETE FROM toolbar WHERE appid  = 'Z'
;
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'other', 'autorep', '报表专家', 'Report Expert', 'sheet', 'Z', 'w_gds_auto_report', '', 'F', 10 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'other', 'calc', '计算器', 'Calculation', 'response', 'Z', 'w_gds_calculator', '', 'F', 10 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'other', 'external', '外部程序', 'External', 'response', 'Z', 'w_gds_extraprg', '', 'F', 10 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'guestlist', '预订列表', 'Resrv. List', 'sheet', 'Z', 'w_gds_master_list_res_cen', 'ZZ', 'F', 20 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'guests', '客户档案', 'Profiles', 'sheet', 'Z', 'w_gds_guest_list', '', 'F', 30 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'loginmember', '登陆成员', 'Login member', 'action', 'Z', '', '', 'F', 10 ) 
;
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'newres', '新建预订', 'New Reservation', 'response', 'Y', 'w_gds_master', 'AFITR', 'F', 10 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'guestlist1', '预订列表', 'Resrv. List', 'sheet', 'Y', 'w_gds_master_list_res', '', 'F', 20 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'guests1', '客户档案', 'Profiles', 'sheet', 'Y', 'w_gds_guest_list', '', 'F', 35 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'rmlst', '客房列表', 'Room List', 'sheet', 'Y', 'w_gds_reserve_rmsta_list_cen', '', 'F', 80 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'rmsta', '客房可用与占用', 'Rooms Available and Occupation', 'response', 'Y', 'w_gds_type_detail_avail_cen', '', 'F', 10 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'events', '活动事务', 'Events', 'response', 'Y', 'w_gds_events_list_member', '', 'F', 80 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'infomation', '公共信息', 'Public Informatins', 'sheet', 'Y', 'w_gl_information', '', 'F', 81 ) 
;
-- 系统工作表 
DELETE FROM basecode WHERE cat = 'moduno' AND code = 'ZZ'
;
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'moduno','ZZ','预订中心','Center Reservation','F','F',0,'','F' ) 
;

