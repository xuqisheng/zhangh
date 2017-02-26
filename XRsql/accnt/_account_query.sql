if exists(select * from sysobjects where name = "account_query")
   drop table account_query;

create table account_query
(
	code				char(3)			not null,							/*����*/
	name1				char(30)			not null,							/*��������*/
	name2				char(30)			null,									/*Ӣ������*/
	pccode			varchar(255)	null,									/*������*/
	argcode			varchar(255)	null,									/*�˵�����*/
	ref				char(1)			null,									/*0:����;1.����;2.����*/
	reason			char(30)			null,									/*�Ż�����*/
	crradjt			char(30)			null,									/*��־*/
	modu_id			char(30)			null,									/*ģ���*/
	tofrom			char(30)			null,									/*ת�˷�ʽ*/
	mode				char(30)			null,									/*��������*/
	billno			char(30)			null,									/*���˵���*/
	amount			char(30)			null,									/*��Χ*/
	query_table		char(30)			null,									/*����Դ*/
	query_where		varchar(255)	null,									/*����*/
	query_order		varchar(255)	null									/*����*/
)
exec   sp_primarykey account_query, code
create unique index index1 on account_query(code)
;
insert account_query values("010", "����", "", null, "-98-99", "1", null, null, null, null, null, null, null, "gltemp", "", " roomno, accnt, number ")
insert account_query values("020", "����", "", null, "+98+99", "2", null, null, null, null, null, null, null, "gltemp", "", " roomno, accnt, number ")
insert account_query values("030", "------------------------------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
insert account_query values("040", "�ֹ���", "", "-000", null, "0", null, "+  +AD+LT+LA", "+02", "-TO-FM", null, null, null, "gltemp", "", " pccode,accnt,servcode ")
insert account_query values("050", "������(����)", "", null, null, "0", null, "+AD+LA", "+02", null, null, null, null, "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("060", "������(����)", "", null, null, "0", null, "+AD+LA", "+02", null, null, null, ">=0", "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("070", "������(����)", "", null, null, "0", null, "+AD+LA", "+02", null, null, null, "<0", "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("080", "------------------------------", null, null, null, null, null, null, null,null, null, null, null, null, null, null)
insert account_query values("090", "�Գ���", "", null, null, "0", null, "+C +CO+CA", null, null, null, null, null, "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("100", "------------------------------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
insert account_query values("110", "�Ż���(����)", "", null, "", "0", null, null, null, null, null, null, null, "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("120", "�Ż���(�ֹ�)", "", "-02", "", "0", null, null, null, null, null, null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("130", "------------------------------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
insert account_query values("140", "���˷���", "", "+000", null, "1", null, "-C -CO", null, null, "+J+j", null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("150", "��ۻ��˷���", "", "+000", null, "1", null, "-C -CO", null, null, "+j", null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("160", "ȫ�ⷿ��(�����÷�)", "", "+000", null, "1", null, "-C -CO", null, null, "+J+j+C", null, null, "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("170", "�������ȫ�췿��", "", "+000", null, "1", null, "-C -CO", null, null, "+N", null, null, "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("180", "������հ��췿��", "", "+000", null, "1", null, "-C -CO", null, null, "+P", null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("190", "�ֹ�����", "", "+010", null, "", null, "-C -CO", null, null, "+S+T", null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("200", "------------------------------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
insert account_query values("220", "������Ŀ", "", null, null, "0", null, null, null, null, null, null, null, "outtemp", " 1=1 ", " pccode,roomno,accnt,servcode ")
insert account_query values("230", "------------------------------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
insert account_query values("240", "����ת��", "", null, null, "0", null, "-CT-LC", null, "+TO+FM", null, null, null, "gltemp", null, " roomno,accnt,tofrom,accntof,number ")
insert account_query values("250", "����ת��", "", null, null, "0", null, "+CT+LC", null, "+TO+FM", null, null, null, "gltemp", null, " roomno,accnt,tofrom,accntof,number ")
insert account_query values("530", "------------------------------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
insert account_query values("540", "�绰ת����ϸ", "", null, null, "0", null, null, "+05", null, null, null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("550", "�ۺ�����ת����ϸ", "", null, null, "0", null, null, "+04", null, null, null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("560", "��������ת����ϸ", "", null, null, "0", null, null, "+06", null, null, null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("799", "----------�û��Զ���----------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
;

insert basecode values ('account_table',	'gltemp',		'��������(����)',	'',	'T',	'F',	10,	'');
insert basecode values ('account_table',	'gltemp_f',		'��������(����)',	'',	'T',	'F',	20,	'');
insert basecode values ('account_table',	'gltemp_a',		'��������(AR��)',	'',	'T',	'F',	30,	'');
insert basecode values ('account_table',	'taccount',		'��������(����)',	'',	'T',	'F',	40,	'');
insert basecode values ('account_table',	'taccount_f',	'��������(����)',	'',	'T',	'F',	50,	'');
insert basecode values ('account_table',	'taccount_a',	'��������(AR��)',	'',	'T',	'F',	60,	'');
insert basecode values ('account_table',	'outtemp',		'��������(����)',	'',	'T',	'F',	70,	'');
insert basecode values ('account_table',	'outtemp_f',	'��������(����)',	'',	'T',	'F',	80,	'');
insert basecode values ('account_table',	'outtemp_a',	'��������(AR��)',	'',	'T',	'F',	90,	'');
insert basecode values ('account_table',	'account',		'��ǰ����(����)',	'',	'T',	'F',	100,	'');
insert basecode values ('account_table',	'account_f',	'��ǰ����(����)',	'',	'T',	'F',	110,	'');
insert basecode values ('account_table',	'account_a',	'��ǰ����(AR��)',	'',	'T',	'F',	120,	'');
insert basecode values ('account_table',	'haccount',		'��ʷ����(����)',	'',	'T',	'F',	130,	'');
insert basecode values ('account_table',	'haccount_f',	'��ʷ����(����)',	'',	'T',	'F',	140,	'');
insert basecode values ('account_table',	'haccount_a',	'��ʷ����(AR��)',	'',	'T',	'F',	150,	'');
insert basecode values ('account_table',	'aaccount',		'��������(����)',	'',	'T',	'F',	160,	'');
insert basecode values ('account_table',	'aaccount_f',	'��������(����)',	'',	'T',	'F',	170,	'');
insert basecode values ('account_table',	'aaccount_a',	'��������(AR��)',	'',	'T',	'F',	180,	'');
//
insert into basecode values ('accntcode_crradjt','AD','������','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','C','�������','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','CO','����','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','CA','����ĵ�����','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','LT','����ת�˱�־','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','LA','��ת�ĵ�����','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','LL','��ת��ת����(����ת��)','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','  ','��ͨ��','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','CT','����ת�˱�־','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','LC','��ת��ת����(����ת��)','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_tofrom','TO','ת������','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_tofrom','FM','ת������','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','J','���˷���(ȫ��)','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','j','���˷���(����)','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','B','��������(ȫ��)','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','b','��������(����)','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','P','���췿��','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','N','ȫ�췿��','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','S','�ֹ�����','', 'T', 'F', 10, '');
