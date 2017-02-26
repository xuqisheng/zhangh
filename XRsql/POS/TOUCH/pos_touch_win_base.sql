	
------------------------------------------------------------
--
--	触摸屏界面设计模板
--
------------------------------------------------------------

-- 功能分类
create table pos_func_class(
	func_class		char(40) default '' not null,            	-- 类别
	class_des		char(40) default '' not null,					-- 描述
	remark			varchar(60)  null
)
;
exec sp_primarykey pos_func_class,func_class
create unique index index1 on pos_func_class(func_class)
;

INSERT INTO pos_func_class VALUES (	'system', '系统类',	NULL);
INSERT INTO pos_func_class VALUES (	'order',	'点菜类',	NULL);
INSERT INTO pos_func_class VALUES (	'menu_list',	'开单入口类',	NULL);
INSERT INTO pos_func_class VALUES (	'check',	'结帐类check',	NULL);
INSERT INTO pos_func_class VALUES (	'login',	'登陆窗口类',	NULL);
INSERT INTO pos_func_class VALUES (	'map',	'餐位图类',	NULL);
INSERT INTO pos_func_class VALUES (	'dish_cond',	'配料窗口类',	NULL);

-- 功能
create table pos_func(
	class				char(40) default '' not null,					-- 类别			
	func				char(40) default '' not null,					-- 函数
	func_des			char(40) default '' not null,					-- 描述
	parm				text,													-- 参数
	nextwin			char(1)  default 'N' not null,				-- 是否要打开窗口
	remark			varchar(60)  null
)
;
exec sp_primarykey pos_func,func
create unique index index1 on pos_func(func)
;

-- 附加功能：主要有关点菜
create table pos_func_more(
	class				char(40) default '' not null,					-- 类别
	func				char(40) default '' not null,					-- 函数
	descript			char(20) default '' not null,					-- 描述
	descript1		char(20) default '' not null,					-- 描述
	parm				char(100),											-- 参数
	remark			varchar(60)  null,
	sequence			char(10)		null
)
;
exec sp_primarykey pos_func_more,func
create unique index index1 on pos_func_more(func)
;
insert into pos_func_more select 'order', 'f_menu_guests', '人数','','','','100';
insert into pos_func_more select 'order', 'f_menu_tableno', '台号','','','','100';
insert into pos_func_more select 'order', 'f_menu_srv_rate', '服务费率','','','','100';
insert into pos_func_more select 'order', 'f_menu_dsc_rate', '折扣费率','','','','100';
insert into pos_func_more select 'order', 'f_menu_mode', '模式','','','','100';
insert into pos_func_more select 'order', 'f_menu_tea', '茶位费','','','','100';
insert into pos_func_more select 'order', 'f_dish_co', '冲菜','','','','100';
insert into pos_func_more select 'order', 'f_dish_number', '改数量','','','','100';
insert into pos_func_more select 'order', 'f_dish_price', '改单价','','','','100';
insert into pos_func_more select 'order', 'f_dish_reward', '赠送','','','','100';
insert into pos_func_more select 'order', 'f_dish_dsc', '单菜折扣','','','','100';
insert into pos_func_more select 'order', 'f_dish_ent', '单菜款待','','','','100';
insert into pos_func_more select 'order', 'f_dish_nofee', '单菜免','','','','100';
insert into pos_func_more select 'order', 'f_dish_nosrv', '免服务费','','','','100';
insert into pos_func_more select 'order', 'f_dish_rename', '改菜名','','','','100';
insert into pos_func_more select 'order', 'f_kitchen_callup', '叫起','','','','100';
insert into pos_func_more select 'order', 'f_kitchen_updish', '起菜','','','','100';
insert into pos_func_more select 'order', 'f_kitchen_quick', '催菜','','','','100';
insert into pos_func_more select 'order', 'f_kitchen_slow', '缓菜','','','','100';



-- 界面模板
create table pos_win_class(
	win_class		char(40) default '' not null,					-- 模板
	class_name		char(40) default '' not null,					-- 命名解释
	dw_name			char(40) default '' not null,					-- 模版ｄｗ
	dw_number		int		default 0  not null,					-- 窗口中其他数据窗口的数量
	win_default		char(40)	default '' not null,					-- 缺省窗口
	remark			varchar(60)											--	描述
)
;
exec sp_primarykey pos_win_class,win_class
create unique index index1 on pos_win_class(win_class)
;

--	界面
create table pos_win(
	win_class		char(40) default '' not null,					-- 模板
	win_name			char(40) default '' not null,					-- 窗口
	win_des			char(40) default '' not null,					-- 描述
	arrangement		char(1) 	default 'C' not null,				-- 位置安排:U-Up；B-botton；R-right；L-left；C-center
	dtl_row			int		default	0	not null,				-- 如有明细查询每行个数
	dtl_column		int		default	0	not null,				-- 如有明细查询每列个数
	dw_syntax		text		,											-- 界面数据窗口语法
	sys				char(1)	default	'N' not null,				-- 是否是系统窗口
	wintype			char(1)	default	'0' not null,				-- 窗口类别 0-中餐，1-西餐, 2-外卖
	langid			char(1)	default	'0' not null				-- 语种　
)
;
exec sp_primarykey pos_win,win_name
create unique index index1 on pos_win(win_name)
;

--	界面模板能用的功能类
create table pos_win_func(
	win_class		char(40) default '' not null,					-- 模板
	func_class		char(40) default '' not null					-- 功能类
)
;
exec sp_primarykey pos_win_func,win_class,func_class
create unique index index1 on pos_win_func(win_class,func_class)
;


