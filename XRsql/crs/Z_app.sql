-- appid define
DELETE FROM appid WHERE code ='Z'
;
INSERT INTO appid VALUES (	'Z',	'', '����Ԥ��',	'Group Booking',	' ',	'xrcenter')
;
-- ϵͳ����
DELETE FROM sys_function WHERE code = '0399'
;
INSERT INTO sys_function(code,class,descript,descript1,fun_des) VALUES ('0399','03','����Ԥ��',	'Group Booking','appid!Z')
;
-- ������
DELETE FROM toolbar_cat WHERE appid  = 'Z'
;
INSERT INTO toolbar_cat ( code, descript, descript1, appid, moduno, pic, show, sequence ) VALUES ( 'exit', '�˳�', 'Exit', 'Z', 'ZS', 'exit', 'T', 800 ) 
INSERT INTO toolbar_cat ( code, descript, descript1, appid, moduno, pic, show, sequence ) VALUES ( 'other', '����', 'Other', 'Z', 'Z', 'flower', 'T', 100 ) 
INSERT INTO toolbar_cat ( code, descript, descript1, appid, moduno, pic, show, sequence ) VALUES ( 'reserve', 'Ԥ��', 'Reservation', 'Z', 'ZY', 'res', 'T', 10 ) 
INSERT INTO toolbar_cat ( code, descript, descript1, appid, moduno, pic, show, sequence ) VALUES ( 'return_crs', '����', 'Return', 'Z', 'YS', 'exit', 'T', 800 ) 
;
DELETE FROM toolbar WHERE appid  = 'Z'
;
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'other', 'autorep', '����ר��', 'Report Expert', 'sheet', 'Z', 'w_gds_auto_report', '', 'F', 10 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'other', 'calc', '������', 'Calculation', 'response', 'Z', 'w_gds_calculator', '', 'F', 10 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'other', 'external', '�ⲿ����', 'External', 'response', 'Z', 'w_gds_extraprg', '', 'F', 10 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'guestlist', 'Ԥ���б�', 'Resrv. List', 'sheet', 'Z', 'w_gds_master_list_res_cen', 'ZZ', 'F', 20 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'guests', '�ͻ�����', 'Profiles', 'sheet', 'Z', 'w_gds_guest_list', '', 'F', 30 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'loginmember', '��½��Ա', 'Login member', 'action', 'Z', '', '', 'F', 10 ) 
;
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'newres', '�½�Ԥ��', 'New Reservation', 'response', 'Y', 'w_gds_master', 'AFITR', 'F', 10 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'guestlist1', 'Ԥ���б�', 'Resrv. List', 'sheet', 'Y', 'w_gds_master_list_res', '', 'F', 20 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'guests1', '�ͻ�����', 'Profiles', 'sheet', 'Y', 'w_gds_guest_list', '', 'F', 35 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'rmlst', '�ͷ��б�', 'Room List', 'sheet', 'Y', 'w_gds_reserve_rmsta_list_cen', '', 'F', 80 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'rmsta', '�ͷ�������ռ��', 'Rooms Available and Occupation', 'response', 'Y', 'w_gds_type_detail_avail_cen', '', 'F', 10 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'events', '�����', 'Events', 'response', 'Y', 'w_gds_events_list_member', '', 'F', 80 ) 
INSERT INTO toolbar ( appid, cat, code, descript, descript1, wtype, auth, source, parm, multi, sequence ) VALUES ( 'Z', 'reserve', 'infomation', '������Ϣ', 'Public Informatins', 'sheet', 'Y', 'w_gl_information', '', 'F', 81 ) 
;
-- ϵͳ������ 
DELETE FROM basecode WHERE cat = 'moduno' AND code = 'ZZ'
;
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'moduno','ZZ','Ԥ������','Center Reservation','F','F',0,'','F' ) 
;

