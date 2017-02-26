
// ----------------------------------------------------------------
// 	argst - 系统联系人，签单人  关联表
// ----------------------------------------------------------------
if exists(select * from sysobjects where name = "argst")
	drop table argst;
create table  argst
(
	no    		char(7)					not null,	  	// guest(class='T')
	accnt    	char(10)					not null,	  	// armst / guest
	tag1			char(1)	default 'F'	not null,		// 联系人
	tag2			char(1)	default 'F'	not null,		// 签单人
	tag3			char(1)	default 'F'	not null,		// 负责人
	tag4			char(1)	default 'F'	not null,		// 备用
	tag5			char(1)	default 'F'	not null,		// 备用
	cby         char(10)  					null,		 //  修改人工号  
	changed     datetime 					null,		 //  修改时间
   logmark     int  		default 0 		not null
)
exec sp_primarykey argst,no,accnt
create unique index index1 on argst(no,accnt)
create index index2 on argst(accnt)
;

// ----------------------------------------------------------------
// 	argst_log
// ----------------------------------------------------------------
if exists(select * from sysobjects where name = "argst_log")
	drop table argst_log;
create table  argst_log
(
	no    		char(7)					not null,	  	// guest
	accnt    	char(10)					not null,	  	// armst / guest
	tag1			char(1)	default 'F'	not null,		// 联系人
	tag2			char(1)	default 'F'	not null,		// 签单人
	tag3			char(1)	default 'F'	not null,		// 负责人
	tag4			char(1)	default 'F'	not null,		// 备用
	tag5			char(1)	default 'F'	not null,		// 备用
	cby         char(10)  					null,		 //  修改人工号  
	changed     datetime 					null,		 //  修改时间
   logmark     int  		default 0 		not null
)
exec sp_primarykey argst_log,no,accnt,logmark
create unique index index1 on argst_log(no,accnt,logmark)
;


// ----------------------------------------------------------------
// 视图view  = arguest
// ----------------------------------------------------------------
if exists(select * from sysobjects where name = "arguest")
	drop view arguest;
create view  arguest as 
	select  a.*, b.accnt, b.tag1, b.tag2, b.tag3, b.tag4, b.tag5, cby1=b.cby, changed1=b.changed  
		from guest a, argst b where a.no=b.no 
;
