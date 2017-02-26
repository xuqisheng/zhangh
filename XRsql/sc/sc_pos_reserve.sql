create table sc_pos_reserve
(
	resno					char(10)				not null,
	tag					char(1)				not null,	/*�Ͳ����*/        -- N
	bdate					datetime				not null,	/*�������� -- ��Ӧ��������*/ -- N
	date0					datetime				not null,	/*�Ͳ�����,ʱ��*/       -- N
	shift					char(1)				not null,                  -- N
	name					varchar(50)			null,       /*��ϵ��,����Ա*/     -- N
	unit					varchar(60)			not null,	/*������λ, name */      -- N
	phone					char(20)				null,
	tables				integer default 1	not null,	/*����*/   -- N
	guest					integer				not null,	/*������*/   -- N
	standent				money default 0	not null,   /*��׼*/   -- N
	stdunit				char(1)				null,       /*��׼��λ*/     -- N
	stdno					char(2)				null,
	deptno				char(2)				not null,	/*���ź�*/
	pccode				char(10)				not null,	/*res_plu.���غ�*/    -- N
	tableno				char(4)				null,			/*����,������,��Ϊ����Ⱥ�еĵ�һ��*/
	paymth				char(1) default '0' not null, /*֧����ʽ*/
	mode					char(3)				null,			/*ģʽ*/
	sta					char(1)				not null,	/*״̬,"1"Ԥ��,"2"ȷ��,"7"�Ǽ�*/
	cusno					char(7)				null,			/*������λ��*/         -- N
	haccnt				char(10)				null,			/*���˺�*/               -- N
	tranlog				char(10)				null,			/*Э���*/
	menu_header			text					null,			/*��ʽ����*/
	menu_detail			text					null,			/*��ʽ����*/
	menu_footer			text					null,			/*��ʽ����*/
	remark				text					null,			/*��ע*/                   -- N
	menu					char(10)				null,			/*�ǼǺ�Ĳ˵���*/
	amount				money default 0	null,			/*���ѽ��*/
	doc					varchar(250)		null,			/*ole �ĵ�*/
	empno					char(10)				not null,	/*����Ա*/                     -- N
	date					datetime	default getdate()	not null,	/*����ʱ��*/          -- N
	email					char(30)	default '' not null,	/**/
	unitto	 			char(40) default '' null,		/*�ͷ���λ*/
	araccnt				char(10)	default '' null,     /*�����˺�*/
	accnt					char(10)	default '' null,     /*ȫ��Ԥ���˺� sc_eventresvation.evtresno*/  -- N
	flag					varchar(50)	default '' null,     /*����̬*/ 
	logmark				int	   default 0      ,
   saleid            char(10)  default '' not null,     /*����Ա*/                -- N
	reserveplu			text						null,				/*Ԥ��ʱ��Ĳ�*/
	meet					char(1)	default 'N'	not null,     /*��Ԥ���Ƿ��л�����Ϣ*/      -- 040524 add
	more					char(1)	default 'N'	not null,     /*��Ԥ���Ƿ�Ҫ�����*/        -- 040524 add
	meetname				varchar(60)	default 'N'	not null,   /*���飬�����*/   		     -- 040531 add
	cby char(10)      default 'N'	not null,
	cg_date datetime	,
	ciy char(10)		default 'N'	not null,
	ci_date datetime,
	sc_resno				char(10)		not null
	)
;
exec sp_primarykey sc_pos_reserve,  sc_resno;
create unique index index1 on sc_pos_reserve(sc_resno);
