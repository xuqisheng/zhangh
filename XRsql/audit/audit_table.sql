/* 来源分析报表 */
if exists (select * from sysobjects where name ='mktsummaryrep' and type ='U')
   drop table mktsummaryrep;
create table  mktsummaryrep
(
   date       datetime 							null,
   class      char(1)  							not null, /* 大类,M=Market ,S=Source, C=Channel */
   grp   		char(10)  						not null, 
   code     	char(10)							not null,
   pquan      int 				default 0 	not null,
   rquan      numeric(10,1) 	default 0 	not null,
   rincome    money 				default 0 	not null,
   tincome    money 				default 0 	not null,
	rsvc		money 				default 0 	not null,
	rpak		money 				default 0 	not null,
	fincome	money					default 0 	not null,
	rarr		int					default 0 	not null,
	rdep		int					default 0 	not null,
	parr		int					default 0 	not null,
	pdep		int					default 0 	not null,
	noshow	int					default 0 	not null,
	cxl		int					default 0 	not null
)
exec sp_primarykey mktsummaryrep,class,grp,code
create unique index index1 on mktsummaryrep(class,grp,code)
;

if exists (select * from sysobjects where name ='ymktsummaryrep' and type ='U')
   drop table ymktsummaryrep;
create table  ymktsummaryrep
(
   date       datetime 							null,
   class      char(1)  							not null, /* 大类,M=Market ,S=Source, C=Channel */
   grp   		char(10)  						not null, 
   code     	char(10)							not null,
   pquan      int 				default 0 	not null,
   rquan      numeric(10,1) 	default 0 	not null,
   rincome    money 				default 0 	not null,
   tincome    money 				default 0 	not null,
	rsvc		money 				default 0 	not null,
	rpak		money 				default 0 	not null,
	fincome	money					default 0 	not null,
	rarr		int					default 0 	not null,
	rdep		int					default 0 	not null,
	parr		int					default 0 	not null,
	pdep		int					default 0 	not null,
	noshow	int					default 0 	not null,
	cxl		int					default 0 	not null
)
exec sp_primarykey ymktsummaryrep,date,class,grp,code
create unique index index1 on ymktsummaryrep(date,class,grp,code)
create unique index index2 on ymktsummaryrep(class,grp,code,date)
;

/* 来源分析报表 detail */
if exists (select * from sysobjects where name ='mktsummaryrep_detail' and type ='U')
   drop table mktsummaryrep_detail;
create table  mktsummaryrep_detail
(
   date       datetime 							null,
	accnt			char(10)							not null,
	haccnt		char(7)			default ''	null,
	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,
	name			varchar(60)	  	default ''	null,
	sta			char(1)							null,
	roomno		char(5)							null,
	rate			money								null,
	arr			datetime							null,
	dep			datetime							null,
   market     	char(3)							null,
   src     		char(3)							null,
   channel    	char(3)							null,
   ratecode   	char(10)							null,
	restype		char(3)							null,
   pquan      int 				default 0 	not null,
   rquan      numeric(10,1) 	default 0 	not null,
   rincome    money 				default 0 	not null,
   tincome    money 				default 0 	not null,
	rsvc		money 				default 0 	not null,
	rpak		money 				default 0 	not null,
	fincome	money					default 0 	not null,
	rarr		int					default 0 	not null,
	rdep		int					default 0 	not null,
	parr		int					default 0 	not null,
	pdep		int					default 0 	not null,
	noshow	int					default 0 	not null,
	cxl		int					default 0 	not null,
   type     char(5)                       null,
   gtype    char(3)                       null
)
exec sp_primarykey mktsummaryrep_detail,accnt
create unique index index1 on mktsummaryrep_detail(accnt)
;


/* 来源分析报表 detail */
if exists (select * from sysobjects where name ='ymktsummaryrep_detail' and type ='U')
   drop table ymktsummaryrep_detail;
