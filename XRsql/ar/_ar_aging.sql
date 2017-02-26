if exists (select * from sysobjects where name ='ar_aging' and type ='U')
	drop table ar_aging;
create table ar_aging
(
	pc_id			char(4)			not null, 
	catalog		char(3)			not null, 
	accnt			char(10)			not null, 
	descript		char(24)			not null, 
	name			char(50)			not null, 
	amount1		money				default 0 not null,
	amount2		money				default 0 not null,
	amount3		money				default 0 not null,
	amount4		money				default 0 not null,
	amount5		money				default 0 not null,
	amount6		money				default 0 not null,
	amount7		money				default 0 not null,
	amount8		money				default 0 not null,
	amount9		money				default 0 not null,
	amount10		money				default 0 not null,
	amount		money				default 0 not null
)
exec sp_primarykey ar_aging, pc_id, catalog, accnt
create unique index index1 on ar_aging(pc_id, catalog, accnt)
;


