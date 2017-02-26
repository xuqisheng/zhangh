--------------------------------------------------------------------------------
--  ְԱ����
--------------------------------------------------------------------------------

-- TABLE:ְԱ������Ϣ����message_mail
if exists(select * from sysobjects where name = "message_mail")
	drop table message_mail
;
create table message_mail 
(
	id				   int   							    not null,
	sort				char(1)      default '0'       not null,  -- ������� 0-���� 1-���� 2-ȫ��
	sender			char(10)		 default ''	    	 not null,  -- ������
	senddate			datetime     default getdate() not null,  -- ����ʱ�� 
	receiver       varchar(254) default ''        not null,  -- ������|�����б�
	subject			varchar(128) default ''        not null,  -- �������� 
	content			text			 default ''        not null,  -- ��������
	status			char(1)      default '1'       not null   -- ����״̬ 0-�ݸ� 1-�ѷ��� 3-��ɾ��
)
exec sp_primarykey message_mail,id
create unique index index1 on message_mail(id)
;

-- TABLE:ְԱ������Ϣ����message_mailrecv
if exists(select * from sysobjects where name = "message_mailrecv")
	drop table message_mailrecv
;
create table message_mailrecv
(
	id				   int   							    not null,  -- ��Ӧmessage_mail.id
	receiver  		char(10)		 default ''        not null,  -- ������ 
	recvdate		   datetime		 default getdate() not null,  -- ����ʱ�� 
	tag				char(1)      default '1'       not null,  -- ����״̬ 0-δ���� 1-�Ķ� 2-�ظ� 3-��ɾ�� 4-������Ч
	reid			   int   		 default 0		    not null   -- �ظ�����ԭʼ��ӦID
)
create index index1 on message_mailrecv(id,receiver)
;

-- TABLE:ְԱ��������message_chat
if exists(select * from sysobjects where name = "message_chat")
	drop table message_chat
;
create table message_chat
(
	id				   int   							    not null,
	sort    			char(1)      default '1'       not null,  -- ״̬ 1-���� 2-�㲥 
	sender			char(10)		 default ''		    not null,  -- ������
	senddate			datetime     default getdate() not null,  -- ����ʱ�� 
	content			text			 default ''        not null,  -- ��������
	receiver  		char(10)		 default ''        not null,  -- ������ 
	tag    			char(1)      default '1'       not null   -- ״̬ 0-δ���� 1-�Ķ� 2-��ɾ��
)
exec sp_primarykey message_chat,id
create unique index index1 on message_chat(id)
;

