/* �Ĵ��������ۺϱ��� */

if exists (select * from sysobjects where name ='sjourrep' and type ='U')
	drop table sjourrep;
create table sjourrep
(
	date			datetime			not null,
	tag			char(1)			default '' not null, 
	deptno		char(5)			not null,
	pccode		char(5)			default '' not null,
	descript		char(24)			not null,
	balance_l	money				default 0 not null,			/* ����δ���� */
	day0			money				default 0 not null,			/* ���շ����� */
	month0		money				default 0 not null,			/* ���·����� */
	day1			money				default 0 not null,			/* ���ռ������ */
	month1		money				default 0 not null,			/* ���¼������ */
	day2			money				default 0 not null,			/* ���ն����ۿ� */
	month2		money				default 0 not null,			/* ���¶����ۿ� */
	day3			money				default 0 not null,
	month3		money				default 0 not null,
	day8			money				default 0 not null,			/* ����ʵ�ռ��˿� */
	month8		money				default 0 not null,			/* ����ʵ�ռ��˿� */
	day9			money				default 0 not null,			/* ����ʵ�տ� */
	month9		money				default 0 not null,			/* ����ʵ�տ� */
	balance_t	money				default 0 not null			/* ����δ���� */
);
exec sp_primarykey sjourrep, tag, deptno, pccode
create unique index index1 on sjourrep(tag, deptno, pccode)
;

if exists (select * from sysobjects where name ='ysjourrep' and type ='U')
	drop table ysjourrep;
create table ysjourrep
(
	date			datetime			not null,
	tag			char(1)			default '' not null, 
	deptno		char(5)			not null,
	pccode		char(5)			default '' not null,
	descript		char(24)			not null,
	balance_l	money				default 0 not null,			/* ����δ���� */
	day0			money				default 0 not null,			/* ���շ����� */
	month0		money				default 0 not null,			/* ���·����� */
	day1			money				default 0 not null,			/* ���ռ������ */
	month1		money				default 0 not null,			/* ���¼������ */
	day2			money				default 0 not null,			/* ���ն����ۿ� */
	month2		money				default 0 not null,			/* ���¶����ۿ� */
	day3			money				default 0 not null,
	month3		money				default 0 not null,
	day8			money				default 0 not null,			/* ����ʵ�ռ��˿� */
	month8		money				default 0 not null,			/* ����ʵ�ռ��˿� */
	day9			money				default 0 not null,			/* ����ʵ�տ� */
	month9		money				default 0 not null,			/* ����ʵ�տ� */
	balance_t	money				default 0 not null			/* ����δ���� */
);
exec sp_primarykey ysjourrep, date, tag, deptno, pccode
create unique index index1 on ysjourrep(date, tag, deptno, pccode)
;
