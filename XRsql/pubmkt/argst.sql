
// ----------------------------------------------------------------
// 	argst - ϵͳ��ϵ�ˣ�ǩ����  ������
// ----------------------------------------------------------------
if exists(select * from sysobjects where name = "argst")
	drop table argst;
create table  argst
(
	no    		char(7)					not null,	  	// guest(class='T')
	accnt    	char(10)					not null,	  	// armst / guest
	tag1			char(1)	default 'F'	not null,		// ��ϵ��
	tag2			char(1)	default 'F'	not null,		// ǩ����
	tag3			char(1)	default 'F'	not null,		// ������
	tag4			char(1)	default 'F'	not null,		// ����
	tag5			char(1)	default 'F'	not null,		// ����
	cby         char(10)  					null,		 //  �޸��˹���  
	changed     datetime 					null,		 //  �޸�ʱ��
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
	tag1			char(1)	default 'F'	not null,		// ��ϵ��
	tag2			char(1)	default 'F'	not null,		// ǩ����
	tag3			char(1)	default 'F'	not null,		// ������
	tag4			char(1)	default 'F'	not null,		// ����
	tag5			char(1)	default 'F'	not null,		// ����
	cby         char(10)  					null,		 //  �޸��˹���  
	changed     datetime 					null,		 //  �޸�ʱ��
   logmark     int  		default 0 		not null
)
exec sp_primarykey argst_log,no,accnt,logmark
create unique index index1 on argst_log(no,accnt,logmark)
;


// ----------------------------------------------------------------
// ��ͼview  = arguest
// ----------------------------------------------------------------
if exists(select * from sysobjects where name = "arguest")
	drop view arguest;
create view  arguest as 
	select  a.*, b.accnt, b.tag1, b.tag2, b.tag3, b.tag4, b.tag5, cby1=b.cby, changed1=b.changed  
		from guest a, argst b where a.no=b.no 
;
