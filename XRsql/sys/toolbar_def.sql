// --------------------------------------------------------------------
//	�� toolbar_name �в�����Ŀ
// --------------------------------------------------------------------

delete toolbar_name where appid='1';
delete toolbar where appid='1';

// ����ǰ̨ϵͳ���й���
// reserve
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'newres','�½�Ԥ��','New Reserve','response','','w_gds_master','AFITR','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'guestlist','�����б�','Guests List','sheet','','w_gds_master_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'waitlist','WaitList','Wait-List','response','','w_gds_master_wait_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'asklist','������ѯ','Sales Inquire','sheet','','w_gds_turnaway_list','','F');

// recept
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'arrival','���յ���','Today Arrival','sheet','','w_gds_master_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'walk-in','walk-in','Walk-In','sheet','','w_gds_master_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'blocking','�ۺ��ŷ�','Rooms Booking','response','','w_gds_master_booking','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'q-rooms','Q-Rooms','Q-Rooms','response','','w_gds_master_qroom','','F');

// house
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hsmap1','ʵʱ��̬-1','Rooms Map','sheet','','w_gds_house_map_ygr','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hsmap2','ʵʱ��̬-2','Rooms Map','sheet','','w_gds_house_map_new','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hschgsta','��̬����','Rooms Status','sheet','','w_gds_house_rmsta_change','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hscomsume','�ͷ�����Ʒ','Contums','sheet','','w_gds_gs_main','B','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hswork','������ͳ��','Workloads','sheet','','w_gds_gs_main','A','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hsworkloc','����������','Word Assignment','sheet','','w_wz_house_work_allot','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hsrmhis','�ͷ���ʷ','Room History','','','','','F');

// pubmkt
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'guests','�ͻ�����','Profile','sheet','','w_gds_guest_list','','F');

// bus
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'busphone','����绰','Bus. Phone','response','','w_gds_business_call_folio','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'busfax','������','Bus. Fax','response','','w_gds_fax_folio','','F');

// bos
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'bosact','���ʴ���','Posting','sheet','','w_gds_bos_accounting','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'bosdish1','��ǰ����','Dish Inquire','sheet','','w_gds_bos_dish_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'bosdish2','��ʷ����','Dish History','sheet','','w_gds_bos_dish_hlist','','F');

// audit
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'AllPrintList','�����б�','Bills List','sheet','','w_cyj_allbill_list','','F');

// info 
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'meetroom','��������Ϣ','Meeting Rooms','sheet','','w_res_dotbmp_meetroom','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'rent','���޷���','Room Lease','sheet','','w_goods_av_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'message','��������','Messages','sheet','','w_trace_leaveword_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'location','����ȥ��','Location','sheet','','w_trace_leaveword_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'events','�����','Events','response','','w_gds_events_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'infomation','������Ϣ','Public Informatins','sheet','','w_gl_information','','F');

insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'log','��־��ѯ','Logs','','','','','F');

insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'autorep','����ר��','Reports','sheet','','w_gds_auto_report','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'adtrep','���˱���','Audit Reports','sheet','','w_gds_audit_report','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'shiftrep','���౨��','Shift Reports','','','','','F');

// other
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'phone','�绰����','Phone Functions','','','','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'external','�ⲿ����','External','response','','w_gds_extraprg','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'calc','������','Calculation','response','','w_gds_calculator','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'printer','���ô�ӡ��','Printer Setup','','','','','F');

insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'runsta','����״̬','Running Status','response','','w_gds_runsta','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'mail','ְԱ��Ϣ','Mail','response','','w_trace_master','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)   // ���Ƿ�����Ļ��ĳ���̶��ط�(״̬��)
	values('1', 'logbook','�����¼','Log Book','response','','w_trace_master','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'password','��������','Password','response','','w_gh_set_passwd','','F');



// 1-1. ǰ̨ϵͳ - Ԥ��
delete toolbar where appid='1' and cat='01';
insert toolbar(appid,cat,code,sequence) values('1','reserve','newres',10);
insert toolbar(appid,cat,code,sequence) values('1','reserve','guestlist',20);
insert toolbar(appid,cat,code,sequence) values('1','reserve','waitlist',30);
insert toolbar(appid,cat,code,sequence) values('1','reserve','asklist',40);
insert toolbar(appid,cat,code,sequence) values('1','reserve','meetroom',50);
insert toolbar(appid,cat,code,sequence) values('1','reserve','guests',60);
insert toolbar(appid,cat,code,sequence) values('1','reserve','events',70);
insert toolbar(appid,cat,code,sequence) values('1','reserve','infomation',80);

// 1-2. ǰ̨ϵͳ - �Ӵ�
delete toolbar where appid='1' and cat='02';
insert toolbar(appid,cat,code,sequence) values('1','recept','arrival',10);
insert toolbar(appid,cat,code,sequence) values('1','recept','walk-in',20);
insert toolbar(appid,cat,code,sequence) values('1','recept','guestlist',30);
insert toolbar(appid,cat,code,sequence) values('1','recept','blocking',40);
insert toolbar(appid,cat,code,sequence) values('1','recept','q-rooms',50);

// 1-3. ǰ̨ϵͳ - ����

// 1-4. ǰ̨ϵͳ - ����

// 1-5. ǰ̨ϵͳ - �ͷ�
delete toolbar where appid='1' and cat='05';
insert toolbar(appid,cat,code,sequence) values('1','house','hsmap1',10);
insert toolbar(appid,cat,code,sequence) values('1','house','q-rooms',15);
insert toolbar(appid,cat,code,sequence) values('1','house','hschgsta',20);
insert toolbar(appid,cat,code,sequence) values('1','house','bosact',30);
insert toolbar(appid,cat,code,sequence) values('1','house','bosdish1',40);
insert toolbar(appid,cat,code,sequence) values('1','house','hscomsume',60);
insert toolbar(appid,cat,code,sequence) values('1','house','hswork',70);
insert toolbar(appid,cat,code,sequence) values('1','house','shiftrep',90);
insert toolbar(appid,cat,code,sequence) values('1','house','hsrmhis',100);

// 1-6. ǰ̨ϵͳ - ����
delete toolbar where appid='1' and cat='06';
insert toolbar(appid,cat,code,sequence) values('1','business','bosact',10);
insert toolbar(appid,cat,code,sequence) values('1','business','bosdish1',20);
insert toolbar(appid,cat,code,sequence) values('1','business','busphone',30);
insert toolbar(appid,cat,code,sequence) values('1','business','busfax',40);
insert toolbar(appid,cat,code,sequence) values('1','business','shiftrep',90);
insert toolbar(appid,cat,code,sequence) values('1','business','infomation',100);

// 1-7. ǰ̨ϵͳ - ���
delete toolbar where appid='1' and cat='07';
insert toolbar(appid,cat,code,sequence) values('1','polite','guestlist',10);
insert toolbar(appid,cat,code,sequence) values('1','polite','message',20);
insert toolbar(appid,cat,code,sequence) values('1','polite','rent',30);
insert toolbar(appid,cat,code,sequence) values('1','polite','location',40);
insert toolbar(appid,cat,code,sequence) values('1','polite','events',50);
insert toolbar(appid,cat,code,sequence) values('1','polite','infomation',60);

// 1-8. ǰ̨ϵͳ - ���
delete toolbar where appid='1' and cat='08';
insert toolbar(appid,cat,code,sequence) values('1','audit','AllPrintList',10);

// 1-9. ǰ̨ϵͳ - ��ѯ
delete toolbar where appid='1' and cat='09';
insert toolbar(appid,cat,code,sequence) values('1','info','meetroom',10);
insert toolbar(appid,cat,code,sequence) values('1','info','rent',20);
insert toolbar(appid,cat,code,sequence) values('1','info','message',30);
insert toolbar(appid,cat,code,sequence) values('1','info','location',40);
insert toolbar(appid,cat,code,sequence) values('1','info','events',50);
insert toolbar(appid,cat,code,sequence) values('1','info','information',60);
insert toolbar(appid,cat,code,sequence) values('1','info','log',70);
insert toolbar(appid,cat,code,sequence) values('1','info','autorep',80);
insert toolbar(appid,cat,code,sequence) values('1','info','adtrep',90);


// 1-10. ǰ̨ϵͳ - ����
delete toolbar where appid='1' and cat='10';
insert toolbar(appid,cat,code,sequence) values('1','other','phone',10);
insert toolbar(appid,cat,code,sequence) values('1','other','external',20);
insert toolbar(appid,cat,code,sequence) values('1','other','calc',30);
insert toolbar(appid,cat,code,sequence) values('1','other','blocking',40);
insert toolbar(appid,cat,code,sequence) values('1','other','printer',50);
insert toolbar(appid,cat,code,sequence) values('1','other','runsta',60);
insert toolbar(appid,cat,code,sequence) values('1','other','mail',70);
insert toolbar(appid,cat,code,sequence) values('1','other','logbook',80);
insert toolbar(appid,cat,code,sequence) values('1','other','password',90);
