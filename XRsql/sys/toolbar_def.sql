// --------------------------------------------------------------------
//	向 toolbar_name 中插入项目
// --------------------------------------------------------------------

delete toolbar_name where appid='1';
delete toolbar where appid='1';

// 插入前台系统所有功能
// reserve
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'newres','新建预订','New Reserve','response','','w_gds_master','AFITR','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'guestlist','宾客列表','Guests List','sheet','','w_gds_master_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'waitlist','WaitList','Wait-List','response','','w_gds_master_wait_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'asklist','销售问询','Sales Inquire','sheet','','w_gds_turnaway_list','','F');

// recept
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'arrival','本日到达','Today Arrival','sheet','','w_gds_master_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'walk-in','walk-in','Walk-In','sheet','','w_gds_master_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'blocking','综合排房','Rooms Booking','response','','w_gds_master_booking','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'q-rooms','Q-Rooms','Q-Rooms','response','','w_gds_master_qroom','','F');

// house
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hsmap1','实时房态-1','Rooms Map','sheet','','w_gds_house_map_ygr','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hsmap2','实时房态-2','Rooms Map','sheet','','w_gds_house_map_new','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hschgsta','房态管理','Rooms Status','sheet','','w_gds_house_rmsta_change','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hscomsume','客房消耗品','Contums','sheet','','w_gds_gs_main','B','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hswork','工作量统计','Workloads','sheet','','w_gds_gs_main','A','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hsworkloc','清洁任务分配','Word Assignment','sheet','','w_wz_house_work_allot','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'hsrmhis','客房历史','Room History','','','','','F');

// pubmkt
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'guests','客户档案','Profile','sheet','','w_gds_guest_list','','F');

// bus
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'busphone','商务电话','Bus. Phone','response','','w_gds_business_call_folio','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'busfax','商务传真','Bus. Fax','response','','w_gds_fax_folio','','F');

// bos
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'bosact','入帐处理','Posting','sheet','','w_gds_bos_accounting','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'bosdish1','当前帐务','Dish Inquire','sheet','','w_gds_bos_dish_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'bosdish2','历史帐务','Dish History','sheet','','w_gds_bos_dish_hlist','','F');

// audit
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'AllPrintList','单据列表','Bills List','sheet','','w_cyj_allbill_list','','F');

// info 
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'meetroom','会议室信息','Meeting Rooms','sheet','','w_res_dotbmp_meetroom','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'rent','租赁服务','Room Lease','sheet','','w_goods_av_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'message','宾客留言','Messages','sheet','','w_trace_leaveword_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'location','宾客去向','Location','sheet','','w_trace_leaveword_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'events','活动事务','Events','response','','w_gds_events_list','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'infomation','公共信息','Public Informatins','sheet','','w_gl_information','','F');

insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'log','日志查询','Logs','','','','','F');

insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'autorep','报表专家','Reports','sheet','','w_gds_auto_report','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'adtrep','稽核报表','Audit Reports','sheet','','w_gds_audit_report','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'shiftrep','交班报表','Shift Reports','','','','','F');

// other
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'phone','电话功能','Phone Functions','','','','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'external','外部程序','External','response','','w_gds_extraprg','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'calc','计算器','Calculation','response','','w_gds_calculator','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'printer','设置打印机','Printer Setup','','','','','F');

insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'runsta','运行状态','Running Status','response','','w_gds_runsta','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'mail','职员消息','Mail','response','','w_trace_master','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)   // 考虑放在屏幕上某个固定地方(状态栏)
	values('1', 'logbook','交班记录','Log Book','response','','w_trace_master','','F');
insert toolbar_name(appid,code,descript,descript1,wtype,auth,source,parm,multi)
	values('1', 'password','更换密码','Password','response','','w_gh_set_passwd','','F');



// 1-1. 前台系统 - 预订
delete toolbar where appid='1' and cat='01';
insert toolbar(appid,cat,code,sequence) values('1','reserve','newres',10);
insert toolbar(appid,cat,code,sequence) values('1','reserve','guestlist',20);
insert toolbar(appid,cat,code,sequence) values('1','reserve','waitlist',30);
insert toolbar(appid,cat,code,sequence) values('1','reserve','asklist',40);
insert toolbar(appid,cat,code,sequence) values('1','reserve','meetroom',50);
insert toolbar(appid,cat,code,sequence) values('1','reserve','guests',60);
insert toolbar(appid,cat,code,sequence) values('1','reserve','events',70);
insert toolbar(appid,cat,code,sequence) values('1','reserve','infomation',80);

// 1-2. 前台系统 - 接待
delete toolbar where appid='1' and cat='02';
insert toolbar(appid,cat,code,sequence) values('1','recept','arrival',10);
insert toolbar(appid,cat,code,sequence) values('1','recept','walk-in',20);
insert toolbar(appid,cat,code,sequence) values('1','recept','guestlist',30);
insert toolbar(appid,cat,code,sequence) values('1','recept','blocking',40);
insert toolbar(appid,cat,code,sequence) values('1','recept','q-rooms',50);

// 1-3. 前台系统 - 收银

// 1-4. 前台系统 - 销售

// 1-5. 前台系统 - 客房
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

// 1-6. 前台系统 - 商务
delete toolbar where appid='1' and cat='06';
insert toolbar(appid,cat,code,sequence) values('1','business','bosact',10);
insert toolbar(appid,cat,code,sequence) values('1','business','bosdish1',20);
insert toolbar(appid,cat,code,sequence) values('1','business','busphone',30);
insert toolbar(appid,cat,code,sequence) values('1','business','busfax',40);
insert toolbar(appid,cat,code,sequence) values('1','business','shiftrep',90);
insert toolbar(appid,cat,code,sequence) values('1','business','infomation',100);

// 1-7. 前台系统 - 礼宾
delete toolbar where appid='1' and cat='07';
insert toolbar(appid,cat,code,sequence) values('1','polite','guestlist',10);
insert toolbar(appid,cat,code,sequence) values('1','polite','message',20);
insert toolbar(appid,cat,code,sequence) values('1','polite','rent',30);
insert toolbar(appid,cat,code,sequence) values('1','polite','location',40);
insert toolbar(appid,cat,code,sequence) values('1','polite','events',50);
insert toolbar(appid,cat,code,sequence) values('1','polite','infomation',60);

// 1-8. 前台系统 - 审核
delete toolbar where appid='1' and cat='08';
insert toolbar(appid,cat,code,sequence) values('1','audit','AllPrintList',10);

// 1-9. 前台系统 - 查询
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


// 1-10. 前台系统 - 其他
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
