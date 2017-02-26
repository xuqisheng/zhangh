-- jierep
if exists(select * from sysobjects where name = 'jierep' and type = 'U')
	drop table jierep;
CREATE TABLE jierep 
(
    date      datetime    NOT NULL,
    order_    char(2)     DEFAULT '' NULL,
    itemno    money       DEFAULT 0 NULL,
    mode      char(1)     DEFAULT '' NULL,
    class     char(8)     DEFAULT '' NULL,
    descript  varchar(50) DEFAULT '' NULL,
    descript1 varchar(50) DEFAULT '' NULL,
    rectype   char(1)     DEFAULT '' NULL,
    toop      char(1)     DEFAULT '' NULL,
    toclass   char(8)     DEFAULT '' NULL,
    sequence  integer     DEFAULT 0 NOT NULL,
    day01     money       DEFAULT 0 NULL,
    day02     money       DEFAULT 0 NULL,
    day03     money       DEFAULT 0 NULL,
    day04     money       DEFAULT 0 NULL,
    day05     money       DEFAULT 0 NULL,
    day06     money       DEFAULT 0 NULL,
    day07     money       DEFAULT 0 NULL,
    day08     money       DEFAULT 0 NULL,
    day09     money       DEFAULT 0 NULL,
    day99     money       DEFAULT 0 NULL,
    month01   money       DEFAULT 0 NULL,
    month02   money       DEFAULT 0 NULL,
    month03   money       DEFAULT 0 NULL,
    month04   money       DEFAULT 0 NULL,
    month05   money       DEFAULT 0 NULL,
    month06   money       DEFAULT 0 NULL,
    month07   money       DEFAULT 0 NULL,
    month08   money       DEFAULT 0 NULL,
    month09   money       DEFAULT 0 NULL,
    month99   money       DEFAULT 0 NULL
);
EXEC sp_primarykey 'jierep', class;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON jierep(class);


-- yjierep
if exists(select * from sysobjects where name = 'yjierep' and type = 'U')
	drop table yjierep;
CREATE TABLE yjierep 
(
    date      datetime    NOT NULL,
    order_    char(2)     DEFAULT '' NULL,
    itemno    money       DEFAULT 0 NULL,
    mode      char(1)     DEFAULT '' NULL,
    class     char(8)     DEFAULT '' NULL,
    descript  varchar(50) DEFAULT '' NULL,
    descript1 varchar(50) DEFAULT '' NULL,
    rectype   char(1)     DEFAULT '' NULL,
    toop      char(1)     DEFAULT '' NULL,
    toclass   char(8)     DEFAULT '' NULL,
    sequence  integer     DEFAULT 0 NOT NULL,
    day01     money       DEFAULT 0 NULL,
    day02     money       DEFAULT 0 NULL,
    day03     money       DEFAULT 0 NULL,
    day04     money       DEFAULT 0 NULL,
    day05     money       DEFAULT 0 NULL,
    day06     money       DEFAULT 0 NULL,
    day07     money       DEFAULT 0 NULL,
    day08     money       DEFAULT 0 NULL,
    day09     money       DEFAULT 0 NULL,
    day99     money       DEFAULT 0 NULL,
    month01   money       DEFAULT 0 NULL,
    month02   money       DEFAULT 0 NULL,
    month03   money       DEFAULT 0 NULL,
    month04   money       DEFAULT 0 NULL,
    month05   money       DEFAULT 0 NULL,
    month06   money       DEFAULT 0 NULL,
    month07   money       DEFAULT 0 NULL,
    month08   money       DEFAULT 0 NULL,
    month09   money       DEFAULT 0 NULL,
    month99   money       DEFAULT 0 NULL
);
EXEC sp_primarykey 'yjierep', date, class;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON yjierep(date, class);


-- dairep
if exists(select * from sysobjects where name = 'dairep' and type = 'U')
	drop table dairep;
