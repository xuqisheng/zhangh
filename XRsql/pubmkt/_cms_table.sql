------------------------------------------------------
--	Ӷ�����֮��ϸ����
------------------------------------------------------
//exec sp_rename cms_defitem, a_cms_defitem;
if object_id('cms_defitem') is not null
	drop table cms_defitem
;
CREATE TABLE cms_defitem 
(
    no        char(10)     NOT NULL,					//��Ӷ���
    unit      char(1)      DEFAULT '0' NOT NULL,	//��Ӷ��λ 0 �� /��    1 - /��
    type      char(1)      DEFAULT '0' NOT NULL,	//��Ӷ���� 0 �� ������ 1 ������ 2 - �׼� 
    rmtype    varchar(255)  DEFAULT '' NOT NULL,		//����
    amount    money        DEFAULT 0 NOT NULL,		//��Ӷ��������
    dayuse    char(2)      DEFAULT 'TT' NOT NULL,	//�����Ƿ�Ӷ T ����  F �� ��
    uproom1   money        DEFAULT 0 NOT NULL,		//���ݷ�Ӷ����1
    upamount1 money        DEFAULT 0 NOT NULL,		//��Ӷ��������1
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
    rmtype_s  char(1)      DEFAULT 'F' NOT NULL,	//����ȡ�� ���ݷ�Ӷ�ַ���ͳ�Ƽ��� T ����  F �� ��
    name      varchar(30)     DEFAULT '' NOT NULL,		//����
    datecond  varchar(100) 				NULL,			//��Ӷ�������������õ绰ʱ�ε����뷨 
	 extra     char(10)     DEFAULT '0000000000' not null,//ֻ����ǰ2λ����һλ�۳����ۣ��ڶ�λ�۳�����ѣ

	 d_line    money        DEFAULT 0 NOT NULL,            //�׼�
	 begin_		datetime						null,
	 end_			datetime						null		 
);
EXEC sp_primarykey 'cms_defitem', no;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON cms_defitem(no);
//insert cms_defitem select *, null, null from a_cms_defitem;
//update cms_defitem set dayuse=substring(dayuse,1,1)+'T' ;
//drop table a_cms_defitem;

------------------------------------------------------
--	Ӷ�����
------------------------------------------------------
//exec sp_rename cmscode, a_cmscode;
if object_id('cmscode') is not null
	drop table cmscode
;
CREATE TABLE cmscode 
(
    code      char(10)    NOT NULL,						// ��Ӷ����
    descript  varchar(60) NOT NULL,						// ��������
    descript1 varchar(60) NOT NULL,						// Ӣ������
    halt      char(1)     DEFAULT 'F' NOT NULL,		// ͣ�ñ�־    T ��ͣ��  F �� �� 
    upmode    char(1)     NOT NULL,						// ���ݷ�Ӷʱ��� M �� Y �� J �� A ����
    rmtype_s  char(1)     DEFAULT 'F' NOT NULL,		// ���ݷ�Ӷ�ַ���ͳ�Ƽ��� T ����  F �� ��
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
--	Ӷ����� ��Ӧ ��ϸ����
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
--	Ӷ���¼
------------------------------------------------------
//exec sp_rename cms_rec, a_cms_rec; 
if object_id('cms_rec') is not null
	drop table cms_rec
;
CREATE TABLE cms_rec 
(
    id        numeric(10,0) IDENTITY,
    sta       char(1)       DEFAULT 'I' NOT NULL,	-- Ӷ���¼��״̬ I=��Ч X=ɾ�� U=��Ч 
	 auto		  char(1)       default 'F' not null,	-- �Ƿ�Ϊ�Զ��������˲����ġ�
    bdate     datetime      NOT NULL,
    accnt     char(10)      NOT NULL,					-- ����Ӷ���ԭʼ�˺� 
    name      varchar(50)   NOT NULL,
    to_accnt  char(10)      default '' NOT NULL,					-- ������ת��ʱ����ʺ� 
    number    int           default 0  not NULL,	-- ����Ӷ��ķ����� account �е��ʴΣ���Ӧ�˺��� accnt or to_accnt 
    type      char(5)       default '' not NULL,	-- ����
    roomno    char(5)       default '' not NULL,
    belong    char(10)      default '' not NULL,  -- Ӷ������չ�����λ 
    cusno     char(10)      default '' not NULL,
    agent     char(10)      default '' not NULL,
    source    char(10)      default '' not NULL,
    arr       datetime      NULL,
    dep       datetime      NULL,
    rmrate    money         DEFAULT 0	 NOT NULL,	-- ����
    exrate    money         DEFAULT 0	 NOT NULL,	-- �Ӵ�
    dsrate    money         DEFAULT 0	 NOT NULL,	-- �ۿ�
    rmsur     money         DEFAULT 0	 NOT NULL,	-- �����
    rmtax     money         DEFAULT 0	 NOT NULL,	-- ˰
    w_or_h    money         DEFAULT 0	 NOT NULL,	-- ȫ��/���� 
	 netrate   money			 DEFAULT 0	 NOT NULL,	-- ������
	 packrate  money		    DEFAULT 0	 NOT NULL,	-- ���۷�
    mode      char(10)      DEFAULT '' NOT NULL,	-- account.mode 
    ratecode  char(10)      DEFAULT '' NOT NULL,	-- ������
    cmscode   char(10)      DEFAULT '' NOT NULL,	-- Ӷ����
    cmsunit   char(1)       DEFAULT '' NOT NULL,
    cmstype   char(1)       DEFAULT '' NOT NULL,
    cmsvalue  money         DEFAULT 0	 NOT NULL,
    cms0      money         DEFAULT 0	 NOT NULL,   -- ���ȷ����Ӷ��
    cms       money         DEFAULT 0	 NOT NULL,   -- ��һ��ȷ����Ӷ�� 
    ref       varchar(60)   DEFAULT ''	 NULL,

    post      char(10)      NOT NULL,					-- ��ǰӶ���¼�Ĳ������� 
    postdate  datetime      NOT NULL,
    back      char(10)      DEFAULT 'F' NOT NULL,	-- �Ƿ��Ѿ��ۼ����� ��
    market    char(3)       default ''  NOT NULL,	-- �г���
    cmsdetail char(10)      NULL,						-- Ӷ����ϸ��

    isaudit   char(1)       DEFAULT 'F' not NULL,		-- �Ƿ��Ѿ���� ��
    auditby   varchar(10)   NULL,
    auditdate datetime      NULL,

    ispaied   int           default 0   not NULL,	-- ��Ӧ��Ӷid = cms_pay_history 
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

-- Ӷ��֧����¼  Dev1 Joy 
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
    payby     varchar(10) NULL,  -- ֧������Ϣ
    paydate   datetime    NULL,
    cby       varchar(10) NULL,	-- ���Բ�������Ϣ 
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


-- Ӷ��top list -  Dev1 Joy 
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



