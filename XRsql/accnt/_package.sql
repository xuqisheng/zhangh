// Package�����
if exists(select * from sysobjects where type ="U" and name = "package")
   drop table package;

create table package
(
	code					char(8)			not null,								/* ���� */
	type					char(1)			not null,								/* ��� */
	descript				char(30)			not null,								/* ���� */
	descript1			char(30)			default '' not null,					/* Ӣ������ */
	pccode				char(5)			not null,								/* ������ */
	quantity				money				default 1 not null,					/* ���� */
	amount				money				default 0 not null,					/* ��� */
	rule_calc			char(10)			default '0000000000' not null,	/* ���㷽ʽѡ��
																								��һλ:0.���ù���Package_Detail��;1.���ù���Account��
																								�ڶ�λ:0.include;1.exclude
																								����λ:0.�����;1.������
																								����λ:0.�̶����;1.��������;2.������;3.����ͯ
																								����λ:0.�������;1.���ⲻ��
																								��ʮλ:���Գɱ������ѵĸ���(��������) */
	rule_post			char(3)			not null,								/* ���˷�ʽ */
	rule_parm			char(30)			default '' not null,					/* �������� */
	starting_days		integer			default 1 not null,					/* �����˺�ĵڼ��쿪ʼ��Ч */
	closing_days		integer			default 1 not null,					/* �ܵ���Ч���� */
	starting_time		char(8)			default '00:00:00' not null,		/* ÿ�����Ч������ʼʱ�� */
	closing_time		char(8)			default '23:59:59' not null,		/* ÿ�����Ч���˽�ֹʱ�� */
	pccodes				varchar(255)	default '' not null,					/* ���Թ�����Ӫҵ������� */
	pos_pccode			char(5)			default '' not null,					/* �����޶�󣬼���Account��Ӫҵ������� */
	credit				money				default 0 not null,					/* ����ת�˵Ľ�� */
	accnt					char(10)			default '' not null,					/* �����˻����˺� */
	profit				char(5)			default '' not null,
	loss					char(5)			default '' not null,
	cby					char(10)			not null,								/* ���� */
	changed				datetime			default getdate() not null,		/* ʱ�� */
	logmark				integer			default 0 not null
);
exec sp_primarykey package, code
create unique index index1 on package(code)
;
//insert package values ('SVR', '1', '�����', '', '002', 1, 0.1, '00101', '*', '', 1, 1, '00:00:00', '23:59:59', '', '', 0, 'HRY', getdate(), 1);
//insert package values ('TAX', '5', '�ǽ���', '', '005', 1, 0.05, '00101', '*', '', 1, 1, '00:00:00', '23:59:59', '', '', 0, 'HRY', getdate(), 1);
//insert package values ('BFA', '6', 'ӳ����', '', '100', 1, 68, '00000', '*', '', 1, 1, '00:00:00', '23:59:59', '100;110;120', '', 200, 'HRY', getdate(), 1);

// Package��ϸ��(˵��:��ʹʹ��Pakcage,��Account�ж���һ�н��Ϊ�����ϸ��)
// Master.LastinumbתΪPackage.Numberָ��
if exists(select * from sysobjects where type ="U" and name = "package_detail")
   drop table package_detail;
