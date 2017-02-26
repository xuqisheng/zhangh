if object_id('swreg') is not null
	drop table swreg;
CREATE TABLE swreg 
(
    folio       char(10)     DEFAULT '0'	 NOT NULL,
    sfolio      char(12)     NULL,
    sta         char(1)      DEFAULT 'I'	 NOT NULL,
    grade       char(1)      NOT NULL,
    class       char(1)      NOT NULL,
    goods       varchar(20)  NOT NULL,
    descript    varchar(100) NULL,
    amount      money        DEFAULT 0 NOT NULL,
    pick_man    varchar(50)  NULL,
    pick_add    varchar(50)  NULL,
    pick_date   datetime     NULL,
    pick_thing  varchar(100)  NULL,
    rep_man     varchar(50)  NOT NULL,
    rep_date    datetime     NOT NULL,
    rep_phone   varchar(20)  NULL,
    rep_address varchar(50)  NULL,
	 host_hno	 char(7)      NULL,		-- Ê§Ö÷
	 host_name	 varchar(50)  NULL,
    get_hno     char(7)      NULL,
    get_man     varchar(50)  NULL,
    get_idcls   char(3)      NULL,
    get_ident   varchar(20)  NULL,
    get_date    datetime     NULL,
    get_reason  varchar(30)  NULL,
    get_phone   varchar(20)  NULL,
    get_address varchar(50)  NULL,
    sure        char(10)     NULL,
    link        char(10)     NULL,
    refer       varchar(40)  NULL,
    empno       char(10)     NULL,
    date        datetime     NULL,
    logmark     int          DEFAULT 0 NOT NULL
);
EXEC sp_primarykey 'swreg', folio
CREATE UNIQUE NONCLUSTERED INDEX folio ON swreg(folio)


if object_id('hswreg') is not null
	drop table hswreg;
CREATE TABLE hswreg 
(
    folio       char(10)     DEFAULT '0'	 NOT NULL,
    sfolio      char(12)     NULL,
    sta         char(1)      DEFAULT 'I'	 NOT NULL,
    grade       char(1)      NOT NULL,
    class       char(1)      NOT NULL,
    goods       varchar(20)  NOT NULL,
    descript    varchar(100) NULL,
    amount      money        DEFAULT 0 NOT NULL,
    pick_man    varchar(50)  NULL,
    pick_add    varchar(50)  NULL,
    pick_date   datetime     NULL,
    pick_thing  varchar(100)  NULL,
    rep_man     varchar(50)  NOT NULL,
    rep_date    datetime     NOT NULL,
    rep_phone   varchar(20)  NULL,
    rep_address varchar(50)  NULL,
	 host_hno	 char(7)      NULL,		-- Ê§Ö÷
	 host_name	 varchar(50)  NULL,
    get_hno     char(7)      NULL,
    get_man     varchar(50)  NULL,
    get_idcls   char(3)      NULL,
    get_ident   varchar(20)  NULL,
    get_date    datetime     NULL,
    get_reason  varchar(30)  NULL,
    get_phone   varchar(20)  NULL,
    get_address varchar(50)  NULL,
    sure        char(10)     NULL,
    link        char(10)     NULL,
    refer       varchar(40)  NULL,
    empno       char(10)     NULL,
    date        datetime     NULL,
    logmark     int          DEFAULT 0 NOT NULL
);
EXEC sp_primarykey 'hswreg', folio
CREATE UNIQUE NONCLUSTERED INDEX folio ON hswreg(folio)


if object_id('swreg_log') is not null
	drop table swreg_log;
CREATE TABLE swreg_log 
(
    folio       char(10)     DEFAULT '0'	 NOT NULL,
    sfolio      char(12)     NULL,
    sta         char(1)      DEFAULT 'I'	 NOT NULL,
    grade       char(1)      NOT NULL,
    class       char(1)      NOT NULL,
    goods       varchar(20)  NOT NULL,
    descript    varchar(100) NULL,
    amount      money        DEFAULT 0 NOT NULL,
    pick_man    varchar(50)  NULL,
    pick_add    varchar(50)  NULL,
    pick_date   datetime     NULL,
    pick_thing  varchar(100)  NULL,
    rep_man     varchar(50)  NOT NULL,
    rep_date    datetime     NOT NULL,
    rep_phone   varchar(20)  NULL,
    rep_address varchar(50)  NULL,
	 host_hno	 char(7)      NULL,		-- Ê§Ö÷
	 host_name	 varchar(50)  NULL,
    get_hno     char(7)      NULL,
    get_man     varchar(50)  NULL,
    get_idcls   char(3)      NULL,
    get_ident   varchar(20)  NULL,
    get_date    datetime     NULL,
    get_reason  varchar(30)  NULL,
    get_phone   varchar(20)  NULL,
    get_address varchar(50)  NULL,
    sure        char(10)     NULL,
    link        char(10)     NULL,
    refer       varchar(40)  NULL,
    empno       char(10)     NULL,
    date        datetime     NULL,
    logmark     int          DEFAULT 0 NOT NULL
);
EXEC sp_primarykey 'swreg_log', folio,logmark;
CREATE UNIQUE NONCLUSTERED INDEX folio ON swreg_log(folio,logmark);


