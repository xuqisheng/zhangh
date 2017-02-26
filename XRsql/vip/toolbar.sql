--------------------------------------------------------
--	toolbar_cat 
--------------------------------------------------------
delete toolbar_cat where appid='K';

INSERT INTO toolbar_cat VALUES ('make','贵宾卡','Manage','K','12','2inv','T',10);
INSERT INTO toolbar_cat VALUES ('point','积分','Points','K','12','sale','T',30);
INSERT INTO toolbar_cat VALUES ('billing','帐务','Billing','K','12','cash','T',40);
INSERT INTO toolbar_cat VALUES ('query','查询','Information','K','12','query','T',45);
INSERT INTO toolbar_cat VALUES ('other','其他','Other','K','12','flower','T',50);
INSERT INTO toolbar_cat VALUES ('exit','退出','Exit','K','','exit','T',100);



--------------------------------------------------------
--	toolbar
--------------------------------------------------------
delete toolbar where appid='K';

INSERT INTO toolbar VALUES ('K','billing','billing','账务处理','Billing','sheet','','','','F',10);
INSERT INTO toolbar VALUES ('K','billing','daycred','交班报表','Cashier Reports','response','','','','F',50);
INSERT INTO toolbar VALUES ('K','billing','queryaccnt','账务查询','Account Query','sheet','','','','F',40);

INSERT INTO toolbar VALUES ('K','make','ccard1','积分卡','Points Card','response','','w_gds_vipcard','A1','F',50);
INSERT INTO toolbar VALUES ('K','make','cardlist','卡列表','Cards List','sheet','','w_gl_vip_card_list','','F',100);
INSERT INTO toolbar VALUES ('K','make','cardread','读卡','Read Card','response','','w_gds_vip_read_select','','F',200);

INSERT INTO toolbar VALUES ('K','other','calc','计算器','Calculation','response','','w_gds_calculator','','F',30);
INSERT INTO toolbar VALUES ('K','other','external','外部程序','External','response','','w_gds_extraprg','','F',20);
INSERT INTO toolbar VALUES ('K','other','logbook','交班记录','Log Book','response','','w_trace_master','','F',80);
INSERT INTO toolbar VALUES ('K','other','mail','职员消息','Mail','response','','w_trace_master','','F',70);
INSERT INTO toolbar VALUES ('K','other','password','更换密码','Password','response','','w_cyj_set_passwd','','F',90);
INSERT INTO toolbar VALUES ('K','other','printer','设置打印机','Printer Setup','system','','','','F',50);
INSERT INTO toolbar VALUES ('K','other','runsta','运行状态','Station Status','response','','w_gds_runsta','','F',60);

INSERT INTO toolbar VALUES ('K','point','prule','积分换算表','Calc Rule','response','','w_gl_vipdef1','','F',100);
INSERT INTO toolbar VALUES ('K','point','pparm','积分系数表','Calc Modulus','response','','w_gl_vipdef2','','F',200);
INSERT INTO toolbar VALUES ('K','point','pquery','积分查询','Points Query','','','','','F',300);
INSERT INTO toolbar VALUES ('K','point','pchg','积分兑换','Points Change','sheet','','w_gds_bos_accounting','96','F',400);
INSERT INTO toolbar VALUES ('K','point','pmove','积分转移','Ponts Move','response','','w_gds_vipcard_point_transfer','','F',500);
INSERT INTO toolbar VALUES ('K','point','pinput','积分录入','Ponts Input','response','','w_gds_vipcard_point_post','','F',500);


INSERT INTO toolbar VALUES ('K','query','adtrep','稽核报表','Audit Reports','sheet','','w_gds_audit_report','','F',500);
INSERT INTO toolbar VALUES ('K','query','autorep','报表专家','Report Expert','sheet','','w_gds_auto_report','','F',400);
INSERT INTO toolbar VALUES ('K','query','guestlist','宾客列表','Guests List','sheet','','w_gds_master_list_other','','F',100);
INSERT INTO toolbar VALUES ('K','query','guests','客户档案','Profiles','sheet','','w_gds_guest_list','','F',200);
INSERT INTO toolbar VALUES ('K','query','infomation','公共信息','Public Informatins','response','','w_gl_information','','F',600);
