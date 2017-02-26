------------------------------------------------------
--	佣金代码之明细代码
------------------------------------------------------
//exec sp_rename cms_defitem, a_cms_defitem;
if object_id('cms_defitem') is not null
	drop table cms_defitem
;
CREATE TABLE cms_defitem 
(
    no        char(10)     NOT NULL,					//返佣编号
    unit      char(1)      DEFAULT '0' NOT NULL,	//返佣单位 0 － /间    1 - /次
    type      char(1)      DEFAULT '0' NOT NULL,	//返佣类型 0 － 按比例 1 －定额 2 - 底价 
    rmtype    varchar(255)  DEFAULT '' NOT NULL,		//房类
    amount    money        DEFAULT 0 NOT NULL,		//返佣比例或金额
    dayuse    char(2)      DEFAULT 'TT' NOT NULL,	//加收是否返佣 T －是  F － 否
    uproom1   money        DEFAULT 0 NOT NULL,		//阶梯返佣间数1
    upamount1 money        DEFAULT 0 NOT NULL,		//返佣比例或金额1
    uproom2   money        DEFAULT 0 NOT NULL,
    upamount2 money        DEFAULT 0 NOT NULL,
    uproom3   money        DEFAULT 0 NOT NULL,
    upamount3 money        DEFAULT 0 NOT NULL,
    uproom4   money        DEFAULT 0 NOT NULL,
    upamount4 money        DEFAULT 0 NOT NULL,
    uproom5   money        DEFAULT 0 NOT NULL,
    upamount5 money        DEFAULT 0 NOT NULL,
    uproom6   money        DEFAULT 0 NOT NULL,
    upamount6 money        DEFAULT 0 NOT NULL,
    uproom7   money        DEFAULT 0 NOT NULL,
    upamount7 money        DEFAULT 0 NOT NULL,
    rmtype_s  char(1)      DEFAULT 'F' NOT NULL,	//现已取消 阶梯返佣分房类统计间天 T －是  F － 否
    name      varchar(30)     DEFAULT '' NOT NULL,		//名称
    datecond  varchar(100) 				NULL,			//返佣日期条件，采用电话时段的输入法 
	 extra     char(10)     DEFAULT '0000000000' not null,//只用了前2位，第一位扣除包价，第二位扣除服务费�

	 d_line    money        DEFAULT 0 NOT NULL,            //底价
	 begin_		datetime						null,
	 end_			datetime						null		 
);
EXEC sp_primarykey 'cms_defitem', no;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON cms_defitem(no);
//insert cms_defitem select *, null, null from a_cms_defitem;
//update cms_defitem set dayuse=substring(dayuse,1,1)+'T' ;
//drop table a_cms_defitem;

------------------------------------------------------
--	佣金代码
------------------------------------------------------
//exec sp_rename cmscode, a_cmscode;
if object_id('cmscode') is not null
	drop table cmscode
;
CREATE TABLE cmscode 
(
    code      char(10)    NOT NULL,						// 返佣码编号
    descript  varchar(60) NOT NULL,						// 中文描述
    descript1 varchar(60) NOT NULL,						// 英文描述
    halt      char(1)     DEFAULT 'F' NOT NULL,		// 停用标志    T －停用  F － 否 
    upmode    char(1)     NOT NULL,						// 阶梯返佣时间段 M 月 Y 年 J 季 A 不限
    rmtype_s  char(1)     DEFAULT 'F' NOT NULL,		// 阶梯返佣分房类统计间天 T －是  F － 否
	 sequence		int		default 0 	not null,
	 begin_		datetime		null,
	 end_ 		datetime		null,
	 flag			char(20) 	default '' not null
);
EXEC sp_primarykey 'cmscode', code;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON cmscode(code)
CREATE UNIQUE NONCLUSTERED INDEX index2 ON cmscode(descript)
;
//insert cmscode select *, null, null, '' from a_cmscode;
//drop table a_cmscode;
//select * from cmscode; 

------------------------------------------------------
--	佣金代码 对应 明细代码
------------------------------------------------------
if object_id('cmscode_link') is not null
	drop table cmscode_link
;
CREATE TABLE cmscode_link 
(
    code    char(10) NOT NULL,
    pri     int      DEFAULT 0 NOT NULL,
    cmscode char(10) NOT NULL
);
EXEC sp_primarykey 'cmscode_link', code,pri;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON cmscode_link(code,pri)
CREATE UNIQUE NONCLUSTERED INDEX index2 ON cmscode_link(code,cmscode)
;

------------------------------------------------------
--	佣金记录
------------------------------------------------------
//exec sp_rename cms_rec, a_cms_rec; 
if object_id('cms_rec') is not null
	drop table cms_rec