create table  ymktsummaryrep_detail
(
   date       datetime 							null,
	accnt			char(10)							not null,
	haccnt		char(7)			default ''	null,
	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,
	name			varchar(60)	  	default ''	null,
	sta			char(1)							null,
	roomno		char(5)							null,
	rate			money								null,
	arr			datetime							null,
	dep			datetime							null,
   market     	char(3)							null,
   src     		char(3)							null,
   channel    	char(3)							null,
   ratecode   	char(10)							null,
	restype   	char(3)							null,
   pquan      int 				default 0 	not null,
   rquan      numeric(10,1) 	default 0 	not null,
   rincome    money 				default 0 	not null,
   tincome    money 				default 0 	not null,
	rsvc		money 				default 0 	not null,
	rpak		money 				default 0 	not null,
	fincome	money					default 0 	not null,
	rarr		int					default 0 	not null,
	rdep		int					default 0 	not null,
	parr		int					default 0 	not null,
	pdep		int					default 0 	not null,
	noshow	int					default 0 	not null,
	cxl		int					default 0 	not null,
 	type     char(5)                       null,
   gtype    char(3)                       null
)
exec sp_primarykey ymktsummaryrep_detail,date, accnt
create unique index index1 on ymktsummaryrep_detail(date, accnt)
;

-- audit_impdata  &  yaudit_impdata
if exists (select * from sysobjects where name ='audit_impdata' and type ='U')
   drop table audit_impdata;
create table audit_impdata
(
	date			datetime		not null,
	class			varchar(40)	default '' not null,
	amount		money			default 0  not null,
	amount_m		money			default 0  not null,
	amount_y		money			default 0  not null,
	descript		varchar(50)	default '' not null,
	descript1	varchar(50)	default '' not null,
	addedby		char(8)		default '' not null,
	sequence		int			default 0  not null,
	line			char(1)		default ' ' null,
	row			int			default 0 null,
	halt			char(1)		default 'F' null
)
exec sp_primarykey audit_impdata,class
create unique index index1 on audit_impdata(class);
;
if exists (select * from sysobjects where name ='yaudit_impdata' and type ='U')
   drop table yaudit_impdata;
create table yaudit_impdata
(
	date			datetime		not null,
	class			varchar(40)	default '' not null,
	amount		money			default 0  not null,
	amount_m		money			default 0  not null,
	amount_y		money			default 0  not null,
	descript		varchar(50)	default '' not null,
	descript1	varchar(50)	default '' not null,
	addedby		char(8)		default '' not null,
	sequence		int			default 0  not null,
	line			char(1)		default ' ' null,
	row			int			default 0 null,
	halt			char(1)		default 'F' null
)
exec sp_primarykey yaudit_impdata,date, class
create unique index index1 on yaudit_impdata(date, class);
;

//manager_report & ymanager_report 将audit_impdata按大房类分开存
if exists (select * from sysobjects where name ='manager_report' and type ='U')
   drop table manager_report;
create table manager_report
(
    date     datetime    NOT NULL,
    class    varchar(40) DEFAULT '' NOT NULL,
    gtype    char(3)     NOT NULL,
    amount   money       DEFAULT 0 NOT NULL,
    amount_m money       DEFAULT 0 NOT NULL,
    amount_y money       DEFAULT 0 NOT NULL,
    remark   varchar(50) DEFAULT '' NOT NULL
)
EXEC sp_primarykey manager_report, class,gtype
;

if exists (select * from sysobjects where name ='ymanager_report' and type ='U')
   drop table ymanager_report;
create table ymanager_report
(
    date     datetime    NOT NULL,
    class    varchar(40) DEFAULT '' NOT NULL,
    gtype    char(3)     NOT NULL,
    amount   money       DEFAULT 0 NOT NULL,
    amount_m money       DEFAULT 0 NOT NULL,
    amount_y money       DEFAULT 0 NOT NULL,
    remark   varchar(50) DEFAULT '' NOT NULL
)
EXEC sp_primarykey ymanager_report, date,class,gtype
;

// bjourrep
if exists (select * from sysobjects where name ='bjourrep' and type ='U')
   drop table bjourrep;