create table package_detail
(
	accnt					char(10)			not null,								/* �˺� */
	number				integer			not null,								/* �ؼ��� */
	roomno				char(5)			default '' not null,					/* ���� */
	code					char(8)			default '' not null,					/* ���� */
	descript				char(30)			not null,								/* ���� */
	descript1			char(30)			default '' not null,					/* Ӣ������ */
	bdate					datetime			not null,								/*  */
	starting_date		datetime			default '2000/1/1' not null,		/* ��Ч��ʼ���� */
	closing_date		datetime			default '2038/12/31' not null,	/* ��Ч��ֹ���� */
	starting_time		char(8)			default '00:00:00' not null,		/* ÿ�����Ч������ʼʱ�� */
	closing_time		char(8)			default '23:59:59' not null,		/* ÿ�����Ч���˽�ֹʱ�� */
	pccodes				varchar(255)	default '' not null,					/* ���Թ�����Ӫҵ������� */
	pos_pccode			char(5)			default '' not null,					/* �����޶�󣬼���Account��Ӫҵ������� */
	quantity				money				default 0 not null,					/* ���� */
	charge				money				default 0 not null,					/* ��ת�˵Ľ�� */
	credit				money				default 0 not null,					/* ����ת�˵Ľ�� */
	posted_accnt		char(10)			default '' not null,					/* ʵ��ת�˵��˺� */
	posted_roomno		char(5)			default '' not null,					/* ʵ��ת�˵ķ��� */
	posted_number		integer			default 0 not null,					/* ��Ӧ�ؼ���(ʵ��ʹ�õ�����һ��Package) */
	tag					char(1)			default '0' not null,				/* ��־��0.�Զ������Package(δ��);
																										1.�Զ������Package(������һ����);
																										2.�Զ������Package(���ù�);
																										5.�Զ������Package(�ѳ���);
																										9.ʵ��ʹ��Package����ϸ */
	account_accnt		char(10)			default '' not null,					/* �˺�(��ӦAccount.Accnt) */
	account_number		integer			default 0 not null,					/* �˴�(��ӦAccount.Number) */
	account_date		datetime			default getdate() not null,		/* �˺�(��ӦAccount.log_date) */
	flag					char(1)			default 'F' 	not null				/* ҹ�������־ */
);
exec sp_primarykey package_detail, accnt, number
create unique index index1 on package_detail(accnt, number)
create index index2 on package_detail(accnt, account_accnt)
create index index3 on package_detail(accnt, tag, starting_date, closing_date, starting_time, closing_time)
;
if exists(select * from sysobjects where type ="U" and name = "hpackage_detail")
   drop table hpackage_detail;
create table hpackage_detail
(
	accnt					char(10)			not null,								/* �˺� */
	number				integer			not null,								/* �ؼ��� */
	roomno				char(5)			default '' not null,					/* ���� */
	code					char(8)			default '' not null,					/* ���� */
	descript				char(30)			not null,								/* ���� */
	descript1			char(30)			default '' not null,					/* Ӣ������ */
	bdate					datetime			not null,								/*  */
	starting_date		datetime			default '2000/1/1' not null,		/* ��Ч��ʼ���� */
	closing_date		datetime			default '2038/12/31' not null,	/* ��Ч��ֹ���� */
	starting_time		char(8)			default '00:00:00' not null,		/* ÿ�����Ч������ʼʱ�� */
	closing_time		char(8)			default '23:59:59' not null,		/* ÿ�����Ч���˽�ֹʱ�� */
	pccodes				varchar(255)	default '' not null,					/* ���Թ�����Ӫҵ������� */
	pos_pccode			char(5)			default '' not null,					/* �����޶�󣬼���Account��Ӫҵ������� */
	quantity				money				default 0 not null,					/* ���� */
	charge				money				default 0 not null,					/* ��ת�˵Ľ�� */
	credit				money				default 0 not null,					/* ����ת�˵Ľ�� */
	posted_accnt		char(10)			default '' not null,					/* ʵ��ת�˵��˺� */
	posted_roomno		char(5)			default '' not null,					/* ʵ��ת�˵ķ��� */
	posted_number		integer			default 0 not null,					/* ��Ӧ�ؼ���(ʵ��ʹ�õ�����һ��Package) */
	tag					char(1)			default '0' not null,				/* ��־��0.�Զ������Package(δ��);
																										1.�Զ������Package(������һ����);
																										2.�Զ������Package(���ù�);
																										5.�Զ������Package(�ѳ���);
																										9.ʵ��ʹ��Package����ϸ */
	account_accnt		char(10)			default '' not null,					/* �˺�(��ӦAccount.Accnt) */
	account_number		integer			default 0 not null,					/* �˴�(��ӦAccount.Number) */
	account_date		datetime			default getdate() not null,		/* �˺�(��ӦAccount.log_date) */
	flag					char(1)			default 'F' 	not null				/* ҹ�������־ */
);
exec sp_primarykey hpackage_detail, accnt, number
create unique index index1 on hpackage_detail(accnt, number)
create index index2 on hpackage_detail(accnt, account_accnt)
create index index3 on hpackage_detail(accnt, tag, starting_date, closing_date, starting_time, closing_time)
;

