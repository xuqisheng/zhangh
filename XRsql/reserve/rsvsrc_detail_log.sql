if exists(select 1 from sysobjects where name='rsvsrc_detail_log' and type='U')
drop table rsvsrc_detail_log
;
CREATE TABLE rsvsrc_detail_log 
(
    accnt     char(10)    NOT NULL,
    id        int         not null,
    type      char(5)     NOT NULL,
    roomno    char(5)     DEFAULT ''	 NOT NULL,
    blkmark   char(1)     DEFAULT ''	 NOT NULL,
    blkcode   char(10)    DEFAULT ''	 NOT NULL,
    date_     datetime    NOT NULL,
    quantity  money       default 0  not null,
    gstno     int         DEFAULT 0	 NOT NULL,
    child     int         DEFAULT 0	 NOT NULL,
    rmrate    money       DEFAULT 0	 NOT NULL,
    rate      money       DEFAULT 0	 NOT NULL,
    qrate     money       default 0   not null,
 	 trate     money       default 0 not null,   --加上外加包价后的房价
 	 p_srv     money       default 0   not null,     //服务费包价
    p_bf      money       default 0   not null,     //早餐包价
	 p_lau     money       default 0   not null,     //洗衣费包价
    p_cms     money       default 0  not null,      //佣金
    p_ot      money       default 0   not null,     //其它包价
    discount  money       DEFAULT 0   NOT NULL,
    discount1 money       DEFAULT 0   NOT NULL,
    rtreason  char(3)     DEFAULT ''	 NOT NULL,
    remark    varchar(50) DEFAULT ''	 NOT NULL,
    saccnt    char(10)    DEFAULT ''	 NOT NULL,
    master    char(10)    DEFAULT ''	 NOT NULL,
    rateok    char(1)     DEFAULT 'F'	 NOT NULL,
    arr       datetime    NOT NULL,
    dep       datetime    NOT NULL,
    ratecode  char(10)    DEFAULT '' 	 NOT NULL,
    src       char(3)     DEFAULT '' 	 NOT NULL,
    market    char(3)     DEFAULT '' 	 NOT NULL,
    packages  varchar(50) DEFAULT ''	 NOT NULL,
    srqs      varchar(30) DEFAULT ''	 NOT NULL,
    amenities varchar(30) DEFAULT ''	 NOT NULL,
    exp_m     money       NULL,
    exp_dt    datetime    NULL,
    exp_s1    varchar(20) NULL,
    exp_s2    varchar(20) NULL,
    cby       char(10)    NULL,
    changed   datetime    NULL,
    logmark   int         DEFAULT 0		 NULL,
    mode      char(1)     DEFAULT '' NOT NULL,
    calc      char(1)     default 'F' not null
)
;
CREATE NONCLUSTERED INDEX index1
    ON dbo.rsvsrc_detail_log(accnt,id,type,roomno,date_,gstno,rate,remark,logmark)
;

