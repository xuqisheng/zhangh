	
------------------------------------------------------------
--
--	�������������ṹ����
--
------------------------------------------------------------

-- ���ܷ���
create table pos_func_class(
	func_class		char(40) default '' not null,            	-- ���
	class_des		char(40) default '' not null,					-- ����
	remark			varchar(60)  null
)
;
exec sp_primarykey pos_func_class,func_class
create unique index index1 on pos_func_class(func_class)
;
INSERT INTO pos_func_class VALUES (	'system',	'ϵͳ��',	NULL);
INSERT INTO pos_func_class VALUES (	'order',	'��˲�����',	NULL);
INSERT INTO pos_func_class VALUES (	'login',	'��½������',	NULL);
INSERT INTO pos_func_class VALUES (	'check',	'������',	NULL);
INSERT INTO pos_func_class VALUES (	'menu_list',	'����������',	NULL);
INSERT INTO pos_func_class VALUES (	'map',	'��λͼ��',	NULL);
INSERT INTO pos_func_class VALUES (	'dish_cond',	'���ϴ�����',	NULL);
INSERT INTO pos_func_class VALUES (	'info',	'��ѯ��',	NULL);

-- ����
create table pos_func(
	class				char(40) default '' not null,					-- ���			
	func				char(40) default '' not null,					-- ����
	func_des			char(40) default '' not null,					-- ����
	parm				text,													-- ����
	nextwin			char(1)  default 'N' not null,				-- �Ƿ�Ҫ�򿪴���
	remark			varchar(60)  null,
   sequence 		char(10)    DEFAULT '1000' NOT NULL,
   halt     		varchar(1)  NULL
)
;
exec sp_primarykey pos_func,func
create unique index index1 on pos_func(func)
;

-- ���ӹ��ܣ���Ҫ�йص��
create table pos_func_more(
	class				char(40) default '' not null,					-- ���
	func				char(40) default '' not null,					-- ����
	descript			char(20) default '' not null,					-- ����
	descript1		char(20) default '' not null,					-- ����
	parm				char(100),											-- ����
	remark			varchar(60)  null,
	sequence			char(10)		null,
   halt      char(1)     NULL
)
;
exec sp_primarykey pos_func_more,func
create unique index index1 on pos_func_more(func)
;


-- ����ģ��
create table pos_win_class(
	win_class		char(40) default '' not null,					-- ģ��
	class_name		char(40) default '' not null,					-- ��������
	dw_name			char(40) default '' not null,					-- ģ����
	dw_number		int		default 0  not null,					-- �������������ݴ��ڵ�����
	win_default		char(40)	default '' not null,					-- ȱʡ����
	remark			varchar(60),										--	����
	usedw				char(1)	default 'F' not null,            -- �Ƿ�ֱ��ʹ��pbl�е�dw 
	wintype			char(1)  default '0' not null             
)
;
exec sp_primarykey pos_win_class,win_class
create unique index index1 on pos_win_class(win_class)
;

--	����
create table pos_win(
	win_class		char(40) default '' not null,					-- ģ��
	win_name			char(40) default '' not null,					-- ����
	win_des			char(40) default '' not null,					-- ����
	arrangement		char(1) 	default 'C' not null,				-- λ�ð���:U-Up��B-botton��R-right��L-left��C-center
	dtl_row			int		default	0	not null,				-- ������ϸ��ѯÿ�и���
	dtl_column		int		default	0	not null,				-- ������ϸ��ѯÿ�и���
	dwlist			char(40)	default	''	not null,				-- ���ݴ����б�����
	dw_syntax		text		,											-- �������ݴ����﷨
	sys				char(1)	default	'N' not null,				-- �Ƿ���ϵͳ����
	usedw				char(1)	default	'F' not null,				-- �Ƿ�ֱ�ӵ���pbd��datawindow
	wintype			char(1)  default  '0' not null,             -- ��������, 0 - �в�, 1 - ����
	langid			char(1)	default	'0' not null,				-- ���֡�
   dtl_row1    int      NULL,
   dtl_column1 int      NULL
)
;
exec sp_primarykey pos_win,win_name
create unique index index1 on pos_win(win_name)
;

--	����ģ�����õĹ�����
create table pos_win_func(
	win_class		char(40) default '' not null,					-- ģ��
	func_class		char(40) default '' not null					-- ������
)
;
exec sp_primarykey pos_win_func,win_class,func_class
create unique index index1 on pos_win_func(win_class,func_class)
;


/*
	��������½, �ſ���Ϣͬ����(sys_empno)���ձ�
*/
if exists(select * from sysobjects where name = "pos_login_card" and type ="U")
	 drop table pos_login_card;

create table pos_login_card
(
	card				char(20)		not null,								/*����Ϣ*/
	empno				char(10)		not null									/*���ش���*/
)
;
exec sp_primarykey pos_login_card, card
create unique index index1 on pos_login_card(card)
;

