
if exists(select * from sysobjects where name = "billmode")
	drop table billmode
;
create table billmode
(
	code			char(3)			default '' not null,				/* 代码 */
	descript		char(20)			default '' not null,				/* 描述 */
	printtype   char(10)       default '' not null,          /* 账单类别*/
	printname   char(10)       default '' not null,          /* 打印机名称*/
	modu        char(30)       default '#' not null          /* 适用模快*/     
)
exec sp_primarykey billmode, code
create unique index index1 on billmode(code)
;
INSERT INTO billmode VALUES (	'1',	'接待单据',	'rsvbill',	'bill',	'01#25#11#');
INSERT INTO billmode VALUES (	'11',	'预定单',	'rsvbill',	'bill',	'01#25#11#');
INSERT INTO billmode VALUES (	'12',	'登记单',	'regbill',	'bill',	'01#25#11#');
INSERT INTO billmode VALUES (	'13',	'信封',	'envelop',	'bill',	'01#25#11#');
INSERT INTO billmode VALUES (	'2',	'前台帐单',	'abill',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'21',	'明细帐目',	'abill',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'25',	'按费用分类',	'abill',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'26',	'按日期分类',	'abill',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'27',	'按房间费用分类',	'abill',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'28',	'按成员分类',	'abill',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'3',	'前台发票收据',	'acheck',	'check',	'01#03#02#');
INSERT INTO billmode VALUES (	'31',	'标准发票',	'acheck',	'check',	'01#03#02#');
INSERT INTO billmode VALUES (	'32',	'预收收据',	'earnest',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'6',	'餐饮娱乐',	'pbill',	'bill',	'04#');
INSERT INTO billmode VALUES (	'61',	'明细帐单',	'pbill',	'bill',	'04#');
INSERT INTO billmode VALUES (	'62',	'汇总帐单',	'pbill',	'bill',	'04#');
INSERT INTO billmode VALUES (	'65',	'发票',	'pcheck',	'check',	'04#');
