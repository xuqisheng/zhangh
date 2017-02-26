/* �����Ż�,�ۿ�,�����ϸ */
if exists (select * from sysobjects where name ='discount_detail' and type ='U')
	drop table discount_detail;

create table discount_detail
(
	date				datetime,										/* Ӫҵ���� */
	modu_id			char(2)	not null,							/* ģ��� */
	accnt				char(10)	not null,							/* �ʺ�(ǰ̨)
																				�˵���(�ۺ�����)
																				��ˮ��(��������) */
	number			integer	default 0 not null,				/* �д� */
	pccode			char(5)	not null,							/* ������ */
	charge			money		default 0 not null,				/* ��� */
	paycode			char(5)	default '' not null,				/* ���ʽ(�ۿ�Ϊ'ZZZ') */
	key0				char(3)	default '' not null,				/* �Ż���Ա���� */
	billno			char(10)	default '' not null,				/* ���ʵ���(ǰ̨����) */
)
exec sp_primarykey discount_detail, modu_id, accnt, number, pccode, paycode, key0, billno
create unique index index1 on discount_detail(modu_id, accnt, number, pccode, paycode, key0, billno)
;

/* �����Ż�,�ۿ�,�����ϸ */
if exists (select * from sysobjects where name ='ydiscount_detail' and type ='U')
	drop table ydiscount_detail;

create table ydiscount_detail
(
	date				datetime,										/* Ӫҵ���� */
	modu_id			char(2)	not null,							/* ģ��� */
	accnt				char(10)	not null,							/* �ʺ�(ǰ̨)
																				�˵���(�ۺ�����)
																				��ˮ��(��������) */
	number			integer	default 0 not null,				/* �д� */
	pccode			char(5)	not null,							/* ������ */
	charge			money		default 0 not null,				/* ��� */
	paycode			char(5)	default '' not null,				/* ���ʽ(�ۿ�Ϊ'ZZZ') */
	key0				char(3)	default '' not null,				/* �Ż���Ա���� */
	billno			char(10)	default '' not null,				/* ���ʵ���(ǰ̨����) */
)
exec sp_primarykey ydiscount_detail, date, modu_id, accnt, number, pccode, paycode, key0, billno
create unique index index1 on ydiscount_detail(date, modu_id, accnt, number, pccode, paycode, key0, billno)
;

/* �����Ż�,�ۿ�,������ܱ� */
if exists (select * from sysobjects where name ='discount' and type ='U')
	drop table discount;

create table discount
(
	date				datetime,										/* Ӫҵ���� */
	key0				char(3)	not null,							/* �Ż���Ա���� */
	paycode			char(5)	default '' not null,				/* ���ʽ(�ۿ�Ϊ'ZZZ') */
	pccode			char(5)	not null,							/* ������ */
	day				money		default 0 not null,				/* ���� */
	month				money		default 0 not null,				/* ���� */
	year				money		default 0 not null				/* ���� */
)
exec sp_primarykey discount, key0, paycode, pccode
create unique index index1 on discount(key0, paycode, pccode)
;

/* �����Ż�,�ۿ�,������ܱ� */
if exists (select * from sysobjects where name ='ydiscount' and type ='U')
	drop table ydiscount;

create table ydiscount
(
	date				datetime,										/* Ӫҵ���� */
	key0				char(3)	not null,							/* �Ż���Ա���� */
	paycode			char(5)	default '' not null,				/* ���ʽ(�ۿ�Ϊ'ZZZ') */
	pccode			char(5)	not null,							/* ������ */
	day				money		default 0 not null,				/* ���� */
	month				money		default 0 not null,				/* ���� */
	year				money		default 0 not null				/* ���� */
)
exec sp_primarykey ydiscount, date, key0, paycode, pccode
create unique index index1 on ydiscount(date, key0, paycode, pccode)
;

/* ��ӡ����ʱ��*/

if exists (select * from sysobjects where name = 'pdiscount' and type = 'U')
	drop table pdiscount;
create table pdiscount
(
	pc_id		char(4), 
	key0		char(3), 
	descript	char(16)	default '' null,
	v1			money		default 0  not null, 
	v2			money		default 0  not null, 
	v3			money		default 0  not null, 
	v4			money		default 0  not null, 
	v5			money		default 0  not null, 
	v6			money		default 0  not null, 
	v7			money		default 0  not null, 
	v8			money		default 0  not null, 
	v9			money		default 0  not null, 
	v10		money		default 0  not null, 
	v11		money		default 0  not null, 
	v12		money		default 0  not null, 
	v13		money		default 0  not null, 
	v14		money		default 0  not null, 
	v15		money		default 0  not null, 
	v16		money		default 0  not null, 
	v17		money		default 0  not null, 
	v18		money		default 0  not null, 
	v19		money		default 0  not null, 
	v20		money		default 0  not null, 
	vtl		money		default 0  not null, 
)
exec sp_primarykey pdiscount, pc_id, key0
create unique index index1 on pdiscount(pc_id, key0)
;