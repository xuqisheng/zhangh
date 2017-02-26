if exists(select 1 from sysobjects where name='rsvsrc_detail' and type='U')
drop table rsvsrc_detail
;
CREATE TABLE dbo.rsvsrc_detail
(
    accnt     char(10)    NOT NULL,
    id        int         NOT NULL,
    type      char(5)     NOT NULL,
    roomno    char(5)     DEFAULT '' NOT NULL,
    blkmark   char(1)     DEFAULT '' NOT NULL,
    blkcode   char(10)    DEFAULT '' NOT NULL,
    date_     datetime    NOT NULL,
    quantity  money       DEFAULT 0 NOT NULL,
    gstno     int         DEFAULT 0 NOT NULL,
    child     int         DEFAULT 0 NOT NULL,
    rmrate    money       DEFAULT 0 NOT NULL,
    rate      money       DEFAULT 0 NOT NULL,
    qrate     money       DEFAULT 0 NOT NULL,
    trate     money       default 0 not null,   --加上外加包价后的房价
    p_srv     money       DEFAULT 0 NOT NULL,
    p_bf      money       DEFAULT 0 NOT NULL,
    p_lau     money       DEFAULT 0 NOT NULL,
    p_cms     money       DEFAULT 0 NOT NULL,
    p_ot      money       DEFAULT 0 NOT NULL,
    discount  money       DEFAULT 0 NOT NULL,
    discount1 money       DEFAULT 0 NOT NULL,
    rtreason  char(3)     DEFAULT '' NOT NULL,
    remark    varchar(50) DEFAULT '' NOT NULL,
    saccnt    char(10)    DEFAULT '' NOT NULL,
    master    char(10)    DEFAULT '' NOT NULL,
    rateok    char(1)     DEFAULT 'F' NOT NULL,
    arr       datetime    NOT NULL,
    dep       datetime    NOT NULL,
    ratecode  char(10)    DEFAULT '' NOT NULL,
    src       char(3)     DEFAULT '' NOT NULL,
    market    char(3)     DEFAULT '' NOT NULL,
    packages  varchar(50) DEFAULT '' NOT NULL,
    srqs      varchar(30) DEFAULT '' NOT NULL,
    amenities varchar(30) DEFAULT '' NOT NULL,
    exp_m     money       NULL,
    exp_dt    datetime    NULL,
    exp_s1    varchar(20) NULL,
    exp_s2    varchar(20) NULL,
    cby       char(10)    NULL,
    changed   datetime    NULL,
    logmark   int         DEFAULT 0 NULL,
    mode      char(1)     DEFAULT '' NOT NULL,
    calc      char(1)     DEFAULT 'F' NOT NULL
)
;

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.rsvsrc_detail(accnt,id,date_,type,quantity,roomno,gstno,rate,remark)
;
