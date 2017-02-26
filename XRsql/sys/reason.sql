
// reason_type -- 放在 basecode 

if exists(select * from sysobjects where name = 'reason' and type ='U')
	drop table reason;
create table reason (
		type			char(3)			not null,
		code			char(3)			not null,
		descript		char(30)			not null,
		descript1		char(30)		not null,
		p01			money				default 0 not null,		// 客房
		p02			money				default 0 not null,		// 餐饮
		p03			money				default 0 not null,		// 娱乐
		p04			money				default 0 not null,		// 其他
		p90			money				default 0 not null,		// 款待
		halt			char(1)			default 'F' not null,
		sequence		int				default 0	not null
);
exec sp_primarykey reason, code
create unique index index1 on reason(code)
;
