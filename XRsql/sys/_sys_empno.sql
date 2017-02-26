// ------------------------------------------------------------------------------
// 用户表 
// ------------------------------------------------------------------------------

//exec sp_rename  sys_empno, a_sys_empno ; 

if exists(select * from sysobjects where name = "sys_empno")
	drop table sys_empno;
CREATE TABLE sys_empno 
(
    empno    char(10)  NOT NULL,
    cash     char(10)  DEFAULT '' NOT NULL,
    name     varchar(20)  NOT NULL,
    password varchar(15)  NOT NULL,
    htldept  char(10)  default '' NOT NULL,	-- 酒店部门
    htljob   char(10)  default '' NOT NULL,	-- 酒店岗位
    deptno   char(3)   NOT NULL,					-- 权限组别 
    lockdate datetime  NULL,
    birth    datetime  NULL,
    logdate  datetime  NULL,
    allows   varchar(100) NOT NULL,
    locked   char(1)   NOT NULL,
    tag      char(1)   NOT NULL,
    phone    varchar(30)  NOT NULL,
    callno   varchar(30)  NOT NULL,
    sex      char(1)   NOT NULL,
    functag  char(1)   NULL,
    reptag   char(1)   NULL,
    moduno   char(2)   NULL,
    langid   smallint  DEFAULT 0 NULL,
    guesttag char(1)   DEFAULT 'T' NULL,
    cardno   varchar(30)  NULL
)
EXEC sp_primarykey 'sys_empno', empno;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON sys_empno(empno);
//
//insert sys_empno 
//	SELECT empno,
//			cash,
//			name,
//			password,'OT','10',
//			deptno,
//			lockdate,
//			birth,
//			logdate,
//			allows,
//			locked,
//			tag,
//			phone,
//			callno,
//			sex,
//			functag,
//			reptag,
//			moduno,
//			langid,
//			guesttag,
//			cardno  
//	 FROM a_sys_empno  ;
//select * from sys_empno; 
//
