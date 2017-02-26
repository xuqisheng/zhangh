
if exists(select * from sysobjects where name = "billmode")
	drop table billmode
;
create table billmode
(
	code			char(3)			default '' not null,				/* ���� */
	descript		char(20)			default '' not null,				/* ���� */
	printtype   char(10)       default '' not null,          /* �˵����*/
	printname   char(10)       default '' not null,          /* ��ӡ������*/
	modu        char(30)       default '#' not null          /* ����ģ��*/     
)
exec sp_primarykey billmode, code
create unique index index1 on billmode(code)
;
INSERT INTO billmode VALUES (	'1',	'�Ӵ�����',	'rsvbill',	'bill',	'01#25#11#');
INSERT INTO billmode VALUES (	'11',	'Ԥ����',	'rsvbill',	'bill',	'01#25#11#');
INSERT INTO billmode VALUES (	'12',	'�Ǽǵ�',	'regbill',	'bill',	'01#25#11#');
INSERT INTO billmode VALUES (	'13',	'�ŷ�',	'envelop',	'bill',	'01#25#11#');
INSERT INTO billmode VALUES (	'2',	'ǰ̨�ʵ�',	'abill',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'21',	'��ϸ��Ŀ',	'abill',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'25',	'�����÷���',	'abill',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'26',	'�����ڷ���',	'abill',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'27',	'��������÷���',	'abill',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'28',	'����Ա����',	'abill',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'3',	'ǰ̨��Ʊ�վ�',	'acheck',	'check',	'01#03#02#');
INSERT INTO billmode VALUES (	'31',	'��׼��Ʊ',	'acheck',	'check',	'01#03#02#');
INSERT INTO billmode VALUES (	'32',	'Ԥ���վ�',	'earnest',	'bill',	'01#03#02#');
INSERT INTO billmode VALUES (	'6',	'��������',	'pbill',	'bill',	'04#');
INSERT INTO billmode VALUES (	'61',	'��ϸ�ʵ�',	'pbill',	'bill',	'04#');
INSERT INTO billmode VALUES (	'62',	'�����ʵ�',	'pbill',	'bill',	'04#');
INSERT INTO billmode VALUES (	'65',	'��Ʊ',	'pcheck',	'check',	'04#');
