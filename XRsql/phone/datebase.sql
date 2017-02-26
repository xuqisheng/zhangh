//�绰����

if exists(select * from sysobjects where name = "phpackage")  --�绰�������ñ�
	drop table phpackage;
CREATE TABLE phpackage 
(
    startt  datetime NOT NULL, --���ۿ�ʼʱ��
    daynum  int      NOT NULL,  --��������
    fee     money    NOT NULL,  --���۽��
    sndnum  int      NOT NULL,  --����ʱ��
    cost    money    NOT NULL,  --ʵ��֧��
    flag    char(2)  NULL,    --����
    extno   varchar(40) NULL,  --���۷ֻ�
    pid     varchar(40) NULL   --���۵绰����
)
EXEC sp_primarykey phpackage, pid
;

if exists(select * from sysobjects where name = "phpackage_detail")  --�绰���ۼ�����ʱ��
	drop table phpackage_detail;
CREATE TABLE phpackage_detail 
(
    id       int      NOT NULL,  --id
    roomid   char(10) NOT NULL,  --�ֻ���
    code     char(16) NOT NULL,--��������
    descript char(30) NOT NULL,--����
    calltype char(2)  NOT NULL,--�绰����
    startt   datetime NOT NULL,--��ͨʱ��
    sndnum   int      NOT NULL,--ͨ��ʱ��
    fee      money    NOT NULL,--ʵ��֧��
    freefee  money    NULL,--��Ѳ���
    freesnd  int      NULL   --���ʱ��
)

EXEC sp_primarykey phpackage_detail, id
;

if exists(select * from sysobjects where name = "phcodeg")   --�������ά��
	drop table phcodeg;
CREATE TABLE phcodeg 
(
    id        char(2)  NOT NULL,
    descript  char(30) NOT NULL,--���ڵ�
    begintime int      NOT NULL,--��ʼʱ��
    endtime   int      NOT NULL,--����ʱ��
    delay     int      NOT NULL,--��ʱ
    basesnd   int      NOT NULL,--��ʱ��
    stepsnd   int      NOT NULL,--����ʱ��
    grpsnd    int      NOT NULL,--�ƴ�
    rate1     money    NOT NULL,--��������
    rate2     money    NOT NULL,--�𲽷�\������
    sumfee    money    NOT NULL, --����
    seq       int      NULL --���к�
)

EXEC sp_primarykey phcodeg, id

CREATE UNIQUE NONCLUSTERED INDEX id
    ON phcodeg(id)

;

if exists(select * from sysobjects where name = "phcoden")  --�������ά��
	drop table phcoden;
CREATE TABLE phcoden 
(
    code     char(16) NOT NULL, --����
    descript char(30) NULL,  --����
    pgid     char(2)  NULL  --����������
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
if exists(select * from sysobjects where name = "phextroom")  --�ֻ�-���Ŷ���
	drop table phextroom;
CREATE TABLE phextroom 
(
    extno   char(8)  NOT NULL,  --�ֻ�����
    roomno  char(8)  NOT NULL,  --�������
    lextno  varchar(16)  NULL,  --����
    rgid    char(2)  NOT NULL,  --�������
    site    varchar(20) NULL  --���ڵ�
)
EXEC sp_primarykey phextroom, extno
CREATE UNIQUE NONCLUSTERED INDEX index1  ON phextroom(extno)
CREATE NONCLUSTERED INDEX index2  ON phextroom(roomno)
CREATE NONCLUSTERED INDEX index3  ON phextroom(lextno)
;


if exists(select * from sysobjects where name = "phfolio")  --��ϸ�绰��ˮ��
	drop table phfolio;
CREATE TABLE dbo.phfolio 
(
    log_date   datetime    NOT NULL,--�Ǽ�ʱ��
    inumber    int         NOT NULL,--���к�
    phcode     varchar(30) NOT NULL,--�����绰
    address    varchar(30) NULL,--��ַ
    date       datetime    NOT NULL,--��ͨʱ��
    n          int         NOT NULL,--���μƷѴ���
    valuestr   varchar(50) NOT NULL,--���μƷѴ���
    feestr     varchar(50) NOT NULL,--���μƷѷ���
    fee_base   money       NOT NULL,--������
    fee_serve  money       NOT NULL,--�����
    fee_pre    money       NOT NULL,--�ܷ�
    fee        money       NOT NULL,--��������
    calltype   char(2)     NOT NULL,--�绰����
    room       char(10)    NOT NULL,--�ֻ���
    length     int         NOT NULL,--ͨ��ʱ��
    serve_code char(2)     NOT NULL,--����Ѵ���
    empno      char(10)    NOT NULL,--����Ա
    refer      char(10)    NOT NULL,--��ע
    shift      char(1)     NULL,--����
    trunk      char(3)     NULL,--�м�
    type       char(1)     NULL,--����
    tag        char(1)     NULL, --
    fee_real   money       null
)

EXEC sp_primarykey phfolio, inumber
CREATE UNIQUE NONCLUSTERED INDEX index1 ON dbo.phfolio(inumber)
;



if exists(select * from sysobjects where name = "phhfolio") --����
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
    backid     int      NULL,  --����id
    backdate   datetime NULL  --����ʱ��
)

