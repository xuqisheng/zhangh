if object_id('swrep') is not null
	drop table swrep;
CREATE TABLE swrep 
(
    folio      char(10)     DEFAULT '0'	 NOT NULL,
    sfolio     char(12)     NULL,
    sta        char(1)      DEFAULT 'I'	 NOT NULL,
    grade      char(1)      NOT NULL,
    class      char(1)      NOT NULL,
    goods      varchar(20)  NOT NULL,
    descript   varchar(100) NULL,
    amount     money        DEFAULT 0 NOT NULL,
    lose_hno   varchar(7)   NULL,
    lose_man   varchar(50)  NULL,
    lose_add   varchar(50)  NULL,
    lose_date  datetime     NULL,
    lose_thing varchar(100) NULL,
    rep_man    varchar(50)  NOT NULL,
    rep_date   datetime     NOT NULL,
    phone      varchar(20)  NULL,
    address    varchar(50)  NULL,
    link       char(10)     NULL,
    refer      varchar(40)  NULL,
    empno      char(10)     NULL,
    date       datetime     NULL,
    logmark    int          DEFAULT 0 NOT NULL
);
EXEC sp_primarykey 'swrep', folio;
CREATE UNIQUE NONCLUSTERED INDEX folio ON swrep(folio);


if object_id('hswrep') is not null
	drop table hswrep;
CREATE TABLE hswrep 
(
    folio      char(10)     DEFAULT '0'	 NOT NULL,
    sfolio     char(12)     NULL,
    sta        char(1)      DEFAULT 'I'	 NOT NULL,
    grade      char(1)      NOT NULL,
    class      char(1)      NOT NULL,
    goods      varchar(20)  NOT NULL,
    descript   varchar(100) NULL,
    amount     money        DEFAULT 0 NOT NULL,
    lose_hno   varchar(7)   NULL,
    lose_man   varchar(50)  NULL,
    lose_add   varchar(50)  NULL,
    lose_date  datetime     NULL,
    lose_thing varchar(100) NULL,
    rep_man    varchar(50)  NOT NULL,
    rep_date   datetime     NOT NULL,
    phone      varchar(20)  NULL,
    address    varchar(50)  NULL,
    link       char(10)     NULL,
    refer      varchar(40)  NULL,
    empno      char(10)     NULL,
    date       datetime     NULL,
    logmark    int          DEFAULT 0 NOT NULL
);
EXEC sp_primarykey 'hswrep', folio;
CREATE UNIQUE NONCLUSTERED INDEX folio ON hswrep(folio);


if object_id('swrep_log') is not null
	drop table swrep_log;
CREATE TABLE swrep_log 
(
    folio      char(10)     DEFAULT '0'	 NOT NULL,
    sfolio     char(12)     NULL,
    sta        char(1)      DEFAULT 'I'	 NOT NULL,
    grade      char(1)      NOT NULL,
    class      char(1)      NOT NULL,
    goods      varchar(20)  NOT NULL,
    descript   varchar(100) NULL,
    amount     money        DEFAULT 0 NOT NULL,
    lose_hno   varchar(7)   NULL,
    lose_man   varchar(50)  NULL,
    lose_add   varchar(50)  NULL,
    lose_date  datetime     NULL,
    lose_thing varchar(100) NULL,
    rep_man    varchar(50)  NOT NULL,
    rep_date   datetime     NOT NULL,
    phone      varchar(20)  NULL,
    address    varchar(50)  NULL,
    link       char(10)     NULL,
    refer      varchar(40)  NULL,
    empno      char(10)     NULL,
    date       datetime     NULL,
    logmark    int          DEFAULT 0 NOT NULL
);
EXEC sp_primarykey 'swrep_log', folio,logmark;
CREATE UNIQUE NONCLUSTERED INDEX folio ON swrep_log(folio,logmark);
