	
------------------------------------------------------------
--
--	�������������ģ��
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

INSERT INTO pos_func_class VALUES (	'system', 'ϵͳ��',	NULL);
INSERT INTO pos_func_class VALUES (	'order',	'�����',	NULL);
INSERT INTO pos_func_class VALUES (	'menu_list',	'���������',	NULL);
INSERT INTO pos_func_class VALUES (	'check',	'������check',	NULL);
INSERT INTO pos_func_class VALUES (	'login',	'��½������',	NULL);
INSERT INTO pos_func_class VALUES (	'map',	'��λͼ��',	NULL);
INSERT INTO pos_func_class VALUES (	'dish_cond',	'���ϴ�����',	NULL);

-- ����
create table pos_func(
	class				char(40) default '' not null,					-- ���			
	func				char(40) default '' not null,					-- ����
	func_des			char(40) default '' not null,					-- ����
	parm				text,													-- ����
	nextwin			char(1)  default 'N' not null,				-- �Ƿ�Ҫ�򿪴���
	remark			varchar(60)  null
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
	sequence			char(10)		null
)
;
exec sp_primarykey pos_func_more,func
create unique index index1 on pos_func_more(func)
;
insert into pos_func_more select 'order', 'f_menu_guests', '����','','','','100';
insert into pos_func_more select 'order', 'f_menu_tableno', '̨��','','','','100';
insert into pos_func_more select 'order', 'f_menu_srv_rate', '�������','','','','100';
insert into pos_func_more select 'order', 'f_menu_dsc_rate', '�ۿ۷���','','','','100';
insert into pos_func_more select 'order', 'f_menu_mode', 'ģʽ','','','','100';
insert into pos_func_more select 'order', 'f_menu_tea', '��λ��','','','','100';
insert into pos_func_more select 'order', 'f_dish_co', '���','','','','100';
insert into pos_func_more select 'order', 'f_dish_number', '������','','','','100';
insert into pos_func_more select 'order', 'f_dish_price', '�ĵ���','','','','100';
insert into pos_func_more select 'order', 'f_dish_reward', '����','','','','100';
insert into pos_func_more select 'order', 'f_dish_dsc', '�����ۿ�','','','','100';
insert into pos_func_more select 'order', 'f_dish_ent', '���˿��','','','','100';
insert into pos_func_more select 'order', 'f_dish_nofee', '������','','','','100';
insert into pos_func_more select 'order', 'f_dish_nosrv', '������','','','','100';
insert into pos_func_more select 'order', 'f_dish_rename', '�Ĳ���','','','','100';
insert into pos_func_more select 'order', 'f_kitchen_callup', '����','','','','100';
insert into pos_func_more select 'order', 'f_kitchen_updish', '���','','','','100';
insert into pos_func_more select 'order', 'f_kitchen_quick', '�߲�','','','','100';
insert into pos_func_more select 'order', 'f_kitchen_slow', '����','','','','100';



-- ����ģ��
create table pos_win_class(
	win_class		char(40) default '' not null,					-- ģ��
	class_name		char(40) default '' not null,					-- ��������
	dw_name			char(40) default '' not null,					-- ģ����
	dw_number		int		default 0  not null,					-- �������������ݴ��ڵ�����
	win_default		char(40)	default '' not null,					-- ȱʡ����
	remark			varchar(60)											--	����
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
	dw_syntax		text		,											-- �������ݴ����﷨
	sys				char(1)	default	'N' not null,				-- �Ƿ���ϵͳ����
	wintype			char(1)	default	'0' not null,				-- ������� 0-�вͣ�1-����, 2-����
	langid			char(1)	default	'0' not null				-- ���֡�
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


