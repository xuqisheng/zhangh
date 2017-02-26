//********************吧台管理主要表结构及其说明***********************
--1.吧台物品大类表
if exists(select * from sysobjects where name = "pos_st_class" and type ="U")
	drop table pos_st_class;
CREATE TABLE dbo.pos_st_class 
(
    code     char(12) NOT NULL,
    name     char(10) NOT NULL,
    eng_name char(60) DEFAULT '' NULL
);
EXEC sp_primarykey 'dbo.pos_st_class', code;

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_st_class(code);

CREATE UNIQUE NONCLUSTERED INDEX index2
    ON dbo.pos_st_class(name);

--2.吧台物品小类表
if exists(select * from sysobjects where name = "pos_st_subclass" and type ="U")
	drop table pos_st_subclass;
CREATE TABLE dbo.pos_st_subclass 
(
    code      char(12) NOT NULL,
    name      char(16) NOT NULL,
    cseg      char(10) DEFAULT '' NOT NULL,  --所属大类编码
    cname     char(10) DEFAULT '' NOT NULL,
    cstype    char(2)  DEFAULT '' NULL,
    eng_name  char(60) DEFAULT '' NULL,
    eng_cname char(60) DEFAULT '' NULL
);
EXEC sp_primarykey 'dbo.pos_st_subclass', code;


CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_st_subclass(code);

--3.吧台物品表
if exists(select * from sysobjects where name = "pos_st_article" and type ="U")
	drop table pos_st_article;
CREATE TABLE dbo.pos_st_article 
(
    code        char(12) NOT NULL,
    name        char(40) NOT NULL,
    unit        char(6)  NOT NULL,
    price       money    DEFAULT 0 NOT NULL,
    max_quan    money    DEFAULT 0 NOT NULL,				--备用
    min_quan    money    DEFAULT 0 NOT NULL,				--备用
    sseg        char(12) DEFAULT '' NOT NULL,			
    sname       char(16) DEFAULT '' NOT NULL,
    cseg        char(12) DEFAULT '' NOT NULL,
    cname       char(10) DEFAULT '' NOT NULL,
    oactmode    char(10) DEFAULT 'RR 2' NOT NULL,
    actmode     char(10) DEFAULT 'RR 2' NOT NULL,
    helpcode    char(60) DEFAULT '' NOT NULL,			--与后台不一致
    standent    char(16) DEFAULT '' NOT NULL,			--与后台不一致【长度加大】
    band        char(10) DEFAULT '' NOT NULL,			--备用
    warning     int      DEFAULT 0 NOT NULL,				--备用
    lpno        int      DEFAULT 0 NOT NULL,				--先进先出批号
    lprice      money    DEFAULT 0 NOT NULL,				--备用
    unit2       char(6)  DEFAULT '' NOT NULL,			--备用
    equn2       money    DEFAULT 0 NOT NULL,				--备用
    minprice    money    DEFAULT 0 NOT NULL,				--备用
    minsup      char(14) DEFAULT '' NOT NULL,			--备用
    maxprice    money    DEFAULT 0 NOT NULL,				--备用
    maxsup      char(14) DEFAULT '' NOT NULL,			--备用
    avprice     money    DEFAULT 0  	 NOT NULL,		--备用
    storage     char(2)  DEFAULT '' 	 NOT NULL,		--备用【存货类别ABC分类】
    quocode     char(3)  DEFAULT '0' NOT NULL,			--备用
    csnumber    money    DEFAULT 0 	 NOT NULL,
    csunit      char(4)  DEFAULT '' 	 NOT NULL,
    csbili      int      DEFAULT 0 	 NOT NULL,			--备用
    cstype      char(2)  DEFAULT ''	 NOT NULL,			--成本属性
    safe_quan   money    DEFAULT 0 	 NOT NULL,			--备用
    valid       char(1)  DEFAULT '1' NOT NULL,			--有效性：1有效，0无效【与后台不一致】
    ref         char(60) DEFAULT '' 	 NOT NULL,
    sale_price  money    DEFAULT 0 	 NOT NULL,				--备用
    limitnumber money    DEFAULT 0 	 NOT NULL,    			--备用
    eng_name    char(60) DEFAULT '' NULL,
    eng_sname   char(60) DEFAULT '' NULL,
    eng_cname   char(60) DEFAULT '' NULL
)

EXEC sp_primarykey 'dbo.pos_st_article', code;

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_st_article(code);
    
--4.成本卡
if exists(select * from sysobjects where name = "pos_pldef_price" and type ="U")
	drop table pos_pldef_price;
CREATE TABLE dbo.pos_pldef_price 
(
    pccode   char(3)  NOT NULL,
    id       int      DEFAULT 0	 NOT NULL,
    inumber  int      DEFAULT 0	 NOT NULL,
    artcode  char(12) DEFAULT ''	 NOT NULL,				--用于后台物品码
    unit     char(4)  DEFAULT ''	 NOT NULL,        --菜品单位
    descript char(40) DEFAULT '' NOT NULL,
    number   money    DEFAULT 0	 NOT NULL,					--原料配比数量
    article  char(12) DEFAULT '' NOT NULL,					--用于吧台管理与artcode只取其一
    csunit   char(4)  DEFAULT '' NOT NULL,					--原料单位
    price    money    DEFAULT 0 NOT NULL,						--原料单价
    rate     money    DEFAULT 0 NOT NULL,						--除净率
    condid   int      DEFAULT 0  NULL								--已无用
);
EXEC sp_primarykey 'dbo.pos_pldef_price', id,inumber,artcode,article;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_pldef_price(id,inumber,artcode,article);
    
