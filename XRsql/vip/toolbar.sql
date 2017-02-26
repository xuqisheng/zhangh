--------------------------------------------------------
--	toolbar_cat 
--------------------------------------------------------
delete toolbar_cat where appid='K';

INSERT INTO toolbar_cat VALUES ('make','�����','Manage','K','12','2inv','T',10);
INSERT INTO toolbar_cat VALUES ('point','����','Points','K','12','sale','T',30);
INSERT INTO toolbar_cat VALUES ('billing','����','Billing','K','12','cash','T',40);
INSERT INTO toolbar_cat VALUES ('query','��ѯ','Information','K','12','query','T',45);
INSERT INTO toolbar_cat VALUES ('other','����','Other','K','12','flower','T',50);
INSERT INTO toolbar_cat VALUES ('exit','�˳�','Exit','K','','exit','T',100);



--------------------------------------------------------
--	toolbar
--------------------------------------------------------
delete toolbar where appid='K';

INSERT INTO toolbar VALUES ('K','billing','billing','������','Billing','sheet','','','','F',10);
INSERT INTO toolbar VALUES ('K','billing','daycred','���౨��','Cashier Reports','response','','','','F',50);
INSERT INTO toolbar VALUES ('K','billing','queryaccnt','�����ѯ','Account Query','sheet','','','','F',40);

INSERT INTO toolbar VALUES ('K','make','ccard1','���ֿ�','Points Card','response','','w_gds_vipcard','A1','F',50);
INSERT INTO toolbar VALUES ('K','make','cardlist','���б�','Cards List','sheet','','w_gl_vip_card_list','','F',100);
INSERT INTO toolbar VALUES ('K','make','cardread','����','Read Card','response','','w_gds_vip_read_select','','F',200);

INSERT INTO toolbar VALUES ('K','other','calc','������','Calculation','response','','w_gds_calculator','','F',30);
INSERT INTO toolbar VALUES ('K','other','external','�ⲿ����','External','response','','w_gds_extraprg','','F',20);
INSERT INTO toolbar VALUES ('K','other','logbook','�����¼','Log Book','response','','w_trace_master','','F',80);
INSERT INTO toolbar VALUES ('K','other','mail','ְԱ��Ϣ','Mail','response','','w_trace_master','','F',70);
INSERT INTO toolbar VALUES ('K','other','password','��������','Password','response','','w_cyj_set_passwd','','F',90);
INSERT INTO toolbar VALUES ('K','other','printer','���ô�ӡ��','Printer Setup','system','','','','F',50);
INSERT INTO toolbar VALUES ('K','other','runsta','����״̬','Station Status','response','','w_gds_runsta','','F',60);

INSERT INTO toolbar VALUES ('K','point','prule','���ֻ����','Calc Rule','response','','w_gl_vipdef1','','F',100);
INSERT INTO toolbar VALUES ('K','point','pparm','����ϵ����','Calc Modulus','response','','w_gl_vipdef2','','F',200);
INSERT INTO toolbar VALUES ('K','point','pquery','���ֲ�ѯ','Points Query','','','','','F',300);
INSERT INTO toolbar VALUES ('K','point','pchg','���ֶһ�','Points Change','sheet','','w_gds_bos_accounting','96','F',400);
INSERT INTO toolbar VALUES ('K','point','pmove','����ת��','Ponts Move','response','','w_gds_vipcard_point_transfer','','F',500);
INSERT INTO toolbar VALUES ('K','point','pinput','����¼��','Ponts Input','response','','w_gds_vipcard_point_post','','F',500);


INSERT INTO toolbar VALUES ('K','query','adtrep','���˱���','Audit Reports','sheet','','w_gds_audit_report','','F',500);
INSERT INTO toolbar VALUES ('K','query','autorep','����ר��','Report Expert','sheet','','w_gds_auto_report','','F',400);
INSERT INTO toolbar VALUES ('K','query','guestlist','�����б�','Guests List','sheet','','w_gds_master_list_other','','F',100);
INSERT INTO toolbar VALUES ('K','query','guests','�ͻ�����','Profiles','sheet','','w_gds_guest_list','','F',200);
INSERT INTO toolbar VALUES ('K','query','infomation','������Ϣ','Public Informatins','response','','w_gl_information','','F',600);
