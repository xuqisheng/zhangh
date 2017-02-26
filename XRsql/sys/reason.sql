
// reason_type -- ���� basecode 

if exists(select * from sysobjects where name = 'reason' and type ='U')
	drop table reason;
create table reason (
		type			char(3)			not null,
		code			char(3)			not null,
		descript		char(30)			not null,
		descript1		char(30)		not null,
		p01			money				default 0 not null,		// �ͷ�
		p02			money				default 0 not null,		// ����
		p03			money				default 0 not null,		// ����
		p04			money				default 0 not null,		// ����
		p90			money				default 0 not null,		// ���
		halt			char(1)			default 'F' not null,
		sequence		int				default 0	not null
);
exec sp_primarykey reason, code
create unique index index1 on reason(code)
;