CREATE TABLE dairep 
(
    date      datetime    NOT NULL,
    order_    char(2)     DEFAULT '' NULL,
    itemno    int         DEFAULT 0 NULL,
    mode      char(1)     DEFAULT '' NULL,
    class     char(8)     DEFAULT '' NULL,
    descript  varchar(50) DEFAULT '' NOT NULL,
    descript1 varchar(50) DEFAULT '' NOT NULL,
    sequence  integer     DEFAULT 0 NOT NULL,
    credit01  money       DEFAULT 0 NULL,
    credit02  money       DEFAULT 0 NULL,
    credit03  money       DEFAULT 0 NULL,
    credit04  money       DEFAULT 0 NULL,
    credit05  money       DEFAULT 0 NULL,
    credit06  money       DEFAULT 0 NULL,
    credit07  money       DEFAULT 0 NULL,
    sumcre    money       DEFAULT 0 NULL,
    last_bl   money       DEFAULT 0 NULL,
    debit     money       DEFAULT 0 NULL,
    credit    money       DEFAULT 0 NULL,
    till_bl   money       DEFAULT 0 NULL,
    credit01m money       DEFAULT 0 NULL,
    credit02m money       DEFAULT 0 NULL,
    credit03m money       DEFAULT 0 NULL,
    credit04m money       DEFAULT 0 NULL,
    credit05m money       DEFAULT 0 NULL,
    credit06m money       DEFAULT 0 NULL,
    credit07m money       DEFAULT 0 NULL,
    sumcrem   money       DEFAULT 0 NULL,
    last_blm  money       DEFAULT 0 NULL,
    debitm    money       DEFAULT 0 NULL,
    creditm   money       DEFAULT 0 NULL,
    till_blm  money       DEFAULT 0 NULL
);
EXEC sp_primarykey 'dairep', class;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON dairep(class);

-- ydairep
if exists(select * from sysobjects where name = 'ydairep' and type = 'U')
	drop table ydairep;
CREATE TABLE ydairep 
(
    date      datetime    NOT NULL,
    order_    char(2)     DEFAULT '' NULL,
    itemno    int         DEFAULT 0 NULL,
    mode      char(1)     DEFAULT '' NULL,
    class     char(8)     DEFAULT '' NULL,
    descript  varchar(50) DEFAULT '' NOT NULL,
    descript1 varchar(50) DEFAULT '' NOT NULL,
    sequence  integer     DEFAULT 0 NOT NULL,
    credit01  money       DEFAULT 0 NULL,
    credit02  money       DEFAULT 0 NULL,
    credit03  money       DEFAULT 0 NULL,
    credit04  money       DEFAULT 0 NULL,
    credit05  money       DEFAULT 0 NULL,
    credit06  money       DEFAULT 0 NULL,
    credit07  money       DEFAULT 0 NULL,
    sumcre    money       DEFAULT 0 NULL,
    last_bl   money       DEFAULT 0 NULL,
    debit     money       DEFAULT 0 NULL,
    credit    money       DEFAULT 0 NULL,
    till_bl   money       DEFAULT 0 NULL,
    credit01m money       DEFAULT 0 NULL,
    credit02m money       DEFAULT 0 NULL,
    credit03m money       DEFAULT 0 NULL,
    credit04m money       DEFAULT 0 NULL,
    credit05m money       DEFAULT 0 NULL,
    credit06m money       DEFAULT 0 NULL,
    credit07m money       DEFAULT 0 NULL,
    sumcrem   money       DEFAULT 0 NULL,
    last_blm  money       DEFAULT 0 NULL,
    debitm    money       DEFAULT 0 NULL,
    creditm   money       DEFAULT 0 NULL,
    till_blm  money       DEFAULT 0 NULL
);
EXEC sp_primarykey 'ydairep', date, class;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON ydairep(date, class);


-- 底表宾客账、应收账款以及以后的积分等等

if exists(select * from sysobjects where name = "jiedai")
	drop table jiedai;