//insert package_detail values ('3012018', 1, '1210', 'BFA', '���', '', '2001/1/1', '2003/12/31', '00:00:00', '23:59:59', '100;110;120', '', 0, 100, '', '', 0, '0', '3012018', 1, getdate());
//insert package_detail values ('3012028', 1, '1219', 'BFA', '���', '', '2001/1/1', '2003/12/31', '00:00:00', '23:59:59', '100;110;120', '', 0, 100, '', '', 0, '0', '3012028', 1, getdate());

insert basecode values ('package_rule_post', '*', 'ÿ������', 'Post Every Night', 'T', 'F', 10, '');
insert basecode values ('package_rule_post', 'B', '���ڵ���ĵ�����������', 'Post on Arrival Night', 'T', 'F', 20, '');
insert basecode values ('package_rule_post', 'E', '�������һ����������', 'Post on Last Night', 'T', 'F', 30, '');
insert basecode values ('package_rule_post', 'W', '��һ���е�ĳ��������', 'Post on Certain Nights of the Week', 'T', 'F', 40, '');
insert basecode values ('package_rule_post', '-B', '���˵����������ÿ������', 'PostEvery Night Except Arrival Night', 'T', 'F', 50, '');
insert basecode values ('package_rule_post', '-E', '�������һ����ÿ������', 'PostEvery Night Except Last Night', 'T', 'F', 60, '');
insert basecode values ('package_rule_post', 'M', '����ͷβ������ÿ������', 'Do NOT Post on Arrival and Last Night', 'T', 'F', 70, '');
//
insert basecode values ('package_rule_4', '0', '�̶�����', 'Flat Rate', 'T', 'F', 10, '');
insert basecode values ('package_rule_4', '1', '��������ȡ', 'Per Person', 'T', 'F', 20, '');
insert basecode values ('package_rule_4', '2', '����������ȡ', 'Per Adult', 'T', 'F', 30, '');
insert basecode values ('package_rule_4', '3', '����ͯ����ȡ', 'Per Child', 'T', 'F', 40, '');
//
insert basecode values ('package_type', '1', '���', 'Breakfast', 'T', 'F', 10, '');
insert basecode values ('package_type', '2', '�в�', 'Lunch', 'T', 'F', 20, '');
insert basecode values ('package_type', '3', '���', 'Dinner', 'T', 'F', 30, '');
insert basecode values ('package_type', '4', '��ϲ�', 'Miscellaneous', 'T', 'F', 40, '');
insert basecode values ('package_type', '5', '�����', 'Service Charge', 'T', 'F', 50, '');
insert basecode values ('package_type', '6', '�ǽ���', 'Tax', 'T', 'F', 60, '');
//
INSERT INTO sysdefault VALUES (	'd_gl_code_package_edit',	'rule_post',	'*');
INSERT INTO sysdefault VALUES (	'd_gl_code_package_edit',	'rule_4',	'0');
INSERT INTO sysdefault VALUES (	'd_gl_code_package_edit',	'type',	'1');
INSERT INTO sysdefault VALUES (	'd_gl_code_package_edit',	'quantity',	'1');
INSERT INTO sysdefault VALUES (	'd_gl_code_package_edit',	'amount',	'0');
