//团体结算单临时数据表
if exists(select * from sysobjects where name = "grp_checkbill")
	drop table grp_checkbill;
CREATE TABLE grp_checkbill
       (modu_id char(2) NOT NULL,
		 pc_id char(4) NOT NULL,
		 date datetime NULL,			//发生日期
		 accnt char(7) NULL,			//帐号
		 roomno char(4) NULL,
       rmtype char(3) NULL,
       pccode char(2) NULL,		//费用码
		 servcode char(1) NULL,
       billno char(10) NULL,		//单号
		 rooms integer NULL,			//房、次数
       charge money NULL,			//消费
       credit money NULL,			//预付
		 isfut char(1) NULL) ;	//是否已发生--T/F



/*
CREATE TABLE bill_mode (
	code char(3),
	descript char(30),
	descript1 char(30),
	printtype char(10),
	modu char(254),
	halt char(1),
	sequence float,
	extctrl char(16));
INSERT INTO bill_mode VALUES (
	'51',
	'团体结算单(按项目)',
	'Group Check Bill1',
	'chkbill',
	'chkbill',
	'F',
	100,
	'F');
INSERT INTO bill_mode VALUES (
	'52',
	'团体结算单(按日期)',
	'Group Check Bill(daily)',
	'chkbill1',
	'chkbill',
	'F',
	110,
	'F');
INSERT INTO bill_mode VALUES (
	'53',
	'团体结算单(按房号)',
	'Group Check Bill(room)',
	'chkbill2',
	'chkbill',
	'F',
	120,
	'F');


CREATE TABLE bill_unit (
	printtype char(10),
	language char(1),
	descript char(30),
	descript1 char(30),
	paperwidth float,
	paperlength float,
	papertype char(1),
	detailrow float,
	syntax char(32767),
	inumber float,
	savemodi char(1),
	paperzoom float,
	worddot char(254),
	extctrl char(16));
INSERT INTO bill_unit VALUES (
	'chkbill',
	'C',
	'团体结算单1',
	'Group Check Bill',
	200,
	200,
	'V',
	10,
	'd_clg_grp_chkbill',
	0,
	'T',
	100,
	NULL,
	NULL);
INSERT INTO bill_unit VALUES (
	'chkbill1',
	'C',
	'团体结算单(每日)',
	'Group Check Bill(daily)',
	200,
	200,
	'V',
	10,
	'd_clg_grp_chkbill_date',
	0,
	'F',
	100,
	NULL,
	NULL);
INSERT INTO bill_unit VALUES (
	'chkbill2',
	'C',
	'团体结算单(每房)',
	'Group Check Bill(room)',
	200,
	200,
	'V',
	10,
	'd_clg_grp_chkbill_roomno',
	0,
	'F',
	100,
	NULL,
	NULL);


*/