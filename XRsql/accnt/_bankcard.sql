if exists (select * from sysobjects where name ='bankcard' and type ='U')
	drop table bankcard;
create table bankcard
(
	pccode			char(5)		not null,
	bankcode			char(3)		not null,
	accnt				char(10)		default '' not null,
	commission		money			default 0 not null,		/* �����еĻؿ���(�����ÿ���Ч) */
)
exec sp_primarykey bankcard, pccode, bankcode
create unique index index1 on bankcard(pccode, bankcode);

insert bankcard select pccode, '', commission from pccode where deptno in ('C', 'D');

insert basecode values ('bankcode', '010', '��������', '', 'T', 'F', 10, '');
insert basecode values ('bankcode', '020', 'ũҵ����', '', 'T', 'F', 20, '');
insert basecode values ('bankcode', '030', '�й�����', '', 'T', 'F', 30, '');
insert basecode values ('bankcode', '040', '��������', '', 'T', 'F', 40, '');
insert basecode values ('bankcode', '050', '��ͨ����', '', 'T', 'F', 50, '');
insert basecode values ('bankcode', '060', '��������', '', 'T', 'F', 60, '');
insert basecode values ('bankcode', '070', '�������', '', 'T', 'F', 70, '');
insert basecode values ('bankcode', '410', '����ҵ����', '', 'T', 'F', 410, '');
insert basecode values ('bankcode', '510', '�������', '', 'T', 'F', 510, '');
