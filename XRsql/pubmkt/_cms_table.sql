------------------------------------------------------
--	Ó¶½ð´úÂëÖ®Ã÷Ï¸´úÂë
------------------------------------------------------
//exec sp_rename cms_defitem, a_cms_defitem;
if object_id('cms_defitem') is not null
	drop table cms_defitem
;
CREATE TABLE cms_defitem 
(
    no        char(10)     NOT NULL,					//·µÓ¶±àºÅ
    unit      char(1)      DEFAULT '0' NOT NULL,	//·µÓ¶µ¥Î» 0 £­ /¼ä    1 - /´Î
    type      char(1)      DEFAULT '0' NOT NULL,	//·µÓ¶ÀàÐÍ 0 £­ °´±ÈÀý 1 £­¶¨¶î 2 - µ×¼Û 
    rmtype    varchar(255)  DEFAULT '' NOT NULL,		//·¿Àà
    amount    money        DEFAULT 0 NOT NULL,		//·µÓ¶±ÈÀý»ò½ð¶î
    dayuse    char(2)      DEFAULT 'TT' NOT NULL,	//¼ÓÊÕÊÇ·ñ·µÓ¶ T £­ÊÇ  F £­ ·ñ
    uproom1   money        DEFAULT 0 NOT NULL,		//½×ÌÝ·µÓ¶¼äÊý1
    upamount1 money        DEFAULT 0 NOT NULL,		//·µÓ¶±ÈÀý»ò½ð¶î1
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
    rmtype_s  char(1)      DEFAULT 'F' NOT NULL,	//ÏÖÒÑÈ¡Ïû ½×ÌÝ·µÓ¶·Ö·¿ÀàÍ³¼Æ¼äÌì T £­ÊÇ  F £­ ·ñ
    name      varchar(30)     DEFAULT '' NOT NULL,		//Ãû³Æ
    datecond  varchar(100) 				NULL,			//·µÓ¶ÈÕÆÚÌõ¼þ£¬²ÉÓÃµç»°Ê±¶ÎµÄÊäÈë·¨ 
	 extra     char(10)     DEFAULT '0000000000' not null,//Ö»ÓÃÁËÇ°2Î»£¬µÚÒ»Î»¿Û³ý°ü¼Û£¬µÚ¶þÎ»¿Û³ý·þÎñ·Ñ£

	 d_line    money        DEFAULT 0 NOT NULL,            //µ×¼Û
	 begin_		datetime						null,
	 end_			datetime						null		 
);
EXEC sp_primarykey 'cms_defitem', no;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON cms_defitem(no);
//insert cms_defitem select *, null, null from a_cms_defitem;
//update cms_defitem set dayuse=substring(dayuse,1,1)+'T' ;
//drop table a_cms_defitem;

------------------------------------------------------
--	Ó¶½ð´úÂë
------------------------------------------------------
//exec sp_rename cmscode, a_cmscode;
if object_id('cmscode') is not null
	drop table cmscode
