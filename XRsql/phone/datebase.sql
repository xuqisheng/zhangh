//电话包价

if exists(select * from sysobjects where name = "phpackage")  --电话包价设置表
	drop table phpackage;
CREATE TABLE phpackage 
(
    startt  datetime NOT NULL, --包价开始时间
    daynum  int      NOT NULL,  --包价天数
    fee     money    NOT NULL,  --包价金额
    sndnum  int      NOT NULL,  --包价时间
    cost    money    NOT NULL,  --实际支付
    flag    char(2)  NULL,    --包日
    extno   varchar(40) NULL,  --包价分机
    pid     varchar(40) NULL   --包价电话类型
)
EXEC sp_primarykey phpackage, pid
;

if exists(select * from sysobjects where name = "phpackage_detail")  --电话包价计算零时表
	drop table phpackage_detail;
CREATE TABLE phpackage_detail 
(
    id       int      NOT NULL,  --id
    roomid   char(10) NOT NULL,  --分机号
    code     char(16) NOT NULL,--拨出号码
    descript char(30) NOT NULL,--描述
    calltype char(2)  NOT NULL,--电话类型
    startt   datetime NOT NULL,--接通时间
    sndnum   int      NOT NULL,--通话时长
    fee      money    NOT NULL,--实际支付
    freefee  money    NULL,--免费部分
    freesnd  int      NULL   --免费时长
)

EXEC sp_primarykey phpackage_detail, id
;

if exists(select * from sysobjects where name = "phcodeg")   --具体费率维护
	drop table phcodeg;
CREATE TABLE phcodeg 
(
    id        char(2)  NOT NULL,
    descript  char(30) NOT NULL,--所在地
    begintime int      NOT NULL,--开始时间
    endtime   int      NOT NULL,--结束时间
    delay     int      NOT NULL,--延时
    basesnd   int      NOT NULL,--起步时间
    stepsnd   int      NOT NULL,--单步时长
    grpsnd    int      NOT NULL,--计次
    rate1     money    NOT NULL,--单步费率
    rate2     money    NOT NULL,--起步费\包单步
    sumfee    money    NOT NULL, --包费
    seq       int      NULL --序列号
)

EXEC sp_primarykey phcodeg, id

CREATE UNIQUE NONCLUSTERED INDEX id
    ON phcodeg(id)

;

if exists(select * from sysobjects where name = "phcoden")  --具体号码维护
	drop table phcoden;
CREATE TABLE phcoden 
(
    code     char(16) NOT NULL, --号码
    descript char(30) NULL,  --地区
    pgid     char(2)  NULL  --号码所在组
)

EXEC sp_primarykey phcoden, code

CREATE UNIQUE NONCLUSTERED INDEX code
    ON phcoden(code)
;
if exists(select * from sysobjects where name = "phempty_deal")  
	drop table phempty_deal;
CREATE TABLE phempty_deal 
(
    date    datetime NOT NULL,
    inumber int      NOT NULL,
    refer0  char(7)  NULL,
    refer1  char(7)  NULL,
    empno   char(3)  NOT NULL
)

EXEC sp_primarykey phempty_deal, date

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON phempty_deal(date)
;
if exists(select * from sysobjects where name = "phextroom")  --分机-房号对照
	drop table phextroom;
CREATE TABLE phextroom 
(
    extno   char(8)  NOT NULL,  --分机号码
    roomno  char(8)  NOT NULL,  --房间号码
    lextno  varchar(16)  NULL,  --长号
    rgid    char(2)  NOT NULL,  --房间类别
    site    varchar(20) NULL  --所在地
)
EXEC sp_primarykey phextroom, extno
CREATE UNIQUE NONCLUSTERED INDEX index1  ON phextroom(extno)
CREATE NONCLUSTERED INDEX index2  ON phextroom(roomno)
CREATE NONCLUSTERED INDEX index3  ON phextroom(lextno)
;


if exists(select * from sysobjects where name = "phfolio")  --详细电话流水账
	drop table phfolio;
CREATE TABLE dbo.phfolio 
(
    log_date   datetime    NOT NULL,--登记时间
    inumber    int         NOT NULL,--序列号
    phcode     varchar(30) NOT NULL,--拨出电话
    address    varchar(30) NULL,--地址
    date       datetime    NOT NULL,--接通时间
    n          int         NOT NULL,--复次计费次数
    valuestr   varchar(50) NOT NULL,--复次计费代码
    feestr     varchar(50) NOT NULL,--复次计费费率
    fee_base   money       NOT NULL,--基本费
    fee_serve  money       NOT NULL,--服务费
    fee_pre    money       NOT NULL,--总费
    fee        money       NOT NULL,--处理后费用
    calltype   char(2)     NOT NULL,--电话类型
    room       char(10)    NOT NULL,--分机号
    length     int         NOT NULL,--通话时长
    serve_code char(2)     NOT NULL,--服务费代码
    empno      char(10)    NOT NULL,--操作员
    refer      char(10)    NOT NULL,--备注
    shift      char(1)     NULL,--工号
    trunk      char(3)     NULL,--中继
    type       char(1)     NULL,--类型
    tag        char(1)     NULL, --
    fee_real   money       null
)

