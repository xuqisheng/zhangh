if exists (select * from sysobjects where name ='bankcard' and type ='U')
	drop table bankcard;
create table bankcard
(
	pccode			char(5)		not null,
	bankcode			char(3)		not null,
	accnt				char(10)		default '' not null,
	commission		money			default 0 not null,		/* 给银行的回扣率(对信用卡有效) */
)
exec sp_primarykey bankcard, pccode, bankcode
create unique index index1 on bankcard(pccode, bankcode);

insert bankcard select pccode, '', commission from pccode where deptno in ('C', 'D');

insert basecode values ('bankcode', '010', '工商银行', '', 'T', 'F', 10, '');
insert basecode values ('bankcode', '020', '农业银行', '', 'T', 'F', 20, '');
insert basecode values ('bankcode', '030', '中国银行', '', 'T', 'F', 30, '');
insert basecode values ('bankcode', '040', '建设银行', '', 'T', 'F', 40, '');
insert basecode values ('bankcode', '050', '交通银行', '', 'T', 'F', 50, '');
insert basecode values ('bankcode', '060', '招商银行', '', 'T', 'F', 60, '');
insert basecode values ('bankcode', '070', '光大银行', '', 'T', 'F', 70, '');
insert basecode values ('bankcode', '410', '市商业银行', '', 'T', 'F', 410, '');
insert basecode values ('bankcode', '510', '汇丰银行', '', 'T', 'F', 510, '');