--5.物流业务单据主单
if exists(select * from sysobjects where name = "pos_st_documst" and type ="U")
	drop table pos_st_documst;
CREATE TABLE dbo.pos_st_documst 
(
    id       int         NOT NULL,
    lockmark char(4)     NULL,
    ostcode  char(3)     NULL,          --出库
    istcode   char(3)     NOT NULL,		 --入库
    vdate    datetime    NOT NULL,
    vtype    char(2)     NOT NULL,
    vno      int         DEFAULT 0 NULL,
    spcode   char(4)     NULL,
    invoice  char(10)    NULL,
    ref      varchar(60) DEFAULT '' NULL,
    vmark    char(2)     DEFAULT '' NOT NULL,    //内部标志=''表示业务单据;'A'- "OY"记录帐余数量和金额;'B' - "RR"期初结转单;'E':期未结转单,在历史收发存中抵消期初转入单据　
    empno    char(10)     DEFAULT '' NOT NULL,	 --操作员
    log_date datetime    DEFAULT getdate() NOT NULL,    --备用
    logmark  int         DEFAULT 0 NOT NULL,				  --备用
    empno0   char(10)     DEFAULT '' NOT NULL,           --收货人【备用】
	 empno1   char(10)     DEFAULT '' NOT NULL,			  --发货人【备用】
    costitem char(5)     DEFAULT '' NOT NULL,           --备用用于成本系统
    paymth   char(5)     DEFAULT '' NOT NULL,			  --付款方式
    tag     char(1)     DEFAULT '' NOT NULL				  --保留标志
);

EXEC sp_primarykey 'dbo.pos_st_documst', vdate,vtype,vno,id;

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_st_documst(vdate,vtype,vno,id);

CREATE UNIQUE NONCLUSTERED INDEX index2
    ON dbo.pos_st_documst(id);

CREATE UNIQUE NONCLUSTERED INDEX index3
    ON dbo.pos_st_documst(vtype,vdate,vno,id);
    

--6.物流业务单据明细
if exists(select * from sysobjects where name = "pos_st_docudtl" and type ="U")
	drop table pos_st_docudtl;
CREATE TABLE dbo.pos_st_docudtl         --参照后台系统st_docu_dtl
(
    id        int      NOT NULL,
    subid     int      NOT NULL,
    code      char(12) NOT NULL,
    number    money    DEFAULT 0 NOT NULL,
    amount    money    DEFAULT 0 NOT NULL,
    price     money    DEFAULT 0 NOT NULL,
    validdate datetime DEFAULT getdate() NOT NULL,
    tax       money    DEFAULT 0 NOT NULL,												--以下备用
    deliver   money    DEFAULT 0 NOT NULL,
    rebate    money    DEFAULT 0 NOT NULL,
    csaccnt   char(12) DEFAULT '' NOT NULL,
    prid      int      DEFAULT 0 NOT NULL,
    tag       char(1)  DEFAULT '' NOT NULL,
    productor char(60) DEFAULT '' NOT NULL,
    pdate     datetime DEFAULT getdate() NOT NULL,
    kpdays    char(10) DEFAULT '' NOT NULL,
    note      char(50) DEFAULT '' NOT NULL
);
EXEC sp_primarykey 'dbo.pos_st_docudtl', id,code,subid
;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_st_docudtl(id,code,subid)
;
CREATE UNIQUE NONCLUSTERED INDEX index2
    ON dbo.pos_st_docudtl(id,subid)
;

--7.餐饮吧台日结状态记录
if exists(select * from sysobjects where name = "pos_store_checkout" and type ="U")
	drop table pos_store_checkout;
CREATE TABLE dbo.pos_store_checkout                --餐饮吧台库存结转
(
    pc_id	char(4) default '' not null,
	 code 	char(2) default ''  NOT NULL,							--日结所需做的工作ID
    descript	char(40)	default '' NOT NULL, 			--日结所需做的工作描述                 
    flag  char(1) NOT NULL										--成功与否的标志
);

EXEC sp_primarykey 'dbo.pos_store_checkout', pc_id,code;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_store_checkout( pc_id,code);


--8.库存记录表
if exists(select * from sysobjects where name = "pos_store_stock" and type ="U")
	drop table pos_store_stock;
CREATE TABLE dbo.pos_store_stock                 --物品实时库存表 
(
    istcode char(3)  NOT NULL,							--库存仓库编码
    code    char(12)      NOT NULL, 					--物品编码                  
    price  money NOT NULL,									--库存平均价(单据价格来源)
    number    money    NOT NULL,							--库存数量
	 amount    money    NOT NULL							--库存金额
);

EXEC sp_primarykey 'dbo.pos_store_stock', istcode,code;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_store_stock(istcode,code);
    
--9.吧台定义表
if exists(select * from sysobjects where name = "pos_store" and type ="U")
	drop table pos_store;
CREATE TABLE dbo.pos_store 
(
    code      char(3)   NOT NULL,         --吧台码
    descript  char(20)  NOT NULL,
    descript1 char(50)  NULL,
    pccodes   char(100) NOT NULL,					--对应营业点码
    empno     char(10)  DEFAULT ''	 NOT NULL,
    sup       char(6)   NULL,						  --无用
    barcode   char(5)   NULL							--无用
)
;
EXEC sp_primarykey 'dbo.pos_store', code
;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_store(code)
;
