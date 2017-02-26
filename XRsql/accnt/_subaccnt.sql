// ���˻������
if exists(select * from sysobjects where type ="U" and name = "subaccnt")
   drop table subaccnt;

create table subaccnt
(
	roomno				char(5)			default '' not null,				/* ���� */
	haccnt				char(7)			default '' not null,				/* ���˺� */
	accnt					char(10)			not null,							/* �˺� */
	subaccnt				integer			default 0 not null,				/* ���˺�*/
	to_roomno			char(5)			default '' not null,				/* ת�˷��� */
	to_accnt				char(10)			default '' not null,				/* ת���˺� */
	name					char(50)			not null,							/* ���� */
	pccodes				varchar(255)	not null,							/* ������ */
	starting_time		datetime			default '2000/1/1' not null,	/* ��Ч����ʼ */
	closing_time		datetime			default '2038/1/1' not null,	/* ��Ч�ڽ�ֹ */
	cby					char(10)			not null,							/* ���� */
	changed				datetime			default getdate() not null,	/* ʱ�� */
	type					char(1)			default '1' not null,			/* ��(AB)�˻������: 
																							0.�������
																							2.����Ϊ��Ա����(ֻ�������������У���Ա�Դ�Ϊģ��)
																							5.���˻�(�Զ�ת�˲�����˻�) */
	tag					char(1)			default '0' not null,			/* 0.ϵͳ�Զ�����(�����޸�)
																							1.ϵͳ�Զ�����(���޸ġ�����ɾ��)
																							2.�˹�����(���޸�) */
	paycode				char(5)			default '' not null,				/* ���ʽ */
	ref					varchar(50)		default '' not null,				/* ��ע */
	logmark				integer			default 0 not null
);
exec sp_primarykey subaccnt, accnt, subaccnt, type, tag, starting_time, closing_time
create unique index index1 on subaccnt(accnt, subaccnt, type, tag, starting_time, closing_time)
create index index2 on subaccnt(to_accnt, type)
create index index3 on subaccnt(accnt, haccnt)
;
// ���˻�log�����
if exists(select * from sysobjects where type ="U" and name = "subaccnt_log")
   drop table subaccnt_log;

create table subaccnt_log
(
	roomno				char(5)			default '' not null,				/* ���� */
	haccnt				char(7)			default '' not null,				/* ���˺� */
	accnt					char(10)			not null,							/* �˺� */
	subaccnt				integer			default 0 not null,				/* ���˺�*/
	to_roomno			char(5)			default '' not null,				/* ת�˷��� */
	to_accnt				char(10)			default '' not null,				/* ת���˺� */
	name					char(50)			not null,							/* ���� */
	pccodes				varchar(255)	not null,							/* ������ */
	starting_time		datetime			default '2000/1/1' not null,	/* ��Ч����ʼ */
	closing_time		datetime			default '2038/1/1' not null,	/* ��Ч�ڽ�ֹ */
	cby					char(10)			not null,							/* ���� */
	changed				datetime			default getdate() not null,	/* ʱ�� */
	type					char(1)			default '1' not null,			/* ��(AB)�˻������: 
																							0.�������
																							2.����Ϊ��Ա����(ֻ�������������У���Ա�Դ�Ϊģ��)
																							5.���˻�(�Զ�ת�˲�����˻�) */
	tag					char(1)			default '0' not null,			/* 0.ϵͳ�Զ�����(�����޸�)
																							1.ϵͳ�Զ�����(���޸ġ�����ɾ��)
																							2.�˹�����(���޸�) */
	paycode				char(5)			default '' not null,				/* ���ʽ */
	ref					varchar(50)		default '' not null,				/* ��ע */
	logmark				integer			default 0 not null
);
exec sp_primarykey subaccnt_log, accnt, subaccnt, type, logmark
create unique index index1 on subaccnt_log(accnt, subaccnt, type, logmark)
;
//insert subaccnt select isnull(b.roomno, ''), a.accnt, convert(integer,isnull(a.subaccnt, '0')) + 1, isnull(c.roomno, ''),
//	a.to_accnt, a.name,a.pccodes,'2000/1/1','2038/1/1', a.empno,a.date, a.type, a.tag, '', '', 1
//	from foxhis3.dbo.subaccnt a, foxhis3.dbo.master b, foxhis3.dbo.master c
//	where a.accnt *= b.accnt and a.accnt *= c.accnt;
//delete subaccnt where type in ('2', '4');
//update subaccnt set type = '5' where type = '6';
//update subaccnt set pccodes = '+', tag = '0' where type = '5' and subaccnt = 1;
//update subaccnt set tag = '2' where type = '5' and subaccnt != 1;
////
//insert basecode (cat, code, descript, descript1)
//	select 'deptno'+type, deptno, deptname, isnull(descript1,'') from deptdef;
if exists(select * from sysobjects where type ="U" and name = "hsubaccnt")
   drop table hsubaccnt;

create table hsubaccnt
(
	roomno				char(5)			default '' not null,				/* ���� */
	haccnt				char(7)			default '' not null,				/* ���˺� */
	accnt					char(10)			not null,							/* �˺� */
	subaccnt				integer			default 0 not null,				/* ���˺�*/
	to_roomno			char(5)			default '' not null,				/* ת�˷��� */
	to_accnt				char(10)			default '' not null,				/* ת���˺� */
	name					char(50)			not null,							/* ���� */
	pccodes				varchar(255)	not null,							/* ������ */
	starting_time		datetime			default '2000/1/1' not null,	/* ��Ч����ʼ */
	closing_time		datetime			default '2038/1/1' not null,	/* ��Ч�ڽ�ֹ */
	cby					char(10)			not null,							/* ���� */
	changed				datetime			default getdate() not null,	/* ʱ�� */
	type					char(1)			default '1' not null,			/* ��(AB)�˻������: 
																							0.�������
																							2.����Ϊ��Ա����(ֻ�������������У���Ա�Դ�Ϊģ��)
																							5.���˻�(�Զ�ת�˲�����˻�) */
	tag					char(1)			default '0' not null,			/* 0.ϵͳ�Զ�����(�����޸�)
																							1.ϵͳ�Զ�����(���޸ġ�����ɾ��)
																							2.�˹�����(���޸�) */
	paycode				char(5)			default '' not null,				/* ���ʽ */
	ref					varchar(50)		default '' not null,				/* ��ע */
	logmark				integer			default 0 not null
);
exec sp_primarykey hsubaccnt, accnt, subaccnt, type, tag, starting_time, closing_time
create unique index index1 on hsubaccnt(accnt, subaccnt, type, tag, starting_time, closing_time)
create index index2 on hsubaccnt(to_accnt, type)
create index index3 on hsubaccnt(accnt, haccnt)
;