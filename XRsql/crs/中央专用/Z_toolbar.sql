
DELETE FROM toolbar WHERE appid = 'Z'
DELETE FROM toolbar_cat WHERE appid = 'Z'
;

INSERT INTO toolbar_cat VALUES (	'reserve',	'Ԥ��',	'Reservation',	'Z',	'01',	'res',	'T',	10)
INSERT INTO toolbar_cat VALUES (	'other',	'����',	'Other',	'Z',	'10',	'flower',	'T',	100)
INSERT INTO toolbar_cat VALUES (	'exit',	'�˳�',	'Exit',	'Z',	'',	'exit',	'T',	800)

INSERT INTO toolbar VALUES (	'Z',	'reserve',	'loginmember',	'��½��Ա',	'Login member',	'action',	'',	'',	'',	'F',	10);
INSERT INTO toolbar VALUES (	'Z',	'reserve',	'guestlist',	'Ԥ���б�',	'Resrv. List',	'sheet',	'',	'w_gds_master_list_res_cen',	'ZZ',	'F',	20);
INSERT INTO toolbar VALUES (	'Z',	'reserve',	'guests',	'�ͻ�����',	'Profiles',	'sheet',	'',	'w_gds_guest_list',	'',	'F',	 30);
INSERT INTO toolbar VALUES (	'Z',	'other',	'external',	'�ⲿ����',	'External',	'response',	'',	'w_gds_extraprg',	'',	'F',	10);
INSERT INTO toolbar VALUES (	'Z',	'other',	'calc',	'������',	'Calculation',	'response',	'',	'w_gds_calculator',	'',	'F',	20);
INSERT INTO toolbar VALUES (	'Z',	'other',	'runsta',	'����״̬',	'Station Status',	'response',	'',	'w_gds_runsta',	'',	'F',	40);
INSERT INTO toolbar VALUES (	'Z',	'other',	'mail',	'ְԱ��Ϣ',	'Mail',	'response',	'',	'w_trace_master',	'',	'F',	50);
;

-- �л�����Աʱ��
DELETE FROM toolbar WHERE appid = 'Y'
DELETE FROM toolbar_cat WHERE appid = 'Y'
;
INSERT INTO toolbar_cat  VALUES ( 'reserve', 'Ԥ��', 'Reservation', 'Y', '01', 'res', 'T', 10 ) 
INSERT INTO toolbar_cat  VALUES ( 'info', '��Ϣ��ѯ', 'Information', 'Y', '09', 'query', 'T', 90 ) 
INSERT INTO toolbar_cat  VALUES ( 'return_crs', '����', 'Return', 'Y', '', 'exit', 'T', 800 ) 

INSERT INTO toolbar  VALUES ( 'Y', 'info', 'rmsta', '�ͷ�������ռ��', 'Rooms Available and Occupation', 'response', '', 'w_gds_type_detail_avail_cen', '', 'F', 10 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'info', 'rmlst', '�ͷ��б�', 'Room List', 'sheet', '', 'w_gds_reserve_rmsta_list_cen', '', 'F', 80 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'info', 'autorep', '����ר��', 'Report Expert', 'sheet', '', 'w_gds_auto_report', '', 'F', 80 ) 

INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'newres', '�½�Ԥ��', 'New Reservation', 'response', '', 'w_gds_master', 'AFITR', 'F', 10 ) 
//INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'rmqry', '���۲�ѯ', 'Room Query', 'action', '', '', '', 'F', 15 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'guestlist', 'Ԥ���б�', 'Resrv. List', 'sheet', '', 'w_gds_master_list_res', '', 'F', 20 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'guests', '�ͻ�����', 'Profiles', 'sheet', '', 'w_gds_guest_list', '', 'F', 35 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'rmsta', '�ͷ�������ռ��', 'Rooms Available and Occupation', 'response', '', 'w_gds_type_detail_avail', '', 'F', 40 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'rmlst', '�ͷ��б�', 'Room List', 'sheet', '', 'w_gds_reserve_rmsta_list', '', 'F', 50 ) 
INSERT INTO toolbar  VALUES (	'Y', 'reserve', 'events',	'�����',	'Events',	'response',	'',	'w_gds_events_list_member',	'',	'F',	80);
INSERT INTO toolbar  VALUES (	'Y', 'reserve', 'infomation',	'������Ϣ',	'Public Informatins',	'sheet',	'',	'w_gl_information',	'',	'F',	81);
INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'calc', '������', 'Calculation', 'response', '', 'w_gds_calculator', '', 'F', 90 ) 
INSERT INTO toolbar  VALUES ( 'Y', 'reserve', 'printer', '���ô�ӡ��', 'Printer Setup', 'system', '', '', '', 'F', 91 ) 
;