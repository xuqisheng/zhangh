
-- Appid 
delete appid where code='E';
insert appid(code,moduno,descript,descript1,ref,exename) values('E','','����ʵʩ����','Xx WorkPlace','','work');

-- Toolbar_cat, Toolbar
delete toolbar_cat where appid='E';
delete toolbar where appid='E';

Insert toolbar_cat(code,descript,descript1,appid,moduno,pic,show,sequence) values('bill','�˵�','Bill & Folio','E','10','2inv','T',10);
	Insert toolbar Values('E','bill','billsetup','Ʊ������','Bill Setup','response','','w_cyj_bill_edit','','F',10);
	Insert toolbar Values('E','bill','billsyn','DW �﷨','DW Dyntax','response','','w_bill_datawindow','','F',20);
	Insert toolbar Values('E','bill','guestlist','��ס�����б�','In-House List','sheet','','w_gds_master_list_inhouse','','F',30);
	Insert toolbar Values('E','bill','poslist','POS ��ѯ','POS Query','response','','w_cyj_pos_query_condition','','F',40);
	Insert toolbar Values('E','bill','printmsg','���Դ�ӡ','Print Messages','response','','w_trace_leaveword_print','','F',50);

Insert toolbar_cat(code,descript,descript1,appid,moduno,pic,show,sequence) values('interface','�ӿ�','Interface','E','20','2f9','T',20);

Insert toolbar_cat(code,descript,descript1,appid,moduno,pic,show,sequence) values('free','���ɿռ�','Free Space','E','30','flower','T',30);
	Insert toolbar Values('E','free','free','���ɿռ�','Free Fly','response','','w_gds_sys_interface','','F',100);

Insert toolbar_cat(code,descript,descript1,appid,moduno,pic,show,sequence) values('query','��ѯ','Query','E','30','query','T',40);
	Insert toolbar Values('E','query','guests','�ͻ�����','Profiles','sheet','','w_gds_guest_list','','F',100);
	Insert toolbar Values('E','query','guestlist','�����б�','Guests List','sheet','','w_gds_master_list_other','','F',200);
	Insert toolbar Values('E','query','reshis','��ʷס��','Room History','sheet','','w_gds_hmaster_list','','F',300);
	Insert toolbar Values('E','query','cus','������','House Account','sheet','','w_gds_master_list_cus','','F',400);
	Insert toolbar Values('E','query','ar','Ӧ����','AR Account','sheet','','w_gds_master_list_ar','','F',500);
	Insert toolbar Values('E','query','autorep','����ר��','Report Expert','sheet','','w_gds_auto_report','','F',600);
	Insert toolbar Values('E','query','adtrep','���˱���','Audit Reports','sheet','','w_gds_audit_report','','F',700);
	Insert toolbar Values('E','query','infomation','������Ϣ','Public Informatins','response','','w_gl_information','','F',800);
	Insert toolbar Values('E','query','events','�����','Events','response','','w_gds_events_list','','F',900);

Insert toolbar_cat(code,descript,descript1,appid,moduno,pic,show,sequence) values('exit','�˳�','Exit','E','','exit','T',100);