create table bjourrep
(
	date			datetime							null,

	item			char(2)							null, 
   class			char(8)		default ''		not null,
   name			varchar(20)	default ''		not null,
   ename			varchar(20) default ''		not null,
   day			money			default 0		not null,
   month			money			default 0		not null,

   pmonth		money			default 0		not null,
   lmonth		money			default 0		not null,
   line			integer		default 0		not null,

	item1			char(2)							null, 
   class1		char(8)		default ''		not null,
   name1			varchar(20)	default ''		not null,
   ename1		varchar(20) default ''		not null,
   day1			money			default 0		not null,
   month1		money			default 0		not null
)
exec sp_primarykey bjourrep,class,line
create unique index index1 on bjourrep(class,line)
create index index2 on bjourrep(line);

// ybjourrep 
if exists (select * from sysobjects where name ='ybjourrep' and type ='U')
   drop table ybjourrep;
create table ybjourrep
(
	date			datetime							null,

	item			char(2)							null, 
   class			char(8)		default ''		not null,
   name			varchar(20)	default ''		not null,
   ename			varchar(20) default ''		not null,
   day			money			default 0		not null,
   month			money			default 0		not null,

   pmonth		money			default 0		not null,
   lmonth		money			default 0		not null,
   line			integer		default 0		not null,

	item1			char(2)							null, 
   class1		char(8)		default ''		not null,
   name1			varchar(20)	default ''		not null,
   ename1		varchar(20) default ''		not null,
   day1			money			default 0		not null,
   month1		money			default 0		not null
)
exec sp_primarykey ybjourrep,date,class,line
create unique index index1 on ybjourrep(date,class,line);


/* 进(在)店客人按国籍省份统计*/

if exists ( select * from sysobjects where name = 'gststa' and type = 'U')
	drop table gststa;

create table gststa
(
	date			datetime					not null,
	gclass		char(1)  default ''	not null,
	order_		char(2)  default ''	not null,
	nation		char(3)  default ''	not null,
	descript		varchar(30) default ''	not null,
	descript1	varchar(40) default ''	not null,
	sequence		integer	default 0	not null,
	dtc			integer	default 0	not null,	-- 日：散客人次
	dgc			integer	default 0	not null,	-- 日：团体人次
	dmc			integer	default 0	not null,	-- 日：会议人次
	dtt			integer	default 0	not null,	-- 日：散客人天
	dgt			integer	default 0	not null,	-- 日：团体人天
	dmt			integer	default 0	not null,	-- 日：会议人天
	mtc			integer	default 0	not null,
	mgc			integer	default 0	not null,
	mmc			integer	default 0	not null,
	mtt			integer	default 0	not null,
	mgt			integer	default 0	not null,
	mmt			integer	default 0	not null,
	ytc			integer	default 0	not null,
	ygc			integer	default 0	not null,
	ymc			integer	default 0	not null,
	ytt			integer	default 0	not null,
	ygt			integer	default 0	not null,
	ymt			integer	default 0	not null
)
exec sp_primarykey gststa, gclass, order_, nation
create unique index index1 on gststa(gclass, order_, nation)
;

if exists ( select * from sysobjects where name = 'ygststa' and type = 'U')
	drop table ygststa;

create table ygststa
(
	date			datetime					not null,
	gclass		char(1)  default ''	not null,
	order_		char(2)  default ''	not null,
	nation		char(3)  default ''	not null,
	descript		varchar(30) default ''	not null,
	descript1	varchar(40) default ''	not null,
	sequence		integer	default 0	not null,
	dtc			integer	default 0	not null,
	dgc			integer	default 0	not null,
	dmc			integer	default 0	not null,
	dtt			integer	default 0	not null,
	dgt			integer	default 0	not null,
	dmt			integer	default 0	not null,
	mtc			integer	default 0	not null,
	mgc			integer	default 0	not null,
	mmc			integer	default 0	not null,
	mtt			integer	default 0	not null,
	mgt			integer	default 0	not null,
	mmt			integer	default 0	not null,
	ytc			integer	default 0	not null,
	ygc			integer	default 0	not null,
	ymc			integer	default 0	not null,
	ytt			integer	default 0	not null,
	ygt			integer	default 0	not null,
	ymt			integer	default 0	not null
)
exec sp_primarykey ygststa, date, gclass, order_, nation
create unique index index1 on ygststa(date, gclass, order_, nation)
create unique index index2 on ygststa(gclass, order_, nation, date)
;

