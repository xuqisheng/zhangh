--------------------------------------------------------------------------------
--  TABLE:����������message_trace
--------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "message_trace")
	drop table message_trace
;
create table message_trace 
(
	id				   int   							    not null,
	sort				char(3)      default 'AFF'     not null,  -- ������� basecode.cat = 'MsgTraceSort' 
	accnt          char(10)     default ''        not null,  -- ��صı����ʺ�
	sender			char(10)		 default '' 	    not null,  -- ������
	senddate			datetime     default getdate() not null,  -- ����ʱ�� 
	recvaddr       varchar(254) default ''        not null,  -- ������|�����б�
	receiver       varchar(30)  default ''        not null,  -- ������|�����б�
	subject			varchar(128) default ''        not null,  -- �������� 
	content			text			 default ''        not null,  -- �������� 
	inure				datetime     default getdate() not null,  -- ��Чʱ��
	abate 			datetime     default getdate() not null,  -- ʧЧʱ��
	tag				char(1)      default '0'       not null,  -- ����״̬ 0-���봦�� 1-δ���� 2-�Ѵ��� 3-��ɾ�� 4-��ʧЧ
	resolver 		char(10)		 default ''        not null,  -- ������
	resolvedate		datetime		 default getdate() not null,  -- ����ʱ�� 
	remark			varchar(254) default ''        not null,  -- ����ע 
	action         char(3)      default ''        not null,  -- ���񸽼Ӵ���  basecode.cat = 'MsgTraceAction' 
	extdata        varchar(254) default ''        not null,  -- ������Ϣ 
	feetag         char(1)      default 'F'       not null,  -- ����״̬ T-�����Ѿ����� F-û������ 
	feecode        char(5)      default ''        not null,  -- ������ = pccode
	amount			money			 default 0.00      not null,  -- ���ý��  
	chargeup       char(4)      default ''        not null,  -- ������Ա
	chargeupdate   datetime     default getdate() not null,   -- ����ʱ�� 
	cby				char(10)		default '!' 	not null,	/* �����޸�����Ϣ */
	changed			datetime		default getdate()		not null 
)
exec sp_primarykey message_trace,id
create unique index index1 on message_trace(id)
;
-- history
if exists(select * from sysobjects where name = "message_trace_h")
	drop table message_trace_h
;
create table message_trace_h
(
	id				   int   							    not null,
	sort				char(3)      default 'AFF'     not null,  -- ������� basecode.cat = 'MsgTraceSort' 
	accnt          char(10)     default ''        not null,  -- ��صı����ʺ�
	sender			char(10)		 default '' 	    not null,  -- ������
	senddate			datetime     default getdate() not null,  -- ����ʱ�� 
	recvaddr       varchar(254) default ''        not null,  -- ������|�����б�
	receiver       varchar(30)  default ''        not null,  -- ������|�����б�
	subject			varchar(128) default ''        not null,  -- �������� 
	content			text			 default ''        not null,  -- �������� 
	inure				datetime     default getdate() not null,  -- ��Чʱ��
	abate 			datetime     default getdate() not null,  -- ʧЧʱ��
	tag				char(1)      default '0'       not null,  -- ����״̬ 0-���봦�� 1-δ���� 2-�Ѵ��� 3-��ɾ�� 4-��ʧЧ
	resolver 		char(10)		 default ''        not null,  -- ������
	resolvedate		datetime		 default getdate() not null,  -- ����ʱ�� 
	remark			varchar(254) default ''        not null,  -- ����ע 
	action         char(3)      default ''        not null,  -- ���񸽼Ӵ���  basecode.cat = 'MsgTraceAction' 
	extdata        varchar(254) default ''        not null,  -- ������Ϣ 
	feetag         char(1)      default 'F'       not null,  -- ����״̬ T-�����Ѿ����� F-û������ 
	feecode        char(5)      default ''        not null,  -- ������ = pccode
	amount			money			 default 0.00      not null,  -- ���ý��  
	chargeup       char(4)      default ''        not null,  -- ������Ա
	chargeupdate   datetime     default getdate() not null,   -- ����ʱ�� 
	cby				char(10)		default '!' 	not null,	/* �����޸�����Ϣ */
	changed			datetime		default getdate()		not null 
)
exec sp_primarykey message_trace_h,id
create unique index index1 on message_trace_h(id)
;
--------------------------------------------------------------------------------
--  MsgTraceSort
--------------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='MsgTraceSort')
	delete basecode_cat where cat='MsgTraceSort';
insert basecode_cat(cat,descript,descript1,len) select 'MsgTraceSort', '�������', 'MsgTraceSort', 3;

delete basecode where cat='MsgTraceSort';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'MsgTraceSort', 'AFF', '��ͨ����', 'Common Affair','F','F',0,'';

--------------------------------------------------------------------------------
--  MsgTraceAction
--------------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='MsgTraceAction')
	delete basecode_cat where cat='MsgTraceAction';
insert basecode_cat(cat,descript,descript1,len) select 'MsgTraceAction', '���񸽼Ӵ���', 'MsgTraceAction', 3;

delete basecode where cat='MsgTraceAction';

--------------------------------------------------------------------------------
--  Trace Brief Help
--------------------------------------------------------------------------------
if not exists(select 1 from basecode where cat='BriefClass' and code = 'AffairHelp')
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'BriefClass', 'AffairHelp', '����ģ��', 'Affair Help','T','F',0,''
;
