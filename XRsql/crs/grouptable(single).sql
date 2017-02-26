//grp_single_yjourrep
CREATE TABLE grp_single_yjourrep 
(
	 hotelid			char(20)		default '' not null,
    date         datetime    NULL,
    class        char(8)     DEFAULT ''		 NOT NULL,
    descript     varchar(50) DEFAULT ''		 NOT NULL,
    descript1    varchar(50) DEFAULT ''		 NOT NULL,
    rectype      char(2)     DEFAULT ''		 NULL,
    toop         char(2)     DEFAULT ''		 NULL,
    toclass1     char(8)     DEFAULT ''		 NULL,
    toclass2     char(8)     DEFAULT ''		 NULL,
    unit         char(6)     DEFAULT '. .'	 NULL,
    show         char(1)     DEFAULT 'T'	 NULL,
    impindex     char(8)     DEFAULT ''		 NULL,
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
;

CREATE UNIQUE CLUSTERED INDEX index1
    ON grp_single_yjourrep(hotelid,date,class)
;
CREATE NONCLUSTERED INDEX index2
    ON grp_single_yjourrep(hotelid,class,date)
;
//grp_single_yaudit_impdata
CREATE TABLE grp_single_yaudit_impdata 
(
    hotelid  char(20) default '' not null,
    date      datetime NOT NULL,
    class     char(8)  DEFAULT '' NOT NULL,
    amount    money    DEFAULT 0 NOT NULL,
    amount_m  money    DEFAULT 0 NOT NULL,
    amount_y  money    DEFAULT 0 NOT NULL,
    descript  char(40) DEFAULT '' NOT NULL,
    descript1 char(40) DEFAULT '' NOT NULL,
    addedby   char(8)  DEFAULT '' NOT NULL,
    sequence  int      DEFAULT 0 NOT NULL
)
;
CREATE UNIQUE CLUSTERED INDEX index1
    ON grp_single_yaudit_impdata(hotelid,date,class)
;

//grp_single_ymktsummaryrep 
CREATE TABLE grp_single_ymktsummaryrep 
(
    hotelid char(20)        not null,
    date    datetime      NULL,
    class   char(1)       NOT NULL,
    grp     char(10)      NOT NULL,
    code    char(10)      NOT NULL,
    pquan   int           DEFAULT 0 	 NOT NULL,
    rquan   numeric(10,1) DEFAULT 0 	 NOT NULL,
    rincome money         DEFAULT 0 	 NOT NULL,
    tincome money         DEFAULT 0 	 NOT NULL,
    rsvc    money         DEFAULT 0 	 NOT NULL,
    rpak    money         DEFAULT 0 	 NOT NULL
)
;
CREATE UNIQUE CLUSTERED INDEX index1
    ON grp_single_ymktsummaryrep(hotelid,date,class,grp,code)
;
CREATE UNIQUE NONCLUSTERED INDEX index2
    ON grp_single_ymktsummaryrep(hotelid,class,grp,code,date)
;

//grp_single_events 
CREATE TABLE grp_single_events 
(
    hotelid  char(20)   not null,
    id       int         NOT NULL,
    sta      char(1)     DEFAULT 'I'		 NOT NULL,
    descript varchar(60) NOT NULL,
    remark   text        DEFAULT ''   	 NOT NULL,
    begin_   datetime    NOT NULL,
    end_     datetime    NOT NULL,
    crtby    char(10)    NOT NULL,
    crttime  datetime    NOT NULL,
    cby      char(10)    NOT NULL,
    changed  datetime    NOT NULL
)
;
CREATE UNIQUE CLUSTERED INDEX index1
    ON grp_single_events(hotelid,id)
;