;
CREATE TABLE cmscode 
(
    code      char(10)    NOT NULL,						// ·µÓ¶Âë±àºÅ
    descript  varchar(60) NOT NULL,						// ÖÐÎÄÃèÊö
    descript1 varchar(60) NOT NULL,						// Ó¢ÎÄÃèÊö
    halt      char(1)     DEFAULT 'F' NOT NULL,		// Í£ÓÃ±êÖ¾    T £­Í£ÓÃ  F £­ ·ñ 
    upmode    char(1)     NOT NULL,						// ½×ÌÝ·µÓ¶Ê±¼ä¶Î M ÔÂ Y Äê J ¼¾ A ²»ÏÞ
    rmtype_s  char(1)     DEFAULT 'F' NOT NULL,		// ½×ÌÝ·µÓ¶·Ö·¿ÀàÍ³¼Æ¼äÌì T £­ÊÇ  F £­ ·ñ
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
--	Ó¶½ð´úÂë ¶ÔÓ¦ Ã÷Ï¸´úÂë
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
--	Ó¶½ð¼ÇÂ¼
------------------------------------------------------
//exec sp_rename cms_rec, a_cms_rec; 
if object_id('cms_rec') is not null
	drop table cms_rec
;
CREATE TABLE cms_rec 
(
    id        numeric(10,0) IDENTITY,
    sta       char(1)       DEFAULT 'I' NOT NULL,	-- Ó¶½ð¼ÍÂ¼µÄ×´Ì¬ I=ÓÐÐ§ X=É¾³ý U=ÎÞÐ§ 
	 auto		  char(1)       default 'F' not null,	-- ÊÇ·ñÎª×Ô¶¯·¿·ÑÈëÕË²úÉúµÄ¡£
    bdate     datetime      NOT NULL,
    accnt     char(10)      NOT NULL,					-- ²úÉúÓ¶½ðµÄÔ­Ê¼ÕËºÅ 
    name      varchar(50)   NOT NULL,
    to_accnt  char(10)      default '' NOT NULL,					-- ·¿·ÑÓÐ×ªÕËÊ±ºòµÄÕÊºÅ 
    number    int           default 0  not NULL,	-- ²úÉúÓ¶½ðµÄ·¿·ÑÔÚ account ÖÐµÄÕÊ´Î£¬¶ÔÓ¦ÕËºÅÊÇ accnt or to_accnt 
    type      char(5)       default '' not NULL,	-- ·¿Àà
    roomno    char(5)       default '' not NULL,
    belong    char(10)      default '' not NULL,  -- Ó¶½ðµÄ×îÖÕ¹éÊôµ¥Î» 
    cusno     char(10)      default '' not NULL,
    agent     char(10)      default '' not NULL,
    source    char(10)      default '' not NULL,
    arr       datetime      NULL,
    dep       datetime      NULL,
    rmrate    money         DEFAULT 0	 NOT NULL,	-- ·¿·Ñ
    exrate    money         DEFAULT 0	 NOT NULL,	-- ¼Ó´²
    dsrate    money         DEFAULT 0	 NOT NULL,	-- ÕÛ¿Û
    rmsur     money         DEFAULT 0	 NOT NULL,	-- ·þÎñ·Ñ
    rmtax     money         DEFAULT 0	 NOT NULL,	-- Ë°
    w_or_h    money         DEFAULT 0	 NOT NULL,	-- È«Ìì/°ëÌì 
	 netrate   money			 DEFAULT 0	 NOT NULL,	-- ¾»·¿¼Û
	 packrate  money		    DEFAULT 0	 NOT NULL,	-- °ü¼Û·Ñ
    mode      char(10)      DEFAULT '' NOT NULL,	-- account.mode 
    ratecode  char(10)      DEFAULT '' NOT NULL,	-- ·¿¼ÛÂë
    cmscode   char(10)      DEFAULT '' NOT NULL,	-- Ó¶½ðÂë
    cmsunit   char(1)       DEFAULT '' NOT NULL,
    cmstype   char(1)       DEFAULT '' NOT NULL,
    cmsvalue  money         DEFAULT 0	 NOT NULL,
    cms0      money         DEFAULT 0	 NOT NULL,   -- ×îºóÈ·¶¨µÄÓ¶½ð
    cms       money         DEFAULT 0	 NOT NULL,   -- ÉÏÒ»´ÎÈ·¶¨µÄÓ¶½ð 
    ref       varchar(60)   DEFAULT ''	 NULL,

    post      char(10)      NOT NULL,					-- µ±Ç°Ó¶½ð¼ÇÂ¼µÄ²úÉú¹¤ºÅ 
    postdate  datetime      NOT NULL,
    back      char(10)      DEFAULT 'F' NOT NULL,	-- ÊÇ·ñÒÑ¾­¿Û¼õ·¿·Ñ £¿
    market    char(3)       default ''  NOT NULL,	-- ÊÐ³¡Âë
    cmsdetail char(10)      NULL,						-- Ó¶½ðÃ÷Ï¸Âë

    isaudit   char(1)       DEFAULT 'F' not NULL,		-- ÊÇ·ñÒÑ¾­ÉóºË £¿
    auditby   varchar(10)   NULL,
    auditdate datetime      NULL,

    ispaied   int           default 0   not NULL,	-- ¶ÔÓ¦»ØÓ¶id = cms_pay_history 
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

-- Ó¶½ðÖ§¸¶¼ÇÂ¼  Dev1 Joy 
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
    payby     varchar(10) NULL,  -- Ö§¸¶ÈËÐÅÏ¢
    paydate   datetime    NULL,
    cby       varchar(10) NULL,	-- µçÄÔ²Ù×÷ÈËÐÅÏ¢ 
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


-- Ó¶½ðtop list -  Dev1 Joy 
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