;
CREATE TABLE cms_rec 
(
    id        numeric(10,0) IDENTITY,
    sta       char(1)       DEFAULT 'I' NOT NULL,	-- 佣金纪录的状态 I=有效 X=删除 U=无效 
	 auto		  char(1)       default 'F' not null,	-- 是否为自动房费入账产生的。
    bdate     datetime      NOT NULL,
    accnt     char(10)      NOT NULL,					-- 产生佣金的原始账号 
    name      varchar(50)   NOT NULL,
    to_accnt  char(10)      default '' NOT NULL,					-- 房费有转账时候的帐号 
    number    int           default 0  not NULL,	-- 产生佣金的房费在 account 中的帐次，对应账号是 accnt or to_accnt 
    type      char(5)       default '' not NULL,	-- 房类
    roomno    char(5)       default '' not NULL,
    belong    char(10)      default '' not NULL,  -- 佣金的最终归属单位 
    cusno     char(10)      default '' not NULL,
    agent     char(10)      default '' not NULL,
    source    char(10)      default '' not NULL,
    arr       datetime      NULL,
    dep       datetime      NULL,
    rmrate    money         DEFAULT 0	 NOT NULL,	-- 房费
    exrate    money         DEFAULT 0	 NOT NULL,	-- 加床
    dsrate    money         DEFAULT 0	 NOT NULL,	-- 折扣
    rmsur     money         DEFAULT 0	 NOT NULL,	-- 服务费
    rmtax     money         DEFAULT 0	 NOT NULL,	-- 税
    w_or_h    money         DEFAULT 0	 NOT NULL,	-- 全天/半天 
	 netrate   money			 DEFAULT 0	 NOT NULL,	-- 净房价
	 packrate  money		    DEFAULT 0	 NOT NULL,	-- 包价费
    mode      char(10)      DEFAULT '' NOT NULL,	-- account.mode 
    ratecode  char(10)      DEFAULT '' NOT NULL,	-- 房价码
    cmscode   char(10)      DEFAULT '' NOT NULL,	-- 佣金码
    cmsunit   char(1)       DEFAULT '' NOT NULL,
    cmstype   char(1)       DEFAULT '' NOT NULL,
    cmsvalue  money         DEFAULT 0	 NOT NULL,
    cms0      money         DEFAULT 0	 NOT NULL,   -- 最后确定的佣金
    cms       money         DEFAULT 0	 NOT NULL,   -- 上一次确定的佣金 
    ref       varchar(60)   DEFAULT ''	 NULL,

    post      char(10)      NOT NULL,					-- 当前佣金记录的产生工号 
    postdate  datetime      NOT NULL,
    back      char(10)      DEFAULT 'F' NOT NULL,	-- 是否已经扣减房费 ？
    market    char(3)       default ''  NOT NULL,	-- 市场码
    cmsdetail char(10)      NULL,						-- 佣金明细码

    isaudit   char(1)       DEFAULT 'F' not NULL,		-- 是否已经审核 ？
    auditby   varchar(10)   NULL,
    auditdate datetime      NULL,

    ispaied   int           default 0   not NULL,	-- 对应回佣id = cms_pay_history 
    payby     varchar(10)   NULL,
    paydate   datetime      NULL,

    cby       char(10)      NOT NULL,
    changed   datetime      NOT NULL,
	 logmark   int           default 0  not null
)
CREATE UNIQUE NONCLUSTERED INDEX index0  ON cms_rec(id)
CREATE NONCLUSTERED INDEX index1 ON cms_rec(postdate,accnt)
CREATE NONCLUSTERED INDEX index2 ON cms_rec(accnt,postdate)
CREATE NONCLUSTERED INDEX index3 ON cms_rec(bdate,cmscode)
CREATE NONCLUSTERED INDEX index4 ON cms_rec(belong,bdate)

;
//insert cms_rec (sta,auto,bdate,accnt,name,to_accnt,number,type,roomno,belong,cusno,agent,source,arr,dep,
//	rmrate,exrate,dsrate,rmsur,rmtax,w_or_h,mode,cmscode,cmsunit,cmstype,cmsvalue,cms0,cms,ref,
//	post,postdate,back,market,cmsdetail,isaudit,auditby,auditdate,ispaied,payby,paydate,cby,changed,logmark)
//SELECT sta,'T',bdate,accnt,name,to_accnt,number,type,roomno,agent,cusno,agent,source,arr,dep,
//	rmrate,exrate,dsrate,rmsur,rmtax,w_or_h,mode,cmscode,cmsunit,cmstype,cmsvalue,cms0,cms,ref,
//	post,postdate,back,market,cmsdetail,isaudit,auditby,auditdate,isnull(ispaied,0) ,payby,paydate,cby,changed,0  
//FROM a_cms_rec  ;
//update cms_rec set belong=source where belong='';
//update cms_rec set belong=cusno where belong='';
//delete cms_rec where belong='';
//drop table a_cms_rec; 

-- 佣金支付记录  Dev1 Joy 
//exec sp_rename cms_pay_history, a_cms_pay_history; 
if object_id('cms_pay_history') is not null
	drop table cms_pay_history
;
CREATE TABLE cms_pay_history 
(
    cms_id    int         NOT NULL,
    cms_cusid varchar(10) NOT NULL,
    cms0sum   money       NULL,
    w_or_hsum money       NULL,
    begindate datetime    NULL,
    enddate   datetime    NULL,
    payby     varchar(10) NULL,  -- 支付人信息
    paydate   datetime    NULL,
    cby       varchar(10) NULL,	-- 电脑操作人信息 
    cbydate   datetime    NULL,
    billno    varchar(10) NULL
)
EXEC sp_primarykey 'cms_pay_history', cms_id;
create unique index index1 on cms_pay_history(cms_id);
//insert cms_pay_history 
//	SELECT cms_id,cms_cusid,cms0sum,w_or_hsum,begindate,enddate,cby,cbydate,cby,cbydate,billno 
//	FROM a_cms_pay_history  ;
//select * from cms_pay_history;
//drop table a_cms_pay_history;


-- 佣金top list -  Dev1 Joy 
if object_id('cms_toplist') is not null
	drop table cms_toplist
;
CREATE TABLE cms_toplist 
(
    no        varchar(10)  NOT NULL,
    descript  varchar(100) NULL,
    cms0total money        NULL,
    begindate datetime     NULL,
    enddate   datetime     NULL
)
EXEC sp_primarykey 'cms_toplist', no;
create unique index index1 on cms_toplist(no);