EXEC sp_primarykey phfolio, inumber
CREATE UNIQUE NONCLUSTERED INDEX index1 ON dbo.phfolio(inumber)
;



if exists(select * from sysobjects where name = "phhfolio") --备份
	drop table phhfolio;
CREATE TABLE phhfolio 
(
   log_date   datetime    NOT NULL,
    inumber    int         NOT NULL,
    phcode     varchar(30) NOT NULL,
    address    varchar(30) NULL,
    date       datetime    NOT NULL,
    n          int         NOT NULL,
    valuestr   varchar(50) NOT NULL,
    feestr     varchar(50) NOT NULL,
    fee_base   money       NOT NULL,
    fee_serve  money       NOT NULL,
    fee_pre    money       NOT NULL,
    fee        money       NOT NULL,
    calltype   char(2)     NOT NULL,
    room       char(10)    NOT NULL,
    length     int         NOT NULL,
    serve_code char(2)     NOT NULL,
    empno      char(10)    NOT NULL,
    refer      char(10)    NOT NULL,
    shift      char(1)     NULL,
    trunk      char(3)     NULL,
    type       char(1)     NULL,
    tag        char(1)     NULL,
    fee_real   money       null,
    backid     int      NULL,  --备份id
    backdate   datetime NULL  --备份时间
)

EXEC sp_primarykey phhfolio, inumber

CREATE UNIQUE NONCLUSTERED INDEX inumber
    ON dbo.phhfolio(inumber ,backid)
;


if exists(select * from sysobjects where name = "phncls")  --电话类型描述
	drop table phncls;
CREATE TABLE phncls 
(
    pgid        char(2)  NOT NULL,  --类型号
    descript   varchar(30) NOT NULL,--描述
    seq         int      NULL  --序号
)

EXEC sp_primarykey phncls, pgid

CREATE UNIQUE NONCLUSTERED INDEX PGid
    ON phncls(pgid)
;


if exists(select * from sysobjects where name = "phparms")  --详细号码计费设置
	drop table phparms;
CREATE TABLE phparms 
(
    pgid   char(16) NOT NULL,  --电话类别
    rgid   char(8)  NOT NULL,  --分级类别
    pvalue char(20) NULL,  --电话计费部分代码
    svalue char(2)  NULL,  --服务费部分代码
    cutfee char(2)  NULL  --四舍五入代码
)

EXEC sp_primarykey phparms, pgid,rgid

CREATE UNIQUE NONCLUSTERED INDEX id
    ON phparms(pgid ,rgid)
;

if exists(select * from sysobjects where name = "phparms_roomcol")
	drop table phparms_roomcol;
CREATE TABLE phparms_roomcol 
(
    roomid char(8) NULL,
    col_id char(2) NULL
)

EXEC sp_primarykey phparms_roomcol, roomid

CREATE UNIQUE NONCLUSTERED INDEX col_id
    ON phparms_roomcol(col_id)
;

if exists(select * from sysobjects where name = "phparms_setup")  --详细号码计费设置临时表
	drop table phparms_setup;
CREATE TABLE phparms_setup 
(
    code  char(16) NOT NULL,--电话号码
    gid   char(2)  NULL, --组别
    A     char(20) NULL,
    B     char(20) NULL,
    C     char(20) NULL,
    D     char(20) NULL,
    E     char(20) NULL,
    F     char(20) NULL,
    G     char(20) NULL,
    H     char(20) NULL,
    I     char(20) NULL,
    J     char(20) NULL,
    K     char(20) NULL,
    L     char(20) NULL,
    M     char(20) NULL,
    N     char(20) NULL,
    O     char(20) NULL,
    P     char(20) NULL,
    Q     char(20) NULL,
    R     char(20) NULL,
    S     char(20) NULL,
    T     char(10) NULL,
    U     char(10) NULL,
    V     char(10) NULL,
    W     char(10) NULL,
    X     char(10) NULL,
    Y     char(10) NULL,
    Z     char(10) NULL,
    flag  char(2)  NULL,
    color char(26) NULL
)

EXEC sp_primarykey phparms_setup, code
CREATE UNIQUE NONCLUSTERED INDEX code
    ON phparms_setup(code)
;



if exists(select * from sysobjects where name = "phround")  --四舍五入设置
	drop table phround;
CREATE TABLE phround 
(
    swid     char(2)  NOT NULL,--四舍五入代码
    descript char(20) NULL --描述
)

EXEC sp_primarykey phround, swid
CREATE UNIQUE NONCLUSTERED INDEX id
    ON phround(swid)
;

if exists(select * from sysobjects where name = "phsvcset") --服务费率设置
	drop table phsvcset;
CREATE TABLE phsvcset 
(
    fid        char(2) NOT NULL, --服务费代码
    ext_fee    money   NOT NULL, --额外费用
    adj_rate   float   NOT NULL, --实际费率
    serve_rate float   NOT NULL, --服务费率
    min_serve  money   NOT NULL, --最小费用
    dial_fee   money   NOT NULL, --拨号费
    other_fee  money   NOT NULL --其他费用
)

