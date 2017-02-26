/* 营业总表 */

if exists (select * from sysobjects where name ='jourrep' and type ='U')
	drop table jourrep;
create table jourrep
(
    date         datetime    NOT NULL,
    class        char(8)     DEFAULT ''		NOT NULL,
    descript     varchar(50) DEFAULT ''		NOT NULL,
    descript1    varchar(50) DEFAULT ''		NOT NULL,
    rectype      char(2)     DEFAULT ''		NULL,
    toop         char(2)     DEFAULT ''		NULL,
    toclass1     char(8)     DEFAULT ''		NULL,
    toclass2     char(8)     DEFAULT ''		NULL,
    unit         char(6)     DEFAULT '. .'	NULL,
    show         char(1)     DEFAULT 'T'		NULL,
    impindex     varchar(40) DEFAULT ''		NULL,
    sequence     integer     DEFAULT 0			NOT NULL,
    withp        char(1)     DEFAULT 'T'		NULL,
    day          money       DEFAULT 0			NULL,
    month        money       DEFAULT 0			NULL,
    pmonth       money       DEFAULT 0			NULL,
    lmonth       money       DEFAULT 0			NULL,
    year         money       DEFAULT 0			NULL,
    pyear        money       DEFAULT 0			NULL,
    lyear        money       DEFAULT 0			NULL,
    day_rebate   money       DEFAULT 0			NULL,
    month_rebate money       DEFAULT 0			NULL,
    year_rebate  money       DEFAULT 0			NULL
)
exec sp_primarykey jourrep, class
CREATE UNIQUE NONCLUSTERED INDEX index1 ON jourrep(class);

if exists (select * from sysobjects where name ='yjourrep' and type ='U')
	drop table yjourrep;
create table yjourrep
(
    date         datetime    NOT NULL,
    class        char(8)     DEFAULT ''		NOT NULL,
    descript     varchar(50) DEFAULT ''		NOT NULL,
    descript1    varchar(50) DEFAULT ''		NOT NULL,
    rectype      char(2)     DEFAULT ''		NULL,
    toop         char(2)     DEFAULT ''		NULL,
    toclass1     char(8)     DEFAULT ''		NULL,
    toclass2     char(8)     DEFAULT ''		NULL,
    unit         char(6)     DEFAULT '. .'	NULL,
    show         char(1)     DEFAULT 'T'		NULL,
    impindex     varchar(40) DEFAULT ''		NULL,
    sequence     integer     DEFAULT 0			NOT NULL,
    withp        char(1)     DEFAULT 'T'		NULL,
    day          money       DEFAULT 0			NULL,
    month        money       DEFAULT 0			NULL,
    pmonth       money       DEFAULT 0			NULL,
    lmonth       money       DEFAULT 0			NULL,
    year         money       DEFAULT 0			NULL,
    pyear        money       DEFAULT 0			NULL,
    lyear        money       DEFAULT 0			NULL,
    day_rebate   money       DEFAULT 0			NULL,
    month_rebate money       DEFAULT 0			NULL,
    year_rebate  money       DEFAULT 0			NULL
)
exec sp_primarykey yjourrep, date, class
CREATE UNIQUE NONCLUSTERED INDEX index1 ON jourrep(date, class);
create index index2 on yjourrep(class, date)
;
