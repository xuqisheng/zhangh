/* LPR 各部门收入表 */

if exists (select * from sysobjects where name ='njourrep' and type ='U')
	drop table njourrep;
create table njourrep
(
    date         datetime    NOT NULL,
    class        char(8)     DEFAULT ''	 NOT NULL,
    descript     varchar(50) DEFAULT ''	 NOT NULL,
    descript1    varchar(50) DEFAULT ''	 NOT NULL,
    rectype      char(2)     DEFAULT ''	 NULL,
    toop         char(2)     DEFAULT ''	 NULL,
    toclass1     char(8)     DEFAULT ''	 NULL,
    toclass2     char(8)     DEFAULT ''	 NULL,
    unit         char(6)     DEFAULT '. .' NULL,
    show         char(1)     DEFAULT 'T'	 NULL,
    impindex     varchar(40) DEFAULT ''	 NULL,
    sequence     integer     DEFAULT 0		 NOT NULL,
    withp        char(1)     DEFAULT 'T'	 NULL,
    day          money       DEFAULT 0		 NULL,
    month        money       DEFAULT 0		 NULL,
    pmonth       money       DEFAULT 0		 NULL,
    lmonth       money       DEFAULT 0		 NULL,
    year         money       DEFAULT 0		 NULL,
    pyear        money       DEFAULT 0		 NULL,
    lyear        money       DEFAULT 0		 NULL,
    day_rebate   money       DEFAULT 0		 NULL,
    month_rebate money       DEFAULT 0		 NULL,
    year_rebate  money       DEFAULT 0		 NULL
)
exec sp_primarykey njourrep, class
CREATE UNIQUE NONCLUSTERED INDEX index1 ON njourrep(class);

if exists (select * from sysobjects where name ='ynjourrep' and type ='U')
	drop table ynjourrep;
create table ynjourrep
(
    date         datetime    NOT NULL,
    class        char(8)     DEFAULT ''	 NOT NULL,
    descript     varchar(50) DEFAULT ''	 NOT NULL,
    descript1    varchar(50) DEFAULT ''	 NOT NULL,
    rectype      char(2)     DEFAULT ''	 NULL,
    toop         char(2)     DEFAULT ''	 NULL,
    toclass1     char(8)     DEFAULT ''	 NULL,
    toclass2     char(8)     DEFAULT ''	 NULL,
    unit         char(6)     DEFAULT '. .' NULL,
    show         char(1)     DEFAULT 'T'	 NULL,
    impindex     varchar(40) DEFAULT ''	 NULL,
    sequence     integer     DEFAULT 0		 NOT NULL,
    withp        char(1)     DEFAULT 'T'	 NULL,
    day          money       DEFAULT 0		 NULL,
    month        money       DEFAULT 0		 NULL,
    pmonth       money       DEFAULT 0		 NULL,
    lmonth       money       DEFAULT 0		 NULL,
    year         money       DEFAULT 0		 NULL,
    pyear        money       DEFAULT 0		 NULL,
    lyear        money       DEFAULT 0		 NULL,
    day_rebate   money       DEFAULT 0		 NULL,
    month_rebate money       DEFAULT 0		 NULL,
    year_rebate  money       DEFAULT 0		 NULL
)
exec sp_primarykey ynjourrep, date, class
CREATE UNIQUE NONCLUSTERED INDEX index1 ON ynjourrep(date, class);
create index index2 on ynjourrep(class, date)
;
