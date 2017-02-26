
-- Appid 
delete appid where code='E';
insert appid(code,moduno,descript,descript1,ref,exename) values('E','','工程实施环境','Xx WorkPlace','','work');

-- Toolbar_cat, Toolbar
delete toolbar_cat where appid='E';
delete toolbar where appid='E';

Insert toolbar_cat(code,descript,descript1,appid,moduno,pic,show,sequence) values('bill','账单','Bill & Folio','E','10','2inv','T',10);
	Insert toolbar Values('E','bill','billsetup','票据设置','Bill Setup','response','','w_cyj_bill_edit','','F',10);
	Insert toolbar Values('E','bill','billsyn','DW 语法','DW Dyntax','response','','w_bill_datawindow','','F',20);
	Insert toolbar Values('E','bill','guestlist','在住宾客列表','In-House List','sheet','','w_gds_master_list_inhouse','','F',30);
	Insert toolbar Values('E','bill','poslist','POS 查询','POS Query','response','','w_cyj_pos_query_condition','','F',40);
	Insert toolbar Values('E','bill','printmsg','留言打印','Print Messages','response','','w_trace_leaveword_print','','F',50);

Insert toolbar_cat(code,descript,descript1,appid,moduno,pic,show,sequence) values('interface','接口','Interface','E','20','2f9','T',20);

Insert toolbar_cat(code,descript,descript1,appid,moduno,pic,show,sequence) values('free','自由空间','Free Space','E','30','flower','T',30);
	Insert toolbar Values('E','free','free','自由空间','Free Fly','response','','w_gds_sys_interface','','F',100);

Insert toolbar_cat(code,descript,descript1,appid,moduno,pic,show,sequence) values('query','查询','Query','E','30','query','T',40);
	Insert toolbar Values('E','query','guests','客户档案','Profiles','sheet','','w_gds_guest_list','','F',100);
	Insert toolbar Values('E','query','guestlist','宾客列表','Guests List','sheet','','w_gds_master_list_other','','F',200);
	Insert toolbar Values('E','query','reshis','历史住客','Room History','sheet','','w_gds_hmaster_list','','F',300);
	Insert toolbar Values('E','query','cus','消费帐','House Account','sheet','','w_gds_master_list_cus','','F',400);
	Insert toolbar Values('E','query','ar','应收帐','AR Account','sheet','','w_gds_master_list_ar','','F',500);
	Insert toolbar Values('E','query','autorep','报表专家','Report Expert','sheet','','w_gds_auto_report','','F',600);
	Insert toolbar Values('E','query','adtrep','稽核报表','Audit Reports','sheet','','w_gds_audit_report','','F',700);
	Insert toolbar Values('E','query','infomation','公共信息','Public Informatins','response','','w_gl_information','','F',800);
	Insert toolbar Values('E','query','events','活动事务','Events','response','','w_gds_events_list','','F',900);

Insert toolbar_cat(code,descript,descript1,appid,moduno,pic,show,sequence) values('exit','退出','Exit','E','','exit','T',100);