create table jiedai
(
    date         datetime    NOT NULL,
    order_       char(2)     DEFAULT '' NULL,
    itemno       int         DEFAULT 0 NULL,
    mode         char(1)     DEFAULT '' NULL,
    class        char(8)     DEFAULT '' NULL,
    descript     varchar(50) DEFAULT '' NOT NULL,
    descript1    varchar(50) DEFAULT '' NOT NULL,
    last_charge  money       DEFAULT 0 NULL,		-- 上日借方余额
    last_credit  money       DEFAULT 0 NULL,		-- 上日贷方余额
    charge       money       DEFAULT 0 NULL,		-- 本日借方发生
    credit       money       DEFAULT 0 NULL,		-- 本日贷方发生
    apply        money       DEFAULT 0 NULL,		-- 本日结帐
    till_charge  money       DEFAULT 0 NULL,		-- 本日借方余额
    till_credit  money       DEFAULT 0 NULL,		-- 本日贷方余额
    last_chargem money       DEFAULT 0 NULL,		-- 上月借方余额
    last_creditm money       DEFAULT 0 NULL,		-- 上月贷方余额
    chargem      money       DEFAULT 0 NULL,		-- 本月借方发生
    creditm      money       DEFAULT 0 NULL,		-- 本月贷方发生
    applym       money       DEFAULT 0 NULL,		-- 本月结帐
    till_chargem money       DEFAULT 0 NULL,		-- 本月借方余额
    till_creditm money       DEFAULT 0 NULL		-- 本月贷方余额
)
exec sp_primarykey jiedai, class
CREATE UNIQUE NONCLUSTERED INDEX index1 ON jiedai(class)
;

if exists(select * from sysobjects where name = "yjiedai")
	drop table yjiedai;
create table yjiedai(
    date         datetime    NOT NULL,
    order_       char(2)     DEFAULT '' NULL,
    itemno       int         DEFAULT 0 NULL,
    mode         char(1)     DEFAULT '' NULL,
    class        char(8)     DEFAULT '' NULL,
    descript     varchar(50) DEFAULT '' NOT NULL,
    descript1    varchar(50) DEFAULT '' NOT NULL,
    last_charge  money       DEFAULT 0 NULL,		-- 上日借方余额
    last_credit  money       DEFAULT 0 NULL,		-- 上日贷方余额
    charge       money       DEFAULT 0 NULL,		-- 本日借方发生
    credit       money       DEFAULT 0 NULL,		-- 本日贷方发生
    apply        money       DEFAULT 0 NULL,		-- 本日结帐
    till_charge  money       DEFAULT 0 NULL,		-- 本日借方余额
    till_credit  money       DEFAULT 0 NULL,		-- 本日贷方余额
    last_chargem money       DEFAULT 0 NULL,		-- 上月借方余额
    last_creditm money       DEFAULT 0 NULL,		-- 上月贷方余额
    chargem      money       DEFAULT 0 NULL,		-- 本月借方发生
    creditm      money       DEFAULT 0 NULL,		-- 本月贷方发生
    applym       money       DEFAULT 0 NULL,		-- 本月结帐
    till_chargem money       DEFAULT 0 NULL,		-- 本月借方余额
    till_creditm money       DEFAULT 0 NULL		-- 本月贷方余额
)
exec sp_primarykey yjiedai, date, class
CREATE UNIQUE NONCLUSTERED INDEX index1 ON jiedai(date, class)
;

//insert jiedai select date, order_, itemno, mode, class, descript, descript1, 0,
//	last_bl, 0, debit, credit, 0, till_bl, 0, last_blm, 0, debitm, creditm, 0, till_blm, 0
//	from dairep where substring(class, 1, 3) in ('020', '030', '040');
//insert yjiedai select date, order_, itemno, mode, class, descript, descript1, 0,
// last_bl, 0, debit, credit, 0, till_bl, 0, last_blm, 0, debitm, creditm, 0, till_blm, 0
//	from ydairep where substring(class, 1, 3) in ('020', '030', '040');
