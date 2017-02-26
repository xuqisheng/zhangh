// fixed_charge�����
if exists(select * from sysobjects where type ="U" and name = "fixed_charge")
   drop table fixed_charge;

create table fixed_charge
(
	accnt					char(10)			not null,								/* �˺� */
	number				integer			not null,								/*  */
	pccode				char(5)			not null,								/* ������ */
	argcode				char(3)			default '' null,						/* �ı���(��ӡ���˵��Ĵ���) */
	amount				money				default 0 not null,					/* ��� */
	quantity				money				default 0 not null,					/* ���� */
	starting_time		datetime			default '2000-1-1' not null,					/* ��Ч����ʼ */
	closing_time		datetime			default '2000-1-1 23:59:59' not null,		/* ��Ч�ڽ�ֹ */
	cby					char(10)			not null,								/* ���� */
	changed				datetime			default getdate() not null,		/* ʱ�� */
	logmark				integer			default 0 not null
);
exec sp_primarykey fixed_charge, accnt, number
create unique index index1 on fixed_charge(accnt, number)
;
// fixed_charge_log�����
if exists(select * from sysobjects where type ="U" and name = "fixed_charge_log")
   drop table fixed_charge_log;

create table fixed_charge_log
(
	accnt					char(10)			not null,								/* �˺� */
	number				integer			not null,								/*  */
	pccode				char(5)			not null,								/* ������ */
	argcode				char(3)			default '' null,						/* �ı���(��ӡ���˵��Ĵ���) */
	amount				money				default 0 not null,					/* ��� */
	quantity				money				default 0 not null,					/* ���� */
	starting_time		datetime			default '2000-1-1' not null,					/* ��Ч����ʼ */
	closing_time		datetime			default '2000-1-1 23:59:59' not null,		/* ��Ч�ڽ�ֹ */
	cby					char(10)			not null,								/* ���� */
	changed				datetime			default getdate() not null,		/* ʱ�� */
	logmark				integer			default 0 not null
);
exec sp_primarykey fixed_charge_log, accnt, number, logmark
create unique index index1 on fixed_charge_log(accnt, number, logmark)
;
//insert fixed_charge values ('SVR', '1', '�����', '', '002', 0.1, '0010', '*', '', '0', '0', '2000-1-1', '2000-1-1 23:59:59', '', '', 0, 'HRY', getdate(), 1);
//insert fixed_charge values ('TAX', '5', '�ǽ���', '', '005', 0.05, '0010', '*', '', '0', '0', '2000-1-1', '2000-1-1 23:59:59', '', '', 0, 'HRY', getdate(), 1);
//insert fixed_charge values ('BFA', '6', 'ӳ����', '', '100', 68, '0000', '*', '', '0', '0', '2000-1-1', '2000-1-1 23:59:59', '100;110;120', '', 200, 'HRY', getdate(), 1);
//
//// fixed_charge��ϸ��(˵��:��ʹʹ��Pakcage,��Account�ж���һ�н��Ϊ�����ϸ��)
//// Master.LastinumbתΪfixed_charge.Numberָ��
//if exists(select * from sysobjects where type ="U" and name = "fixed_charge_detail")
//   drop table fixed_charge_detail;
//
//create table fixed_charge_detail
//(
//	accnt					char(10)			not null,								/* �˺� */
//	number				integer			not null,								/* �ؼ��� */
//	roomno				char(5)			default '' not null,					/* ���� */
//	code					char(4)			default '' not null,					/* ���� */
//	descript				char(30)			not null,								/* ���� */
//	descript1			char(30)			default '' not null,					/* Ӣ������ */
//	starting_time		datetime			default '2000-1-1' not null,					/* ��Ч����ʼ */
//	closing_time		datetime			default '2038-1-1 23:59:59' not null,		/* �ڶ���������Ч�ڽ�ֹ;��ת�����Ƿ���ʱ�� */
//	pccodes				varchar(255)	default '' not null,					/* ���Թ�����Ӫҵ������� */
//	pos_pccode			char(3)			default '' not null,					/* �����޶�󣬼���Account��Ӫҵ������� */
//	charge				money				default 0 not null,					/* ��ת�˵Ľ�� */
//	credit				money				default 0 not null,					/* ����ת�˵Ľ�� */
//	posted_accnt		char(10)			default '' not null,					/* ʵ��ת�˵��˺� */
//	posted_roomno		char(5)			default '' not null,					/* ʵ��ת�˵ķ��� */
//	posted_number		integer			default 0 not null,					/* ��Ӧ�ؼ���(ʵ��ʹ�õ�����һ��fixed_charge) */
//	tag					char(1)			default '0' not null,				/* ��־��0.�Զ������fixed_charge(δ��);
//																										1.�Զ������fixed_charge(������һ����);
//																										2.�Զ������fixed_charge(���ù�);
//																										5.�Զ������fixed_charge(�ѳ���);
//																										9.ʵ��ʹ��fixed_charge����ϸ */
//	account_accnt		char(10)			default '' not null,					/* �˺�(��ӦAccount.Accnt) */
//	account_number		integer			default 0 not null					/* �˴�(��ӦAccount.Number) */
//);
//exec sp_primarykey fixed_charge_detail, accnt, number
//create unique index index1 on fixed_charge_detail(accnt, number)
//create index index2 on fixed_charge_detail(accnt, account_number)
//create index index3 on fixed_charge_detail(accnt, tag, starting_time, closing_time)
//;
//
//insert fixed_charge_detail values ('3012028', 1, '1219', 'BFA', '���', '', '2001/1/1', '2003/12/31', '100;110;120', '', 0, 200, '', '', 0, '0', '3012028', 1);
//
//insert basecode values ('fixed_charge_rule_post', '*', 'ÿ������', 'Post Every Night', 'T', 'F', 10, '');
//insert basecode values ('fixed_charge_rule_post', 'B', '���ڵ���ĵ�����������', 'Post on Arrival Night', 'T', 'F', 20, '');
//insert basecode values ('fixed_charge_rule_post', 'E', '�������һ����������', 'Post on Last Night', 'T', 'F', 30, '');
//insert basecode values ('fixed_charge_rule_post', 'W', '��һ���е�ĳ��������', 'Post on Certain Nights of the Week', 'T', 'F', 40, '');
//insert basecode values ('fixed_charge_rule_post', '-B', '���˵����������ÿ������', 'PostEvery Night Except Arrival Night', 'T', 'F', 50, '');
//insert basecode values ('fixed_charge_rule_post', '-E', '�������һ����ÿ������', 'PostEvery Night Except Last Night', 'T', 'F', 60, '');
//insert basecode values ('fixed_charge_rule_post', 'M', '����ͷβ������ÿ������', 'Do NOT Post on Arrival and Last Night', 'T', 'F', 70, '');
////
//insert basecode values ('fixed_charge_rule_4', '0', '�̶�����', 'Flat Rate', 'T', 'F', 10, '');
//insert basecode values ('fixed_charge_rule_4', '1', '��������ȡ', 'Per Person', 'T', 'F', 20, '');
//insert basecode values ('fixed_charge_rule_4', '2', '����������ȡ', 'Per Adult', 'T', 'F', 30, '');
//insert basecode values ('fixed_charge_rule_4', '3', '����ͯ����ȡ', 'Per Child', 'T', 'F', 40, '');
////
//insert basecode values ('fixed_charge_type', '1', '���', 'Breakfast', 'T', 'F', 10, '');
//insert basecode values ('fixed_charge_type', '2', '�в�', 'Lunch', 'T', 'F', 20, '');
//insert basecode values ('fixed_charge_type', '3', '���', 'Dinner', 'T', 'F', 30, '');
//insert basecode values ('fixed_charge_type', '4', '��ϲ�', 'Miscellaneous', 'T', 'F', 40, '');
//insert basecode values ('fixed_charge_type', '5', '�����', 'Service Charge', 'T', 'F', 50, '');
//insert basecode values ('fixed_charge_type', '6', '�ǽ���', 'Tax', 'T', 'F', 60, '');
//