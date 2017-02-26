// ---------------------------------------------------------------------
// phfolio
// ---------------------------------------------------------------------
if exists(select * from sysobjects where name = "phfolio")
	drop table phfolio;
create table phfolio
(
	log_date		datetime	default getdate() not null,	/*�������*/
	inumber		integer	not null,							/*�������к�,��1��ʼ*/
	date			datetime	not null,							/*��ͨʱ��*/
	room			char(8)	not null,							/*�ֻ���*/
	length		char(8)	not null,							/*ͨѶ����*/
	empno			char(10)	not null,							/*����*/
	shift			char(1)	not null,							/*���*/
	phcode		char(20)	not null,							/*Ŀ�ĺ���*/
	calltype		char(1)	not null,							/*ref to phncls*/
	fee			money		not null,							/*�����ܶ�*/
	fee_base		money		not null,							/*������*/
	fee_serve	money		not null,							/*�����*/
	fee_dial		money		not null,							/*���ŷ�*/
	fee_cancel	money		not null,							/*���ŷ�*/
	refer			char(10)	null,									/*��ע*/
	tag			char(1)	null,
	type			char(1)	null,
	trunk			char(3)	null,									/*�м�*/
	address		varchar(20)	 null
)
exec sp_primarykey phfolio,inumber
create unique index index0 on phfolio(inumber)
create index index1 on phfolio(date)
create index index2 on phfolio(room)
create index index3 on phfolio(refer);


// ---------------------------------------------------------------------
// phhfolio
// ---------------------------------------------------------------------
if exists(select * from sysobjects where name = "phhfolio")
	drop table phhfolio;
create table phhfolio
(
	log_date		datetime	default getdate() not null,	/*�������*/
	inumber		integer	not null,							/*�������к�,��1��ʼ*/
	date			datetime	not null,							/*��ͨʱ��*/
	room			char(8)	not null,							/*�ֻ���*/
	length		char(8)	not null,							/*ͨѶ����*/
	empno			char(10)	not null,							/*����*/
	shift			char(1)	not null,							/*���*/
	phcode		char(20)	not null,							/*Ŀ�ĺ���*/
	calltype		char(1)	not null,							/*ref to phncls*/
	fee			money		not null,							/*�����ܶ�*/
	fee_base		money		not null,							/*������*/
	fee_serve	money		not null,							/*�����*/
	fee_dial		money		not null,							/*���ŷ�*/
	fee_cancel	money		not null,							/*���ŷ�*/
	refer			char(10)	null,									/*��ע*/
	tag			char(1)	null,
	type			char(1)	null,
	trunk			char(3)	null,									/*�м�*/
	address		varchar(20)	 null
)
exec sp_primarykey phhfolio,inumber
create index index0 on phhfolio(inumber)
create index index1 on phhfolio(date)
create index index2 on phhfolio(room)
create index index3 on phhfolio(refer);