if exists ( select * from sysobjects where name = 'gststa1' and type = 'U')
	drop table gststa1;
create table gststa1
(
	date			datetime					not null,
	gclass		char(2) default ''	not null,
	wfrom			char(6) default ''	not null,
	descript		varchar(30) default ''	not null,
	descript1	varchar(40) default ''	not null,
	sequence		integer	default 0	not null,
	dtc			integer	default 0	not null,
	dgc			integer	default 0	not null,
	dmc			integer	default 0	not null,
	dtt			integer	default 0	not null,
	dgt			integer	default 0	not null,
	dmt			integer	default 0	not null,
	mtc			integer	default 0	not null,
	mgc			integer	default 0	not null,
	mmc			integer	default 0	not null,
	mtt			integer	default 0	not null,
	mgt			integer	default 0	not null,
	mmt			integer	default 0	not null,
	ytc			integer	default 0	not null,
	ygc			integer	default 0	not null,
	ymc			integer	default 0	not null,
	ytt			integer	default 0	not null,
	ygt			integer	default 0	not null,
	ymt			integer	default 0	not null
)
exec sp_primarykey gststa1, gclass, wfrom
create unique index index1 on gststa1(gclass, wfrom)
;

if exists ( select * from sysobjects where name = 'ygststa1' and type = 'U')
	drop table ygststa1;
create table ygststa1
(
	date			datetime					not null,
	gclass		char(2) default ''	not null,
	wfrom			char(6) default ''	not null,
	descript		varchar(30) default ''	not null,
	descript1	varchar(40) default ''	not null,
	sequence		integer	default 0	not null,
	dtc			integer	default 0	not null,
	dgc			integer	default 0	not null,
	dmc			integer	default 0	not null,
	dtt			integer	default 0	not null,
	dgt			integer	default 0	not null,
	dmt			integer	default 0	not null,
	mtc			integer	default 0	not null,
	mgc			integer	default 0	not null,
	mmc			integer	default 0	not null,
	mtt			integer	default 0	not null,
	mgt			integer	default 0	not null,
	mmt			integer	default 0	not null,
	ytc			integer	default 0	not null,
	ygc			integer	default 0	not null,
	ymc			integer	default 0	not null,
	ytt			integer	default 0	not null,
	ygt			integer	default 0	not null,
	ymt			integer	default 0	not null
)
exec sp_primarykey ygststa1, date, gclass, wfrom
create unique index index1 on ygststa1(date, gclass, wfrom)
create unique index index2 on ygststa1(gclass, wfrom, date)
;

IF OBJECT_ID('gststa_info') IS NOT NULL
    DROP TABLE gststa_info;
CREATE TABLE gststa_info 
(
    pc_id    char(4)  NOT NULL,
    modu_id  char(2)  NOT NULL,
    gclass   char(1)  DEFAULT '' NULL,
    order_   char(2)  DEFAULT '' NULL,
    nation   char(3)  DEFAULT '' NULL,
    descript varchar(30) DEFAULT '' NULL,
    descript1 varchar(40) DEFAULT '' NULL,
    sequence  int      DEFAULT 0 NULL,
    tc       int      DEFAULT 0 NULL,
    gc       int      DEFAULT 0 NULL,
    tt       int      DEFAULT 0 NULL,
    gt       int      DEFAULT 0 NULL
)
EXEC sp_primarykey 'gststa_info', pc_id,modu_id,gclass,order_,nation
CREATE UNIQUE NONCLUSTERED INDEX index1  ON gststa_info(pc_id,modu_id,gclass,order_,nation)
;