EXEC sp_primarykey phhfolio, inumber

CREATE UNIQUE NONCLUSTERED INDEX inumber
    ON dbo.phhfolio(inumber ,backid)
;


if exists(select * from sysobjects where name = "phncls")  --�绰��������
	drop table phncls;
CREATE TABLE phncls 
(
    pgid        char(2)  NOT NULL,  --���ͺ�
    descript   varchar(30) NOT NULL,--����
    seq         int      NULL  --���
)

EXEC sp_primarykey phncls, pgid

CREATE UNIQUE NONCLUSTERED INDEX PGid
    ON phncls(pgid)
;


if exists(select * from sysobjects where name = "phparms")  --��ϸ����Ʒ�����
	drop table phparms;
CREATE TABLE phparms 
(
    pgid   char(16) NOT NULL,  --�绰���
    rgid   char(8)  NOT NULL,  --�ּ����
    pvalue char(20) NULL,  --�绰�ƷѲ��ִ���
    svalue char(2)  NULL,  --����Ѳ��ִ���
    cutfee char(2)  NULL  --�����������
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

if exists(select * from sysobjects where name = "phparms_setup")  --��ϸ����Ʒ�������ʱ��
	drop table phparms_setup;
CREATE TABLE phparms_setup 
(
    code  char(16) NOT NULL,--�绰����
    gid   char(2)  NULL, --���
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



if exists(select * from sysobjects where name = "phround")  --������������
	drop table phround;
CREATE TABLE phround 
(
    swid     char(2)  NOT NULL,--�����������
    descript char(20) NULL --����
)

EXEC sp_primarykey phround, swid
CREATE UNIQUE NONCLUSTERED INDEX id
    ON phround(swid)
;

if exists(select * from sysobjects where name = "phsvcset") --�����������
	drop table phsvcset;
CREATE TABLE phsvcset 
(
    fid        char(2) NOT NULL, --����Ѵ���
    ext_fee    money   NOT NULL, --�������
    adj_rate   float   NOT NULL, --ʵ�ʷ���
    serve_rate float   NOT NULL, --�������
    min_serve  money   NOT NULL, --��С����
    dial_fee   money   NOT NULL, --���ŷ�
    other_fee  money   NOT NULL --��������
)

EXEC sp_primarykey phsvcset, fid
CREATE UNIQUE NONCLUSTERED INDEX fid
    ON dbo.phsvcset(fid)
;

if exists(select * from sysobjects where name = "phtimeanal") --���㻰����ʱ��
	drop table phtimeanal;
CREATE TABLE phtimeanal 
(
    pc_id    char(4) DEFAULT '0.01' NULL, --����ip
    modu_id  char(2) DEFAULT '05' NULL, --ģ��id
    id       char(2) DEFAULT '-' NULL,--id
    startt   char(8) NULL,--��ʼʱ��
    endt     char(8) NULL,--����ʱ��
    factor   money   NULL,--ʵ�ʷ���
    duration money   NULL --ʱ��
)
CREATE UNIQUE NONCLUSTERED INDEX id
    ON phtimeanal(pc_id ,id ,modu_id)
;

if exists(select * from sysobjects where name = "phtimedef") --�Ż�ʱ������
	drop table phtimedef;
CREATE TABLE phtimedef 
(
    gid       char(2)  NOT NULL, --��id
    id        char(2)  NOT NULL,--id
    timedesc  char(30) NOT NULL,--����
    datecond  char(60) NOT NULL,--ʱ�����
    starttime char(8)  NOT NULL,--��ʼʱ��
    endtime   char(8)  NOT NULL,--����ʱ��
    fact      money    NOT NULL --ʵ�ʷ���
)

EXEC sp_primarykey phtimedef, gid,id
CREATE UNIQUE NONCLUSTERED INDEX id
    ON phtimedef(gid ,id)
;

if exists(select * from sysobjects where name = "phtimename") --ʱ������
	drop table phtimename;
CREATE TABLE phtimename 
(
    id       char(2)  NOT NULL, --id
    descript char(20) NOT NULL --����
)

EXEC sp_primarykey 'dbo.phtimename', id

CREATE UNIQUE CLUSTERED INDEX index1
    ON dbo.phtimename(id)
;

if exists(select * from sysobjects where name = "phuserdef") --�û�����
	drop table phuserdef;
CREATE TABLE phuserdef 
(
    rgid     char(2)  NOT NULL,  --�ּ�����
    descript char(30) NOT NULL --����
)

EXEC sp_primarykey phuserdef, rgid

CREATE UNIQUE NONCLUSTERED INDEX rgig
    ON phuserdef(rgid)
;

if exists(select * from sysobjects where name = "phone_type") --�û�����
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

if exists(select * from sysobjects where name = "phauerrlog")  --�Զ����ʴ�����Ϣ
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
