if exists(select * from sysobjects where name = "bursar")
	drop table bursar;
CREATE TABLE bursar 
(
    code      char(20)     NOT NULL,
    descript  varchar(30)  NOT NULL,
    descript1 varchar(30)  DEFAULT ''			 NOT NULL,
    kind      char(2)      DEFAULT '' 		 NOT NULL,
    src       char(20)     DEFAULT ''		 NOT NULL,
    classes   varchar(255) DEFAULT ''		 NOT NULL
);
EXEC sp_primarykey 'bursar', code;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON bursar(code)
;

if exists(select * from sysobjects where name = "bursar_code")
	drop table bursar_code;
CREATE TABLE bursar_code 
(
    code      char(15)    NOT NULL,
    descript  varchar(30) NOT NULL,
    descript1 varchar(30) NOT NULL,
    class     char(4)     DEFAULT '' 		 NOT NULL,
    no        varchar(20) DEFAULT '' 		 NOT NULL,
    instready varchar(1)  DEFAULT 'T'		 NOT NULL
)
;
EXEC sp_primarykey 'bursar_code', code;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON bursar_code(code)
;

if exists(select * from sysobjects where name = "bursar_def")
	drop table bursar_def;
CREATE TABLE bursar_def 
(
    code    char(15)     NOT NULL,
    id      int          NOT NULL,
    remark  varchar(30)  DEFAULT '' 	 NULL,
    bursar  char(20)     NOT NULL,
    tag     char(2)      DEFAULT '½è' 	 NOT NULL,
    src     varchar(20)     DEFAULT '' 	 NOT NULL,
    classes varchar(255) DEFAULT '' 	 NOT NULL
)
;
EXEC sp_primarykey 'bursar_def', code,id;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON bursar_def(code,id)
;

if exists(select * from sysobjects where name = "bursar_out")
	drop table bursar_out;
CREATE TABLE bursar_out 
(
    date   datetime    NOT NULL,
    code   char(15)    NOT NULL,
    id     int         NOT NULL,
    remark varchar(30) DEFAULT '' 	 NULL,
    bursar char(20)    NOT NULL,
    kind   char(2)     DEFAULT '' 		 NOT NULL,
    tag    char(2)     DEFAULT '½è' 	 NOT NULL,
    amount money       DEFAULT 0 		 NOT NULL
)
;
EXEC sp_primarykey 'bursar_out', code,id
;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON bursar_out(code,id)
;