IF OBJECT_ID('gststa1_info') IS NOT NULL
    DROP TABLE gststa1_info;
CREATE TABLE gststa1_info 
(
    pc_id    char(4)  NOT NULL,
    modu_id  char(2)  NOT NULL,
    gclass   char(2)  DEFAULT '' NULL,
    wfrom    char(5)  DEFAULT '' NULL,
    descript varchar(30) DEFAULT '' NULL,
    descript1 varchar(40) DEFAULT '' NULL,
	sequence  int      DEFAULT 0 NULL,
    tc       int      DEFAULT 0 NULL,
    gc       int      DEFAULT 0 NULL,
    tt       int      DEFAULT 0 NULL,
    gt       int      DEFAULT 0 NULL
)
EXEC sp_primarykey 'gststa1_info', pc_id,modu_id,gclass,wfrom
CREATE UNIQUE NONCLUSTERED INDEX index1 ON gststa1_info(pc_id,modu_id,gclass,wfrom)
;

IF OBJECT_ID('gststa_grf') IS NOT NULL
    DROP TABLE gststa_grf;
CREATE TABLE gststa_grf 
(
    pc_id   char(4)     NOT NULL,
    modu_id char(2)     NOT NULL,
    number  int         NOT NULL,
    descript varchar(30) DEFAULT '' NULL,
    descript1 varchar(40) DEFAULT '' NULL,
	sequence  int      DEFAULT 0 NULL,
    value   money       DEFAULT 0 NOT NULL
)
EXEC sp_primarykey 'gststa_grf', pc_id,modu_id,number
CREATE UNIQUE NONCLUSTERED INDEX index1 ON gststa_grf(pc_id,modu_id,number)
;


/* 简易余额表*/
if exists (select * from sysobjects where name ='mstbalrep' and type ='U')
	drop table mstbalrep;
create table mstbalrep
(
	date				datetime		not null,
	accnt				char(10)		not null, 
	roomno			char(5)		default '' not null, 
	groupno			char(10)		default '' not null, 
	sta				char(1)		default '' not null, 
	name				varchar(50)	default '' null, 
	artag1			char(5)		default '' not null,
	artag1_grp		char(5)		default '' not null,
	group_des		varchar(50)	default '' null, 
	cus_des			varchar(50)	default '' null, 
	agent_des		varchar(50)	default '' null, 
	source_des		varchar(50)	default '' null, 
	arr				datetime		null, 
	dep				datetime		null, 
	lastbl			money			default 0 not null, 
	charge			money			default 0 not null, 
	credit			money			default 0 not null, 
	tillbl			money			default 0 not null, 
	payment			varchar(60)				null,
	ref				varchar(255)			null
)
exec sp_primarykey mstbalrep, accnt
create unique index index1 on mstbalrep(accnt)
;

if exists (select * from sysobjects where name ='ymstbalrep' and type ='U')
	drop table ymstbalrep;
create table ymstbalrep
(
	date				datetime		not null,
	accnt				char(10)		not null, 
	roomno			char(5)		default '' not null, 
	groupno			char(10)		default '' not null, 
	sta				char(1)		default '' not null, 
	name				varchar(50)	default '' null, 
	artag1			char(5)		default '' not null,
	artag1_grp		char(5)		default '' not null,
	group_des		varchar(50)	default '' null, 
	cus_des			varchar(50)	default '' null, 
	agent_des		varchar(50)	default '' null, 
	source_des		varchar(50)	default '' null, 
	arr				datetime		null, 
	dep				datetime		null, 
	lastbl			money			default 0 not null, 
	charge			money			default 0 not null, 
	credit			money			default 0 not null, 
	tillbl			money			default 0 not null, 
	payment			varchar(60)				null,
	ref				varchar(255)			null
)
exec sp_primarykey ymstbalrep, date,accnt
create unique index index1 on ymstbalrep(date,accnt)
;