EXEC sp_primarykey phsvcset, fid
CREATE UNIQUE NONCLUSTERED INDEX fid
    ON dbo.phsvcset(fid)
;

if exists(select * from sysobjects where name = "phtimeanal") --计算话费临时表
	drop table phtimeanal;
CREATE TABLE phtimeanal 
(
    pc_id    char(4) DEFAULT '0.01' NULL, --电脑ip
    modu_id  char(2) DEFAULT '05' NULL, --模块id
    id       char(2) DEFAULT '-' NULL,--id
    startt   char(8) NULL,--开始时间
    endt     char(8) NULL,--结束时间
    factor   money   NULL,--实际费率
    duration money   NULL --时长
)
CREATE UNIQUE NONCLUSTERED INDEX id
    ON phtimeanal(pc_id ,id ,modu_id)
;

if exists(select * from sysobjects where name = "phtimedef") --优惠时段描述
	drop table phtimedef;
CREATE TABLE phtimedef 
(
    gid       char(2)  NOT NULL, --组id
    id        char(2)  NOT NULL,--id
    timedesc  char(30) NOT NULL,--描述
    datecond  char(60) NOT NULL,--时段情况
    starttime char(8)  NOT NULL,--开始时间
    endtime   char(8)  NOT NULL,--结束时间
    fact      money    NOT NULL --实际费率
)

EXEC sp_primarykey phtimedef, gid,id
CREATE UNIQUE NONCLUSTERED INDEX id
    ON phtimedef(gid ,id)
;

if exists(select * from sysobjects where name = "phtimename") --时段描述
	drop table phtimename;
CREATE TABLE phtimename 
(
    id       char(2)  NOT NULL, --id
    descript char(20) NOT NULL --描述
)

EXEC sp_primarykey 'dbo.phtimename', id

CREATE UNIQUE CLUSTERED INDEX index1
    ON dbo.phtimename(id)
;

if exists(select * from sysobjects where name = "phuserdef") --用户分组
	drop table phuserdef;
CREATE TABLE phuserdef 
(
    rgid     char(2)  NOT NULL,  --分级大类
    descript char(30) NOT NULL --描述
)

EXEC sp_primarykey phuserdef, rgid

CREATE UNIQUE NONCLUSTERED INDEX rgig
    ON phuserdef(rgid)
;

if exists(select * from sysobjects where name = "phone_type") --用户分组
	drop table phone_type;
CREATE TABLE phone_type 
(
    code       char(10)     NOT NULL,
    des        char(20)     NOT NULL,
    pfolio     varchar(200) DEFAULT '' NULL,
    remark     varchar(50)  DEFAULT '' NULL,
    openwind   char(30)     DEFAULT 'w_hry_phone_disp_folio' NULL,
    typeid     char(1)      DEFAULT 'A' NULL,
    flag       char(1)      DEFAULT 'F' NULL,
    customflag char(1)      DEFAULT 'F' NULL,
    posfolio   int          DEFAULT '0' NULL,
    dates      varchar(255) DEFAULT '' NULL,
    times      varchar(255) DEFAULT '' NULL,
    zj         varchar(255) DEFAULT '' NULL,
    bj         varchar(255) DEFAULT '' NULL,
    rmflag     char(1)      DEFAULT 'F' NULL,
    trunk      char(100)    DEFAULT '' NULL,
    length     varchar(255) DEFAULT '' NULL,
    length1    varchar(255) DEFAULT '' NULL
)


CREATE UNIQUE NONCLUSTERED INDEX index1
    ON phone_type(code)

CREATE UNIQUE NONCLUSTERED INDEX index2
    ON phone_type(des)
;

if exists(select * from sysobjects where name = "phauerrlog")  --自动入帐错误信息
	drop table phauerrlog;

CREATE TABLE phauerrlog 
(
    log_date datetime  NOT NULL,
    extno    char(10)  NOT NULL,
    msg      char(100) NOT NULL,
    phcode   char(26)  NOT NULL,
    sndnum   int       NOT NULL
)

EXEC sp_primarykey 'dbo.phauerrlog', log_date

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.phauerrlog(log_date)
;


if exists(select * from sysobjects where name = "phngrade")
	drop table phngrade;
CREATE TABLE phngrade 
(
    code     char(1)  NOT NULL,
    descript char(8)  NOT NULL,
    cmd      char(10) NOT NULL
)

CREATE UNIQUE NONCLUSTERED INDEX phngrade_x
    ON dbo.phngrade(code)
;

if exists(select * from sysobjects where name = "foliosrc")
	drop table foliosrc;
CREATE TABLE foliosrc 
(
    no     char(10)      NULL,
    date   char(10)      NULL,
    time   char(10)      NULL,
    zj     char(10)      NULL,
    bj     char(20)      NULL,
    length char(10)      NULL,
    done   char(1)       NULL,
    code   numeric(10,0) IDENTITY
)
EXEC sp_primarykey 'dbo.foliosrc', no
;
