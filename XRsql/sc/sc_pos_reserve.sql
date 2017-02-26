create table sc_pos_reserve
(
	resno					char(10)				not null,
	tag					char(1)				not null,	/*就餐类别*/        -- N
	bdate					datetime				not null,	/*输入日期 -- 对应账务日期*/ -- N
	date0					datetime				not null,	/*就餐日期,时间*/       -- N
	shift					char(1)				not null,                  -- N
	name					varchar(50)			null,       /*联系人,销售员*/     -- N
	unit					varchar(60)			not null,	/*主方单位, name */      -- N
	phone					char(20)				null,
	tables				integer default 1	not null,	/*桌数*/   -- N
	guest					integer				not null,	/*客人数*/   -- N
	standent				money default 0	not null,   /*标准*/   -- N
	stdunit				char(1)				null,       /*标准单位*/     -- N
	stdno					char(2)				null,
	deptno				char(2)				not null,	/*部门号*/
	pccode				char(10)				not null,	/*res_plu.场地号*/    -- N
	tableno				char(4)				null,			/*桌号,对团体,其为桌号群中的第一个*/
	paymth				char(1) default '0' not null, /*支付方式*/
	mode					char(3)				null,			/*模式*/
	sta					char(1)				not null,	/*状态,"1"预订,"2"确认,"7"登记*/
	cusno					char(7)				null,			/*主方单位号*/         -- N
	haccnt				char(10)				null,			/*客人号*/               -- N
	tranlog				char(10)				null,			/*协议号*/
	menu_header			text					null,			/*菜式安排*/
	menu_detail			text					null,			/*菜式安排*/
	menu_footer			text					null,			/*菜式安排*/
	remark				text					null,			/*备注*/                   -- N
	menu					char(10)				null,			/*登记后的菜单号*/
	amount				money default 0	null,			/*消费金额*/
	doc					varchar(250)		null,			/*ole 文档*/
	empno					char(10)				not null,	/*操作员*/                     -- N
	date					datetime	default getdate()	not null,	/*输入时间*/          -- N
	email					char(30)	default '' not null,	/**/
	unitto	 			char(40) default '' null,		/*客方单位*/
	araccnt				char(10)	default '' null,     /*记账账号*/
	accnt					char(10)	default '' null,     /*全局预定账号 sc_eventresvation.evtresno*/  -- N
	flag					varchar(50)	default '' null,     /*附加态*/ 
	logmark				int	   default 0      ,
   saleid            char(10)  default '' not null,     /*销售员*/                -- N
	reserveplu			text						null,				/*预定时点的菜*/
	meet					char(1)	default 'N'	not null,     /*本预定是否有会议信息*/      -- 040524 add
	more					char(1)	default 'N'	not null,     /*本预定是否要订多餐*/        -- 040524 add
	meetname				varchar(60)	default 'N'	not null,   /*会议，活动名称*/   		     -- 040531 add
	cby char(10)      default 'N'	not null,
	cg_date datetime	,
	ciy char(10)		default 'N'	not null,
	ci_date datetime,
	sc_resno				char(10)		not null
	)
;
exec sp_primarykey sc_pos_reserve,  sc_resno;
create unique index index1 on sc_pos_reserve(sc_resno);
