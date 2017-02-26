
-- 通用数据统计功能 

-- 业务类别定义  
if object_id('gs_type') is not null 
	drop table gs_type;
CREATE TABLE gs_type 
(
    code       char(1)     NOT NULL,
    descript   varchar(60) NOT NULL,
    descript1  varchar(60) NOT NULL,
    modunos    varchar(60) DEFAULT '' 		 NOT NULL,
    install_   char(1)     DEFAULT 'F'		 NOT NULL,
    format     varchar(12) DEFAULT '0.00'	 NOT NULL,
    sort       int         DEFAULT 0		 NOT NULL,
    site       varchar(10) DEFAULT ''		 NOT NULL,
    show_begin varchar(10) DEFAULT ''		 NOT NULL,
    show_dw    varchar(20) DEFAULT ''		 NOT NULL,
    input_dw   varchar(20) DEFAULT ''		 NOT NULL,
    itemdes    varchar(12) NULL,
    sitedes    varchar(12) NULL
);
EXEC sp_primarykey 'gs_type', code;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON gs_type(code)
;

-- 每个业务的具体项目 
if object_id('gs_item') is not null 
	drop table gs_item;
CREATE TABLE gs_item 
(
    code     char(1)     NOT NULL,
    item     char(3)     NOT NULL,
    descript varchar(40) NOT NULL,
    descript1 varchar(40) 		NULL,
    sort     varchar(3)  DEFAULT ''			 NOT NULL,
    value    money       DEFAULT 0			 NOT NULL,
    format   text        DEFAULT '' 			 NOT NULL
);
EXEC sp_primarykey 'gs_item', code,item;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON gs_item(code,item);


-- 数据录入临时表 
if object_id('gs_input') is not null 
	drop table gs_input;
CREATE TABLE gs_input 
(
    e1  money DEFAULT 0				 NOT NULL,
    e2  money DEFAULT 0				 NOT NULL,
    e3  money DEFAULT 0				 NOT NULL,
    e4  money DEFAULT 0				 NOT NULL,
    e5  money DEFAULT 0				 NOT NULL,
    e6  money DEFAULT 0				 NOT NULL,
    e7  money DEFAULT 0				 NOT NULL,
    e8  money DEFAULT 0				 NOT NULL,
    e9  money DEFAULT 0				 NOT NULL,
    e10 money DEFAULT 0			 NOT NULL,
    e11 money DEFAULT 0				 NOT NULL,
    e12 money DEFAULT 0				 NOT NULL,
    e13 money DEFAULT 0				 NOT NULL,
    e14 money DEFAULT 0				 NOT NULL,
    e15 money DEFAULT 0				 NOT NULL,
    e16 money DEFAULT 0				 NOT NULL,
    e17 money DEFAULT 0				 NOT NULL,
    e18 money DEFAULT 0				 NOT NULL,
    e19 money DEFAULT 0				 NOT NULL,
    e20 money DEFAULT 0				 NOT NULL,
    e21 money DEFAULT 0				 NOT NULL,
    e22 money DEFAULT 0				 NOT NULL,
    e23 money DEFAULT 0				 NOT NULL,
    e24 money DEFAULT 0				 NOT NULL,
    e25 money DEFAULT 0				 NOT NULL,
    e26 money DEFAULT 0				 NOT NULL,
    e27 money DEFAULT 0				 NOT NULL,
    e28 money DEFAULT 0				 NOT NULL,
    e29 money DEFAULT 0				 NOT NULL,
    e30 money DEFAULT 0				 NOT NULL
);

if object_id('gs_list') is not null 
	drop table gs_list;
CREATE TABLE gs_list 
(
    code     char(1)     NOT NULL,
    descript varchar(10) NOT NULL,
    types    varchar(20) DEFAULT '%'		 NOT NULL
);
EXEC sp_primarykey 'gs_list', code;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON gs_list(code);

if object_id('gs_mode') is not null 
	drop table gs_mode;
CREATE TABLE gs_mode 
(
    code     char(1)     NOT NULL,
    descript varchar(10) NOT NULL
);
EXEC sp_primarykey 'gs_mode', code;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON gs_mode(code);

-- 业务数据存放 
if object_id('gs_rec') is not null 
	drop table gs_rec;
CREATE TABLE gs_rec 
(
    log_date datetime    NOT NULL,
    date     datetime    NOT NULL,
    code     char(1)     NOT NULL,
    site     varchar(10) NOT NULL,
    item     char(3)     NOT NULL,
    amount   money       DEFAULT 0				 NOT NULL,
    empno    char(10)    NOT NULL,
    sta      char(1)     DEFAULT 'I'				 NOT NULL,
    mode     char(1)     NOT NULL
);
EXEC sp_primarykey 'gs_rec', log_date,date,code,site,item;
CREATE NONCLUSTERED INDEX index2 ON gs_rec(code,site,item);
CREATE NONCLUSTERED INDEX index3 ON gs_rec(empno);
CREATE UNIQUE NONCLUSTERED INDEX index1 ON gs_rec(log_date,date,code,site,item);

if object_id('gs_rec_mode') is not null 
	drop table gs_rec_mode;
CREATE TABLE gs_rec_mode 
(
    code     char(1)     NOT NULL,
    descript varchar(10) NOT NULL,
    types    varchar(20) DEFAULT '%'		 NOT NULL
);
EXEC sp_primarykey 'gs_rec_mode', code;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON gs_rec_mode(code);

-- 位置定义 
if object_id('gs_site') is not null 
	drop table gs_site;
CREATE TABLE gs_site 
(
    code      char(1)     NOT NULL,
    site      varchar(10) NOT NULL,
    descript  varchar(20) NOT NULL,
    descript1 varchar(20) NOT NULL,
    toclass1  varchar(20) DEFAULT ''			 NOT NULL,
    toclass2  varchar(20) DEFAULT ''			 NOT NULL,
    toclass3  varchar(20) DEFAULT ''			 NOT NULL
);
EXEC sp_primarykey 'gs_site', code,site;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON gs_site(code,site);

-- 位置定义 临时，有用吗 ？ 
if object_id('gs_site_tmp') is not null 
	drop table gs_site_tmp;
CREATE TABLE gs_site_tmp 
(
    code     char(1)     NOT NULL,
    site     varchar(10) NOT NULL,
    descript varchar(20) NOT NULL,
    descript1 varchar(20) NOT NULL,
    toclass1 varchar(20) DEFAULT ''			 NOT NULL,
    toclass2 varchar(20) DEFAULT ''			 NOT NULL,
    toclass3 varchar(20) DEFAULT ''			 NOT NULL
);
EXEC sp_primarykey 'gs_site_tmp', code,site;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON gs_site_tmp(code,site);

