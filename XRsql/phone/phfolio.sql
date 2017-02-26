// ---------------------------------------------------------------------
// phfolio
// ---------------------------------------------------------------------
if exists(select * from sysobjects where name = "phfolio")
	drop table phfolio;
create table phfolio
(
	log_date		datetime	default getdate() not null,	/*入库日期*/
	inumber		integer	not null,							/*物理序列号,从1开始*/
	date			datetime	not null,							/*接通时间*/
	room			char(8)	not null,							/*分机号*/
	length		char(8)	not null,							/*通讯长度*/
	empno			char(10)	not null,							/*工号*/
	shift			char(1)	not null,							/*班号*/
	phcode		char(20)	not null,							/*目的号码*/
	calltype		char(1)	not null,							/*ref to phncls*/
	fee			money		not null,							/*费用总额*/
	fee_base		money		not null,							/*基本费*/
	fee_serve	money		not null,							/*服务费*/
	fee_dial		money		not null,							/*拨号费*/
	fee_cancel	money		not null,							/*撤号费*/
	refer			char(10)	null,									/*备注*/
	tag			char(1)	null,
	type			char(1)	null,
	trunk			char(3)	null,									/*中继*/
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
	log_date		datetime	default getdate() not null,	/*入库日期*/
	inumber		integer	not null,							/*物理序列号,从1开始*/
	date			datetime	not null,							/*接通时间*/
	room			char(8)	not null,							/*分机号*/
	length		char(8)	not null,							/*通讯长度*/
	empno			char(10)	not null,							/*工号*/
	shift			char(1)	not null,							/*班号*/
	phcode		char(20)	not null,							/*目的号码*/
	calltype		char(1)	not null,							/*ref to phncls*/
	fee			money		not null,							/*费用总额*/
	fee_base		money		not null,							/*基本费*/
	fee_serve	money		not null,							/*服务费*/
	fee_dial		money		not null,							/*拨号费*/
	fee_cancel	money		not null,							/*撤号费*/
	refer			char(10)	null,									/*备注*/
	tag			char(1)	null,
	type			char(1)	null,
	trunk			char(3)	null,									/*中继*/
	address		varchar(20)	 null
)
exec sp_primarykey phhfolio,inumber
create index index0 on phhfolio(inumber)
create index index1 on phhfolio(date)
create index index2 on phhfolio(room)
create index index3 on phhfolio(refer);
