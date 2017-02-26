/* 系统表备份与删除 */

if exists (select 1 from sysobjects where name = 'dltable' and type = 'U' )
	drop table dltable;
create table dltable
(
	tablename		char(30)			not null, 
	keyname			char(30)			not null, 
	keytype			char(10)			not null, 
	groupname	varchar(30)		default '' null, 
	fmroomno		char(5)			default '' null, 
	fmrate		money				default 0  null, 
	toroomno		char(5)			default '' null, 
	torate		money				default 0  null, 
	cby			char(10)			default '' null, 
	changed		datetime			null, 
	logmark		integer			default 0, 
)
exec sp_primarykey dltable, accnt, logmark
create unique index index1 on dltable(accnt, logmark)
;
