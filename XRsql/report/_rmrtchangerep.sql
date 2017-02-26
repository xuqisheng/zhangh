/* 夜审上日换房或改房价报表 */
if exists (select 1 from sysobjects where name = 'rmrtchangerep' and type = 'U' )
	drop table rmrtchangerep;
create table rmrtchangerep
(
	date        datetime       not null,
	accnt			char(10)			not null, 
	name			varchar(50)		default '' not null, 
	groupno		char(10)			default '' null, 
	groupname	varchar(30)		default '' null, 
	fmroomno		char(5)			default '' null, 
	fmrate		money				default 0  null, 
	toroomno		char(5)			default '' null, 
	torate		money				default 0  null, 
	cby			char(10)			default '' null, 
	changed		datetime			null, 
	logmark		integer			default 0, 
)
exec sp_primarykey rmrtchangerep, date,accnt, logmark
create unique index index1 on rmrtchangerep(date,accnt, logmark)
;

if exists (select 1 from sysobjects where name = 'yrmrtchangerep' and type = 'U' )
	drop table yrmrtchangerep;
create table yrmrtchangerep
(
	date        datetime       not null,
	accnt			char(10)			not null, 
	name			varchar(50)		default '' not null, 
	groupno		char(10)			default '' null, 
	groupname	varchar(30)		default '' null, 
	fmroomno		char(5)			default '' null, 
	fmrate		money				default 0  null, 
	toroomno		char(5)			default '' null, 
	torate		money				default 0  null, 
	cby			char(10)			default '' null, 
	changed		datetime			null, 
	logmark		integer			default 0, 
)
exec sp_primarykey yrmrtchangerep, date,accnt, logmark
create unique index index1 on yrmrtchangerep(date,accnt, logmark)
;
insert yrmrtchangerep select * from rmrtchangerep;
